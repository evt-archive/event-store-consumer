module EventStore
  module Consumer
    module StreamName
      extend self

      def consumer_stream_name(stream_name)
        category, stream_id = stream_name.split '-', 2

        if category == '$ce'
          category = stream_id
          "#{category}:consumer"
        else
          category = "#{category}:consumer"
          EventStore::Client::StreamName.stream_name category, stream_id
        end
      end
    end
  end
end
