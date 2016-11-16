module EventStore
  module Consumer
    module Controls
      module Messages
        module ConsumerUpdated
          def self.example(position: nil)
            position ||= Position.example

            consumer_updated = EventStore::Consumer::Messages::ConsumerUpdated.new
            consumer_updated.position = position
            consumer_updated
          end
        end
      end
    end
  end
end
