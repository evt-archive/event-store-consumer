module EventStore
  module Consumer
    class Dispatcher
      class DequeueBatch
        include Actor::Messaging::Message
      end
    end
  end
end
