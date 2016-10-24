require_relative '../automated_init'

context "Subscription, EnqueueBatch Message is Handled" do
  message = Controls::Subscription::EnqueueBatch.example
  stream_name = Controls::StreamName.example

  subscription = EventStore::Consumer::Subscription.new stream_name

  next_message = subscription.handle message

  Fixtures::QueueContents.(
    subscription.queue,
    Controls::Subscription::Batch.example,
    description: "Each entry of batch is enqueued"
  )

  test "GetBatch message is written to actor" do
    assert next_message.instance_of?(Subscription::GetBatch)
  end

  Fixtures::AttributeEquality.(
    next_message,
    Controls::Subscription::GetBatch.example(batch_index: 1),
    description: "GetBatch message"
  )
end
