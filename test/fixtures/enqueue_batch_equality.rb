module Fixtures
  class EnqueueBatchEquality
    include TestBench::Fixture

    initializer :compare, :control

    def self.call(compare, control)
      instance = new compare, control
      instance.()
    end

    def call
      context "EqueueBatch Equality" do
        AttributeEquality.(
          compare,
          control,
          exclude: :entries,
          description: "Message attributes match"
        )

        context "Event Data entries match" do
          control.entries.each_with_index do |control_entry, index|
            compare_entry = compare.entries[index]

            AttributeEquality.(
              compare_entry,
              control_entry,
              exclude: :created_time,
              description: "Entry ##{index + 1}"
            )
          end
        end
      end
    end

    def attribute_names
      @attribute_names ||= compare.class.attribute_names
    end
  end
end
