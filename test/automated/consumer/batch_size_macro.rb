require_relative '../automated_init'

context "Consumer Batch Size Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    batch_size 11
    dispatcher Controls::MessagingDispatcher::Example
  end

  consumer = consumer_class.build 'someStream'

  subscription, _ = consumer.start

  test "Batch size is supplied to get" do
    assert subscription.get.batch_size == 11
  end
end
