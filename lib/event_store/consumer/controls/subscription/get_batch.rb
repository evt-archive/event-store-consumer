module EventStore
  module Consumer
    module Controls
      module Subscription
        module GetBatch
          def self.example(stream_name=nil, starting_position: nil)
            message = Consumer::Subscription::GetBatch.new

            message.slice_uri = StreamReader::StartPath.example(
              stream_name,
              starting_position: starting_position
            )

            message
          end
        end
      end
    end
  end
end
