module EventStore
  module Consumer
    module Controls
      module MessagingDispatcher
        module Handler
          class Example
            include EventStore::Messaging::Handler
            include ::Log::Dependency

            handle Message::ExampleMessage do |msg|
              logger.info "Handled message (MessageStreamPosition: #{msg.stream_position}, MessageGlobalPosition: #{msg.global_position})"
            end
          end

          class Failure
            include EventStore::Messaging::Handler
            include ::Log::Dependency

            handle Message::ExampleMessage do |msg|
              logger.error "Raising error (MessageStreamPosition: #{msg.stream_position.inspect}, MessageGlobalPosition: #{msg.global_position.inspect})"

              raise Error.example
            end
          end

          class VerifySequence
            include EventStore::Messaging::Handler
            include ::Log::Dependency

            handle Message::ExampleMessage do |msg, event_data|
              log_attributes = "MessageStreamPosition: #{msg.stream_position}, MessageGlobalPosition: #{msg.global_position}, EventDataStreamPosition: #{event_data.position}, EventDataGlobalPosition: #{event_data.global_position}"

              if event_data.position == msg.stream_position && event_data.global_position == msg.global_position
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
