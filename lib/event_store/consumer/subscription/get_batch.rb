module EventStore
  module Consumer
    class Subscription
      class GetBatch
        include Actor::Messaging::Message
        include Schema::DataStructure

        attribute :slice_uri, String
      end
    end
  end
end
