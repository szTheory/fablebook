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
  @archive_sha "d2e9e651978825b154857ea0eeaca3a1d8e014d906b2a7fd6a13f4301a3c67d3"
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
  @cn001_source_identities %{
    "mix/lib/mix/compilers/elixir.ex" => {
      "core",
      "https://raw.githubusercontent.com/elixir-lang/elixir/759443e724f55bf58e71c0603644e99058918d52/lib/mix/lib/mix/compilers/elixir.ex"
    },
    "elixir/lib/protocol.ex" => {
      "core",
      "https://raw.githubusercontent.com/elixir-lang/elixir/759443e724f55bf58e71c0603644e99058918d52/lib/elixir/lib/protocol.ex"
    }
  }
  @cn004_source_identities %{
    {"core", "phoenix/lib/phoenix/router.ex"} => {
      "https://repo.hex.pm/tarballs/phoenix-1.8.16.tar",
      46_089,
      "046564dae97dbd0ba58eb78e630fb226a2c8360a86b933dd9604e998c68b17bd"
    },
    {"core", "phoenix/lib/phoenix.ex"} => {
      "https://repo.hex.pm/tarballs/phoenix-1.8.16.tar",
      2891,
      "f831736998100ebf303c30d67802035f87830620b203d78f3d1d41df94a6df62"
    },
    {"floor", "phoenix/lib/phoenix/router.ex"} => {
      "https://repo.hex.pm/tarballs/phoenix-1.8.9.tar",
      45_684,
      "78469c9caa87b05e16ddca8159822263165addc08b07ae8a5e06f76daeab5937"
    },
    {"floor", "phoenix/lib/phoenix.ex"} => {
      "https://repo.hex.pm/tarballs/phoenix-1.8.9.tar",
      2891,
      "f831736998100ebf303c30d67802035f87830620b203d78f3d1d41df94a6df62"
    }
  }
  @leex_source_identities %{
    {"core", "mix/lib/mix/tasks/compile.leex.ex"} => {
      "https://raw.githubusercontent.com/elixir-lang/elixir/759443e724f55bf58e71c0603644e99058918d52/lib/mix/lib/mix/tasks/compile.leex.ex",
      3001,
      "b33cdcb8077d1d31847ffc2673551e1fa5d6d0849bebd8db475260a85cb16d86"
    },
    {"floor", "mix/lib/mix/tasks/compile.leex.ex"} => {
      "https://raw.githubusercontent.com/elixir-lang/elixir/dfe6612e546cec6557900e67651f7d21805472ef/lib/mix/lib/mix/tasks/compile.leex.ex",
      2828,
      "4539da56203ba4f5c8150efad93cf05f7279b7b3a7054c6235e4dee503efb550"
    }
  }
  @asn1_source_identities %{
    {"core", "asn1/src/asn1ct.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct.erl",
      75_577,
      "c6d680ca6798f80e60c71a5f234d82c1d0c3505ef72fdd6ca320393c2b89df54"
    },
    {"core", "asn1/src/asn1ct_check.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_check.erl",
      208_843,
      "9e1a05b8b0ba48c206b2a6a64770000b6493762d03c76fd3d57573c70ef4f9f8"
    },
    {"core", "asn1/src/asn1ct_gen.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_gen.erl",
      54_635,
      "435cfc5de920ed0e9b7c9368c039de71968daf319bb1b214bff790edd49a4014"
    },
    {"core", "asn1/src/asn1ct_table.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_table.erl",
      1_986,
      "031275fc12cd8cae17944a8b9dda857d40d87d272c82591304863c896fc6cf7f"
    },
    {"core", "asn1/src/asn1ct_parser2.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_parser2.erl",
      73_086,
      "9542877f5446e3a38fff2c892b67f19d52075bd4c05c6b43dc7b46fbf159cfb4"
    },
    {"core", "asn1/src/asn1ct_tok.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_tok.erl",
      11_657,
      "4ec523645deaacaf4452cc443ceb27c217b6a6dd6ba63eeaa771c5e4cce58222"
    },
    {"floor", "asn1/src/asn1ct.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct.erl",
      75_395,
      "b4dcd502873bef48d13b0ef19b9750deaf56c3fd26ecf9c0150581a631f3e59e"
    },
    {"floor", "asn1/src/asn1ct_check.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_check.erl",
      208_746,
      "7539066b341ccbcdbdce1a743567accd073123d14b8252930f4473d5fe626277"
    },
    {"floor", "asn1/src/asn1ct_gen.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_gen.erl",
      53_892,
      "894e107c632b9361d9c1c70614dd60db2638333fdc152336f11b6d2ab3b9abef"
    },
    {"floor", "asn1/src/asn1ct_table.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_table.erl",
      1_944,
      "cc26687a7002adc3d12225abbd0d802fe39ea27b0ff55e26805e32771d249749"
    },
    {"floor", "asn1/src/asn1ct_parser2.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_parser2.erl",
      72_969,
      "7fddafa8be67b9388e42e4f1332f93ace5d0607d8090f308b35df4acc9b8fb30"
    },
    {"floor", "asn1/src/asn1ct_tok.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_tok.erl",
      11_540,
      "4d8bde4d0da13582c1da72d235168521d2ebdbdd98b41635edece96afe5a1bf2"
    }
  }
  @asn1_source_names ~w(asn1/src/asn1ct.erl asn1/src/asn1ct_check.erl asn1/src/asn1ct_gen.erl asn1/src/asn1ct_table.erl asn1/src/asn1ct_parser2.erl asn1/src/asn1ct_tok.erl)
  @asn1_external_transform_names ~w(asn1/src/asn1ct_eval_ext.erl asn1/src/asn1ct_constructed_ber_bin_v2.erl asn1/src/asn1ct_constructed_per.erl asn1/src/asn1ct_value.erl asn1/src/asn1ct_rtt.erl)
  @asn1_external_transform_identities %{
    {"core", "asn1/src/asn1ct_eval_ext.erl"} => {2092, "c2fddfd1f6091b225ae4f6eadda70b789927e9476a916ec960e6a64a2e6504ae"},
    {"core", "asn1/src/asn1ct_constructed_ber_bin_v2.erl"} => {49717, "ecb21fb22cf3c5607fff6d49aba5b81a7aed3cc33114fb19c11fea5440699e54"},
    {"core", "asn1/src/asn1ct_constructed_per.erl"} => {68996, "581c66a8c24f1994679ced99693e37ae4e7bbdd4c15d75b8e22244a81ed76d60"},
    {"core", "asn1/src/asn1ct_value.erl"} => {12384, "48db2e0d04491968b79ed91b7641c968c541f8917225f00e277627d38ea67b0f"},
    {"core", "asn1/src/asn1ct_rtt.erl"} => {135654, "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"}
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

  def archive_sha256, do: @archive_sha

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
    validate_asn1_inventory!(records)
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
    validate_cn001_source_identity!(row)
    validate_cn004_source_identity!(row)
    validate_leex_source_identity!(row)
    validate_asn1_source_identity!(row)
    validate_asn1_external_transform_identity!(row)
    data = Map.fetch!(files, path)

    if byte_size(data) != row["bytes"] or digest(data) != row["sha256"],
      do: fail!(:source_digest, path)
  end

  defp validate_record!(row, _files), do: fail!(:manifest_status, row)

  defp validate_cn001_source_identity!(row) do
    lane = row["lane"]
    url = row["url"]

    case Map.fetch(@cn001_source_identities, row["source_path"]) do
      {:ok, {expected_lane, expected_url}}
      when lane == expected_lane and url == expected_url ->
        :ok

      {:ok, expected} ->
        fail!(:source_identity, {row, expected})

      :error ->
        :ok
    end
  end

  defp validate_cn004_source_identity!(row) do
    identity = {row["lane"], row["source_path"]}
    url = row["url"]
    bytes = row["bytes"]
    sha256 = row["sha256"]

    case Map.fetch(@cn004_source_identities, identity) do
      {:ok, {expected_url, expected_bytes, expected_sha256}}
      when url == expected_url and bytes == expected_bytes and sha256 == expected_sha256 ->
        :ok

      {:ok, expected} ->
        fail!(:source_identity, {row, expected})

      :error ->
        :ok
    end
  end

  defp validate_leex_source_identity!(row) do
    identity = {row["lane"], row["source_path"]}
    actual = {row["url"], row["bytes"], row["sha256"]}

    case Map.fetch(@leex_source_identities, identity) do
      {:ok, ^actual} -> :ok
      {:ok, expected} -> fail!(:source_identity, {row, expected})
      :error -> :ok
    end
  end

  defp validate_asn1_source_identity!(row) do
    identity = {row["lane"], row["source_path"]}
    actual = {row["url"], row["bytes"], row["sha256"]}
    expected_path = if is_binary(row["source_path"]), do: row["lane"] <> "/" <> row["source_path"]

    case Map.fetch(@asn1_source_identities, identity) do
      {:ok, ^actual} ->
        if row["path"] == expected_path,
          do: :ok,
          else: fail!(:source_identity, {row, expected_path})

      {:ok, expected} ->
        fail!(:source_identity, {row, expected})

      :error ->
        if row["source_path"] in @asn1_source_names,
          do: fail!(:source_identity, {row, :unexpected_lane_or_path}),
          else: :ok
    end
  end

  defp validate_asn1_inventory!(records) do
    Enum.each(@asn1_source_identities, fn {{lane, source_path}, _identity} ->
      found = Enum.any?(records, &(&1["lane"] == lane and &1["source_path"] == source_path))
      unless found, do: fail!(:source_identity, {lane, source_path, :missing})
    end)
  end

  defp validate_asn1_external_transform_identity!(row) do
    identity = {row["lane"], row["source_path"]}
    actual = {row["bytes"], row["sha256"]}

    case Map.fetch(@asn1_external_transform_identities, identity) do
      {:ok, ^actual} ->
        if row["path"] == row["lane"] <> "/" <> row["source_path"],
          do: :ok,
          else: fail!(:source_identity, {row, :external_transform_path})

      {:ok, expected} ->
        fail!(:source_identity, {row, expected})

      :error ->
        if row["source_path"] in @asn1_external_transform_names,
          do: fail!(:source_identity, {row, :unexpected_external_transform_lane_or_path}),
          else: :ok
    end
  end

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
    case Regex.run(~r/^([a-z0-9_]+\/(?:src|lib)\/[^:]+):([1-9][0-9]*)$/, citation) do
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
