module EventStore
  module Consumer
    module PositionStore
      class ConsumerStream
        include ::Consumer::PositionStore

        dependency :read, EventSource::EventStore::HTTP::Read
        dependency :session, EventSource::EventStore::HTTP::Session
        dependency :write, ::Messaging::EventStore::Write

        def self.build(stream, session: nil)
          stream = EventSource::Stream.canonize stream

          consumer_stream_name = StreamName.consumer_stream_name stream.name

          stream = EventSource::Stream.canonize consumer_stream_name

          instance = new stream
          instance.configure session: session
          instance
        end

        def self.get(stream, session: nil)
          instance = build stream, session: session
          instance.get
        end

        def self.put(stream, position, session: nil)
          instance = build stream, session: session
          instance.put position
        end

        def configure(session: nil)
          session = EventSource::EventStore::HTTP::Session.configure self, session: session

          EventSource::EventStore::HTTP::Read.configure(
            self,
            stream.name,
            precedence: :desc,
            batch_size: 1,
            session: session
          )

          ::Messaging::EventStore::Write.configure self, session: session
        end

        def get
          read.() do |event_data|
            consumer_updated = ::Messaging::Message::Import.(event_data, Messages::ConsumerUpdated)

            return consumer_updated.position

            break
          end

          nil
        end

        def put(position)
          message = Messages::ConsumerUpdated.build
          message.position = position

          write.(message, stream.name)

          message
        end
      end
    end
  end
end
