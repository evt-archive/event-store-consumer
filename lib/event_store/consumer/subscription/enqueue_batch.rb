module EventStore
  module Consumer
    class Subscription
      class EnqueueBatch
        include Actor::Messaging::Message
        include Schema::DataStructure

        attribute :entries
        attribute :next_slice_uri, String
      end
    end
  end
end
