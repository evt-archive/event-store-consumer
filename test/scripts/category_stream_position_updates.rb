require_relative './scripts_init'

event_count = [ENV['EVENT_COUNT'].to_i, 4].max

category_id = Identifier::UUID::Random.get.gsub '-', ''
category = "categoryStreamPositionUpdatesTest#{category_id}"
category_stream = EventStore::Client::StreamName.category_stream_name category

# Instantiate the reader before the category stream exists to make sure it
# "picks up" the creation of the category stream.
stream_metadata_reader = EventStore::Client::HTTP::StreamMetadata::Read.build category_stream

# Write three event_count to three different streams in the same category
event_count.times do |stream_id|
  stream_name = EventStore::Consumer::Controls::StreamName.get category, stream_id, random: false
  EventStore::Consumer::Controls::Writer.write stream_name
end

# Start a consumer, probing the recorded stream position after every message
consumer = EventStore::Consumer.build category_stream, EventStore::Consumer::Controls::Dispatcher::SomeDispatcher

recorded_positions = {}

count = 0
consumer.start do |_, event_data|
  metadata = stream_metadata_reader.()
  fail "No metadata found" if metadata.nil?

  position = metadata.fetch :consumer_position
  recorded_positions[event_data.position] = position

  __logger.focus "Read event at position #{event_data.position}; recorded position is #{position}"

  count += 1
  break if count == event_count
end

assert recorded_positions[0] == 0
assert recorded_positions[1] == 0
assert recorded_positions[2] == 0
assert recorded_positions[3] == 3
