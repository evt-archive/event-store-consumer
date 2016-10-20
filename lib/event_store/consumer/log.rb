module EventStore
  module Consumer
    class Log < ::Log
      def tag!(tags)
        tags << :consumer
        tags << :verbose
      end
    end
  end
end
