require_relative '../automated_init'

context "Consumer Error Handler" do
  error = Controls::Error.example

  consumer_class = Class.new do
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::Example

    attr_accessor :handled_error

    def error_raised(error)
      self.handled_error = error
    end

    def handled_error?(error)
      handled_error == error
    end
  end

  context "Consumer is started" do
    consumer, _, dispatcher = consumer_class.start 'someStream'

    test "Error handler is supplied to dispatcher" do
      dispatcher.error_handler.(error)

      assert consumer.handled_error?(error)
    end
  end
end
