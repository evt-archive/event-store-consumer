module EventStore
  module Consumer
    module Controls
      module StreamName
        def self.example(category: nil, random: nil)
          category ||= Controls::Category.example random: random

          stream_id = ID.example

          EventStore::Client::StreamName.stream_name category, stream_id
        end

        module Consumer
          def self.example
            category = Controls::Category.example

            category = "#{category}:consumer"

            StreamName.example category: category
          end
        end

        module Category
          def self.example(random: nil)
            category = Controls::Category.example random: random

            EventStore::Client::StreamName.category_stream_name category
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
