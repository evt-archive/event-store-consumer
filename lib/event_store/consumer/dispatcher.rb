module EventStore
  module Consumer
    class Dispatcher
      include Actor
      include Log::Dependency

      dependency :messaging_dispatcher, EventStore::Messaging::Dispatcher
      dependency :put_position, Position::Put

      attr_writer :error_handler
      attr_writer :queue

      initializer :stream_type

      def self.build(stream_name, dispatcher_class, error_handler: nil, queue: nil)
        stream_type = get_stream_type stream_name

        instance = new stream_type
        dispatcher_class.configure instance, attr_name: :messaging_dispatcher
        instance.error_handler = error_handler if error_handler
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
          return dequeue_batch
        end
        batch = queue.deq true

        batch.each do |event_data|
          dispatch event_data
        end

        position = get_position batch.last
        put_position.(position)

        logger.info "Batch processed (#{log_attributes}, BatchSize: #{batch.size}, Position: #{position})"

        dequeue_batch
      end

      def dispatch(event_data)
        message = messaging_dispatcher.build_message event_data

        return if message.nil?

        begin
          messaging_dispatcher.dispatch message, event_data
        rescue => error
          error_handler.(error)
        end
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

      def queue
        @queue ||= Queue.new
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
