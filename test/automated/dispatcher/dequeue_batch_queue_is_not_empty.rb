require_relative '../automated_init'

context "Dispatcher, DequeueBatch is Handled and Queue is Not Empty" do
  message = Controls::Dispatcher::DequeueBatch.example

  dispatcher = EventStore::Consumer::Dispatcher.new :stream
  batch = Controls::Subscription::Batch.enqueue dispatcher.queue

  next_message = dispatcher.handle message

  test "DequeueBatch message is written to actor" do
    assert next_message.instance_of?(Dispatcher::DequeueBatch)
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

  test "Consumer position is updated" do
    assert dispatcher.put_position do
      put?
    end
  end
end
