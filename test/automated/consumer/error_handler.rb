require_relative '../automated_init'

context "Consumer Error Handler" do
  error = Controls::Error.example

  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::Messaging::Dispatcher::Example
    stream :some_stream

    attr_accessor :handled_error

    def handle_error(error)
      self.handled_error = error
    end

    def handled_error?(error)
      handled_error == error
    end
  end

  context "Consumer is constructed" do
    consumer = consumer_class.build

    dispatcher = consumer.dispatcher

    test "Error handler is supplied to dispatcher" do
      dispatcher.error_handler.(error)

      assert consumer.handled_error?(error)
    end
  end
end
