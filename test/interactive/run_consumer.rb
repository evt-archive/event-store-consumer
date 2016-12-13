require_relative './interactive_init'

module Fixtures
  class Consumer
    include EventStore::Consumer

    stream get_stream_name
    dispatcher Controls::MessagingDispatcher::VerifySequence
    position_update_interval 5
  end

  class Process
    include ProcessHost::Process

    def start
      Consumer.start
    end
  end
end

ProcessHost.start 'interactive-consumer' do
  record_error do |error|
    puts "Error: #{error}"
  end

  register Fixtures::Process
end
