require_relative '../automated_init'

context "Dispatcher, Error is Raised While Handling ProcessBatch" do
  message = Controls::Dispatcher::ProcessBatch.example

  context "Error handler is not specified" do
    dispatcher = EventStore::Consumer::Dispatcher.new :stream

    Controls::Subscription::Batch.enqueue dispatcher.queue
    Controls::Messaging::Dispatcher::Failure.configure dispatcher

    test "Error is not rescued" do
      assert proc { dispatcher.handle message } do
        raises_error? Controls::Error::Example
      end
    end
  end

  context "Error handler is specified" do
    error = nil

    dispatcher = EventStore::Consumer::Dispatcher.new :stream
    dispatcher.error_handler = proc { |_error| error = _error }

    Controls::Subscription::Batch.enqueue dispatcher.queue
    Controls::Messaging::Dispatcher::Failure.configure dispatcher

    dispatcher.handle message

    test "Error handler is actuated" do
      assert error.instance_of?(Controls::Error::Example)
    end
  end
end
