module EventStore
  module Consumer
    module PositionStore
      class ConsumerStream
        include ::Consumer::PositionStore

        initializer :stream_name

        dependency :read, EventSource::EventStore::HTTP::Read
        dependency :session, EventSource::EventStore::HTTP::Session
        dependency :write, ::Messaging::EventStore::Write

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
          session = EventSource::EventStore::HTTP::Session.configure self, session: session

          EventSource::EventStore::HTTP::Read.configure(
            self,
            stream_name,
            precedence: :desc,
            batch_size: 1,
            session: session
          )

          ::Messaging::EventStore::Write.configure self, session: session
        end

        def get
          position = :no_stream

          read.() do |event_data|
            consumer_updated = ::Messaging::Message::Import.(event_data, Messages::ConsumerUpdated)

            position = consumer_updated.position

            break
          end

          position
        end

        def put(position)
          message = Messages::ConsumerUpdated.build
          message.position = position

          write.(message, stream_name)

          message
        end
      end
    end
  end
end
