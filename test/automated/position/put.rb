require_relative '../automated_init'

context "Put Consumer Position" do
  stream_name = Controls::StreamName.example random: true

  position = Controls::Position.example

  Position.put stream_name, position

  test "Position is written to consumer stream" do
    consumer_stream_name = StreamName.consumer_stream_name stream_name

    position = nil

    Controls::Read.(consumer_stream_name, :backward) do |event_data|
      position = event_data.data[:position]
      break
    end

    assert position == Controls::Position.example
  end
end
