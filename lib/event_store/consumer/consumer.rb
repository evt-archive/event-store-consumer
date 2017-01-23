module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object

      cls.class_exec do
        include ::Log::Dependency

        extend ::Consumer::Build
        extend ::Consumer::Run

        extend ::Consumer::PositionStoreMacro

        prepend Configure

        initializer :stream

        attr_writer :position_update_interval

        attr_accessor :cycle_timeout_milliseconds
        attr_accessor :cycle_maximum_milliseconds

        dependency :position_store, ::Consumer::PositionStore


        extend Start

        include Module

        extend DispatcherMacro

        dependency :subscription, Subscription
        dependency :dispatcher, Dispatcher
        dependency :messaging_dispatcher, EventStore::Messaging::Dispatcher
        dependency :session, EventSource::EventStore::HTTP::Session

        attr_writer :stream_name
      end
    end

    def error_raised(error, _)
      raise error
    end

    def position_update_interval
      @position_update_interval ||= self.class.position_update_interval
    end

    module Configure
      def configure(batch_size: nil, session: nil)
        super if defined? super

        position_store_class = self.class.position_store_class

        unless position_store_class.nil?
          position_store = self.class.position_store_class.configure self, stream.name

          starting_position = position_store.get
        end

        session = EventSource::EventStore::HTTP::Session.configure self, session: session

        messaging_dispatcher = self.class.messaging_dispatcher_class.configure self, attr_name: :messaging_dispatcher
        error_handler = method(:error_raised).to_proc
        Dispatcher.configure(
          self,
          stream_name,
          messaging_dispatcher,
          error_handler: error_handler,
          position_store: position_store,
          position_update_interval: position_update_interval
        )

        Subscription.configure(
          self,
          stream_name,
          dispatcher.address,
          batch_size: batch_size,
          session: session,
          position_store: position_store
        )
      end
    end

    module Module
      def start
        logger.trace "Starting consumer (StreamName: #{stream_name}, Dispatcher: #{messaging_dispatcher.class})"

        Actor::Start.(dispatcher)
        Actor::Start.(subscription)

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

    module Start
      def start(stream_name, **arguments, &probe)
        instance = build stream_name, **arguments

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
