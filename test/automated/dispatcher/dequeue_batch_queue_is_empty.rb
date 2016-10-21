require_relative '../automated_init'

context "Dispatcher, DequeueBatch is Handled and Queue is Empty" do
  message = Controls::Dispatcher::DequeueBatch.example

  dispatcher = EventStore::Consumer::Dispatcher.new :stream

  next_message = dispatcher.handle message

  test "DequeueBatch message is written to actor" do
    assert next_message.instance_of?(Dispatcher::DequeueBatch)
  end
end
