module EventStore
  module Consumer
    module Controls
      module ConsumerStream
        module ConsumerUpdated
          def self.example(position: nil)
            position ||= Position.example

            consumer_updated = Consumer::Position::ConsumerUpdated.new
            consumer_updated.position = position
            consumer_updated
          end
        end
      end
    end
  end
end
