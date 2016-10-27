ENV['LONG_POLL_DURATION'] ||= '1'

ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_COLOR'] ||= 'on'
ENV['LOG_LEVEL'] ||= 'trace'

puts RUBY_DESCRIPTION

require 'pp'
require_relative '../init.rb'

require 'test_bench'; TestBench.activate

require 'event_store/consumer/controls'
require_relative './fixtures/fixtures_init'

include EventStore::Consumer

Consumer = EventStore::Consumer
