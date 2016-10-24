require_relative '../automated_init'

context "Put Position, Substitute" do
  substitute = SubstAttr::Substitute.build Position::Put

  context "Substitute is not actuated" do
    test "Put predicate returns false" do
      refute substitute do
        put?
      end
    end
  end

  context "Substitute is actuated" do
    position = Controls::Position.example

    substitute.(position)

    context "Put predicate" do
      context "No arguments are supplied" do
        test "Predicate returns true" do
          assert substitute do
            put?
          end
        end
      end

      context "Correct position is supplied" do
        test "Predicate returns true" do
          assert substitute do
            put? position
          end
        end
      end

      context "Incorrect position is supplied" do
        test "Predicate returns false" do
          refute substitute do
            put?(position + 1)
          end
        end
      end
    end
  end
end
