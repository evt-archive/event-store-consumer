module EventStore
  module Consumer
    module Controls
      module PositionStore
        class Example
          include EventStore::Consumer::PositionStore

          def get
          end
        end
      end
    end
  end
end
