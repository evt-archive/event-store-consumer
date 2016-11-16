module EventStore
  module Consumer
    module Messages
      class GetBatch
        include Actor::Messaging::Message
        include Schema::DataStructure

        attribute :slice_uri, String
      end
    end
  end
end
