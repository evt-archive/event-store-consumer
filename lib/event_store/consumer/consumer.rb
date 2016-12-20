module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object

      cls.class_exec do
        include ::Log::Dependency
        include Module

        extend BatchSizeMacro
        extend CategoryMacro
        extend DispatcherMacro
        extend PositionStoreMacro
        extend PositionUpdateIntervalMacro
        extend StreamMacro

        extend Build
        extend Start

        dependency :messaging_dispatcher, EventStore::Messaging::Dispatcher
        dependency :position_store, PositionStore
        dependency :session, EventStore::Client::HTTP::Session

        attr_writer :stream_name

        virtual :configure
        virtual :position_update_interval
      end
    end

    module Module
      def batch_size
        self.class.default_batch_size
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
        @stream_name ||= self.class.stream_name
      end

      def consumer_stream_name
        StreamName.consumer_stream_name stream_name
      end
    end

    module BatchSizeMacro
      def batch_size_macro(size)
        define_singleton_method :default_batch_size do
          size
        end
      end
      alias_method :batch_size, :batch_size_macro

      def default_batch_size
        Defaults.batch_size
      end
    end

    module Build
      def build(stream_name=nil, session: nil)
        instance = new

        instance.stream_name = stream_name if stream_name

        position_store_class.configure instance, instance.stream_name
        messaging_dispatcher_class.configure instance, attr_name: :messaging_dispatcher
        EventStore::Client::HTTP::Session.configure instance, session: session

        instance.configure

        instance
      end
    end

    module CategoryMacro
      def category_macro(category)
        category = Casing::Camel.(category, symbol_to_string: true)

        define_singleton_method :stream_name do
          EventStore::Messaging::StreamName.category_stream_name category
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
      def start(session: nil)
        instance = build session: session

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
