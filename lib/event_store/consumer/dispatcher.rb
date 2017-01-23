module EventStore
  module Consumer
    class Dispatcher
      include Actor
      include Log::Dependency

      attr_writer :error_handler
      attr_writer :position_update_interval

      dependency :messaging_dispatcher, ::EventStore::Messaging::Dispatcher
      dependency :position_store, ::Consumer::PositionStore

      initializer :stream_type

      virtual :configure

      def self.build(stream_name, messaging_dispatcher, error_handler: nil, position_store: nil, position_update_interval: nil)
        stream_type = get_stream_type stream_name

        instance = new stream_type

        instance.messaging_dispatcher = messaging_dispatcher
        instance.error_handler = error_handler if error_handler
        instance.position_store = position_store if position_store
        instance.position_update_interval = position_update_interval

        instance.configure

        instance
      end

      handle Messages::DispatchEvent do |dispatch_event|
        event_data = dispatch_event.event_data

        log_attributes = "#{self.log_attributes}, EventType: #{event_data.type.inspect}"
        logger.trace "Dispatching event (#{log_attributes})"

        dispatch event_data
        update_position event_data

        logger.info "Event dispatched (#{log_attributes})"

        nil
      end

      def dispatch(event_data)
        message = messaging_dispatcher.build_message event_data

        return if message.nil?

        begin
          messaging_dispatcher.dispatch message, event_data
        rescue => error
          _retry = false
          retry_proc = proc { _retry = true }

          if error_handler.arity == 1
            error_handler.(error)
          else
            error_handler.(error, retry_proc)
          end

          retry if _retry
        end
      end

      def update_position(event_data)
        next_starting_position = get_position(event_data) + 1

        if update_position? next_starting_position
          logger.trace "Updating starting position (#{log_attributes}, NextStartingPosition: #{next_starting_position}, PositionUpdateInterval: #{position_update_interval})"

          position_store.put next_starting_position

          logger.debug "Updating starting position (#{log_attributes}, NextStartingPosition: #{next_starting_position}, PositionUpdateInterval: #{position_update_interval})"
        end
      end

      def update_position?(next_starting_position)
        next_starting_position % position_update_interval == 0
      end

      def get_position(event_data)
        if stream_type == :category
          event_data.global_position
        else
          event_data.position
        end
      end

      def error_handler
        @error_handler ||= proc { |error| raise error }
      end

      def position_update_interval
        @position_update_interval ||= Defaults.position_update_interval
      end

      def digest
        "#{self.class}[dispatcher=#{messaging_dispatcher.class}, streamType=#{stream_type}]"
      end

      def log_attributes
        "Dispatcher: #{messaging_dispatcher.class.name}"
      end

      def self.get_stream_type(stream_name)
        if StreamName.category? stream_name
          :category
        else
          :stream
        end
      end

      module Assertions
        def dispatched?(event_data)
          messaging_dispatcher.dispatched?(event_data)
        end
      end
    end
  end
end
