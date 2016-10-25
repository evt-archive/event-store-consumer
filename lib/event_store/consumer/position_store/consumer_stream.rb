module EventStore
  module Consumer
    module PositionStore
      class ConsumerStream
        include Log::Dependency

        configure :position

        initializer :stream_name

        dependency :reader, EventStore::Client::HTTP::Reader
        dependency :session, EventStore::Client::HTTP::Session
        dependency :writer, EventStore::Messaging::Writer

        def self.build(stream_name, session: nil)
          consumer_stream_name = StreamName.consumer_stream_name stream_name

          instance = new consumer_stream_name
          instance.configure session: session
          instance
        end

        def self.get(stream_name, session: nil)
          instance = build stream_name, session: session
          instance.get
        end

        def self.put(stream_name, position, session: nil)
          instance = build stream_name, session: session
          instance.put position
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

          EventStore::Messaging::Writer.configure self, session: session
        end

        def get
          log_attributes = "StreamName: #{stream_name}"
          logger.trace "Getting stream position (#{log_attributes})"

          reader.each do |event_data|
            consumer_updated = EventStore::Messaging::Message::Import::EventData.(
              event_data,
              Messages::ConsumerUpdated
            )

            position = consumer_updated.position

            logger.debug "Get stream position done (#{log_attributes}, Position: #{position})"

            return position

            break
          end

          logger.debug "Get stream position done (#{log_attributes}, Position: :no_stream)"

          return :no_stream
        end

        def put(position)
          log_attributes = "StreamName: #{stream_name}, Position: #{position}"
          logger.trace "Putting position (#{log_attributes})"

          message = Messages::ConsumerUpdated.build
          message.position = position

          writer.write message, stream_name

          logger.debug "Put position done (#{log_attributes})"

          message
        end
      end
    end
  end
end
