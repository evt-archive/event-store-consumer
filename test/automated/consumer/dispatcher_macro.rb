require_relative '../automated_init'

context "Consumer Dispatcher Macro" do
  consumer_class = Class.new do
    include Consumer

    dispatcher Controls::Messaging::Dispatcher::Example
    stream :some_stream
  end

  context "Consumer is started" do
    _, _, dispatcher = consumer_class.start

    test "Dispatcher dependency is configured to use specfied messaging dispatcher" do
      assert dispatcher.messaging_dispatcher.instance_of?(Controls::Messaging::Dispatcher::Example)
    end
  end
end
