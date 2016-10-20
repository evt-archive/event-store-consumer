module EventStore
  module Consumer
    module Controls
      module StreamReader
        module SliceURI
          def self.example(stream_name=nil, only_path: nil, starting_position: nil, slice_size: nil)
            stream_name ||= StreamName.example
            starting_position ||= Position::Initial.example
            slice_size ||= Consumer::Subscription::Defaults.batch_size

            path = "/streams/#{stream_name}/#{starting_position}/forward/#{slice_size}"

            if only_path
              path
            else
              settings = EventStore::Client::HTTP::Settings.instance

              host, port = settings.get(:host), settings.get(:port)

              "http://#{host}:#{port}#{path}"
            end
          end
        end
      end
    end
  end
end
