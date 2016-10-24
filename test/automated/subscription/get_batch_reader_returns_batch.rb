require_relative '../automated_init'

context "Subscription, Get Batch is Handled and Stream Reader Returns Batch" do
  stream_name = Controls::Subscription::Write.()

  get_batch = Controls::Subscription::GetBatch.example stream_name

  subscription = EventStore::Consumer::Subscription.new stream_name

  next_message = subscription.handle get_batch

  test "EnqueueBatch is written to actor" do
    assert next_message.instance_of?(Subscription::EnqueueBatch)
  end

  Fixtures::EnqueueBatchEquality.(
    next_message,
    Controls::Subscription::EnqueueBatch.example(stream_name)
  )
end
