module EventStore
  module Consumer
    module Controls
      module Messaging
        module Dispatcher
          class Example
            include EventStore::Messaging::Dispatcher

            handler Controls::Messaging::Handler::Example
          end
        end
      end
    end
  end
end
