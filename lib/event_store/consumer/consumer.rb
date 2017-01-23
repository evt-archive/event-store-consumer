module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object

      cls.class_exec do
        include ::Consumer

        prepend Configure

        extend DispatcherMacro

        extend Start

        dependency :subscription, Subscription
        dependency :dispatcher, Dispatcher
        dependency :messaging_dispatcher, EventStore::Messaging::Dispatcher
      end
    end

    module Configure
      def configure(batch_size: nil, session: nil)
        super if defined? super

        position_store_class = self.class.position_store_class

        unless position_store_class.nil?
          position_store = self.class.position_store_class.configure self, stream.name

          starting_position = position_store.get
        end

        session ||= EventSource::EventStore::HTTP::Session.build

        stream_name = EventSource::EventStore::HTTP::StreamName.canonize stream.name

        messaging_dispatcher = self.class.messaging_dispatcher_class.configure self, attr_name: :messaging_dispatcher
        error_handler = method(:error_raised).to_proc
        Dispatcher.configure(
          self,
          stream_name,
          messaging_dispatcher,
          error_handler: error_handler,
          position_store: position_store,
          position_update_interval: self.class.position_update_interval
        )

        get = EventSource::EventStore::HTTP::Get.build(
          batch_size: Defaults.batch_size,
          long_poll_duration: 1,
          session: session
        )

        subscription = Subscription.configure(
          self,
          stream_name,
          get,
          position: starting_position
        )
        subscription.dispatcher_address = dispatcher.address
      end
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

        Actor::Start.(instance.subscription)
        Actor::Start.(instance.dispatcher)

        return instance, instance.subscription, instance.dispatcher
      end
    end
  end
end
