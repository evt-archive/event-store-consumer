module EventStore
  module Consumer
    module Position
      class Get
        include Log::Dependency

        initializer :stream_name

        dependency :reader, EventStore::Client::HTTP::Reader
        dependency :session, EventStore::Client::HTTP::Session

        def self.build(stream_name, session: nil)
          consumer_stream_name = StreamName.consumer_stream_name stream_name

          instance = new consumer_stream_name
          instance.configure session: session
          instance
        end

        def self.call(*arguments)
          instance = build *arguments
          instance.()
        end

        def configure(session: nil)
          session = EventStore::Client::HTTP::Session.configure self, session: session

          EventStore::Client::HTTP::Reader.configure(
            self,
            stream_name,
            direction: :backward,
            slice_size: 1,
            session: session
          )
        end

        def call
          logger.trace "Getting stream position (#{log_attributes})"

          reader.each do |event_data|
            position = event_data.data[:position]

            logger.debug "Get stream position done (#{log_attributes}, Position: #{position})"

            return position

            break
          end

          logger.debug "Get stream position done (#{log_attributes}, Position: :no_stream)"

          return :no_stream
        end

        def log_attributes
          "StreamName: #{stream_name}"
        end
      end
    end
  end
end
