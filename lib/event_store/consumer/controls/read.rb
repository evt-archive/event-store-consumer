module EventStore
  module Consumer
    module Controls
      module Read
        def self.call(stream_name, direction=nil, &action)
          reader = EventStore::Client::HTTP::Reader.build(
            stream_name,
            direction: direction,
            slice_size: 1
          )

          reader.each &action
        end
      end
    end
  end
end
