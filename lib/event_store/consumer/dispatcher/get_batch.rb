module EventStore
  module Consumer
    class Dispatcher
      class GetBatch
        include Actor::Messaging::Message
      end
    end
  end
end
