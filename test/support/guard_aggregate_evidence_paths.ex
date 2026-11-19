defmodule Fablebook.Test.GuardAggregateEvidencePaths do
  @moduledoc false

  @phase3_legacy ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
  @phase3_archive ".planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
  @phase4_legacy ".planning/phases/04-evidence-only-source-and-gap-provenance-closure"
  @phase4_archive ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure"

  @phase3_required_files ~w(
    03-CORE-AGGREGATE-EVIDENCE.json
    03-FLOOR-AGGREGATE-EVIDENCE.json
    03-SIZING.json
    03-04-METADATA-GAP-RECEIPT.json
    03-04-METADATA-GAP-VALIDATION.json
    03-04-METADATA-GAPS.jsonl
    03-05-T2-POST-R8-HELPER-REVISION.json
    03-05-CORE-FOCUSED-R8-FAILURE.json
    03-05-CORE-FOCUSED-R8-RETEST-FAILURE.json
    03-05-CORE-FOCUSED-R8-RETEST-FAILURE-02.json
  )
  @phase4_required_files ~w(
    04-PROVENANCE-MANIFEST.json
    04-VALIDATION.json
    04-EVIDENCE-REVIEW.json
    04-COVERAGE-CALLER-TRACE.json
    04-SIZING-DIGEST-PROOF.json
    04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl
    04-TYPED-GAPS-ENV06.jsonl
  )

  def phase3_evidence_dir! do
    evidence_dir!("Phase 3", @phase3_archive, @phase3_legacy, @phase3_required_files)
  end

  def phase4_evidence_dir! do
    evidence_dir!("Phase 4", @phase4_archive, @phase4_legacy, @phase4_required_files)
  end

  def phase3_writable_evidence_dir! do
    legacy = expand!(@phase3_legacy)

    if phase3_evidence_dir!() == legacy do
      legacy
    else
      raise ArgumentError,
            "Phase 3 evidence is archived and read-only: #{expand!(@phase3_archive)}"
    end
  end

  # The historical producer helper intentionally retains its original bytes for
  # provenance checks. These temporary file links let its legacy path reads see
  # archived evidence without changing the archived files or that helper.
  def install_legacy_read_aliases! do
    roots = [
      {@phase3_archive, @phase3_legacy, @phase3_required_files},
      {@phase4_archive, @phase4_legacy, @phase4_required_files}
    ]

    Enum.reduce(roots, %{links: [], directories: []}, fn {archive, legacy, required}, state ->
      archive_path = expand!(archive)
      legacy_path = expand!(legacy)

      if evidence_dir!("evidence", archive, legacy, required) == archive_path do
        mirror_files!(archive_path, legacy_path, state)
      else
        state
      end
    end)
  end

  def remove_legacy_read_aliases!(%{links: links, directories: directories}) do
    Enum.each(links, fn path ->
      case File.lstat(path) do
        {:ok, %{type: :symlink}} -> File.rm!(path)
        {:error, :enoent} -> :ok
        {:ok, _other} -> raise "temporary evidence alias changed during test: #{path}"
      end
    end)

    directories
    |> Enum.uniq()
    |> Enum.sort_by(&(String.split(&1, "/") |> length()), :desc)
    |> Enum.each(fn path ->
      case File.rmdir(path) do
        :ok ->
          :ok

        {:error, :enoent} ->
          :ok

        {:error, :eexist} ->
          :ok

        {:error, reason} ->
          raise "could not remove temporary evidence directory #{path}: #{reason}"
      end
    end)

    :ok
  end

  defp evidence_dir!(label, archive, legacy, required_files) do
    archive_path = expand!(archive)
    legacy_path = expand!(legacy)

    cond do
      complete_evidence_dir?(archive_path, required_files) -> archive_path
      complete_evidence_dir?(legacy_path, required_files) -> legacy_path
      true -> raise ArgumentError, "Missing complete #{label} evidence under either path"
    end
  end

  defp complete_evidence_dir?(directory, required_files) do
    File.dir?(directory) and Enum.all?(required_files, &File.regular?(Path.join(directory, &1)))
  end

  defp mirror_files!(archive, legacy, state) do
    files = tree_files!(archive)

    # Validate all existing destinations before creating any aliases. An old,
    # partial legacy tree must never be silently combined with different archive
    # contents.
    Enum.each(files, fn source ->
      destination = Path.join(legacy, Path.relative_to(source, archive))

      case File.lstat(destination) do
        {:ok, %{type: :regular}} ->
          true = File.read!(destination) == File.read!(source)

        {:ok, %{type: :symlink}} ->
          target = destination |> File.read_link!() |> Path.expand(Path.dirname(destination))
          true = target == source

        {:error, :enoent} ->
          :ok

        {:ok, _other} ->
          raise "legacy evidence path conflicts with archive file: #{destination}"
      end
    end)

    state = ensure_directory!(legacy, state)

    Enum.reduce(files, state, fn source, acc ->
      destination = Path.join(legacy, Path.relative_to(source, archive))

      case File.lstat(destination) do
        {:ok, _existing} ->
          acc

        {:error, :enoent} ->
          acc = ensure_directory!(Path.dirname(destination), acc)
          File.ln_s!(source, destination)
          %{acc | links: [destination | acc.links]}
      end
    end)
  end

  defp tree_files!(directory) do
    directory
    |> File.ls!()
    |> Enum.flat_map(fn name ->
      path = Path.join(directory, name)

      case File.lstat!(path).type do
        :directory -> tree_files!(path)
        :regular -> [path]
        type -> raise "unsupported file type in archived evidence: #{path} (#{type})"
      end
    end)
    |> Enum.sort()
  end

  defp ensure_directory!(path, state) do
    if File.dir?(path) do
      state
    else
      parent = Path.dirname(path)
      state = ensure_directory!(parent, state)
      File.mkdir!(path)
      %{state | directories: [path | state.directories]}
    end
  end

  defp expand!(path), do: Path.expand(path, File.cwd!())
end
