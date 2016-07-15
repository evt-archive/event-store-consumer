module EventStore
  class Consumer
    dependency :dispatcher, Messaging::Dispatcher
    dependency :logger, Telemetry::Logger
    dependency :record_position, Position::Record
    dependency :session, Client::HTTP
    dependency :subscription, Messaging::Subscription

    def self.build(stream_name, dispatcher_class, name: nil, session: nil)
      Build.(stream_name, dispatcher_class, name: name, session: session)
    end

    def start(&supplementary_action)
      observe_dispatcher
      start_subscription(&supplementary_action)
    end

    def observe_dispatcher
      dispatcher.dispatched do |_, event_data|
        record_position.(event_data)
      end
    end

    def start_subscription(&supplementary_action)
      loop do
        logger.trace "Starting subscription (Stream Name: #{subscription.stream_name.inspect})"

        subscription.start &supplementary_action

        logger.debug "Subscription stopped (Stream Name: #{subscription.stream_name.inspect})"
      end
    end

    module ProcessHostIntegration
      def change_connection_scheduler(scheduler)
        session.connection.change_connection_scheduler scheduler
      end
    end
  end
end
