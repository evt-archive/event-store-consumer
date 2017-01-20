module EventStore
  module Consumer
    module Controls
      module Write
        def self.call
          stream_name = StreamName.example random: true

          ending_position = Batch::FinalPosition.example

          write = ::EventSource::EventStore::HTTP::Write.build

          batch = (0..ending_position).map do |position|
            EventData::Write.example position: position
          end

          write.(batch, stream_name)

          stream_name
        end
      end
    end
  end
end
