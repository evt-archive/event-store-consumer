module Fixtures
  class AttributeEquality
    include TestBench::Fixture

    attr_writer :attribute_names
    attr_writer :description
    attr_writer :exclude

    initializer :compare, :control

    def self.call(compare, control, attribute_names=nil, description: nil, exclude: nil)
      instance = new compare, control
      instance.attribute_names = attribute_names
      instance.description = description
      instance.exclude = Array(exclude)
      instance.()
    end

    def call
      *, compare_class_name = compare.class.name.split '::'
      *, control_class_name = control.class.name.split '::'

      context "#{description} [#{control_class_name} -> #{compare_class_name}]" do
        attribute_names.each do |attr_name|
          next if exclude.include? attr_name

          control_value = control.public_send attr_name

          if compare.nil?
            compare_value = nil
          else
            compare_value = compare.public_send attr_name
          end

          test "Value of #{attr_name.inspect} matches" do
            comment "Control value: #{control_value.inspect}"
            comment "Compare value: #{compare_value.inspect}"

            assert control_value == compare_value
          end
        end
      end
    end

    def attribute_names
      @attribute_names ||= control.class.attribute_names
    end

    def description
      @description ||= "Attribute Equality"
    end

    def exclude
      @exclude ||= []
    end
  end
end
