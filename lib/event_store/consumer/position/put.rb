module EventStore
  module Consumer
    module Position
      class Put
        include Log::Dependency

        configure :put_position

        initializer :stream_name

        dependency :session, EventStore::Client::HTTP::Session
        dependency :writer, EventStore::Messaging::Writer

        def self.build(stream_name, session: nil)
          consumer_stream_name = StreamName.consumer_stream_name stream_name

          instance = new consumer_stream_name
          instance.configure session: session
          instance
        end

        def self.call(stream_name, position, session: nil)
          instance = build stream_name, session: session
          instance.(position)
        end

        def configure(session: nil)
          session = EventStore::Client::HTTP::Session.configure self, session: session

          EventStore::Messaging::Writer.configure self, session: session
        end

        def call(position)
          log_attributes = "StreamName: #{stream_name}, Position: #{position}"
          logger.trace "Putting position (#{log_attributes})"

          message = ConsumerUpdated.build
          message.position = position

          writer.write message, stream_name

          logger.debug "Put position done (#{log_attributes})"

          message
        end

        module Substitute
          def self.build
            Put.new
          end

          class Put
            attr_accessor :position

            def call(position)
              self.position = position
            end

            module Assertions
              def put?(position=nil)
                if position.nil?
                  self.position ? true : false
                else
                  self.position == position
                end
              end
            end
          end
        end
      end
    end
  end
end
