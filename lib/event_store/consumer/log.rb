module EventStore
  module Consumer
    class Log < ::Log
      def tag!(tags)
        tags << :event_store_consumer
        tags << :consumer
        tags << :verbose
      end
    end
  end
end
