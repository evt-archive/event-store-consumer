require_relative '../automated_init'

context "Subscription, Get Batch is Handled But Dispatcher Depth Exceeds Limit" do
  stream_name = Controls::Write.()

  get_batch = Controls::Messages::GetBatch.example stream_name

  subscription = EventStore::Consumer::Subscription.new stream_name
  subscription.dispatcher_queue_depth_limit = 1
  subscription.dispatcher_address.queue_depth = 2

  next_message = subscription.handle get_batch

  test "Handled GetBatch message is written back to actor" do
    assert next_message == get_batch
  end

  test "Actor thread is delayed" do
    assert subscription.kernel do
      slept? Controls::StreamReader::NoStreamDelayDuration.seconds
    end
  end
end
