require_relative '../automated_init'

context "Dispatcher, Start Message is Handled" do
  message = Actor::Messages::Start.new

  dispatcher = EventStore::Consumer::Dispatcher.new :stream

  next_message = dispatcher.handle message

  test "DequeueBatch message is written to actor" do
    assert next_message.instance_of?(Dispatcher::DequeueBatch)
  end
end
