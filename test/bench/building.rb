require_relative './bench_init'

context "Building a consumer" do
  dispatcher_class = EventStore::Consumer::Controls::Dispatcher::SomeDispatcher
  stream_name = EventStore::Consumer::Controls::StreamName.get

  context do
    consumer = EventStore::Consumer::Build.(stream_name, dispatcher_class)

    test "Configures a dispatcher" do
      assert consumer.dispatcher.is_a?(dispatcher_class)
    end

    test "Configures a logger" do
      assert consumer.logger.is_a?(Telemetry::Logger::ConsoleLogger)
    end

    test "Configures a position recorder" do
      assert consumer.record_position.is_a?(EventStore::Consumer::Position::Record)
    end

    test "Configures an event store client session" do
      assert consumer.session.is_a?(EventStore::Client::HTTP::Session)
    end

    test "Configures a subscription" do
      assert consumer.subscription.class == EventStore::Messaging::Subscription
    end
  end

  context "Current stream position is at the beginning" do
    consumer = EventStore::Consumer::Build.(stream_name, dispatcher_class)

    test "Starting position is set to 0" do
      assert consumer.subscription.starting_position == 0
    end
  end

  context "Current stream position is in the middle" do
    control_position = EventStore::Consumer::Controls::Position.example

    stream_name = EventStore::Consumer::Controls::Writer.write stream_name, position: control_position

    consumer = EventStore::Consumer::Build.(stream_name, dispatcher_class)

    test "Starting position is set to previously recorded stream position" do
      assert consumer.subscription.starting_position == control_position
    end
  end

  context "Supplying a session" do
    session = EventStore::Client::HTTP::Session.build

    consumer = EventStore::Consumer::Build.(stream_name, dispatcher_class, session: session)

    test "Consumer session is set" do
      assert consumer.session == session
    end

    test "Subscription session is set" do
      assert consumer.session == session
    end
  end

  context "Specifying a consumer name" do
    consumer_name = :some_name
    control_position = EventStore::Consumer::Controls::Position.example
    stream_name = EventStore::Consumer::Controls::Writer.write stream_name, position: control_position
    EventStore::Consumer::Position::Write.(stream_name, control_position, metadata_prefix: consumer_name)

    consumer = EventStore::Consumer::Build.(stream_name, dispatcher_class, name: consumer_name)

    test "Name is used as prefix when updating position in stream metadata" do
      assert consumer.record_position do
        metadata_prefix? consumer_name
      end
    end

    test "Name is used as prefix when reading starting position" do
      assert consumer.subscription.starting_position == control_position
    end
  end
end
