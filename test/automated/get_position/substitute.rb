require_relative '../automated_init'

context "Get Starting Position, Substitute" do
  substitute = SubstAttr::Substitute.build Position::Get

  context "Position is not specified" do
    position = substitute.()

    test "No stream is returned" do
      assert position == :no_stream
    end
  end

  context "Position is specified" do
    substitute.position = Controls::Position.example

    position = substitute.()

    test "Specified position is returned" do
      assert position == Controls::Position.example
    end
  end
end
