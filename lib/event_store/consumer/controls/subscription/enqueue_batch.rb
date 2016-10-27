module EventStore
  module Consumer
    module Controls
      module Subscription
        module EnqueueBatch
          def self.example(stream_name=nil, entry_count: nil, starting_position: nil, starting_global_position: nil)
            entry_count ||= Batch::Size.example
            starting_position ||= Position::Initial.example
            starting_global_position ||= starting_position

            entries = (0...entry_count).map do |position|
              stream_position = starting_position + position
              global_position = starting_global_position + position

              EventData.example(
                stream_name,
                stream_position: stream_position,
                global_position: global_position
              )
            end

            next_slice_uri = StreamReader::SliceURI.example(
              stream_name,
              starting_position: starting_position + entry_count
            )

            message = EventStore::Consumer::Subscription::EnqueueBatch.new
            message.entries = entries
            message.next_slice_uri = next_slice_uri
            message
          end
        end
      end
    end
  end
end
