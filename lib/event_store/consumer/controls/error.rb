module EventStore
  module Consumer
    module Controls
      module Error
        def self.example
          Example.new
        end

        class Example < StandardError
          def to_s
            "Control error"
          end
        end
      end
    end
  end
end
