module EventStore
  module Consumer
    module Controls
      module Batch
        module Size
          def self.example
            3
          end
        end

        module FinalPosition
          def self.example(batch_index=nil)
            batch_index ||= 0

            batch_size = Batch::Size.example

            start_position = batch_index * batch_size

            start_position + batch_size - 1
          end
        end
      end
    end
  end
end
