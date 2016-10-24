module EventStore
  module Consumer
    def self.included(cls)
      return if cls == Object
    end
  end
end
