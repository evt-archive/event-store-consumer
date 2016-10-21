module EventStore
  module Consumer
    class Dispatcher
      include Actor
      include Log::Dependency

      dependency :dispatcher, EventStore::Messaging::Dispatcher
      dependency :put_position, Position::Put

      attr_writer :queue

      initializer :stream_type

      def self.build(stream_name, dispatcher_class, queue: nil)
        stream_type = get_stream_type stream_name

        instance = new stream_type
        dispatcher_class.configure instance
        Position::Put.configure instance, stream_name
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
          sleep 0.1
          return dequeue_batch
        end

        batch = queue.deq true

        batch.each do |event_data|
          message = dispatcher.build_message event_data
          dispatcher.dispatch message, event_data if message
        end

        position = get_position batch.last
        put_position.(position)

        logger.info "Batch processed (#{log_attributes}, BatchSize: #{batch.size}, Position: #{position})"

        dequeue_batch
      end

      def get_position(event_data)
        if stream_type == :category
          event_data.position
        else
          event_data.number
        end
      end

      def queue
        @queue ||= Queue.new
      end

      def log_attributes
        "Dispatcher: #{dispatcher.class.name}"
      end

      module Assertions
        def dispatched?(event_data)
          dispatcher.dispatched?(event_data)
        end
      end
    end
  end
end
