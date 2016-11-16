require_relative '../automated_init'

context "Kernel Substitute" do
  context "Slept predicate" do
    context "Sleep has not been actuated" do
      substitute = SubstAttr::Substitute.build EventStore::Consumer::Kernel

      test "False is returned even if no argument is supplied" do
        refute substitute do
          slept?
        end
      end
    end

    context "Sleep has been actuated" do
      substitute = SubstAttr::Substitute.build EventStore::Consumer::Kernel

      substitute.sleep 1

      test "True is returned if no argument is supplied" do
        assert substitute do
          slept?
        end
      end

      test "True is returned if supplied argument matches sleep duration" do
        assert substitute do
          slept? 1
        end
      end

      test "False is returned if supplied argument does not match sleep duration" do
        refute substitute do
          slept? 11
        end
      end
    end
  end
end
