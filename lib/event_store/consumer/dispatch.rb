module EventStore
  module Consumer
    class Dispatch
      include Log::Dependency

      configure :dispatch

      dependency :messaging_dispatcher, ::EventStore::Messaging::Dispatcher

      def self.build(messaging_dispatcher)
        instance = new
        instance.messaging_dispatcher = messaging_dispatcher
        instance
      end

      def call(event_data)
        message = messaging_dispatcher.build_message event_data

        return if message.nil?

        begin
          messaging_dispatcher.dispatch message, event_data
        rescue => error
          _retry = false
          retry_proc = proc { _retry = true }

          if error_handler.arity == 1
            error_handler.(error)
          else
            error_handler.(error, retry_proc)
          end

          retry if _retry
        end
      end

      module Assertions
        def dispatched?(event_data)
          messaging_dispatcher.dispatched?(event_data)
        end
      end
    end
  end
end
