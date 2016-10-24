require_relative '../automated_init'

context "Consumer Category Macro" do
  consumer_class = Class.new do
    include Consumer

    category :some_category
  end

  consumer = consumer_class.build

  test "Specified value is converted to a camel cased category stream name" do
    assert consumer.stream_name == '$ce-someCategory'
  end

  test "Consumer stream name does not include EventStore category projection prefix" do
    assert consumer.consumer_stream_name == 'someCategory:consumer'
  end
end
