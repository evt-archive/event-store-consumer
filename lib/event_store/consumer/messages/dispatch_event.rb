module EventStore
  module Consumer
    module Messages
      class DispatchEvent
        include Actor::Messaging::Message
        include Schema::DataStructure

        attribute :event_data, EventSource::EventData::Read
      end
    end
  end
end
