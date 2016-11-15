require_relative '../automated_init'

context "Dispatcher, Position is Updated" do
  message = Controls::Batch.example

  context "Update interval is exceeded by position of last event in batch" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.position_update_interval = Controls::Batch::Size.example

    dispatcher.handle message

    test "Consumer position is updated" do
      control_position = Controls::Batch::FinalPosition.example + 1

      assert dispatcher.position_store do
        put? control_position
      end
    end
  end

  context "Update interval is not exceeded by position of last event in batch" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.position_update_interval = Controls::Batch::Size.example + 1

    dispatcher.handle message

    test "Consumer position is updated" do
      refute dispatcher.position_store do
        put?
      end
    end
  end
end
