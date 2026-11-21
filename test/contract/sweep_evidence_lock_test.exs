defmodule Fablebook.Test.SweepEvidenceLockTest do
  use ExUnit.Case, async: true

  alias Fablebook.Test.SweepEvidence

  @core_archive_lock_sha "4638a2d1c25b5be2bfaf6b6a3309e9147612f343aa694d64b2af99cc46f33a85"
  @floor_archive_lock_sha "ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847"

  test "accepts only the recorded Phoenix and dependency security patches over the core archive lock" do
    identity =
      SweepEvidence.verify_lock_identity!("core", File.read!("mix.lock"), @core_archive_lock_sha)

    assert identity == %{
             archive_sha256: @core_archive_lock_sha,
             runtime_sha256: "65046e697b1196bb6edea44ea4def4ea96c6e413176cf27e303c3205c1ecffc2",
             overlay:
               "phoenix-1.8.16-to-1.8.17+plug-1.20.3-to-1.20.4+phoenix_live_view-1.2.13-to-1.2.14"
           }
  end

  test "rejects a different Phoenix core pin" do
    bytes = File.read!("mix.lock")
    changed = String.replace(bytes, "\"1.8.17\"", "\"1.8.18\"")
    refute changed == bytes

    assert_raise SweepEvidence.Error, ~r/source evidence lock_patch_identity/, fn ->
      SweepEvidence.verify_lock_identity!("core", changed, @core_archive_lock_sha)
    end
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

  test "accepts only the recorded Phoenix floor pin over the archived floor lock" do
    identity =
      SweepEvidence.verify_lock_identity!(
        "floor",
        File.read!("mix.floor.lock"),
        @floor_archive_lock_sha
      )

    assert identity == %{
             archive_sha256: @floor_archive_lock_sha,
             runtime_sha256: "2bd4044506029bdf311e1cb8d1103d3c503433bc01d8e151d6d5b33ad7cf8a48",
             overlay: "phoenix-1.8.9-to-1.8.17"
           }
  end

  test "rejects a different Phoenix floor pin" do
    bytes = File.read!("mix.floor.lock")
    changed = String.replace(bytes, "\"1.8.17\"", "\"1.8.18\"")
    refute changed == bytes

    assert_raise SweepEvidence.Error, ~r/source evidence lock_patch_identity/, fn ->
      SweepEvidence.verify_lock_identity!("floor", changed, @floor_archive_lock_sha)
    end
  end

  @tag :tmp_dir
  test "pins the Phoenix 1.8.17 router source while preserving archived source evidence", %{
    tmp_dir: tmp_dir
  } do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    installed = SweepEvidence.resolve!(evidence, "phoenix/lib/phoenix/router.ex:816")
    assert installed.sha256 == "7282ca1a4b80ef27022bd0b65f8aa14fd091f05a07a095b96d51364d6db896be"
    assert installed.text == "  defp build_pipes(name, pipe_through) do"

    archive_only = %{
      evidence
      | installed: Map.put(evidence.installed, "phoenix", Path.join(tmp_dir, "absent-phoenix"))
    }

    archived = SweepEvidence.resolve!(archive_only, "phoenix/lib/phoenix/router.ex:818")

    expected_archive_sha =
      if evidence.lane.name == "core",
        do: "046564dae97dbd0ba58eb78e630fb226a2c8360a86b933dd9604e998c68b17bd",
        else: "78469c9caa87b05e16ddca8159822263165addc08b07ae8a5e06f76daeab5937"

    assert archived.sha256 == expected_archive_sha
    assert archived.text == "  defp build_pipes(name, pipe_through) do"

    modified_root = Path.join(tmp_dir, "modified-phoenix")
    modified_source = Path.join(modified_root, "lib/phoenix/router.ex")
    File.mkdir_p!(Path.dirname(modified_source))
    File.write!(modified_source, File.read!(installed.path) <> "\n# unpinned source change\n")

    modified = %{evidence | installed: Map.put(evidence.installed, "phoenix", modified_root)}

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(modified, "phoenix/lib/phoenix/router.ex:816")
    end
  end
end
