module EventStore
  class Consumer
    module Position
      class Record
        configure :record_position

        attr_writer :update_interval

        dependency :logger, Telemetry::Logger
        dependency :write, Write

        def update_interval
          @update_interval ||= Defaults::UpdateInterval.get
        end

        def initialize(update_interval=nil)
          @update_interval = update_interval
        end

        def self.build(stream_name, update_interval=nil, metadata_prefix: nil, session: nil)
          instance = new update_interval
          Telemetry::Logger.configure instance
          Write.configure instance, stream_name, metadata_prefix: metadata_prefix, session: session, attr_name: :write
          instance
        end

        def call(event_data)
          position = event_data.position

          logger.opt_trace "Recording stream position (StreamName: #{write.stream_name.inspect}, Position: #{position.inspect})"

          if interval? position
            previous_position = write.(position)

            logger.opt_debug "Recorded stream position (StreamName: #{write.stream_name.inspect}, Position: #{position.inspect}, PreviousPosition: #{previous_position.inspect})"
            true
          else

            logger.opt_debug "Did not record stream position (StreamName: #{write.stream_name.inspect}, Position: #{position.inspect})"
            false
          end
        end

        def interval?(position)
          cycle = position % update_interval
          cycle.zero?
        end

        module Assertions
          def metadata_prefix?(prefix)
            write.metadata_key == "#{prefix}_consumer_position".to_sym
          end
        end
      end
    end
  end
end
