module EventStore
  module Consumer
    module Controls
      module Messaging
        module Dispatcher
          class Example
            include EventStore::Messaging::Dispatcher

            configure_macro :messaging_dispatcher

            handler Handler::Example
          end

          class Failure
            include EventStore::Messaging::Dispatcher

            configure_macro :messaging_dispatcher

            handler Handler::Failure
          end
        end
      end
    end
  end
end
