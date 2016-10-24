module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object

      cls.class_exec do
        extend CategoryMacro
        extend StreamMacro
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
