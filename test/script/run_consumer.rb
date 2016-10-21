require_relative './script_init'

module Fixtures
  class MessagingDispatcher
    include EventStore::Messaging::Dispatcher

    class Handler
      include ::Log::Dependency
      include EventStore::Messaging::Handler

      handle Controls::Message::ExampleMessage do |msg, event_data|
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
    handler Handler
  end
end

stream_name = get_stream_name

Actor::Supervisor.run do
  queue = SizedQueue.new 1_000_000
  subscription = Subscription.start stream_name, queue: queue
  dispatcher = Dispatcher.start stream_name, Fixtures::MessagingDispatcher, queue: queue
end
