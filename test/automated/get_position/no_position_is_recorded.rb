require_relative '../automated_init'

context "Get Starting Position, No Position is Recorded" do
  stream_name = Controls::StreamName.example random: true

  position = Position::Get.(stream_name)

  test "No stream is returned" do
    assert position == :no_stream
  end
end
