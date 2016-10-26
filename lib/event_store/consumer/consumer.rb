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
        extend StreamMacro
        extend QueueSizeMacro

        extend Build
        extend Start

        dependency :messaging_dispatcher, EventStore::Messaging::Dispatcher
        dependency :session, EventStore::Client::HTTP::Session

        attr_writer :stream_name

        initializer :queue
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

        _, subscription = Subscription.start(
          stream_name,
          batch_size: batch_size,
          queue: queue,
          session: session,
          include: :actor
        )

        _, dispatcher = Dispatcher.start(
          stream_name,
          messaging_dispatcher,
          error_handler: error_handler,
          queue: queue,
          include: :actor,
          position_store: position_store_class
        )

        logger.info "Consumer started (StreamName: #{stream_name}, Dispatcher: #{messaging_dispatcher.class})"

        return subscription, dispatcher
      end

      def position_store_class
        self.class.position_store_class
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
        queue = SizedQueue.new default_queue_size

        instance = new queue
        instance.stream_name = stream_name if stream_name
        messaging_dispatcher_class.configure instance, attr_name: :messaging_dispatcher
        EventStore::Client::HTTP::Session.configure instance, session: session
        instance
      end
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

    module QueueSizeMacro
      def queue_size_macro(size)
        define_singleton_method :default_queue_size do
          size
        end
      end
      alias_method :queue_size, :queue_size_macro

      def default_queue_size
        Defaults.queue_size
      end
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

    module Defaults
      def self.batch_size
        batch_size = ENV['CONSUMER_DEFAULT_BATCH_SIZE']

        return batch_size.to_i if batch_size

        100
      end

      def self.queue_size
        queue_size = ENV['CONSUMER_DEFAULT_QUEUE_SIZE']

        return queue_size.to_i if queue_size

        1_000
      end
    end
  end
end
