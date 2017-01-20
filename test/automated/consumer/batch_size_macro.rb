require_relative '../automated_init'

context "Consumer Batch Size Macro" do
  consumer_class = Class.new do
    include Consumer

    batch_size 11
    dispatcher Controls::MessagingDispatcher::Example
    stream :some_stream
  end

  consumer = consumer_class.build

  subscription, _ = consumer.start

  test "Batch size is supplied to get" do
    assert subscription.get.batch_size == 11
  end
end
