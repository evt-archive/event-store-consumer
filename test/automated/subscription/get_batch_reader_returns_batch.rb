require_relative '../automated_init'

context "Subscription, Get Batch is Handled and Stream Reader Returns Batch" do
  stream_name = Controls::Subscription::Write.()

  get_batch = Controls::Messages::GetBatch.example stream_name

  subscription = EventStore::Consumer::Subscription.new stream_name

  next_message = subscription.handle get_batch

  test "EnqueueBatch is written to actor" do
    assert subscription.write do
      written? next_message
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
