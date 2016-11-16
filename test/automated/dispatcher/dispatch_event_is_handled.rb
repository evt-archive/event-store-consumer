require_relative '../automated_init'

context "Dispatcher, Dispatch Event is Handled" do
  message = Controls::Messages::DispatchEvent.example

  dispatcher = EventStore::Consumer::Dispatcher.new :stream

  dispatcher.handle message

  test "Event data is dispatched" do
    assert dispatcher do
      dispatched? message.event_data
    end
  end
end
