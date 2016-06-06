module EventStore
  class Consumer
    module Position
      class Write
        attr_reader :stream_name

        dependency :logger, Telemetry::Logger
        dependency :update_stream_metadata, Client::HTTP::StreamMetadata::Update

        def initialize(stream_name)
          @stream_name = stream_name
        end

        def self.build(stream_name, session: nil)
          instance = new stream_name

          Client::HTTP::StreamMetadata::Update.configure instance, stream_name, session: session
          Telemetry::Logger.configure instance

          instance
        end

        def self.call(stream_name, position, session: nil)
          instance = build stream_name, session: session
          instance.(position)
        end

        def self.configure(receiver, stream_name, attr_name: nil, session: nil)
          attr_name ||= :write_position

          instance = build stream_name, session: session
          receiver.public_send "#{attr_name}=", instance
          instance
        end

        def call(position)
          logger.trace "Updating stream position (StreamName: #{stream_name.inspect}, Position: #{position.inspect})"

          previous_position = nil

          update_stream_metadata.() do |metadata|
            previous_position = metadata[:consumer_position]
            metadata[:consumer_position] = position
          end

          logger.debug "Updated stream position (StreamName: #{stream_name.inspect}, Position: #{position.inspect}, PreviousPosition: #{previous_position.inspect})"

          previous_position
        end
      end
    end
  end
end
