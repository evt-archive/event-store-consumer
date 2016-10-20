require_relative '../automated_init'

context "Dispatcher, Start Message is Handled" do
  message = Actor::Messages::Start.new
  dispatcher = Controls::Dispatcher.example

  dispatcher = EventStore::Consumer::Dispatcher.new dispatcher

  next_message = dispatcher.handle message

  test "GetBatch message is written to actor" do
    assert next_message.instance_of?(Dispatcher::GetBatch)
  end
end
