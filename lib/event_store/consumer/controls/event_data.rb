module EventStore
  module Consumer
    module Controls
      module EventData
        def self.example(stream_name=nil, stream_position: nil, global_position: nil)
          stream_name ||= StreamName.example
          stream_position ||= Position.example
          global_position ||= stream_position

          type = Type.example
          data = Data.example stream_position: stream_position
          metadata = Metadata.example stream_position: stream_position

          event_data = EventSource::Controls::EventData::Read.example data: data, metadata: metadata, type: type
          event_data.position = stream_position
          event_data.global_position = global_position
          event_data.stream_name = stream_name
          event_data
        end

        module Data
          def self.example(stream_position: nil)
            stream_position ||= Position.example

            { some_attribute: "some value @#{stream_position}" }
          end
        end

        module Metadata
          def self.example(stream_position: nil)
            stream_position ||= Position.example

            { some_meta_attribute: "some metadata value @#{stream_position}" }
          end
        end

        module Type
          def self.example
            "ExampleMessage"
          end
        end

        module Write
          def self.example(position: nil)
            read_event_data = EventData.example stream_position: position

            write_event_data = EventSource::EventData::Write.build

            SetAttributes.(write_event_data, read_event_data)

            write_event_data
          end
        end
      end
    end
  end
end
