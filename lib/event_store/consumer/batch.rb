module EventStore
  module Consumer
    class Batch
      include Actor::Messaging::Message
      include Schema::DataStructure

      attribute :entries, Array, default: ->{ Array.new }
    end
  end
end
