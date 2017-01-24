require_relative './interactive_init'

module Fixtures
  class Consumer
    include EventStore::Consumer

    dispatcher Controls::MessagingDispatcher::VerifySequence
    position_store ::EventStore::Consumer::PositionStore::ConsumerStream, update_interval: 5
  end

  class Process
    include ProcessHost::Process

    def start
      stream = get_stream_name
      Consumer.start stream
    end
  end
end

ProcessHost.start 'interactive-consumer' do
  record_error do |error|
    puts "Error: #{error}"
  end

  register Fixtures::Process
end
