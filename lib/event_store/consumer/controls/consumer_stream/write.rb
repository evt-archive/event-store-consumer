module EventStore
  module Consumer
    module Controls
      module ConsumerStream
        module Write
          def self.call(stream_name=nil, position: nil)
            stream_name ||= StreamName.example random: true

            consumer_stream_name = Consumer::StreamName.consumer_stream_name stream_name

            writer = EventStore::Client::HTTP::EventWriter.build
            event_data = EventData::Write.example position: position

            writer.write event_data, consumer_stream_name

            stream_name
          end
        end
      end
    end
  end
end
