module EventStore
  module Consumer
    module Controls
      module Messages
        module GetBatch
          def self.example
            reply_address = ::Actor::Messaging::Address.build

            ::Consumer::Subscription::GetBatch.new reply_address
          end
        end
      end
    end
  end
end
