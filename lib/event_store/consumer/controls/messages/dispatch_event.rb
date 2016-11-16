module EventStore
  module Consumer
    module Controls
      module Messages
        module DispatchEvent
          def self.example(event_data=nil, stream_position: nil)
            event_data ||= EventData.example stream_position: stream_position

            message = Consumer::Messages::DispatchEvent.new
            message.event_data = event_data
            message
          end
        end
      end
    end
  end
end
