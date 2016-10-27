module EventStore
  module Consumer
    module Defaults
      def self.batch_size
        batch_size = ENV['CONSUMER_DEFAULT_BATCH_SIZE']

        return batch_size.to_i if batch_size

        100
      end

      def self.position_update_interval
        position_update_interval = ENV['CONSUMER_POSITION_UPDATE_INTERVAL']

        return position_update_interval.to_i if position_update_interval

        batch_size
      end

      def self.queue_size
        queue_size = ENV['CONSUMER_DEFAULT_QUEUE_SIZE']

        return queue_size.to_i if queue_size

        1_000
      end
    end
  end
end
