module EventStore
  module Consumer
    module Controls
      module Consumer
        def self.example
          Example.build
        end

        class Example
          include EventStore::Consumer

          category Category.example
          dispatcher MessagingDispatcher::Example
        end
      end
    end
  end
end
