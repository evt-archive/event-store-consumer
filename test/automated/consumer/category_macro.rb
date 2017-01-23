require_relative '../automated_init'

context "Consumer Category Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
  end

  consumer = consumer_class.build 'someCategory'

  test "Specified value is converted to a camel cased category stream name" do
    assert consumer.stream_name == '$ce-someCategory'
  end

  test "Consumer stream name does not include EventStore category projection prefix" do
    assert consumer.consumer_stream_name == 'someCategory:consumer'
  end
end
