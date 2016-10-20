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
        control_batch.each_with_index do |control_entry, position|
          begin
            compare_entry = queue.deq true
          rescue ThreadError
          end

          Fixtures::AttributeEquality.(
            compare_entry,
            control_entry,
            description: "Entry ##{position + 1}"
          )
        end

        test "Queue size matches control batch size" do
          assert queue.empty?
        end
      end
    end

    def description
      @description ||= "Queue Contents"
    end
  end
end
