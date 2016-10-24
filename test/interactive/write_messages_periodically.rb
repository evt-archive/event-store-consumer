require_relative './interactive_init'

stream_name = get_stream_name

stream_position = 0
global_position = 0

if ENV['CATEGORY'] == 'on'
  category, _ = StreamName.split stream_name
  stream_ids = (1..4).map do |i|
    Controls::ID.example i
  end
else
  category, *stream_ids = StreamName.split stream_name
end

writer = EventStore::Messaging::Writer.build

period = ENV['PERIOD']
period ||= 200
period_seconds = Rational(period.to_i, 1000)

loop do
  stream_ids.each do |stream_id|
    message = Controls::Message.example(
      stream_position: stream_position,
      global_position: global_position
    )

    global_position += 1

    stream_name = EventStore::Client::StreamName.stream_name category, stream_id
    expected_version = stream_position - 1

    writer.write message, stream_name, expected_version: expected_version

    sleep period_seconds
  end

  stream_position += 1
end
