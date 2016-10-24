require_relative '../automated_init'

context "Dispatcher Determines EventData Position" do
  event_data = Controls::EventData.example(
    stream_position: 1,
    global_position: 2
  )

  context "Category is being consumed" do
    dispatcher = Dispatcher.new :category

    position = dispatcher.get_position(event_data)

    test "Position is derived from global position" do
      assert position == 2
    end
  end

  context "Stream is being consumed" do
    dispatcher = Dispatcher.new :stream

    position = dispatcher.get_position(event_data)

    test "Position is derived from stream position" do
      assert position == 1
    end
  end
end
