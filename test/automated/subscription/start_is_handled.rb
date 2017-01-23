require_relative '../automated_init'

context "Subscription, Start Message is Handled" do
  message = Actor::Messages::Start
  stream_name = Controls::StreamName.example

  get = EventSource::EventStore::HTTP::Get.build batch_size: 1

  subscription = EventStore::Consumer::Subscription.new stream_name, get

  next_message = subscription.handle message

  test "GetBatch message is written to actor" do
    assert next_message == :get_batch
  end
end
