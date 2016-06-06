module EventStore
  class Consumer
    class Build
      attr_reader :dispatcher_class
      attr_reader :receiver
      attr_reader :stream_name

      dependency :logger, Telemetry::Logger
      dependency :session, EventStore::Client::HTTP::Session
      dependency :settings, Settings

      def initialize(receiver, stream_name, dispatcher_class)
        @receiver = receiver
        @stream_name = stream_name
        @dispatcher_class = dispatcher_class
      end

      def self.build(stream_name, dispatcher_class, session: session)
        receiver = Consumer.new

        instance = new receiver, stream_name, dispatcher_class

        Telemetry::Logger.configure instance
        EventStore::Client::HTTP::Session.configure instance, session: session
        Settings.configure instance

        instance
      end

      def self.call(stream_name, dispatcher_class, session: session)
        instance = build stream_name, dispatcher_class, session: session
        instance.()
      end

      def call
        logger.trace "Building consumer (Stream Name: #{stream_name.inspect}, Dispatcher Type: #{dispatcher_class.name})"

        configure_logger
        configure_position_recorder
        configure_session
        configure_subscription

        logger.trace "Built consumer (Stream Name: #{stream_name.inspect}, Dispatcher Type: #{dispatcher_class.name})"

        receiver
      end

      def configure_logger
        Telemetry::Logger.configure receiver
      end

      def configure_position_recorder
        update_interval = Settings.get :position_update_interval

        Position::Record.configure(
          receiver,
          stream_name,
          update_interval,
          session: session
        )
      end

      def configure_session
        EventStore::Client::HTTP::Session.configure receiver, session: session
      end

      def configure_subscription
        dispatcher = dispatcher_class.configure receiver

        position = Position::Read.(stream_name)

        Messaging::Subscription.configure(
          receiver,
          stream_name,
          dispatcher,
          attr_name: :subscription,
          session: session,
          starting_position: position
        )
      end
    end
  end
end
