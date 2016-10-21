module EventStore
  module Consumer
    module StreamName
      extend self

      def consumer_stream_name(stream_name)
        if category? stream_name
          category, _ = split stream_name
          "#{category}:consumer"
        else
          category, stream_id = split stream_name

          "#{category}:consumer-#{stream_id}"
        end
      end

      def split(stream_name)
        if category? stream_name
          category = stream_name.gsub /^\$ce-/, ''
          stream_id = nil
        else
          category, stream_id = stream_name.split '-', 2
        end

        return category, stream_id
      end

      def category?(stream_name)
        stream_name.start_with? '$ce-'
      end
    end
  end
end
