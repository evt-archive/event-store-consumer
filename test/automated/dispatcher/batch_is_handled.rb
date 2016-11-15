require_relative '../automated_init'

context "Dispatcher, Batch is Handled" do
  message = Controls::Batch.example

  dispatcher = EventStore::Consumer::Dispatcher.new :stream

  dispatcher.handle message

  test "Nothing is written" do
    refute dispatcher.write do
      written?
    end
  end

  context "Each event data in batch is dispatched" do
    message.entries.each_with_index do |event_data, index|
      test "Event data ##{index + 1}" do
        assert dispatcher do
          dispatched? event_data
        end
      end
    end
  end
end
