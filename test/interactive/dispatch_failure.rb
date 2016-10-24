require_relative './interactive_init'

stream_name = get_stream_name

Actor::Supervisor.run do
  queue = SizedQueue.new 1_000_000
  subscription = Subscription.start stream_name, queue: queue
  dispatcher = Dispatcher.start(
    stream_name,
    Controls::Messaging::Dispatcher::Failure,
    queue: queue
  )
end
