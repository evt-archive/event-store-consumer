module EventStore
  module Consumer
    class Dispatcher
      include Actor
      include Log::Dependency

      dependency :dispatcher, EventStore::Messaging::Dispatcher

      attr_writer :queue

      def self.build(dipatcher_class, queue: nil)
        dispatcher = dispatcher_class.build

        instance = new
        instance.dispatcher = dispatcher
        instance.queue = queue if queue
        instance
      end

      handle Actor::Messages::Start do
        DequeueBatch.new
      end

      handle DequeueBatch do |dequeue_batch|
        logger.trace "Dequeuing batch (#{log_attributes})"

        batch_count = 0

        until queue.empty?
          event_data = queue.deq true

          batch_count += 1

          message = dispatcher.build_message event_data
          dispatcher.dispatch message, event_data if message
        end

        logger.trace "Dequeuing batch (#{log_attributes}, BatchCount: #{batch_count})"

        dequeue_batch
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
