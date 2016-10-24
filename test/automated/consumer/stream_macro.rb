require_relative '../automated_init'

context "Consumer Stream Macro" do
  context "Category is specified" do
    consumer_class = Class.new do
      include Consumer

      category :some_category
    end

    consumer = consumer_class.new

    test "Specified value is converted to a camel cased category stream name" do
      assert consumer.stream_name == '$ce-someCategory'
    end

    test "Consumer stream name does not include EventStore category projection prefix" do
      assert consumer.consumer_stream_name == 'someCategory:consumer'
    end
  end

  context "Singleton stream is specified" do
    consumer_class = Class.new do
      include Consumer

      stream :some_stream
    end

    consumer = consumer_class.new

    test "Specified value is converted to a camel cased stream name" do
      assert consumer.stream_name == 'someStream'
    end

    test "Consumer stream name" do
      assert consumer.consumer_stream_name == 'someStream:consumer'
    end
  end

  context "Stream is specified" do
    consumer_class = Class.new do
      include Consumer

      stream 'someStream-1'
    end

    consumer = consumer_class.new

    test "Specified value is converted to a camel cased stream name" do
      assert consumer.stream_name == 'someStream-1'
    end

    test "Consumer stream name" do
      assert consumer.consumer_stream_name == 'someStream:consumer-1'
    end
  end
end
