module EventStore
  module Consumer
    module StreamName
      extend self

      def consumer_stream_name(stream_name)
        if category? stream_name
          category = stream_name.gsub /^\$ce-/, ''
          "#{category}:consumer"
        else
          category, stream_id = stream_name.split '-', 2

          "#{category}:consumer-#{stream_id}"
        end
      end

      def category?(stream_name)
        stream_name.start_with? '$ce-'
      end
    end
  end
end
