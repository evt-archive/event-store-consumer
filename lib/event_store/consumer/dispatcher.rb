module EventStore
  module Consumer
    module Dispatcher
      def call(event_data)
        message = build_message event_data

        return if message.nil?

        dispatch message, event_data
      end
    end
  end
end
