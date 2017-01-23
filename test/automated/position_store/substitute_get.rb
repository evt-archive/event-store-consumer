require_relative '../automated_init'

context "Substitute Position Store, Get" do
  substitute = SubstAttr::Substitute.build Consumer::PositionStore

  context "Position is not specified" do
    position = substitute.get

    test "Nothing is returned" do
      assert position == nil
    end
  end

  context "Position is specified" do
    substitute.get_position = Controls::Position.example

    position = substitute.get

    test "Specified position is returned" do
      assert position == Controls::Position.example
    end
  end
end
