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

batch_size = 25

loop do
  stream_ids.each do |stream_id|
    expected_version = stream_position - 1

    batch = (0...batch_size).map do |index|
      pos = stream_position + index

      message = Controls::Message.example(
        stream_position: pos,
        global_position: global_position
      )

      global_position += 1

      message
    end

    stream_name = EventStore::Messaging::StreamName.stream_name stream_id, category

    writer.write batch, stream_name, expected_version: expected_version

    sleep period_seconds
  end

  stream_position += batch_size
end
