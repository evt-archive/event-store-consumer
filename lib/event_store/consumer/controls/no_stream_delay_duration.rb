module EventStore
  module Consumer
    module Controls
      module NoStreamDelayDuration
        def self.milliseconds
          100
        end

        def self.seconds
          Rational(milliseconds, 1000)
        end
      end
    end
  end
end
