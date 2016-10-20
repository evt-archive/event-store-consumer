module EventStore
  module Consumer
    module Controls
      module Dispatcher
        def self.example
          Example.new
        end

        class Example
          include EventStore::Messaging::Dispatcher
        end
      end
    end
  end
end
