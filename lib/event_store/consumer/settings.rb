module EventStore
  class Consumer
    class Settings < ::Settings
      configure :settings

      def self.data_source
        'settings/event_store_consumer.json'
      end

      def self.instance
        @instance ||= build
      end

      def self.get(setting)
        instance.get setting
      end

      def self.set(receiver)
        instance.set receiver
      end
    end
  end
end
