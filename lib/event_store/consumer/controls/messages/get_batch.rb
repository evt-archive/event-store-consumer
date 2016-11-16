module EventStore
  module Consumer
    module Controls
      module Messages
        module GetBatch
          def self.example(stream_name=nil, batch_index: nil)
            batch_index ||= 0

            if batch_index == 0
              slice_uri = StreamReader::StartPath.example stream_name
            else
              starting_position = batch_index * Batch::Size.example

              slice_uri = StreamReader::SliceURI.example(
                stream_name,
                starting_position: starting_position
              )
            end

            message = EventStore::Consumer::Messages::GetBatch.new
            message.slice_uri = slice_uri
            message
          end
        end
      end
    end
  end
end