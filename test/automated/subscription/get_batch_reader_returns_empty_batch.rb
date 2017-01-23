require_relative '../automated_init'

context "Subscription, Get Batch is Handled and Stream Reader Returns Empty Batch" do
  stream_name = Controls::Write.()

  get = EventSource::EventStore::HTTP::Get.build batch_size: 1

  subscription = EventStore::Consumer::Subscription.new stream_name, get
  subscription.position_store.get_position = Controls::Batch::FinalPosition::Next.example

  next_message = subscription.handle :get_batch

  test "Handled GetBatch message is written back to actor" do
    assert next_message == :get_batch
  end

  test "Actor is not delayed" do
    refute subscription.kernel do
      slept?
    end
  end
end
