module EventStore
  module Consumer
    module PositionStore
      def self.included(cls)
        cls.class_exec do
          include Log::Dependency

          extend Build

          prepend Get
          prepend Put

          configure :position_store

          initializer :stream_name

          virtual :configure

          abstract :get
          abstract :put
        end
      end

      module Get
        def get
          log_attributes = "StreamName: #{stream_name}"
          logger.trace "Getting stream position (#{log_attributes})"

          position = super

          logger.debug "Get stream position done (#{log_attributes}, Position: #{position.inspect})"

          position
        end
      end

      module Put
        def put(position)
          log_attributes = "StreamName: #{stream_name}, Position: #{position}"
          logger.trace "Putting position (#{log_attributes})"

          return_value = super

          logger.debug "Put position done (#{log_attributes})"

          return_value
        end
      end

      module Build
        def build(stream_name)
          instance = new stream_name
          instance.configure
          instance
        end
      end
    end
  end
end
