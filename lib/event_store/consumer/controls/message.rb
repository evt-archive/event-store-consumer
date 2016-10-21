module EventStore
  module Consumer
    module Controls
      module Message
        def self.example(stream_position: nil, global_position: nil)
          stream_position ||= Position.example
          global_position ||= stream_position

          message = ExampleMessage.new
          message.stream_position = stream_position
          message.global_position = global_position
          message
        end

        class ExampleMessage
          include EventStore::Messaging::Message

          attribute :stream_position, Integer
          attribute :global_position, Integer
        end
      end
    end
  end
end
