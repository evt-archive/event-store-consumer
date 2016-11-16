module EventStore
  module Consumer
    module Messages
      class EnqueueBatch
        include Actor::Messaging::Message
        include Schema::DataStructure

        attribute :entries, Array, default: ->{ Array.new }
        attribute :next_slice_uri, String
      end
    end
  end
end
