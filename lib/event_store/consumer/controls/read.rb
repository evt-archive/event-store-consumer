module EventStore
  module Consumer
    module Controls
      module Read
        def self.call(stream_name, precedence=nil, &action)
          EventSource::EventStore::HTTP::Read.(
            stream_name,
            precedence: precedence,
            batch_size: 1,
            &action
          )
        end
      end
    end
  end
end
