module EventStore
  module Consumer
    class Subscription
      include Actor

      dependency :get_starting_position

      initializer :stream_name

      handle Actor::Messages::Start do
      end
    end
  end
end
