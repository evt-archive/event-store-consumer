ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_COLOR'] ||= 'on'
ENV['LOG_TAGS'] ||= 'consumer'

ENV['LOGGER'] ||= 'off'

if ENV['LOGGER'] == 'on'
  ENV['LOG_LEVEL'] ||= 'trace'
else
  ENV['LOG_LEVEL'] ||= 'fatal'
end

puts RUBY_DESCRIPTION

require 'pp'
require_relative '../init.rb'

require 'test_bench'; TestBench.activate

require 'event_store/consumer/controls'

require 'process_host'

include EventStore::Consumer

Consumer = EventStore::Consumer

Telemetry::Logger::AdHoc.activate
