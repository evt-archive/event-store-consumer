require_relative '../automated_init'

context "Consumer Queue Size Macro" do
  consumer_class = Class.new do
    include Consumer

    queue_size 111
    dispatcher Controls::Messaging::Dispatcher::Example
    stream :some_stream
  end

  consumer = consumer_class.build

  test "Queue size is used to construct sized queue" do
    assert consumer.queue.instance_of?(SizedQueue)
    assert consumer.queue.max == 111
  end
end
