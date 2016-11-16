require_relative '../automated_init'

context "Dispatcher, Error is Raised While Dispatching Event" do
  message = Controls::Messages::DispatchEvent.example

  context "Error handler is not specified" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream

    Controls::MessagingDispatcher::Failure.configure dispatcher, attr_name: :messaging_dispatcher

    test "Error is not rescued" do
      assert proc { dispatcher.handle message } do
        raises_error? Controls::Error::Example
      end
    end
  end

  context "Error handler is specified" do
    error = nil

    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.error_handler = lambda { |_error| error = _error }

    Controls::MessagingDispatcher::Failure.configure dispatcher, attr_name: :messaging_dispatcher

    dispatcher.handle message

    test "Error handler is actuated" do
      assert error.instance_of?(Controls::Error::Example)
    end
  end

  context "Specified error handler retries" do
    retry_count = 0

    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.error_handler = proc { |_, retry_dispatch|
      retry_count += 1
      retry_dispatch.() unless retry_count == 3

      fail if retry_count == 4
    }

    Controls::MessagingDispatcher::Failure.configure dispatcher, attr_name: :messaging_dispatcher

    dispatcher.handle message

    test "Dispatcher is retried" do
      assert retry_count == 3
    end
  end
end
