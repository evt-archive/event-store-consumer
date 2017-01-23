require_relative '../automated_init'

context "Consumer Position Store Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
    position_store Controls::PositionStore::Example
  end

  consumer = consumer_class.build 'someStream'

  test "Dispatcher dependency is configured to use specfied position store" do
    assert consumer.dispatcher.position_store.instance_of?(Controls::PositionStore::Example)
  end

  test "Subscription dependency is configured to use specfied position store" do
    assert consumer.subscription.position_store.instance_of?(Controls::PositionStore::Example)
  end
end
