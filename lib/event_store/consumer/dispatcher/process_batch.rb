module EventStore
  module Consumer
    class Dispatcher
      class ProcessBatch
        include Actor::Messaging::Message
      end
    end
  end
end
