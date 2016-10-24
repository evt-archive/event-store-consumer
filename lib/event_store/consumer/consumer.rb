module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object

      cls.class_exec do
        extend CategoryMacro
        extend Build
        extend DispatcherMacro
        extend StreamMacro

        dependency :dispatcher, EventStore::Messaging::Dispatcher
      end
    end

    def stream_name
      self.class.stream_name
    end

    def consumer_stream_name
      StreamName.consumer_stream_name stream_name
    end

    module CategoryMacro
      def category_macro(category)
        category = Casing::Camel.(category, symbol_to_string: true)

        define_singleton_method :stream_name do
          EventStore::Client::StreamName.category_stream_name category
        end
      end
      alias_method :category, :category_macro
    end

    module Build
      def build
        instance = new
        dispatcher_class.configure instance
        instance
      end
    end

    module DispatcherMacro
      def dispatcher_macro(dispatcher_class)
        define_singleton_method :dispatcher_class do
          dispatcher_class
        end
      end
      alias_method :dispatcher, :dispatcher_macro
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
