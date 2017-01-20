require_relative '../automated_init'

context "Subscription, Iterator is Configured" do
  message = Actor::Messages::Start
  stream_name = Controls::StreamName.example

  context do
    subscription = EventStore::Consumer::Subscription.new stream_name

    iterator = subscription.iterator

    test "Stream offset is configured" do
      assert iterator.stream_offset == nil
    end

    test "Batch size is configured" do
      assert iterator.get.batch_size == Controls::Batch.size
    end

    test "Long polling is enabled" do
      assert iterator.get do
        long_poll_enabled?
      end
    end
  end

  context "Session is supplied to subscription" do
    session = EventSource::EventStore::HTTP::Session.build

    subscription = EventStore::Consumer::Subscription.new stream_name
    subscription.session = session

    test "Session of subscription is supplied to get" do
      assert subscription.iterator do |iterator|
        iterator.get.session.equal? session
      end
    end
  end

  context "Consumer position has been previously recorded" do
    subscription = EventStore::Consumer::Subscription.new stream_name
    subscription.position_store.get_position = 11

    test "Iterator stream offset is set to that of consumer position" do
      assert iterator.steram_offest == 11
    end
  end
end
