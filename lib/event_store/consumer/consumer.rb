module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object

      cls.class_exec do
        include ::Consumer

        prepend Configure

        extend DispatcherMacro

        extend Start
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

        get = EventSource::EventStore::HTTP::Get.build(
          batch_size: Defaults.batch_size,
          long_poll_duration: 1,
          session: session
        )

        stream_name = EventSource::EventStore::HTTP::StreamName.canonize stream.name
        subscription = Subscription.configure(
          self,
          stream_name,
          get,
          position: starting_position
        )

        messaging_dispatcher = self.class.messaging_dispatcher_class.build
        Dispatch.configure self, messaging_dispatcher
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

        ::Consumer::Actor.start instance, instance.subscription
        Actor::Start.(instance.subscription)

        return instance, instance.subscription
      end
    end
  end
end
