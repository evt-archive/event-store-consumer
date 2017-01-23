require_relative '../../automated_init'

context "Consumer Stream Position Store, Put Operation" do
  stream_name = Controls::StreamName.example random: true

  position = Controls::Position.example

  EventStore::Consumer::PositionStore::ConsumerStream.put stream_name, position

  test "Position is written to consumer stream" do
    consumer_stream_name = EventStore::Consumer::StreamName.consumer_stream_name stream_name

    position = nil

    Controls::Read.(consumer_stream_name, :desc) do |event_data|
      position = event_data.data[:position]
      break
    end

    assert position == Controls::Position.example
  end
end
