require_relative '../automated_init'

context "Subscription, Iterator is Configured" do
  message = Actor::Messages::Start
  stream_name = Controls::StreamName.example

  get = EventSource::EventStore::HTTP::Get.build batch_size: 1

  context do
    subscription = EventStore::Consumer::Subscription.build stream_name, get

    iterator = subscription.iterator

    test "Stream offset is set to start of stream" do
      assert iterator.stream_offset == 0
    end
  end

  context "Consumer position has been previously recorded" do
    subscription = EventStore::Consumer::Subscription.new stream_name, get
    subscription.position = 11

    test "Iterator stream offset is set to that of consumer position" do
      assert subscription.iterator.stream_offset == 11
    end
  end
end
