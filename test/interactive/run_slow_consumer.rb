require_relative './interactive_init'

module Fixtures
  class Consumer
    include EventStore::Consumer

    stream get_stream_name
    position_update_interval 1000

    class Handler
      include Log::Dependency
      include EventStore::Messaging::Handler

      handle Controls::Message::ExampleMessage do |msg|
        logger.info "Handled message (MessageStreamPosition: #{msg.stream_position}, MessageGlobalPosition: #{msg.global_position})"

        delay
      end

      def delay
        sleep Defaults.delay_seconds
      end

      module Defaults
        def self.delay_milliseconds
          duration = ENV['DELAY_MILLISECONDS']

          if duration
            duration.to_i
          else
            10
          end
        end

        def self.delay_seconds
          @delay_seconds ||= Rational(delay_milliseconds, 1000)
        end
      end
    end

    class Dispatcher
      include EventStore::Messaging::Dispatcher

      handler Handler
    end
    dispatcher Dispatcher
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
