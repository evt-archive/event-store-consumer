module EventStore
  module Consumer
    module Controls
      module Consumer
        def self.example
          Example.build
        end

        class Example
          include Consumer

          #stream StreamName.example
          #dispatcher Dispatcher
          #
          #def handle_error(error)
          #end
        end
      end
    end
  end
end
