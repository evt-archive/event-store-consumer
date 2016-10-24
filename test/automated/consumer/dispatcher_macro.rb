require_relative '../automated_init'

context "Consumer Dispatcher Macro" do
  consumer_class = Class.new do
    include Consumer

    dispatcher Controls::Messaging::Dispatcher::Example
    stream :some_stream
  end

  context "Consumer is constructed" do
    consumer = consumer_class.build

    test "Dispatcher dependency is configured to use specfied messaging dispatcher" do
      dispatcher = consumer.dispatcher

      assert dispatcher.messaging_dispatcher.instance_of?(Controls::Messaging::Dispatcher::Example)
    end
  end
end
