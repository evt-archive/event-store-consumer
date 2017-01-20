module EventStore
  module Consumer
    module Messages
      class EnqueueBatch
        include Actor::Messaging::Message
        include Schema::DataStructure

        attribute :batch, Array, default: ->{ Array.new }

        def each(&block)
          batch.each &block
        end
      end
    end
  end
end
