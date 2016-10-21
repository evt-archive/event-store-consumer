module EventStore
  module Consumer
    module Controls
      module Subscription
        module Batch
          def self.example
            (0...entry_count).map do |position|
              EventData.example stream_position: position
            end
          end

          def self.enqueue(queue)
            batch = example

            batch.each do |event_data|
              queue.enq event_data
            end

            batch
          end

          def self.entry_count
            3
          end
        end
      end
    end
  end
end
