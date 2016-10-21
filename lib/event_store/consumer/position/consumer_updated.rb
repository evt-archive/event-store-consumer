module EventStore
  module Consumer
    module Position
      class ConsumerUpdated
        include EventStore::Messaging::Message

        attribute :position, Integer
      end
    end
  end
end
