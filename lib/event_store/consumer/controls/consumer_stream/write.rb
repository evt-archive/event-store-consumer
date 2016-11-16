module EventStore
  module Consumer
    module Controls
      module ConsumerStream
        module Write
          def self.call(stream_name=nil, position: nil)
            stream_name ||= StreamName.example random: true

            consumer_stream_name = EventStore::Consumer::StreamName.consumer_stream_name stream_name

            message = Messages::ConsumerUpdated.example position: position

            writer = EventStore::Messaging::Writer.build
            writer.write message, consumer_stream_name

            stream_name
          end
        end
      end
    end
  end
end
