module EventStore
  module Consumer
    module Controls
      module Messaging
        module Dispatcher
          class Example
            include EventStore::Messaging::Dispatcher

            handler Handler::Example
          end

          class Failure
            include EventStore::Messaging::Dispatcher

            handler Handler::Failure
          end

          class VerifySequence
            include EventStore::Messaging::Dispatcher

            handler Handler::VerifySequence
          end
        end
      end
    end
  end
end
