require_relative '../automated_init'

context "Consumer Dispatcher Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
  end

  context "Consumer is started" do
    _, _, dispatcher = consumer_class.start 'someStream'

    test "Dispatcher dependency is configured to use specfied messaging dispatcher" do
      assert dispatcher.messaging_dispatcher.instance_of?(Controls::MessagingDispatcher::Example)
    end
  end
end
