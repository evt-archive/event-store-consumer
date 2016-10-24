require_relative './script_init'

module Fixtures
  class MessagingDispatcher
    include EventStore::Messaging::Dispatcher

    handler Controls::Messaging::Handler::VerifySequence
  end
end

stream_name = get_stream_name

Actor::Supervisor.run do
  queue = SizedQueue.new 1_000_000
  subscription = Subscription.start stream_name, queue: queue
  dispatcher = Dispatcher.start stream_name, Fixtures::MessagingDispatcher, queue: queue
end
