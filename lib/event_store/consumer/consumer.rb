module EventStore
  module Consumer
    def self.included(cls)
      cls.class_exec do
        include ::Consumer::EventStore

        extend DispatcherMacro
      end
    end

    module DispatcherMacro
      def dispatcher_macro(dispatcher_class)
        dispatcher = dispatcher_class.build
        dispatcher.extend Dispatcher

        handle dispatcher
      end
      alias_method :dispatcher, :dispatcher_macro
    end
  end
end
