module EventStore
  module Consumer
    module Controls
      module Address
        module Subscription
          def self.example
            id = ID.example

            Actor::Messaging::Address.new id
          end

          module ID
            def self.example
              Controls::ID.example 1
            end
          end
        end

        module Dispatcher
          def self.example
            id = ID.example

            Actor::Messaging::Address.new id
          end

          module ID
            def self.example
              Controls::ID.example 2
            end
          end
        end
      end
    end
  end
end
