require_relative '../automated_init'

context "Subscription, Iterator is Configured" do
  message = Actor::Messages::Start
  stream_name = Controls::StreamName.example

  dispatcher_address = Controls::Address.example

  context do
    subscription = EventStore::Consumer::Subscription.build(
      stream_name,
      dispatcher_address,
      batch_size: Controls::Batch::Size.example
    )

    iterator = subscription.iterator

    test "Stream offset is set to start of stream" do
      assert iterator.stream_offset == 0
    end

    test "Batch size is configured" do
      assert iterator.get.batch_size == Controls::Batch::Size.example
    end

    test "Long polling is enabled" do
      assert iterator.get do
        long_poll_enabled?
      end
    end
  end

  context "Session is supplied to subscription" do
    session = EventSource::EventStore::HTTP::Session.build

    subscription = EventStore::Consumer::Subscription.build(
      stream_name,
      dispatcher_address,
      session: session
    )

    test "Session of subscription is supplied to get" do
      assert subscription.iterator do |iterator|
        iterator.get.session.equal? session
      end
    end
  end

  context "Consumer position has been previously recorded" do
    get = EventSource::EventStore::HTTP::Get.build batch_size: 1

    subscription = EventStore::Consumer::Subscription.new stream_name, get
    subscription.position_store.get_position = 11

    test "Iterator stream offset is set to that of consumer position" do
      assert subscription.iterator.stream_offset == 11
    end
  end
end
