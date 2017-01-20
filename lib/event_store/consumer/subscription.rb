module EventStore
  module Consumer
    class Subscription
      include Actor
      include Log::Dependency

      attr_writer :batch_size
      attr_writer :dispatcher_queue_depth_limit
      attr_writer :iterator

      def iterator
        @iterator ||= EventSource::Iterator.configure(
          self,
          get,
          stream_name,
          position: starting_position
        )
      end

      dependency :dispatcher_address, Actor::Messaging::Address
      dependency :get, EventSource::EventStore::HTTP::Get
      dependency :kernel, Kernel
      dependency :position_store, PositionStore

      initializer :stream_name

      def self.build(stream_name, dispatcher_address, batch_size: nil, position_store: nil, session: nil)
        instance = new stream_name

        cycle = Cycle.build(
          maximum_milliseconds: Defaults.cycle_maximum_milliseconds,
          timeout_milliseconds: Defaults.cycle_maximum_milliseconds
        )

        long_poll_duration = Rational(cycle.maximum_milliseconds, 1000).ceil

        EventSource::EventStore::HTTP::Get.configure(
          instance,
          batch_size: batch_size,
          long_poll_duration: long_poll_duration,
          session: session
        )

        instance.dispatcher_address = dispatcher_address
        instance.position_store = position_store if position_store

        Kernel.configure instance

        instance
      end

      handle Actor::Messages::Start do
        :get_batch
      end

      handle Messages::GetBatch do
        log_attributes = "#{self.log_attributes}"

        verify_dispatcher_queue_depth do |depth, limit|
          logger.debug "Dispatcher queue depth exceeds limit; pausing (#{log_attributes}, Depth: #{depth}, Limit: #{limit})"
          delay
          return :get_batch
        end

        logger.trace "Getting batch (#{log_attributes})"

        batch = []

        while event = iterator.next
          batch << event
        end

        if batch.empty?
          logger.debug "Get batch returned nothing; retrying (#{log_attributes})"
          return :get_batch
        end

        logger.debug "Get batch done (#{log_attributes}, BatchSize: #{batch.count})"

        Messages::EnqueueBatch.build :batch => batch
      end

      handle Messages::EnqueueBatch do |enqueue_batch|
        log_attributes = "#{self.log_attributes}, BatchSize: #{enqueue_batch.batch.count})"

        logger.trace "Enqueuing batch (#{log_attributes})"

        enqueue_batch.each do |event_data|
          dispatch_event = Messages::DispatchEvent.build :event_data => event_data

          send.(dispatch_event, dispatcher_address)
        end

        logger.debug "Enqueue batch done (#{log_attributes})"

        :get_batch
      end

      def verify_dispatcher_queue_depth(&block)
        logger.trace "Verifying dispatcher queue depth (#{log_attributes})"

        depth = dispatcher_address.queue_depth

        limit = dispatcher_queue_depth_limit

        if depth > limit
          logger.debug "Dispatcher queue depth exceeds limit (#{log_attributes}, Depth: #{depth}, Limit: #{limit})"
          block.(depth, limit)
        else
          logger.debug "Dispatcher queue depth within limit (#{log_attributes}, Depth: #{depth}, Limit: #{limit})"
        end
      end

      def starting_position
        starting_position = position_store.get

        if starting_position == :no_stream
          nil
        else
          starting_position
        end
      end

      def delay
        duration = Defaults.no_stream_delay_duration_seconds

        kernel.sleep duration
      end

      def cycle_maximum_milliseconds
        @cycle_maximum_milliseconds ||= Defaults.cycle_maximum_milliseconds
      end

      def dispatcher_queue_depth_limit
        @dispatcher_queue_depth_limit ||= Defaults.dispatcher_queue_depth_limit
      end

      def digest
        "#{self.class}[streamName=#{stream_name}]"
      end

      def log_attributes
        "StreamName: #{iterator.stream_name}, BatchSize: #{get.batch_size}"
      end

      module Assertions
        def session?(session)
          get.session.equal? session
        end
      end
    end
  end
end
