require_relative '../automated_init'

context "Subscription, Get Batch is Handled and Stream Reader Returns Empty Batch" do
  stream_name = Controls::Subscription::Write.()

  get_batch = Controls::Subscription::GetBatch.example stream_name, batch_index: 1

  subscription = EventStore::Consumer::Subscription.new stream_name

  next_message = subscription.handle get_batch

  test "Handled GetBatch message is written back to actor" do
    assert next_message == get_batch
  end

  test "Actor thread is delayed briefly" do
    assert subscription.kernel do
      slept? Defaults.empty_queue_delay_seconds
    end
  end
end
