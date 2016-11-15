require_relative '../automated_init'

context "Subscription, EnqueueBatch Message is Handled" do
  message = Controls::Subscription::EnqueueBatch.example
  stream_name = Controls::StreamName.example

  dispatcher_address = Controls::Address::Dispatcher.example

  subscription = EventStore::Consumer::Subscription.new stream_name
  subscription.dispatcher_address = dispatcher_address

  subscription.handle message

  test "Subscription writes batch to dispatcher" do
    control_message = Controls::Subscription::Batch.example

    assert subscription.write do
      written? control_message, address: dispatcher_address
    end
  end

  test "Subscription writes itself GetBatch message" do
    control_message = Controls::Subscription::GetBatch.example batch_index: 1

    assert subscription.write do
      written? control_message, address: subscription.address
    end
  end
end
