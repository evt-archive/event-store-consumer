require_relative '../bench_init'

context "Writing the current stream position" do
  context "Consumer position is updated" do
    control_position = EventStore::Consumer::Controls::Position.example
    stream_name = EventStore::Consumer::Controls::Writer.write

    EventStore::Consumer::Position::Write.(stream_name, control_position)

    position = EventStore::Consumer::Position::Read.(stream_name)

    assert position == control_position
  end

  context "Configuration" do
    receiver = OpenStruct.new
    stream_name = EventStore::Consumer::Controls::StreamName.get

    context "Default attribute name" do
      EventStore::Consumer::Position::Write.configure receiver, stream_name

      test "The receiver has an instance of a position writer" do
        assert receiver.write_position.is_a?(EventStore::Consumer::Position::Write)
      end
    end

    context "Specific attribute name" do
      EventStore::Consumer::Position::Write.configure receiver, stream_name, attr_name: :some_attr

      test "The receiver has an instance of a position writer" do
        assert receiver.some_attr.is_a?(EventStore::Consumer::Position::Write)
      end
    end
  end
end
