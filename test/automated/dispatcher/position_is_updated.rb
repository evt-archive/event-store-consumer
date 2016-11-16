require_relative '../automated_init'

context "Dispatcher, Position is Updated" do
  next_starting_position = 100
  event_data_position = next_starting_position - 1

  message = Controls::Messages::DispatchEvent.example stream_position: event_data_position

  context "Next starting position is divisible by update interval" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.position_update_interval = 10

    dispatcher.handle message

    test "Consumer position is updated" do
      assert dispatcher.position_store do
        put? next_starting_position
      end
    end
  end

  context "Next starting position is not divisible by update interval" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.position_update_interval = 11

    dispatcher.handle message

    test "Consumer position is updated" do
      refute dispatcher.position_store do
        put?
      end
    end
  end
end
