module EventStore
  module Consumer
    module Controls
      module StreamName
        def self.example(category: nil, random: nil)
          category ||= Controls::Category.example random: random

          stream_id = ID.example

          EventStore::Messaging::StreamName.stream_name stream_id, category
        end

        module Consumer
          def self.example
            category = Controls::Category.example

            category = "#{category}:consumer"

            StreamName.example category: category
          end
        end

        module Singleton
          def self.example(random: nil)
            Controls::Category.example 'someSingleton', random: random
          end

          module Consumer
            def self.example
              category = Singleton.example

              "#{category}:consumer"
            end
          end
        end

        module Category
          def self.example(random: nil)
            category = Controls::Category.example random: random

            EventStore::Messaging::StreamName.category_stream_name category
          end

          module Consumer
            def self.example
              category = Controls::Category.example

              "#{category}:consumer"
            end
          end
        end
      end
    end
  end
end
