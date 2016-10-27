require_relative '../automated_init'

context "Dispatcher, ProcessBatch is Handled and Queue is Empty" do
  message = Controls::Dispatcher::ProcessBatch.example

  dispatcher = EventStore::Consumer::Dispatcher.new :stream

  next_message = dispatcher.handle message

  test "ProcessBatch message is written back to actor" do
    assert next_message.instance_of?(Dispatcher::ProcessBatch)
  end

  test "Actor is delayed briefly" do
    assert dispatcher.kernel do
      slept? Defaults.empty_queue_delay_seconds
    end
  end
end
