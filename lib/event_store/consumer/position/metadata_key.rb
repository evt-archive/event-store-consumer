module EventStore
  class Consumer
    module Position
      module MetadataKey
        def self.get(prefix=nil)
          if prefix
            metadata_key = "#{prefix}_consumer_position".to_sym
          else
            key = :consumer_position
          end
        end
      end
    end
  end
end
