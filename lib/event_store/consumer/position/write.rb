module EventStore
  class Consumer
    module Position
      class Write
        configure :write_position

        attr_reader :metadata_key
        attr_reader :stream_name

        dependency :logger, Telemetry::Logger
        dependency :update_stream_metadata, Client::HTTP::StreamMetadata::Update

        def initialize(stream_name, metadata_key)
          @stream_name = stream_name
          @metadata_key = metadata_key
        end

        def self.build(stream_name, metadata_prefix: nil, session: nil)
          metadata_key = MetadataKey.get metadata_prefix

          instance = new stream_name, metadata_key

          Client::HTTP::StreamMetadata::Update.configure instance, stream_name, session: session
          Telemetry::Logger.configure instance

          instance
        end

        def self.call(stream_name, position, metadata_prefix: nil, session: nil)
          instance = build stream_name, metadata_prefix: metadata_prefix, session: session
          instance.(position)
        end

        def call(position)
          logger.trace "Updating stream position (StreamName: #{stream_name.inspect}, Position: #{position.inspect}, MetadataKey: #{metadata_key.inspect})"

          previous_position = nil

          update_stream_metadata.() do |metadata|
            previous_position = metadata[metadata_key]
            metadata[metadata_key] = position
          end

          logger.debug "Updated stream position (StreamName: #{stream_name.inspect}, Position: #{position.inspect}, MetadataKey: #{metadata_key.inspect}, PreviousPosition: #{previous_position.inspect})"

          previous_position
        end
      end
    end
  end
end
