module EventStore
  module Consumer
    module Controls
      module Subscription
        module Batch
          def self.example(size=nil)
            size ||= self.size

            (0...size).map do |position|
              EventData.example stream_position: position
            end
          end

          def self.enqueue(queue, batch_size: nil)
            batch = example batch_size
            queue.enq batch
            batch
          end

          def self.size
            3
          end
        end
      end
    end
  end
end
