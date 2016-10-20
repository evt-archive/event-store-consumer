require_relative '../automated_init'

context "Subscription, Get Batch is Handled and Stream Reader Returns Nothing" do
  get_batch = Controls::Subscription::GetBatch.example
  stream_name = Controls::StreamName.example random: true

  subscription = EventStore::Consumer::Subscription.new stream_name

  next_message = subscription.handle get_batch

  test "Handled GetBatch message is written back to actor" do
    assert next_message == get_batch
  end

  test "Actor thread is delayed by the long poll duration of the stream reader" do
    assert subscription.kernel do
      slept? Controls::StreamReader::LongPollDuration.example
    end
  end
end
