module EventStore
  module Consumer
    module Messages
      class ConsumerUpdated
        include EventStore::Messaging::Message

        attribute :position, Integer
      end
    end
  end
end
