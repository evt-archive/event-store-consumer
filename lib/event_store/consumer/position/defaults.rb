module EventStore
  class Consumer
    module Position
      module Defaults
        module UpdateInterval
          def self.get
            100
          end
        end
      end
    end
  end
end
