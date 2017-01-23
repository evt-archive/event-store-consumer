require_relative '../automated_init'

context "Subscription, Get Batch is Handled and Stream Reader Returns Batch" do
  stream_name = Controls::Write.()

  get = EventSource::EventStore::HTTP::Get.build batch_size: 1

  subscription = EventStore::Consumer::Subscription.new stream_name, get

  next_message = subscription.handle :get_batch

  test "EnqueueBatch is sent to actor" do
    assert subscription.send do
      sent? next_message
    end
  end

  test "Actor thread is not delayed" do
    refute subscription.kernel do
      slept?
    end
  end

  Fixtures::EnqueueBatchEquality.(
    next_message,
    Controls::Messages::EnqueueBatch.example(stream_name)
  )
end
