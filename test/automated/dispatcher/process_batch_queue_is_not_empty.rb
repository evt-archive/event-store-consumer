require_relative '../automated_init'

context "Dispatcher, ProcessBatch is Handled and Queue is Not Empty" do
  message = Controls::Dispatcher::ProcessBatch.example

  dispatcher = EventStore::Consumer::Dispatcher.new :stream
  batch = Controls::Subscription::Batch.enqueue dispatcher.queue

  next_message = dispatcher.handle message

  test "ProcessBatch message is written to actor" do
    assert next_message.instance_of?(Dispatcher::ProcessBatch)
  end

  test "Actor is not delayed" do
    refute dispatcher.kernel do
      slept?
    end
  end

  context "Each event data in batch is dispatched" do
    batch.each_with_index do |event_data, index|
      test "Event data ##{index + 1}" do
        assert dispatcher do
          dispatched? event_data
        end
      end
    end
  end
end
