module EventStore
  module Consumer
    module Controls
      module Messaging
        module Handler
          class Example
            include ::Log::Dependency
            include EventStore::Messaging::Handler

            handle Message::ExampleMessage do |msg|
              logger.info "Handled message (MessageStreamPosition: #{msg.stream_position}, MessageGlobalPosition: #{msg.global_position})"
            end
          end

          class Failure
            include ::Log::Dependency
            include EventStore::Messaging::Handler

            handle Message::ExampleMessage do |msg|
              logger.error "Raising error (MessageStreamPosition: #{msg.stream_position.inspect}, MessageGlobalPosition: #{msg.global_position.inspect})"

              raise Error.example
            end
          end

          class VerifySequence
            include ::Log::Dependency
            include EventStore::Messaging::Handler

            handle Message::ExampleMessage do |msg, event_data|
              log_attributes = "MessageStreamPosition: #{msg.stream_position}, MessageGlobalPosition: #{msg.global_position}, EventDataStreamPosition: #{event_data.number}, EventDataGlobalPosition: #{event_data.position}"

              if event_data.number == msg.stream_position && event_data.position == msg.global_position
                logger.info "Handled message (#{log_attributes})"
              else
                error_message = "Messages out of order #{log_attributes}"
                logger.error error_message
                raise error_message
              end
            end
          end
        end
      end
    end
  end
end
