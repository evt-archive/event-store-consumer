module EventStore
  module Consumer
    module Controls
      module Category
        def self.example(random: nil)
          if random == true
            random = SecureRandom.hex 7
          end

          "someCategory#{random}"
        end
      end
    end
  end
end
