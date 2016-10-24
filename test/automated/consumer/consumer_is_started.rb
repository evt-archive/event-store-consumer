require_relative '../automated_init'

context "Consumer is Started" do
  consumer_class = Controls::Consumer::Example

  consumer = consumer_class.build

  subscription, dispatcher = consumer.start

  test "Session is supplied to subscription" do
    assert subscription.session == consumer.session
  end

  test "Queue is supplied to subscription" do
    assert subscription.queue == consumer.queue
  end

  test "Queue is supplied to dispatcher" do
    assert dispatcher.queue == consumer.queue
  end
end
