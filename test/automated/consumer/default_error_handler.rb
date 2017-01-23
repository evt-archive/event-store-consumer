require_relative '../automated_init'

context "Consumer Default Error Handler" do
  error = Controls::Error.example

  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example
  end

  consumer = consumer_class.build 'someStrem'

  context "Error handler is actuated" do
    message = Controls::Message.example

    test "Error is reraised" do
      assert proc { consumer.error_raised error, message } do
        raises_error? Controls::Error::Example
      end
    end
  end
end
