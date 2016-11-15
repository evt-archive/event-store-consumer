module EventStore
  module Consumer
    module Kernel
      def self.configure(receiver, attr_name: nil)
        attr_name ||= :kernel

        instance = ::Kernel
        receiver.public_send "#{attr_name}=", instance
        instance
      end

      class Substitute
        attr_accessor :sleep_duration

        def self.build
          new
        end

        def sleep duration=nil
          self.sleep_duration = duration
        end

        module Assertions
          def slept? duration=nil
            if duration.nil?
              sleep_duration ? true : false
            else
              sleep_duration == duration
            end
          end
        end
      end
    end
  end
end
