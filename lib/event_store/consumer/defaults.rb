module EventStore
  module Consumer
    module Defaults
      def self.batch_size
        batch_size = ENV['CONSUMER_BATCH_SIZE']

        return batch_size.to_i if batch_size

        20
      end

      def self.dispatcher_queue_depth_limit
        queue_depth_limit = ENV['CONSUMER_DISPATCHER_QUEUE_DEPTH_LIMIT']

        return queue_depth_limit.to_i if queue_depth_limit

        Rational(batch_size, 3).to_i
      end

      def self.no_stream_delay_duration_seconds
        ms = no_stream_delay_duration_milliseconds

        Rational(ms, 1000)
      end

      def self.no_stream_delay_duration_milliseconds
        no_stream_delay_duration = ENV['CONSUMER_NO_STREAM_DELAY_DURATION']

        return no_stream_delay_duration.to_i if no_stream_delay_duration

        100
      end

      def self.cycle_maximum_milliseconds
        long_poll_duration = ENV['LONG_POLL_DURATION']

        return long_poll_duration.to_i * 1000 if long_poll_duration

        1_000
      end

      def self.position_update_interval
        position_update_interval = ENV['CONSUMER_POSITION_UPDATE_INTERVAL']

        return position_update_interval.to_i if position_update_interval

        batch_size
      end
    end
  end
end
