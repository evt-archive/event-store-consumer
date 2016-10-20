module EventStore
  module Consumer
    module Controls
      module StreamReader
        module StartPath
          def self.example(stream_name=nil, starting_position: nil)
            SliceURI.example(
              stream_name,
              starting_position: starting_position,
              only_path: true
            )
          end
        end
      end
    end
  end
end
