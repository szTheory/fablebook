defmodule Fablebook.Test.SweepEvidenceLockTest do
  use ExUnit.Case, async: true

  alias Fablebook.Test.SweepEvidence

  @core_archive_lock_sha "4638a2d1c25b5be2bfaf6b6a3309e9147612f343aa694d64b2af99cc46f33a85"
  @floor_archive_lock_sha "ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847"

  test "accepts only the recorded Plug security patch over the core archive lock" do
    identity =
      SweepEvidence.verify_lock_identity!("core", File.read!("mix.lock"), @core_archive_lock_sha)

    assert identity == %{
             archive_sha256: @core_archive_lock_sha,
             runtime_sha256: "3c55e9ec28da1fe2f8ded5a8b5e6504542c3536df25c704933cd7ace85224207",
             overlay: "plug-1.20.3-to-1.20.4+phoenix_live_view-1.2.13-to-1.2.14"
           }
  end

  test "rejects a different Plug patch version" do
    bytes = File.read!("mix.lock")
    changed = String.replace(bytes, "\"1.20.4\"", "\"1.20.5\"")
    refute changed == bytes

    assert_raise SweepEvidence.Error, ~r/source evidence lock_(identity|patch_identity)/, fn ->
      SweepEvidence.verify_lock_identity!("core", changed, @core_archive_lock_sha)
    end
  end

  test "rejects a different LiveView patch version" do
    bytes = File.read!("mix.lock")
    changed = String.replace(bytes, "\"1.2.14\"", "\"1.2.15\"")
    refute changed == bytes

    assert_raise SweepEvidence.Error, ~r/source evidence lock_(identity|patch_identity)/, fn ->
      SweepEvidence.verify_lock_identity!("core", changed, @core_archive_lock_sha)
    end
  end

  test "rejects an unrelated dependency change alongside the Plug patch" do
    bytes = File.read!("mix.lock")

    changed =
      String.replace(
        bytes,
        "\"telemetry\": {:hex, :telemetry, \"1.4.2\"",
        "\"telemetry\": {:hex, :telemetry, \"1.4.3\""
      )

    refute changed == bytes

    assert_raise SweepEvidence.Error, ~r/source evidence lock_identity/, fn ->
      SweepEvidence.verify_lock_identity!("core", changed, @core_archive_lock_sha)
    end
  end

  test "keeps the floor lock exactly pinned to its archived identity" do
    identity =
      SweepEvidence.verify_lock_identity!(
        "floor",
        File.read!("mix.floor.lock"),
        @floor_archive_lock_sha
      )

    assert identity == %{
             archive_sha256: @floor_archive_lock_sha,
             runtime_sha256: @floor_archive_lock_sha,
             overlay: nil
           }
  end
end
