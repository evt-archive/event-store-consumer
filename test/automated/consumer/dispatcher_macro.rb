require_relative '../automated_init'

context "Consumer Dispatcher Macro" do
  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
  end

  consumer, _ = consumer_class.build 'someStream'

  dispatch = consumer.dispatch

  test "Dispatch hanlder registry includes an instance of the dispatcher" do
    dispatcher = dispatch.handler_registry.entries.find do |handle|
      handle.is_a? EventStore::Consumer::Dispatcher and
        handle.is_a? Controls::MessagingDispatcher::Example
    end

    assert dispatcher
  end
end
