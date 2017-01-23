require_relative '../automated_init'

context "Consumer Position Update Interval Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
    position_update_interval 111
  end

  consumer = consumer_class.build 'someStream'

  context "Consumer is started" do
    subscription, dispatcher = consumer.start

    test "Position update interval is set on dispatcher dependency" do
      assert dispatcher.position_update_interval == 111
    end
  end
end
