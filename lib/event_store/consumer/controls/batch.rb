module EventStore
  module Consumer
    module Controls
      module Batch
        def self.example(size: nil)
          entries = Entries.example size

          EventStore::Consumer::Batch.build :entries => entries
        end

        module Entries
          def self.example(size=nil)
            size ||= Size.example

            entries = (0...size).map do |position|
              EventData.example stream_position: position
            end
          end
        end

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
