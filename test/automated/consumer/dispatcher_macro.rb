require_relative '../automated_init'

context "Consumer Category Macro" do
  consumer_class = Class.new do
    include Consumer

    dispatcher Controls::Messaging::Dispatcher::Example
  end

  context "Consumer is constructed" do
    consumer = consumer_class.build

    test "Dispatcher is configured" do
      assert consumer.dispatcher.instance_of?(Controls::Messaging::Dispatcher::Example)
    end
  end
end
