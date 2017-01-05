require_relative '../automated_init'

context "Subscription, Stream Reader is Configured" do
  message = Actor::Messages::Start
  stream_name = Controls::StreamName.example

  context do
    subscription = EventStore::Consumer::Subscription.new stream_name

    stream_reader = subscription.stream_reader

    test "Start path is configured" do
      assert stream_reader.start_path == Controls::StreamReader::StartPath.example
    end

    test "Long polling is enabled" do
      assert stream_reader.request.long_poll_enabled?
    end
  end

  context "Session is supplied to subscription" do
    session = EventStore::Client::HTTP::Session.build

    subscription = EventStore::Consumer::Subscription.new stream_name
    subscription.session = session

    test "Session of subscription is supplied to stream reader" do
      assert subscription.stream_reader do |stream_reader|
        stream_reader.request.session.equal? session
      end
    end
  end

  context "Consumer position has been previously recorded" do
    subscription = EventStore::Consumer::Subscription.new stream_name
    subscription.position_store.get_position = 11

    stream_reader = subscription.stream_reader

    test "Stream reader starting position is set to that of consumer position" do
      control_uri = Controls::StreamReader::StartPath.example starting_position: 11

      assert stream_reader.start_path == control_uri
    end
  end
end
