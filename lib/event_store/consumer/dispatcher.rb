module EventStore
  module Consumer
    class Dispatcher
      include Actor
      include Log::Dependency

      dependency :dispatcher, EventStore::Messaging::Dispatcher
      dependency :put_position, Position::Put

      attr_writer :queue

      initializer :stream_type

      def self.build(stream_name, dipatcher_class, queue: nil)
        stream_type = get_stream_type stream_name

        instance = new stream_type
        dispatcher_class.configure instance
        PutPosition.configure instance, stream_name
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
        DequeueBatch.new
      end

      handle DequeueBatch do |dequeue_batch|
        logger.trace "Dequeuing batch (#{log_attributes})"

        batch_count = 0

        event_data = nil

        until queue.empty?
          event_data = queue.deq true

          batch_count += 1

          message = dispatcher.build_message event_data
          dispatcher.dispatch message, event_data if message
        end

        if event_data
          position = get_position event_data
          put_position.(position)
        end

        logger.trace "Dequeuing batch (#{log_attributes}, BatchCount: #{batch_count})"

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
