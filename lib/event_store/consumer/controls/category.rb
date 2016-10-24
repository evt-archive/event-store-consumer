module EventStore
  module Consumer
    module Controls
      module Category
        def self.example(category=nil, random: nil)
          category ||= 'someCategory'

          if random == true
            random = SecureRandom.hex 7
          end

          "#{category}#{random}"
        end
      end
    end
  end
end
