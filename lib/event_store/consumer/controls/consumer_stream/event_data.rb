module EventStore
  module Consumer
    module Controls
      module ConsumerStream
        module EventData
          module Type
            def self.example
              'ConsumerUpdate'
            end
          end

          module Write
            def self.example(position: nil)
              position ||= Position.example

              event_data = EventStore::Client::HTTP::EventData::Write.build
              event_data.type = Type.example
              event_data.data = { position: position }

              event_data.assign_id

              event_data
            end
          end
        end
      end
    end
  end
end
