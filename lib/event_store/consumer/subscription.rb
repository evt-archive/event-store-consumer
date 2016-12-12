module EventStore
  module Consumer
    class Subscription
      include Actor
      include Log::Dependency

      attr_writer :batch_size
      attr_writer :dispatcher_address
      attr_accessor :stream_reader
      attr_accessor :session

      dependency :kernel, Kernel
      dependency :position_store, PositionStore

      initializer :stream_name

      def self.build(stream_name, dispatcher_address, batch_size: nil, position_store: nil, session: nil)
        instance = new stream_name

        instance.batch_size = batch_size if batch_size
        instance.dispatcher_address = dispatcher_address
        instance.session = session
        instance.position_store = position_store if position_store

        Kernel.configure instance
        EventStore::Client::HTTP::Session.configure instance, session: session

        instance
      end

      handle Actor::Messages::Start do
        start_path = stream_reader.start_path

        logger.trace "Configuring initial batch (#{log_attributes}, StartPath: #{start_path})"

        get_batch = Messages::GetBatch.build :slice_uri => start_path

        logger.debug "Initial batch configured (#{log_attributes}, StartPath: #{start_path})"

        get_batch
      end

      handle Messages::GetBatch do |get_batch|
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

        next_slice_uri = slice.next_uri :forward

        logger.debug "Get batch done (#{log_attributes}, EntryCount: #{entries.count}, NextSliceUri: #{next_slice_uri})"

        Messages::EnqueueBatch.build(
          :next_slice_uri => next_slice_uri,
          :entries => slice.entries.reverse
        )
      end

      handle Messages::EnqueueBatch do |enqueue_batch|
        entries = enqueue_batch.entries

        entries.each do |event_data|
          dispatch_event = Messages::DispatchEvent.build :event_data => event_data

          send.(dispatch_event, dispatcher_address)
        end

        get_batch = Messages::GetBatch.new
        get_batch.slice_uri = enqueue_batch.next_slice_uri
        get_batch
      end

      def starting_position
        starting_position = position_store.get

        if starting_position == :no_stream
          nil
        else
          starting_position
        end
      end

      def delay
        duration = Defaults.no_stream_delay_duration_seconds

        kernel.sleep duration
      end

      def stream_reader
        @stream_reader ||= EventStore::Client::HTTP::StreamReader::Continuous.build(
          stream_name,
          session: session,
          slice_size: batch_size,
          starting_position: starting_position
        ).tap do |stream_reader|
          stream_reader.request.enable_long_poll
        end
      end

      def batch_size
        @batch_size ||= Defaults.batch_size
      end

      def dispatcher_address
        @dispatcher_address ||= Actor::Messaging::Address::None
      end

      def log_attributes
        "StreamName: #{stream_name}, BatchSize: #{batch_size}"
      end
    end
  end
end
