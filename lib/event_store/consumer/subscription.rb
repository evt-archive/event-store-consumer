module EventStore
  module Consumer
    class Subscription
      include Actor
      include Log::Dependency

      attr_writer :stream_reader

      dependency :get_position, Position::Get
      dependency :session, EventStore::Client::HTTP::Session

      initializer :stream_name, a(:session, nil)

      def configure
        Position::Get.configure self, stream_name
        self.kernel = Kernel
        EventStore::Client::HTTP::Session.configure self
      end

      handle Actor::Messages::Start do
        slice_uri = stream_reader.start_path

        GetBatch.build :slice_uri => slice_uri
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
