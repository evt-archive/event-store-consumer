require_relative '../automated_init'

context "Consumer Dispatcher Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
  end

  context "Consumer is started" do
    consumer, _ = consumer_class.start 'someStream'

    dispatcher = consumer.dispatch

    test "Dispatcher dependency is configured to use specfied messaging dispatcher" do
      assert dispatcher.messaging_dispatcher.instance_of?(Controls::MessagingDispatcher::Example)
    end
  end
end
