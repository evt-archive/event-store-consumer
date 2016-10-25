require_relative '../../automated_init'

context "Consumer Stream Position Store, Get Operation" do
  context "Previous position is not recorded" do
    stream_name = Controls::StreamName.example random: true

    position = PositionStore::ConsumerStream.get stream_name

    test "No stream is returned" do
      assert position == :no_stream
    end
  end

  context "Previous position is recorded" do
    stream_name = Controls::ConsumerStream::Write.(position: 11)

    context do
      position = PositionStore::ConsumerStream.get stream_name

      test "Recorded position is returned" do
        assert position == 11
      end
    end

    context "Consumer stream has been updated more than once" do
      Controls::ConsumerStream::Write.(stream_name, position: 22)

      position = PositionStore::ConsumerStream.get stream_name

      test "Position of most recent update is returned" do
        assert position == 22
      end
    end
  end
end
