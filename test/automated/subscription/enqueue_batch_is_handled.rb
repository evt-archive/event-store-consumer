require_relative '../automated_init'

context "Subscription, EnqueueBatch Message is Handled" do
  message = Controls::Messages::EnqueueBatch.example
  stream_name = Controls::StreamName.example

  dispatcher_address = Controls::Address.example

  subscription = EventStore::Consumer::Subscription.new stream_name
  subscription.dispatcher_address = dispatcher_address

  subscription.handle message

  test "Subscription sends itself GetBatch message" do
    assert subscription.send do
      sent? :get_batch, address: subscription.address
    end
  end

  context "Subscription sends each event data to dispatcher" do
    message.each.with_index do |event_data, index|
      test "Event ##{index}" do
        control_message = Controls::Messages::DispatchEvent.example event_data

        assert subscription.send do
          sent? control_message, address: dispatcher_address
        end
      end
    end
  end
end
