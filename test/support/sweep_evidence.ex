defmodule Fablebook.Test.SweepEvidence do
  @moduledoc false

  alias Fablebook.Test.InstalledOtp

  defmodule Error do
    defexception [:reason, :detail]

    @impl true
    def message(%{reason: reason, detail: detail}),
      do: "source evidence #{reason}: #{inspect(detail)}"
  end

  @archive Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
  @archive_sha "a31f1d1b19e1c8df543f4844af9d47b7ca7a79985b42bd78186f56c04da06342"
  @refs %{
    "core" => %{
      "otp" => ["29.1.2", "d199a49a01a2079afb6f2c5c9ae047cd4555e68d"],
      "elixir" => ["1.20.4", "759443e724f55bf58e71c0603644e99058918d52"]
    },
    "floor" => %{
      "otp" => ["27.3.4.9", "4aa809ae4eb4a20ad89c23837376acf179877f39"],
      "elixir" => ["1.18.5", "dfe6612e546cec6557900e67651f7d21805472ef"]
    }
  }
  @elixir_apps [:elixir, :eex, :mix, :iex, :logger, :ex_unit]

  def lane! do
    root = :code.root_dir() |> to_string()
    release = :erlang.system_info(:otp_release) |> to_string()
    otp = read!(Path.join([root, "releases", release, "OTP_VERSION"])) |> String.trim()
    lane!(%{elixir: System.version(), otp: otp})
  end

  def lane!(runtime) do
    name = if System.get_env("FABLEBOOK_FLOOR") in [nil, ""], do: "core", else: "floor"
    expected = %{elixir: hd(@refs[name]["elixir"]), otp: hd(@refs[name]["otp"])}

    if runtime != expected,
      do: fail!(:runtime_identity, %{lane: name, expected: expected, actual: runtime})

    Map.put(runtime, :name, name)
  end

  def source_roots! do
    lane = lane!()
    evidence = load_archive!(@archive, @archive_sha)

    try do
      for {_lane, lock} <- evidence.manifest["locks"] do
        actual = read!(lock["path"]) |> digest()
        if actual != lock["sha256"], do: fail!(:lock_identity, lock["path"])
      end

      otp_lib = :code.lib_dir() |> to_string()

      otp_inventory = InstalledOtp.app_roots!(otp_lib, lane: lane.name)
      otp = Map.new(otp_inventory, &{&1.app, &1.root})

      elixir = Map.new(@elixir_apps, &{Atom.to_string(&1), &1 |> :code.lib_dir() |> to_string()})
      deps = Map.new(Mix.Project.deps_paths(), fn {app, path} -> {Atom.to_string(app), path} end)

      Map.merge(evidence, %{
        lane: lane,
        otp_inventory: otp_inventory,
        lock_sha256: evidence.manifest["locks"][lane.name]["sha256"],
        installed: otp |> Map.merge(elixir) |> Map.merge(deps)
      })
    rescue
      error ->
        File.rm_rf!(evidence.archive_root)
        reraise error, __STACKTRACE__
    end
  end

  def load_archive!(path, expected_sha) do
    bytes = read!(path)
    if digest(bytes) != expected_sha, do: fail!(:archive_digest, path)
    files = archive_files!(bytes)
    manifest = archive_manifest!(files)
    validate_manifest!(manifest, files)
    %{archive_root: extract_files!(files), manifest: manifest}
  end

  def lock_digests! do
    evidence = load_archive!(@archive, @archive_sha)

    try do
      Map.new(["core", "floor"], fn lane ->
        {lane, evidence.manifest["locks"][lane]["sha256"]}
      end)
    after
      File.rm_rf!(evidence.archive_root)
    end
  end

  def resolve!(evidence, citation) do
    {relative, line} = parse_citation!(citation)
    row = source_record!(evidence, relative, citation)
    {path, root, origin} = source_file!(evidence, row, relative, citation)
    path = realpath!(path)
    root = realpath!(root)
    if not String.starts_with?(path, root <> "/"), do: fail!(:source_escape, citation)
    data = read!(path)
    if digest(data) != row["sha256"], do: fail!(:source_digest, {citation, origin})
    lines = source_lines(data)
    if line > length(lines), do: fail!(:source_line, citation)

    %{
      path: path,
      line: line,
      text: Enum.at(lines, line - 1),
      sha256: row["sha256"],
      origin: origin
    }
  end

  defp archive_files!(bytes) do
    archive = {:binary, bytes}

    table =
      case :erl_tar.table(archive, [:compressed, :verbose]) do
        {:ok, table} -> table
        {:error, reason} -> fail!(:archive_format, reason)
      end

    names = Enum.map(table, &archive_name!/1)
    if length(names) != MapSet.size(MapSet.new(names)), do: fail!(:archive_duplicate, names)
    {:ok, files} = :erl_tar.extract(archive, [:compressed, :memory])
    Map.new(files, fn {name, data} -> {to_string(name), data} end)
  end

  defp archive_name!({name, type, _size, _mtime, _mode, _uid, _gid}) do
    name = to_string(name)
    if type != :regular, do: fail!(:archive_link_or_type, name)
    if not safe_path?(name), do: fail!(:archive_path, name)
    name
  end

  defp archive_manifest!(files) do
    with {:ok, raw} <- Map.fetch(files, "manifest.json"),
         {:ok, manifest} when is_map(manifest) <- JSON.decode(raw),
         rows when is_list(rows) <- manifest["files"],
         locks when is_map(locks) <- manifest["locks"] do
      manifest
    else
      result -> fail!(:manifest_format, result)
    end
  end

  defp validate_manifest!(manifest, files) do
    if manifest["refs"] != @refs, do: fail!(:source_identity, manifest["refs"])
    validate_lock_manifest!(manifest["locks"])
    records = manifest["files"]
    declared = for row <- records, row["status"] in ["present", "license"], do: row["path"]

    if length(declared) != MapSet.size(MapSet.new(declared)),
      do: fail!(:manifest_duplicate, declared)

    if MapSet.new(Map.keys(files)) != MapSet.new(["manifest.json" | declared]),
      do: fail!(:manifest_inventory, Map.keys(files))

    Enum.each(records, &validate_record!(&1, files))
  end

  defp validate_lock_manifest!(locks) do
    lanes = ["core", "floor"]

    if Map.keys(locks) |> Enum.sort() != lanes,
      do: fail!(:lock_manifest_lanes, Map.keys(locks))

    Enum.each(lanes, fn lane ->
      lock = Map.fetch!(locks, lane)
      expected_path = if lane == "core", do: "mix.lock", else: "mix.floor.lock"

      unless lock["path"] == expected_path and
               is_binary(lock["sha256"]) and Regex.match?(~r/^[a-f0-9]{64}$/, lock["sha256"]),
             do: fail!(:lock_manifest_record, {lane, lock})
    end)
  end

  defp validate_record!(%{"status" => "absent-at-immutable-ref"} = row, _files) do
    if Map.has_key?(row, "path"), do: fail!(:manifest_absence, row)
  end

  defp validate_record!(%{"status" => status} = row, files)
       when status in ["present", "license"] do
    path = row["path"]
    if not String.starts_with?(path, row["lane"] <> "/"), do: fail!(:source_root, row)
    data = Map.fetch!(files, path)

    if byte_size(data) != row["bytes"] or digest(data) != row["sha256"],
      do: fail!(:source_digest, path)
  end

  defp validate_record!(row, _files), do: fail!(:manifest_status, row)

  defp extract_files!(files) do
    token = :crypto.strong_rand_bytes(12) |> Base.url_encode64(padding: false)
    root = Path.join(System.tmp_dir!(), "fablebook-sources-#{token}")
    File.mkdir!(root)

    try do
      for {name, data} <- files do
        path = Path.join(root, name)
        File.mkdir_p!(Path.dirname(path))
        File.write!(path, data, [:exclusive])
      end

      root
    rescue
      error ->
        File.rm_rf!(root)
        reraise error, __STACKTRACE__
    end
  end

  defp source_record!(evidence, relative, citation) do
    [app | _] = Path.split(relative)
    if not Map.has_key?(evidence.installed, app), do: fail!(:unknown_app, {app, citation})

    row =
      Enum.find(evidence.manifest["files"], fn row ->
        row["lane"] == evidence.lane.name and row["source_path"] == relative
      end)

    if is_nil(row), do: fail!(:missing_source, {evidence.lane.name, citation})
    if row["status"] != "present", do: fail!(:lane_absent_source, {evidence.lane.name, citation})
    row
  end

  defp source_file!(evidence, row, relative, citation) do
    [app | _] = Path.split(relative)

    installed =
      Path.join(evidence.installed[app], String.replace_prefix(relative, app <> "/", ""))

    case File.lstat(installed) do
      {:ok, _stat} ->
        {installed, evidence.installed[app], :installed}

      {:error, :enoent} ->
        {Path.join(evidence.archive_root, row["path"]), evidence.archive_root, :archive}

      {:error, reason} ->
        fail!(:unreadable_source, {citation, reason})
    end
  end

  defp parse_citation!(citation) do
    case Regex.run(~r/^([a-z_]+\/(?:src|lib)\/[^:]+):([1-9][0-9]*)$/, citation) do
      [_, path, line] ->
        if not safe_path?(path), do: fail!(:citation_path, citation)
        {path, String.to_integer(line)}

      _invalid ->
        fail!(:citation_format, citation)
    end
  end

  defp source_lines(""), do: []

  defp source_lines(data) do
    lines = String.split(data, "\n")
    if String.ends_with?(data, "\n"), do: Enum.drop(lines, -1), else: lines
  end

  defp safe_path?(path) do
    is_binary(path) and path != "" and Path.type(path) == :relative and
      not String.contains?(path, ["\\", "\0", ":"]) and
      Enum.all?(String.split(path, "/"), &(&1 not in ["", ".", ".."]))
  end

  defp realpath!(path, depth \\ 0)
  defp realpath!(path, depth) when depth > 40, do: fail!(:source_symlink_loop, path)

  defp realpath!(path, depth) do
    [root | parts] = Path.split(Path.expand(path))

    Enum.reduce(parts, root, fn part, parent ->
      current = Path.join(parent, part)

      case File.lstat(current) do
        {:ok, %{type: :symlink}} ->
          link = File.read_link!(current)
          realpath!(Path.expand(link, parent), depth + 1)

        {:ok, _stat} ->
          current

        {:error, reason} ->
          fail!(:unreadable_source, {current, reason})
      end
    end)
  end

  defp read!(path) do
    case File.stat(path) do
      {:ok, %{type: :regular, mode: mode}} ->
        if Bitwise.band(mode, 0o444) == 0, do: fail!(:unreadable_source, path)

        case File.read(path) do
          {:ok, data} -> data
          {:error, reason} -> fail!(:unreadable_source, {path, reason})
        end

      result ->
        fail!(:unreadable_source, {path, result})
    end
  end

  defp digest(data), do: :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  defp fail!(reason, detail), do: raise(Error, reason: reason, detail: detail)
end
