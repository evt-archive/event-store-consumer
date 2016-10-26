require_relative '../automated_init'

context "Consumer Default Error Handler" do
  error = Controls::Error.example

  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::Messaging::Dispatcher::Example
  end

  consumer = consumer_class.build

  context "Error handler is actuated" do
    test "Error is reraised" do
      assert proc { consumer.handle_error error } do
        raises_error? Controls::Error::Example
      end
    end
  end
end
