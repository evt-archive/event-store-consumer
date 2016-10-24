require_relative '../automated_init'

context "Consumer Stream Name" do
  context "Consumer stream name is resolved for a stream" do
    stream_name = Controls::StreamName.example

    consumer_stream_name = StreamName.consumer_stream_name stream_name

    test "Consumer stream name is returned" do
      assert consumer_stream_name == Controls::StreamName::Consumer.example
    end
  end

  context "Consumer stream name is resolved for a singleton stream" do
    stream_name = Controls::StreamName::Singleton.example

    consumer_stream_name = StreamName.consumer_stream_name stream_name

    test "Consumer stream name is returned" do
      assert consumer_stream_name == Controls::StreamName::Singleton::Consumer.example
    end
  end

  context "Consumer stream name is resolved for a category stream" do
    category_stream_name = Controls::StreamName::Category.example

    consumer_stream_name = StreamName.consumer_stream_name category_stream_name

    test "Consumer stream name is returned" do
      assert consumer_stream_name == Controls::StreamName::Category::Consumer.example
    end
  end
end
