module EventStore
  module Consumer
    class Dispatcher
      include Actor
      include Log::Dependency

      initializer :dispatcher

      attr_writer :queue

      handle Actor::Messages::Start do
        GetBatch.new
      end

      def queue
        @queue ||= Queue.new
      end
    end
  end
end
