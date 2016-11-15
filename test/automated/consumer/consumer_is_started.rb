require_relative '../automated_init'

context "Consumer is Started" do
  consumer_class = Controls::Consumer::Example

  consumer = consumer_class.build

  subscription, dispatcher = consumer.start

  test "Session is supplied to subscription" do
    assert subscription.session == consumer.session
  end

  test "Subscription is supplied address of dispatcher" do
    assert subscription.dispatcher_address == dispatcher.address
  end
end
