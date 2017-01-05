module EventStore
  module Consumer
    module Controls
      module StreamReader
        module SliceURI
          def self.example(stream_name=nil, only_path: nil, starting_position: nil, slice_size: nil)
            stream_name ||= StreamName.example
            starting_position ||= Position::Initial.example
            slice_size ||= EventStore::Consumer::Subscription::Defaults.batch_size

            path = "/streams/#{stream_name}/#{starting_position}/forward/#{slice_size}"

            if only_path
              path
            else
              settings = EventStore::Client::HTTP::Settings.instance

              port = settings.get(:port)

              ip_address = IPAddress.example

              "http://#{ip_address}:#{port}#{path}"
            end
          end

          IPAddress = EventSource::EventStore::HTTP::Controls::IPAddress
        end
      end
    end
  end
end
