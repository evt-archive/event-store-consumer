require_relative '../automated_init'

context "Consumer Default Error Handler" do
  error = Controls::Error.example

  consumer_class = Class.new do
    include EventStore::Consumer

    attr_accessor :handled_error

    def handle_error(error)
      self.handled_error = error
    end

    def handled_error?(error)
      handled_error == error
    end
  end
  consumer = consumer_class.new

  context "Error handler is actuated" do
    consumer.handle_error error

    test "Error is handled" do
      assert consumer.handled_error?(error)
    end
  end
end
