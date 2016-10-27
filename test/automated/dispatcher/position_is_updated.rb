require_relative '../automated_init'

context "Dispatcher, Position is Updated" do
  message = Controls::Dispatcher::ProcessBatch.example

  context "Update interval is exceeded by position of last event in batch" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.position_update_interval = Controls::Subscription::Batch::Size.example
    batch = Controls::Subscription::Batch.enqueue dispatcher.queue

    dispatcher.handle message

    test "Consumer position is updated" do
      assert dispatcher.position_store do
        put? Controls::Subscription::Batch::FinalPosition.example
      end
    end
  end

  context "Update interval is not exceeded by position of last event in batch" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.position_update_interval = Controls::Subscription::Batch::Size.example + 1
    batch = Controls::Subscription::Batch.enqueue dispatcher.queue

    dispatcher.handle message

    test "Consumer position is updated" do
      refute dispatcher.position_store do
        put?
      end
    end
  end
end
