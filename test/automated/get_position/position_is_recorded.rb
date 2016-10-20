require_relative '../automated_init'

context "Get Starting Position, Position is Recorded" do
  stream_name = Controls::ConsumerStream::Write.(position: 11)

  context do
    position = Position::Get.(stream_name)

    test "Recorded position is returned" do
      assert position == 11
    end
  end

  context "Consumer stream has been updated more than once" do
    Controls::ConsumerStream::Write.(stream_name, position: 22)

    position = Position::Get.(stream_name)

    test "Position of most recent update is returned" do
      assert position == 22
    end
  end
end
