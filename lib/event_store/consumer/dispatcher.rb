module EventStore
  module Consumer
    class Dispatcher
      include Actor
      include Log::Dependency

      attr_writer :error_handler
      attr_writer :kernel
      attr_writer :position_update_interval
      attr_writer :queue

      dependency :messaging_dispatcher, EventStore::Messaging::Dispatcher
      dependency :position_store, PositionStore

      initializer :stream_type

      def self.build(stream_name, messaging_dispatcher, error_handler: nil, queue: nil, position_store: nil, position_update_interval: nil)
        stream_type = get_stream_type stream_name

        instance = new stream_type

        instance.kernel = Kernel
        instance.messaging_dispatcher = messaging_dispatcher
        instance.error_handler = error_handler if error_handler
        instance.position_store = position_store if position_store
        instance.position_update_interval = position_update_interval
        instance.queue = queue if queue

        instance
      end

      def self.get_stream_type(stream_name)
        if StreamName.category? stream_name
          :category
        else
          :stream
        end
      end

      handle Actor::Messages::Start do
        ProcessBatch.new
      end

      handle ProcessBatch do |dequeue_batch|
        logger.trace "Dequeuing batch (#{log_attributes})"

        if queue.empty?
          logger.debug "Queue is empty; retrying (#{log_attributes})"
          kernel.sleep Defaults.empty_queue_delay_seconds
          return dequeue_batch
        end
        batch = queue.deq true

        batch.each do |event_data|
          dispatch event_data
        end

        update_position batch

        logger.info "Batch processed (#{log_attributes}, BatchSize: #{batch.size})"

        dequeue_batch
      end

      def dispatch(event_data)
        message = messaging_dispatcher.build_message event_data

        return if message.nil?

        begin
          messaging_dispatcher.dispatch message, event_data
        rescue => error
          _retry = false
          retry_proc = proc { _retry = true }

          error_handler.(error, retry_proc)

          retry if _retry
        end
      end

      def update_position(batch)
        next_starting_position = get_position(batch.last) + 1

        if update_position? next_starting_position
          logger.trace "Updating starting position (#{log_attributes}, NextStartingPosition: #{next_starting_position}, PositionUpdateInterval: #{position_update_interval})"

          position_store.put next_starting_position

          logger.debug "Updating starting position (#{log_attributes}, NextStartingPosition: #{next_starting_position}, PositionUpdateInterval: #{position_update_interval})"
        end
      end

      def update_position?(next_starting_position)
        next_starting_position % position_update_interval == 0
      end

      def get_position(event_data)
        if stream_type == :category
          event_data.position
        else
          event_data.number
        end
      end

      def error_handler
        @error_handler ||= proc { |error| raise error }
      end

      def kernel
        @kernel ||= Actor::Substitutes::Kernel.new
      end

      def queue
        @queue ||= Queue.new
      end

      def position_update_interval
        @position_update_interval ||= Defaults.position_update_interval
      end

      def log_attributes
        "Dispatcher: #{messaging_dispatcher.class.name}"
      end

      module Assertions
        def dispatched?(event_data)
          messaging_dispatcher.dispatched?(event_data)
        end
      end
    end
  end
end
