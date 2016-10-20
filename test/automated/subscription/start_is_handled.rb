require_relative '../automated_init'

context "Subcription, Start Message is Handled" do
  message = Actor::Messages::Start.new
  stream_name = Controls::StreamName.example

  subscription = EventStore::Consumer::Subscription.new stream_name
end
