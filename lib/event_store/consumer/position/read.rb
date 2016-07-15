module EventStore
  class Consumer
    module Position
      class Read
        configure :read_position

        attr_reader :metadata_key
        attr_reader :stream_name

        dependency :logger, Telemetry::Logger
        dependency :read_stream_metadata, Client::HTTP::StreamMetadata::Read

        def initialize(stream_name, metadata_key)
          @stream_name = stream_name
          @metadata_key = metadata_key
        end

        def self.build(stream_name, metadata_prefix: nil, session: nil)
          metadata_key = MetadataKey.get metadata_prefix

          instance = new stream_name, metadata_key

          Client::HTTP::StreamMetadata::Read.configure instance, stream_name, session: session
          Telemetry::Logger.configure instance

          instance
        end

        def self.call(*arguments)
          instance = build *arguments
          instance.()
        end

        def call
          logger.trace "Retrieving stream position (Stream Name: #{stream_name.inspect}, MetadataKey: #{metadata_key.inspect})"

          metadata = read_stream_metadata.()

          if metadata.nil?
            position = 0
          else
            position = metadata[metadata_key].to_i
          end

          logger.debug "Retrieved stream position (Stream Name: #{stream_name.inspect}, MetadataKey: #{metadata_key.inspect}, Position: #{position})"

          position
        end
      end
    end
  end
end
