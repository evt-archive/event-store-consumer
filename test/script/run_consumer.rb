require_relative './script_init'

module Fixtures
  class Consumer
    include EventStore::Consumer

    stream get_stream_name
    dispatcher Controls::Messaging::Dispatcher::VerifySequence
  end
end

Actor::Supervisor.run do
  Fixtures::Consumer.start
end
