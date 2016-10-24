module Fixtures
  class QueueContents
    include TestBench::Fixture

    attr_writer :description

    initializer :queue, :control_batch

    def self.call(queue, control_batch, description: nil)
      instance = new queue, control_batch
      instance.description = description
      instance.()
    end

    def call
      context description do
        begin
          compare_batch = queue.deq true
        rescue ThreadError
        end

        control_batch.each_with_index do |control_entry, position|
          if compare_batch
            compare_entry = compare_batch[position]
          end

          Fixtures::AttributeEquality.(
            compare_entry,
            control_entry,
            description: "Entry ##{position + 1}"
          )
        end

        test "Enqueued batch size matches control batch size" do
          assert control_batch.size == compare_batch&.size
        end
      end
    end

    def description
      @description ||= "Queue Contents"
    end
  end
end
