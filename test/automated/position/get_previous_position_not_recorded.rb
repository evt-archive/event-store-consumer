require_relative '../automated_init'

context "Get Starting Position, Previous Position is Not Recorded" do
  stream_name = Controls::StreamName.example random: true

  position = Position.get stream_name

  test "No stream is returned" do
    assert position == :no_stream
  end
end
