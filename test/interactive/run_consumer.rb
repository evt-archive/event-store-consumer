require_relative './interactive_init'

module Fixtures
  class Consumer
    include EventStore::Consumer

    stream get_stream_name
    dispatcher Controls::Messaging::Dispatcher::VerifySequence
    position_update_interval 5
  end
end

Actor::Supervisor.run do
  Fixtures::Consumer.start
end
