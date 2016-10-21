module EventStore
  module Consumer
    class Subscription
      include Actor
      include Log::Dependency

      attr_writer :queue
      attr_accessor :stream_reader
      attr_accessor :session

      dependency :get_position, Position::Get

      initializer :stream_name

      def self.build(stream_name, queue: nil, session: nil)
        instance = new stream_name

        instance.kernel = Kernel
        instance.queue = queue
        instance.session = session

        Position::Get.configure instance, stream_name
        EventStore::Client::HTTP::Session.configure instance, session: session

        instance
      end

      handle Actor::Messages::Start do
        start_path = stream_reader.start_path

        logger.trace "Configuring initial batch (#{log_attributes}, StartPath: #{start_path})"

        get_batch = GetBatch.build :slice_uri => start_path

        logger.debug "Initial batch configured (#{log_attributes}, StartPath: #{start_path})"

        get_batch
      end

      handle GetBatch do |get_batch|
        log_attributes = "#{self.log_attributes}, SliceURI: #{get_batch.slice_uri.inspect})"

        logger.trace "Getting batch (#{log_attributes})"

        slice = stream_reader.next_slice get_batch.slice_uri

        if slice.nil?
          logger.debug "Get batch returned nothing; retrying (#{log_attributes})"
          delay
          return get_batch
        end

        entries = slice.entries

        if entries.empty?
          logger.debug "Get batch returned empty set; retrying (#{log_attributes})"
          return get_batch
        end

        logger.debug "Get batch done (#{log_attributes}, EntryCount: #{entries.count})"

        EnqueueBatch.build(
          :next_slice_uri => slice.next_uri(:forward),
          :entries => slice.entries.reverse
        )
      end

      handle EnqueueBatch do |enqueue_batch|
        enqueue_batch.entries.each do |event_data|
          queue.enq event_data
        end

        get_batch = GetBatch.new
        get_batch.slice_uri = enqueue_batch.next_slice_uri
        get_batch
      end

      def stream_reader
        @stream_reader ||= EventStore::Client::HTTP::StreamReader::Continuous.build(
          stream_name,
          session: session,
          slice_size: batch_size,
          starting_position: starting_position
        )
      end

      def batch_size
        @batch_size ||= Defaults.batch_size
      end

      def delay
        kernel.sleep delay_seconds
      end

      def delay_seconds
        @delay_seconds ||= stream_reader.request.class::Defaults.long_poll_duration.to_f
      end

      def kernel
        @kernel ||= Actor::Substitutes::Kernel.new
      end

      def queue
        @queue ||= Queue.new
      end

      def starting_position
        starting_position = get_position.()

        if starting_position == :no_stream
          nil
        else
          starting_position
        end
      end

      def log_attributes
        "StreamName: #{stream_name}, BatchSize: #{batch_size}"
      end

      module Defaults
        def self.batch_size
          batch_size = ENV['CONSUMER_BATCH_SIZE']

          return batch_size.to_if if batch_size

          100
        end
      end
    end
  end
end
