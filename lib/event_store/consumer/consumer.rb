module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object

      cls.class_exec do
        include ::Log::Dependency
        include Module

        extend DispatcherMacro
        extend PositionStoreMacro
        extend PositionUpdateIntervalMacro

        extend ::Consumer::Build
        extend Start

        initializer :stream

        attr_accessor :cycle_timeout_milliseconds
        attr_accessor :cycle_maximum_milliseconds

        dependency :messaging_dispatcher, EventStore::Messaging::Dispatcher
        dependency :position_store, PositionStore
        dependency :session, EventSource::EventStore::HTTP::Session

        attr_writer :stream_name

        virtual :position_update_interval
      end
    end

    def configure(batch_size: nil, session: nil)
      self.batch_size = batch_size

      self.class.position_store_class.configure self, stream.name

      EventSource::EventStore::HTTP::Session.configure self, session: session

      self.class.messaging_dispatcher_class.configure self, attr_name: :messaging_dispatcher
    end

    module Module
      attr_writer :batch_size

      def batch_size
        @batch_size ||= Defaults.batch_size
      end

      def handle_error(error)
        raise error
      end

      def start
        logger.trace "Starting consumer (StreamName: #{stream_name}, Dispatcher: #{messaging_dispatcher.class})"

        error_handler = method(:handle_error).to_proc

        dispatcher_address, dispatcher = Dispatcher.start(
          stream_name,
          messaging_dispatcher,
          error_handler: error_handler,
          position_store: position_store,
          position_update_interval: position_update_interval,
          include: :actor
        )

        _, subscription = Subscription.start(
          stream_name,
          dispatcher_address,
          batch_size: batch_size,
          session: session,
          position_store: position_store,
          include: :actor
        )

        logger.info "Consumer started (StreamName: #{stream_name}, Dispatcher: #{messaging_dispatcher.class})"

        return subscription, dispatcher
      end

      def stream_name
        @stream_name ||= EventSource::EventStore::HTTP::StreamName.canonize stream.name
      end

      def consumer_stream_name
        StreamName.consumer_stream_name stream_name
      end
    end

    module CategoryMacro
      def category_macro(category)
        category = Casing::Camel.(category, symbol_to_string: true)

        define_singleton_method :stream_name do
          EventSource::EventStore::HTTP::StreamName.category_stream_name category
        end
      end
      alias_method :category, :category_macro
    end

    module DispatcherMacro
      def dispatcher_macro(dispatcher_class)
        define_singleton_method :messaging_dispatcher_class do
          dispatcher_class
        end
      end
      alias_method :dispatcher, :dispatcher_macro
    end

    module PositionStoreMacro
      attr_writer :position_store_class

      def position_store_macro(position_store_class)
        self.position_store_class = position_store_class
      end
      alias_method :position_store, :position_store_macro

      def position_store_class
        @position_store_class ||= PositionStore::ConsumerStream
      end
    end

    module PositionUpdateIntervalMacro
      def position_update_interval_macro(interval)
        define_method :position_update_interval do
          interval
        end
      end
      alias_method :position_update_interval, :position_update_interval_macro
    end

    module Start
      def start(stream_name, session: nil)
        instance = build stream_name, session: session

        actors = instance.start

        return instance, *actors
      end
    end

    module StreamMacro
      def stream_macro(stream)
        stream = Casing::Camel.(stream, symbol_to_string: true)

        define_singleton_method :stream_name do
          stream
        end
      end
      alias_method :stream, :stream_macro
    end
  end
end
