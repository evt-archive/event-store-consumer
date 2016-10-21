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

          EventStore::Client::HTTP::Controls::EventData::Read.example(
            stream_position,
            data: data,
            position: global_position,
            stream_name: stream_name
          )
        end

        module Data
          def self.example(stream_position: nil)
            stream_position ||= Position.example

            { some_attribute: "some value @#{stream_position}" }
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

            write_event_data = EventStore::Client::HTTP::EventData::Write.build
            write_event_data.assign_id

            SetAttributes.(write_event_data, read_event_data)

            write_event_data
          end
        end
      end
    end
  end
end
