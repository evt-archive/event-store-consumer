module EventStore
  module Consumer
    module PositionStore
      module Substitute
        def self.build
          PositionStore.new
        end

        class PositionStore
          attr_writer :get_position
          attr_accessor :put_position

          def get
            get_position
          end

          def put(position)
            self.put_position = position
          end

          def get_position
            @get_position ||= :no_stream
          end

          module Assertions
            def put?(position=nil)
              if position.nil?
                put_position ? true : false
              else
                position == put_position
              end
            end
          end
        end
      end
    end
  end
end
