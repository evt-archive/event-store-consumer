require_relative '../automated_init'

context "Consumer Position Store Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
    position_store Controls::PositionStore::Example
  end

  consumer = consumer_class.build 'someStream'

  context "Consumer is started" do
    subscription, dispatcher = consumer.start

    test "Dispatcher dependency is configured to use specfied position store" do
      assert dispatcher.position_store.instance_of?(Controls::PositionStore::Example)
    end

    test "Subscription dependency is configured to use specfied position store" do
      assert dispatcher.position_store.instance_of?(Controls::PositionStore::Example)
    end
  end
end
