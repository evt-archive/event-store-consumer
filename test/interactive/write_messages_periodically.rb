require_relative './interactive_init'

stream_name = get_stream_name

stream_position = 0
global_position = 0

if ENV['CATEGORY'] == 'on'
  formatted_stream_name = stream_name.gsub /^\$ce-/, ''

  category = Messaging::StreamName.get_category formatted_stream_name
  stream_ids = (1..4).map do |i|
    Controls::ID.example i
  end
else
  category = Messaging::StreamName.get_category stream_name
  id = Messaging::StreamName.get_id stream_name

  stream_ids = Array(id)
end

write = Messaging::EventStore::Write.build

period = ENV['PERIOD']
period ||= 200
period_seconds = Rational(period.to_i, 1000)

batch_size = 25

logger = Log.get __FILE__

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

    stream_name = ::Messaging::StreamName.stream_name stream_id, category

    write.(batch, stream_name, expected_version: expected_version)

    logger.info "Wrote batch (Stream: #{stream_name}, ExpectedVersion: #{expected_version})"

    sleep period_seconds
  end

  stream_position += batch_size
end
