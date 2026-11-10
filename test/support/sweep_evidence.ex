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
  @archive_sha "9a49947455b5d4697f8fd122f0e6d92c7b94dba4641aba6c7e1ca4b0c400315d"
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
    {"core", "asn1/src/asn1ct_gen_check.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_gen_check.erl",
      10779,
      "334d7db4ab13c40f51fcfca8d0862d90c39e57d15bdf5eaf37f698aa4fa7f07b"
    },
    {"floor", "asn1/src/asn1ct_gen_check.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_gen_check.erl",
      10737,
      "80be7185dd900a3b2b890153379ff713a47079fa216aef69b224837f38b3f1b4"
    },
    {"core", "asn1/src/asn1ct_gen_jer.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_gen_jer.erl",
      21571,
      "52037ca2e912292971faf5862786f94de7d815910a8545c0f23179d660bae1a0"
    },
    {"floor", "asn1/src/asn1ct_gen_jer.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_gen_jer.erl",
      21380,
      "5cb747179c6210bfc21d61805708447fca2888e50ef4c6b188a44f0ac2ed1319"
    },
    {"core", "asn1/src/asn1ct_gen_per.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_gen_per.erl",
      14985,
      "f122289b606aff8c26a978a4a61793b5613ae7f712e86e58e3f53d5dcbdd5068"
    },
    {"floor", "asn1/src/asn1ct_gen_per.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_gen_per.erl",
      14868,
      "568dcc2ff43db91e1c6d94d902be06f71696cca02cddcb9cb6b652813552355a"
    },
    {"core", "asn1/src/asn1ct_imm.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_imm.erl",
      87381,
      "ff6c00798a44156ca6c42e134036b014db34de63e855eef4471587c14bb01ed7"
    },
    {"floor", "asn1/src/asn1ct_imm.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_imm.erl",
      87339,
      "975f8bcf64f4719571e2b49037a6500b7661ed2ee6197d003fdbae98c0d143ca"
    },
    {"core", "asn1/src/asn1ct_gen_ber_bin_v2.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_gen_ber_bin_v2.erl",
      53554,
      "ae135c8071bd88d8bee431428876501d00cf0970eb1c8b0f159116c51a99cab1"
    },
    {"floor", "asn1/src/asn1ct_gen_ber_bin_v2.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_gen_ber_bin_v2.erl",
      53437,
      "d873b9136aa2bd97f975f0a7c0e0c4aa8e6e024ba27edc007dc044b1afdd4ba1"
    },
    {"core", "asn1/src/asn1ct_func.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/asn1/src/asn1ct_func.erl",
      4465,
      "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"
    },
    {"floor", "asn1/src/asn1ct_func.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/asn1/src/asn1ct_func.erl",
      4347,
      "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"
    },
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
  @asn1_source_names ~w(asn1/src/asn1ct.erl asn1/src/asn1ct_check.erl asn1/src/asn1ct_gen.erl asn1/src/asn1ct_table.erl asn1/src/asn1ct_parser2.erl asn1/src/asn1ct_tok.erl asn1/src/asn1ct_func.erl asn1/src/asn1ct_gen_ber_bin_v2.erl asn1/src/asn1ct_gen_check.erl asn1/src/asn1ct_gen_jer.erl asn1/src/asn1ct_gen_per.erl asn1/src/asn1ct_imm.erl)
  @asn1_external_transform_names ~w(asn1/src/asn1ct_eval_ext.erl asn1/src/asn1ct_constructed_ber_bin_v2.erl asn1/src/asn1ct_constructed_per.erl asn1/src/asn1ct_value.erl asn1/src/asn1ct_rtt.erl)
  @generator_dispatch_support_identities %{
    {"floor", "stdlib/src/gen_server.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/stdlib/src/gen_server.erl",
      111_386,
      "5adbf93c85a5950a91977dd0ee681412f37ad90392568e4aaaf927e3953c06f0"
    },
    {"floor", "stdlib/src/gen.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/stdlib/src/gen.erl",
      27_057,
      "bf25bd7350ed20be1b5b4e1bbd7fe1776c2ca5ba9a0ae3558df57ede2af7d680"
    },
    {"floor", "stdlib/src/proc_lib.erl"} => {
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/stdlib/src/proc_lib.erl",
      56_739,
      "fb4906c7cee60766e096682240e87881e766b8455fec09f38ee6728e513c1995"
    }
  }
  @asn1_external_transform_identities %{
    {"core", "asn1/src/asn1ct_eval_ext.erl"} =>
      {2092, "c2fddfd1f6091b225ae4f6eadda70b789927e9476a916ec960e6a64a2e6504ae"},
    {"core", "asn1/src/asn1ct_constructed_ber_bin_v2.erl"} =>
      {49_717, "ecb21fb22cf3c5607fff6d49aba5b81a7aed3cc33114fb19c11fea5440699e54"},
    {"core", "asn1/src/asn1ct_constructed_per.erl"} =>
      {68_996, "581c66a8c24f1994679ced99693e37ae4e7bbdd4c15d75b8e22244a81ed76d60"},
    {"core", "asn1/src/asn1ct_value.erl"} =>
      {12_384, "48db2e0d04491968b79ed91b7641c968c541f8917225f00e277627d38ea67b0f"},
    {"core", "asn1/src/asn1ct_rtt.erl"} =>
      {135_654, "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"},
    {"floor", "asn1/src/asn1ct_eval_ext.erl"} =>
      {2092, "c2fddfd1f6091b225ae4f6eadda70b789927e9476a916ec960e6a64a2e6504ae"},
    {"floor", "asn1/src/asn1ct_constructed_ber_bin_v2.erl"} =>
      {49_528, "a173873d7d7a3082cd77ec8caac860b64f421bda2a91a9166845710e69bc97f5"},
    {"floor", "asn1/src/asn1ct_constructed_per.erl"} =>
      {68_908, "0e732766bf11e1e5bc73e79f8529b91eb065efba34fe0d6e29b323e778dbba5c"},
    {"floor", "asn1/src/asn1ct_value.erl"} =>
      {12_270, "771476506bfa10fae9db6a2476bf5487df9ee69030b8b6791473f3bf273608c3"},
    {"floor", "asn1/src/asn1ct_rtt.erl"} =>
      {134_820, "828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d"}
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
    validate_asn1_external_transform_inventory!(records)
    validate_generator_dispatch_support_inventory!(records)
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
    validate_generator_dispatch_support_identity!(row)
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

  defp validate_asn1_external_transform_inventory!(records) do
    Enum.each(@asn1_external_transform_identities, fn {{lane, source_path}, _identity} ->
      if not Enum.any?(records, &(&1["lane"] == lane and &1["source_path"] == source_path)),
        do: fail!(:source_identity, {lane, source_path, :missing})
    end)
  end

  defp validate_generator_dispatch_support_identity!(row) do
    identity = {row["lane"], row["source_path"]}
    actual = {row["url"], row["bytes"], row["sha256"]}

    case Map.fetch(@generator_dispatch_support_identities, identity) do
      {:ok, ^actual} ->
        if row["path"] == row["lane"] <> "/" <> row["source_path"],
          do: :ok,
          else: fail!(:source_identity, {row, :generator_dispatch_support_path})

      {:ok, expected} ->
        fail!(:source_identity, {row, expected})

      :error ->
        :ok
    end
  end

  defp validate_generator_dispatch_support_inventory!(records) do
    Enum.each(@generator_dispatch_support_identities, fn {{lane, source_path}, _identity} ->
      unless Enum.any?(records, &(&1["lane"] == lane and &1["source_path"] == source_path)),
        do: fail!(:source_identity, {lane, source_path, :missing})
    end)
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

defmodule Fablebook.Test.GeneratorDispatchCoreEvidence do
  @moduledoc false

  @core_started_at "2026-11-10T17:55:07Z"
  @core_completed_at "2026-11-10T18:01:39Z"

  def records do
    [
      %{
        lane: "core",
        original_id: "EX-107",
        owner: "01.1.1.4",
        semantic_status: :pending,
        method: :source_only,
        started_at: @core_started_at,
        completed_at: @core_completed_at,
        elapsed_seconds: 392,
        exact_sources: [
          {"asn1/src/asn1ct_func.erl", 4465,
           "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"},
          {"stdlib/src/gen_server.erl", 114_546,
           "45e1cea8e87a49c8f6cec49ec50e082dde6690c3696f9e67de376947fc8f34a3"},
          {"stdlib/src/gen.erl", 27_099,
           "b828697b055865df24aad48ec4cd7f23821fa54a7aa2baa0408a444a5d0d04be"},
          {"stdlib/src/proc_lib.erl", 57_067,
           "a8fc8e94f9ad47ace46cd204fc5eb6fd227c09787f3be906d80d2e4547e6a8c5"},
          {"asn1/src/asn1ct_rtt.erl", 135_654,
           "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"}
        ],
        reviews: [
          review({:asn1ct_func, :start_link, 0}, "asn1/src/asn1ct_func.erl", 29..34,
            ["asn1/src/asn1ct_func.erl:29", "asn1/src/asn1ct_func.erl:30"],
            "start_link/0 passes the fixed module atom and empty arguments/options to gen_server:start_link/3, then stores only the returned pid in the process dictionary. The constructor does not read ASN.1 source text or create callback module names.")
        ],
        callback_trace: [
          {"stdlib/src/gen_server.erl:1028", "gen:start(?MODULE, link, Module, Args, Options)"},
          {"stdlib/src/gen.erl:120", "do_spawn(GenMod, LinkP, Mod, Args, Options)"},
          {"stdlib/src/proc_lib.erl:511", "start_link(M,F,A,Timeout,SpawnOpts)"},
          {"stdlib/src/gen_server.erl:2361", "handle_call     = fun Mod:handle_call/3"},
          {"stdlib/src/gen_server.erl:2362", "handle_cast     = fun Mod:handle_cast/2"},
          {"stdlib/src/gen_server.erl:2373", "decode_msg(#server_data"},
          {"stdlib/src/gen_server.erl:2498", "handle_msg(ServerData, State, {'$gen_call', From, Msg})"},
          {"stdlib/src/gen_server.erl:2520", "handle_msg(ServerData, State, Msg)"},
          {"stdlib/src/gen_server.erl:2478", "try_terminate(#server_data{module = Mod}"},
          {"stdlib/src/gen_server.erl:1850", "reply(Client, Reply)"}
        ],
        selected_function_traces: [
          {:asn1ct_func, :need, 1,
           "need/1 exempts only fixed binary and erlang module atoms; every other MFA is checked by asn1ct_rtt:assert_defined/1 before the fixed {need,MFA} cast. The function does not derive an atom from MFA fields."},
          {:asn1ct_func, :handle_cast, 2,
           "The {need,MFA} callback adds the MFA and its dependencies to the used set through pull_in_deps/2 and asn1ct_rtt:dependencies/1."},
          {:asn1ct_func, :generate, 1,
           "generate/1 obtains the fixed code/0 literal data, intersects it with the used MFA set, serializes selected function data, and writes it to the supplied file descriptor. This is static data selection, not execution of generated functions."},
          {:asn1ct_func, :handle_call, 3,
           "get_gen receives caller-origin Prefix, Key and GenFun in a fixed request tuple. A new name is built as list_to_atom(Prefix ++ integer_to_list(Gc)); the exact caller-controlled prefix therefore reaches atom creation. Key controls cache reuse and GenFun is stored as a callback for later generator-side execution. This remains an interim active atom-creation finding pending Plan 03 guard reconciliation."}
        ],
        selected_function_evidence: [
          function_evidence({:asn1ct_func, :start_link, 0}, :fixed_callback_start,
            [{"asn1/src/asn1ct_func.erl:33", "start_link() ->"}, {"asn1/src/asn1ct_func.erl:34", "gen_server:start_link(?MODULE, [], [])"}],
            "Uses the fixed ?MODULE callback atom and empty argument/options lists; stores the resulting pid under the same fixed module key."),
          function_evidence({:asn1ct_func, :call, 3}, :existing_atom_lookup_and_codegen,
            [{"asn1/src/asn1ct_func.erl:38", "call(M, F, Args) ->"}, {"asn1/src/asn1ct_func.erl:40", "MFA = {M,F,A}"}, {"asn1/src/asn1ct_func.erl:41", "need(MFA)"}, {"asn1/src/asn1ct_func.erl:44", "asn1ct_gen:emit"}],
            "Packages already-atom M/F and argument count as an MFA, requires it from the fixed RTT table, then emits function-call text. No text-to-atom conversion occurs here."),
          function_evidence({:asn1ct_func, :need, 1}, :existing_atom_lookup,
            [{"asn1/src/asn1ct_func.erl:49", "need({binary,_,_}) ->"}, {"asn1/src/asn1ct_func.erl:51", "need({erlang,_,_}) ->"}, {"asn1/src/asn1ct_func.erl:53", "need(MFA) ->"}, {"asn1/src/asn1ct_func.erl:54", "asn1ct_rtt:assert_defined(MFA)"}],
            "Only fixed module exceptions bypass the source-table lookup; all other already-formed MFAs are checked against assert_defined/1 before a fixed need message is cast."),
          function_evidence({:asn1ct_func, :call_gen, 3}, :caller_prefix_reaches_atom_builder,
            [{"asn1/src/asn1ct_func.erl:61", "call_gen(Prefix, Key, Gen) when is_function(Gen, 2) ->"}, {"asn1/src/asn1ct_func.erl:62", "req({gen_func,Prefix,Key,Gen})"}],
            "Forwards caller-supplied Prefix, cache Key and a locally constructed arity-two Gen closure to the callback server. The wrapper itself does not atomize them; the prefix reaches handle_call/3's atom-building branch."),
          function_evidence({:asn1ct_func, :call_gen, 4}, :caller_prefix_reaches_atom_builder,
            [{"asn1/src/asn1ct_func.erl:57", "call_gen(Prefix, Key, Gen, Args) when is_function(Gen, 2) ->"}, {"asn1/src/asn1ct_func.erl:58", "F = req({gen_func,Prefix,Key,Gen})"}, {"asn1/src/asn1ct_func.erl:59", "asn1ct_gen:emit"}],
            "Uses the same caller-supplied prefix/key/closure request, then serializes the returned atom as a generated source identifier and emits arguments. Dynamic atom creation is downstream in handle_call/3."),
          function_evidence({:asn1ct_func, :generate, 1}, :fixed_data_selection,
            [{"asn1/src/asn1ct_func.erl:64", "generate(Fd) ->"}, {"asn1/src/asn1ct_func.erl:68", "Used = sofs:set(Used0, [mfa])"}, {"asn1/src/asn1ct_func.erl:69", "Code = sofs:relation(asn1ct_rtt:code()"}, {"asn1/src/asn1ct_func.erl:72", "file:write(Fd, Funcs)"}],
            "Selects only code-table entries keyed by used MFAs and writes their literal text to the supplied descriptor. This does not execute generated functions or parse their text."),
          function_evidence({:asn1ct_func, :is_used, 1}, :existing_atom_lookup,
            [{"asn1/src/asn1ct_func.erl:74", "is_used({M,F,A}=MFA) when is_atom(M), is_atom(F), is_integer(A) ->"}, {"asn1/src/asn1ct_func.erl:75", "req({is_used,MFA})"}],
            "Accepts only a structured MFA whose module and function are already atoms and asks the server for membership; it does not create atoms from strings."),
          function_evidence({:asn1ct_func, :init, 1}, :fixed_state_initialization,
            [{"asn1/src/asn1ct_func.erl:91", "init([]) ->"}, {"asn1/src/asn1ct_func.erl:92", "used=gb_sets:empty(),gen=gb_trees:empty()"}],
            "Initializes empty set/tree state and a fixed counter; initialization derives no data from caller text."),
          function_evidence({:asn1ct_func, :handle_call, 3}, :active_dynamic_atom_creation_candidate,
            [{"asn1/src/asn1ct_func.erl:109", "handle_call({gen_func,Prefix,Key,GenFun}"}, {"asn1/src/asn1ct_func.erl:112", "Name = list_to_atom(Prefix ++ integer_to_list(Gc0))"}, {"asn1/src/asn1ct_func.erl:114", "gb_trees:insert(Key, {Name,GenFun}, G0)"}],
            "On a cache miss, concatenates the request Prefix with a decimal counter and interns the result, then caches that atom and the callback under Key. Caller A's dec_os_ ++ Name and the source IR prefix in caller B reach this exact sink; caller prefixes and origin are retained per edge below. Interim active atom-creation candidate; no guard or cross-lane conclusion is made here."),
          function_evidence({:asn1ct_func, :handle_cast, 2}, :fixed_data_dependency_expansion,
            [{"asn1/src/asn1ct_func.erl:95", "handle_cast({need,MFA}"}, {"asn1/src/asn1ct_func.erl:98", "pull_in_deps(gb_sets:singleton(MFA), Used0)"}, {"asn1/src/asn1ct_func.erl:137", "asn1ct_rtt:dependencies(MFA)"}],
            "Adds the already formed MFA and its fixed-table dependency closure to a set; it does not create atoms from request text."),
          function_evidence({:asn1ct_func, :terminate, 2}, :no_sink,
            [{"asn1/src/asn1ct_func.erl:123", "terminate(_, _) ->"}, {"asn1/src/asn1ct_func.erl:124", "ok."}],
            "Normal termination returns ok without reading state, invoking a callback supplied by callers, or creating atoms.")
        ]
      }
    ]
  end

  defp review(mfa, source_path, lines, citations, finding) do
    %{
      mfa: mfa,
      source_path: source_path,
      lines: lines,
      citations: citations,
      finding: finding
    }
  end

  defp function_evidence(mfa, interim_disposition, citations, trace) do
    %{mfa: mfa, interim_disposition: interim_disposition, citations: citations, trace: trace}
  end
end

defmodule Fablebook.Test.GeneratorDispatchFloorEvidence do
  @moduledoc false

  @started_at "2026-11-10T18:22:34Z"
  @completed_at "2026-11-10T18:35:13Z"
  @exact_sources [
    {"asn1/src/asn1ct_func.erl", 4347,
     "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"},
    {"stdlib/src/gen_server.erl", 111_386,
     "5adbf93c85a5950a91977dd0ee681412f37ad90392568e4aaaf927e3953c06f0"},
    {"stdlib/src/gen.erl", 27_057,
     "bf25bd7350ed20be1b5b4e1bbd7fe1776c2ca5ba9a0ae3558df57ede2af7d680"},
    {"stdlib/src/proc_lib.erl", 56_739,
     "fb4906c7cee60766e096682240e87881e766b8455fec09f38ee6728e513c1995"},
    {"asn1/src/asn1ct_rtt.erl", 134_820,
     "828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d"}
  ]

  def record do
    %{
      lane: "floor",
      original_id: "EX-107",
      owner: "01.1.1.4",
      semantic_status: :pending,
      method: :source_only,
      started_at: @started_at,
      completed_at: @completed_at,
      elapsed_seconds: elapsed_seconds(),
      exact_sources: @exact_sources,
      selected_function_evidence: selected_function_evidence(),
      callback_trace: [
        {"stdlib/src/gen_server.erl:949", "gen:start(?MODULE, link, Module, Args, Options)"},
        {"stdlib/src/gen.erl:124", "do_spawn(GenMod, link, Mod, Args, Options) ->"},
        {"stdlib/src/gen.erl:126", "proc_lib:start_link(?MODULE, init_it,"},
        {"stdlib/src/proc_lib.erl:507", "start_link(M,F,A,Timeout,SpawnOpts)"},
        {"stdlib/src/proc_lib.erl:265", "erlang:spawn_opt(?MODULE, init_p"},
        {"stdlib/src/proc_lib.erl:322", "init_p(Parent, Ancestors, M, F, A)"},
        {"stdlib/src/proc_lib.erl:327", "init_p_do_apply(M, F, A) ->"},
        {"stdlib/src/gen_server.erl:2279", "handle_call = fun Mod:handle_call/3"},
        {"stdlib/src/gen_server.erl:2280", "handle_cast = fun Mod:handle_cast/2"},
        {"stdlib/src/gen_server.erl:2268", "Msg = receive"},
        {"stdlib/src/gen_server.erl:2292", "decode_msg(Msg, Parent, Name, State, CbCache"},
        {"stdlib/src/gen_server.erl:2328", "try_dispatch({'$gen_cast', Msg}, CbCache, State)"},
        {"stdlib/src/gen_server.erl:2409", "handle_msg({'$gen_call', From, Msg}, Parent"},
        {"stdlib/src/gen_server.erl:1771", "reply(Client, Reply) ->"},
        {"stdlib/src/gen_server.erl:2389", "try_terminate(Mod, Reason, State) ->"},
        {"stdlib/src/proc_lib.erl:671", "init_ack(Parent, Return) ->"}
      ],
      rtt_literal_body: %{
        start_line: 534,
        end_line: 1039,
        bytes: 112_537,
        sha256: "816ef1ae1981656ec27e35dd52d2f1307249004964b56a50ce81740fc5c8d211",
        rows: 254,
        grammar: :pass,
        controls: [:computed_payload, :expression_in_mfa, :trailing_code, :truncation]
      }
    }
  end

  defp selected_function_evidence do
    [
      function(
        {:asn1ct_func, :start_link, 0},
        :fixed_callback_start,
        [
          {"asn1/src/asn1ct_func.erl:28", "start_link() ->"},
          {"asn1/src/asn1ct_func.erl:29", "gen_server:start_link(?MODULE, [], [])"}
        ],
        "Starts the fixed asn1ct_func callback module with empty arguments and options, then stores only the returned process identifier under the fixed module key."
      ),
      function(
        {:asn1ct_func, :call, 3},
        :existing_atom_lookup_and_codegen,
        [
          {"asn1/src/asn1ct_func.erl:33", "call(M, F, Args) ->"},
          {"asn1/src/asn1ct_func.erl:35", "MFA = {M,F,A}"},
          {"asn1/src/asn1ct_func.erl:36", "need(MFA)"},
          {"asn1/src/asn1ct_func.erl:41", "asn1ct_gen:emit"}
        ],
        "Forms an MFA from existing module/function values and argument count, checks the fixed RTT table, then emits call text. This path does not convert source text to atoms."
      ),
      function(
        {:asn1ct_func, :need, 1},
        :existing_atom_lookup,
        [
          {"asn1/src/asn1ct_func.erl:44", "need({binary,_,_}) ->"},
          {"asn1/src/asn1ct_func.erl:46", "need({erlang,_,_}) ->"},
          {"asn1/src/asn1ct_func.erl:48", "need(MFA) ->"},
          {"asn1/src/asn1ct_func.erl:49", "asn1ct_rtt:assert_defined(MFA)"}
        ],
        "Only fixed binary and erlang module exceptions bypass the exact RTT lookup; the ordinary path checks an already formed MFA and sends a fixed need request."
      ),
      function(
        {:asn1ct_func, :call_gen, 3},
        :caller_prefix_forwarded,
        [
          {"asn1/src/asn1ct_func.erl:56", "call_gen(Prefix, Key, Gen)"},
          {"asn1/src/asn1ct_func.erl:57", "req({gen_func,Prefix,Key,Gen})"}
        ],
        "Forwards Prefix, cache Key and an arity-two generator closure in a fixed request tuple. The wrapper does not atomize the prefix; caller-origin details are assigned to the next caller-review task."
      ),
      function(
        {:asn1ct_func, :call_gen, 4},
        :caller_prefix_forwarded,
        [
          {"asn1/src/asn1ct_func.erl:52", "call_gen(Prefix, Key, Gen, Args)"},
          {"asn1/src/asn1ct_func.erl:53", "req({gen_func,Prefix,Key,Gen})"},
          {"asn1/src/asn1ct_func.erl:54", "asn1ct_gen:emit"}
        ],
        "Uses the same request path and serializes the returned function name into generated source. Prefix provenance is deferred to the caller task."
      ),
      function(
        {:asn1ct_func, :generate, 1},
        :fixed_data_selection,
        [
          {"asn1/src/asn1ct_func.erl:59", "generate(Fd) ->"},
          {"asn1/src/asn1ct_func.erl:64", "asn1ct_rtt:code()"},
          {"asn1/src/asn1ct_func.erl:67", "file:write(Fd, Funcs)"}
        ],
        "Selects fixed RTT literal rows using the accumulated MFA set and writes selected source data to the descriptor. The generated text is not interpreted or compiled here."
      ),
      function(
        {:asn1ct_func, :is_used, 1},
        :existing_atom_lookup,
        [
          {"asn1/src/asn1ct_func.erl:69",
           "is_used({M,F,A}=MFA) when is_atom(M), is_atom(F), is_integer(A) ->"},
          {"asn1/src/asn1ct_func.erl:70", "req({is_used,MFA})"}
        ],
        "Requires module and function atoms plus an integer arity before asking the server for membership; it performs no name conversion."
      ),
      function(
        {:asn1ct_func, :init, 1},
        :fixed_state_initialization,
        [
          {"asn1/src/asn1ct_func.erl:86", "init([]) ->"},
          {"asn1/src/asn1ct_func.erl:87", "used=gb_sets:empty(),gen=gb_trees:empty()"}
        ],
        "Initializes empty used-function and generated-function structures with the fixed default counter, independent of source input."
      ),
      function(
        {:asn1ct_func, :handle_call, 3},
        :active_dynamic_atom_creation_candidate,
        [
          {"asn1/src/asn1ct_func.erl:104", "handle_call({gen_func,Prefix,Key,GenFun}"},
          {"asn1/src/asn1ct_func.erl:107", "Name = list_to_atom(Prefix ++ integer_to_list(Gc0))"},
          {"asn1/src/asn1ct_func.erl:109", "gb_trees:insert(Key, {Name,GenFun}, G0)"}
        ],
        "On a cache miss, interns the request Prefix with a fixed decimal counter and stores the resulting atom with its callback under Key. Prefix caller provenance is not decided in the support task; this remains an active atom-creation candidate for the caller batches and Plan 03."
      ),
      function(
        {:asn1ct_func, :handle_cast, 2},
        :fixed_data_dependency_expansion,
        [
          {"asn1/src/asn1ct_func.erl:90", "handle_cast({need,MFA}"},
          {"asn1/src/asn1ct_func.erl:93", "pull_in_deps(gb_sets:singleton(MFA), Used0)"},
          {"asn1/src/asn1ct_func.erl:132", "asn1ct_rtt:dependencies(MFA)"}
        ],
        "Adds the requested existing MFA and its fixed-table dependency closure to the used set. It does not derive atoms from request text."
      ),
      function(
        {:asn1ct_func, :terminate, 2},
        :no_sink,
        [
          {"asn1/src/asn1ct_func.erl:118", "terminate(_, _) ->"},
          {"asn1/src/asn1ct_func.erl:119", "ok."}
        ],
        "Normal termination returns ok without reading source values, invoking request callbacks, or creating atoms."
      )
    ]
  end

  defp function(mfa, interim_disposition, citations, trace) do
    %{mfa: mfa, interim_disposition: interim_disposition, citations: citations, trace: trace}
  end

  defp elapsed_seconds do
    {:ok, started, _offset} = DateTime.from_iso8601(@started_at)
    {:ok, completed, _offset} = DateTime.from_iso8601(@completed_at)
    DateTime.diff(completed, started)
  end
end

defmodule Fablebook.Test.GeneratorDispatchCallerAEvidence do
  @moduledoc false

  @started_at "2026-11-10T18:03:55Z"
  @completed_at "2026-11-10T18:07:21Z"

  def record do
    %{
      lane: "core",
      original_id: "EX-107",
      owner: "01.1.1.4",
      semantic_status: :pending,
      method: :source_only,
      started_at: @started_at,
      completed_at: @completed_at,
      elapsed_seconds: 206,
      exact_sources: [
        {"asn1/src/asn1ct_func.erl", 4465,
         "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"},
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl", 49_717,
         "ecb21fb22cf3c5607fff6d49aba5b81a7aed3cc33114fb19c11fea5440699e54"},
        {"asn1/src/asn1ct_constructed_per.erl", 68_996,
         "581c66a8c24f1994679ced99693e37ae4e7bbdd4c15d75b8e22244a81ed76d60"},
        {"asn1/src/asn1ct_gen.erl", 54_635,
         "435cfc5de920ed0e9b7c9368c039de71968daf319bb1b214bff790edd49a4014"},
        {"asn1/src/asn1ct_gen_ber_bin_v2.erl", 53_554,
         "ae135c8071bd88d8bee431428876501d00cf0970eb1c8b0f159116c51a99cab1"}
      ],
      reviews: [
        review(
          "asn1/src/asn1ct_constructed_ber_bin_v2.erl",
          [65..169, 585..618, 1304..1399, 1502..1503],
          [
            {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:151", "need({ber,dynamicsort_SET_components,1})"},
            {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:167", "call(encode_tags, [\"TagIn\",\"BytesSoFar\",\"LenSoFar\"])"},
            {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:1503", "asn1ct_func:call(ber, F, Args)"}
          ],
          "The complete allocated construction/dispatch spans route the local call/2 wrapper to asn1ct_func:call/3 with the fixed ber module and a generator-selected function/argument list. Its visible dynamic name path derives DecFunName from compiler type/name metadata through mkfuncname and emits it as source; no atom constructor appears in these clauses. The explicitly needed dynamicsort helper is a fixed MFA checked through the target table. This source supports a generated-call trace, not a new atom-sink finding."
        ),
        review(
          "asn1/src/asn1ct_constructed_per.erl",
          [568..589, 626..664, 747..791, 1304..1346],
          [
            {"asn1/src/asn1ct_constructed_per.erl:579", "erlang:md5(term_to_binary({decode,ObjSet,RestFieldNames"},
            {"asn1/src/asn1ct_constructed_per.erl:581", "Gen = fun(_Fd, N) ->"},
            {"asn1/src/asn1ct_constructed_per.erl:586", "Prefix = lists:concat([\"dec_os_\",Name])"},
            {"asn1/src/asn1ct_constructed_per.erl:587", "asn1ct_func:call_gen(Prefix, Key, Gen)"},
            {"asn1/src/asn1ct_constructed_per.erl:634", "Key = {dec_outlined,Def}"},
            {"asn1/src/asn1ct_constructed_per.erl:638", "asn1ct_func:call_gen(Prefix, Key, Gen)"},
            {"asn1/src/asn1ct_constructed_per.erl:755", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"},
            {"asn1/src/asn1ct_constructed_per.erl:768", "asn1ct_func:call_gen(\"dec_fragment\", Key, Gen)"},
            {"asn1/src/asn1ct_constructed_per.erl:788", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"},
            {"asn1/src/asn1ct_constructed_per.erl:1331", "asn1ct_func:call(Mod, skipextensions,"}
          ],
          "All four call_gen/3 sites construct local GenFun closures and use generated schema/type structures in cache keys. The prefixes are fixed literals except dec_os_ ++ Name, where Name comes from compiler object-set/type metadata. The closure captures compiler definitions and emits generated source using the callback-supplied function name; it does not execute the generated function here. Prefix input reaches the target's atom-building branch, so dec_os_ names remain a caller-derived atom-creation candidate for Plan 03 reconciliation. call(Mod,skipextensions,...) carries a fixed enum-derived module and fixed function name; it reaches need/1 table checking, not atom construction."
        ),
        review(
          "asn1/src/asn1ct_gen.erl",
          [63..97, 745..899, 1085..1117],
          [
            {"asn1/src/asn1ct_gen.erl:79", "asn1ct_func:start_link()"},
            {"asn1/src/asn1ct_gen.erl:92", "asn1ct_func:generate(Fd)"},
            {"asn1/src/asn1ct_gen.erl:1098", "do_emit({call,M,F,A}) ->"},
            {"asn1/src/asn1ct_gen.erl:1099", "MFA = {M,F,length(A)}"},
            {"asn1/src/asn1ct_gen.erl:1100", "asn1ct_func:need(MFA)"}
          ],
          "pgen/3 brackets source generation with the fixed server start/generate calls. do_emit/1 accepts an internal {call,M,F,A} emission tuple, constructs its MFA from those existing atom fields and argument count, and asks need/1 to confirm the MFA is in the fixed RTT table before emitting the call text. This is generated-call metadata and existing-atom lookup; it does not create an atom from the emitted text."
        ),
        review(
          "asn1/src/asn1ct_gen_ber_bin_v2.erl",
          [97..112, 1595..1597],
          [
            {"asn1/src/asn1ct_gen_ber_bin_v2.erl:101", "suppress({M,F,_}=MFA, Args) ->"},
            {"asn1/src/asn1ct_gen_ber_bin_v2.erl:102", "asn1ct_func:is_used(MFA)"},
            {"asn1/src/asn1ct_gen_ber_bin_v2.erl:106", ~S/emit(["    _ = ",{call,M,F,Args},com,nl])/},
            {"asn1/src/asn1ct_gen_ber_bin_v2.erl:1596", "asn1ct_func:call(ber, F, Args)"}
          ],
          "suppress/2 receives an already structured MFA and creates only source strings for positional tuple access. If the fixed record says the MFA is used, it places the existing M and F atoms into the generator emission tuple; its call/2 bridge to the target fixes module ber. No caller string is converted into an atom in this path."
        )
      ]
    }
  end

  defp review(source_path, lines, citations, finding) do
    %{source_path: source_path, reviewed_lines: lines, citations: citations, finding: finding}
  end
end

defmodule Fablebook.Test.GeneratorDispatchFloorCallerAEvidence do
  @moduledoc false

  @started_at "2026-11-10T18:36:24Z"
  @completed_at "2026-11-10T18:41:20Z"
  @exact_sources [
    {"asn1/src/asn1ct_func.erl", 4347,
     "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"},
    {"asn1/src/asn1ct_constructed_ber_bin_v2.erl", 49_528,
     "a173873d7d7a3082cd77ec8caac860b64f421bda2a91a9166845710e69bc97f5"},
    {"asn1/src/asn1ct_constructed_per.erl", 68_908,
     "0e732766bf11e1e5bc73e79f8529b91eb065efba34fe0d6e29b323e778dbba5c"},
    {"asn1/src/asn1ct_gen.erl", 53_892,
     "894e107c632b9361d9c1c70614dd60db2638333fdc152336f11b6d2ab3b9abef"},
    {"asn1/src/asn1ct_gen_ber_bin_v2.erl", 53_437,
     "d873b9136aa2bd97f975f0a7c0e0c4aa8e6e024ba27edc007dc044b1afdd4ba1"}
  ]

  def record do
    %{
      lane: "floor",
      original_id: "EX-107",
      owner: "01.1.1.4",
      semantic_status: :pending,
      method: :source_only,
      started_at: @started_at,
      completed_at: @completed_at,
      elapsed_seconds: elapsed_seconds(),
      exact_sources: @exact_sources,
      reviews: [
        review("asn1/src/asn1ct_constructed_ber_bin_v2.erl", [61..165, 578..605, 1294..1382, 1492..1493], [
          {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:147", "asn1ct_func:need({ber,dynamicsort_SET_components,1})"},
          {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:591", "asn1ct_func:need({ber,dynamicsort_SETOF,1})"},
          {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:1363", "mkfuncname(TopType,Cname,WhatKind,Prefix,Suffix)"},
          {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:1493", "asn1ct_func:call(ber, F, Args)"}
        ], "The allocated clauses build decoder names from compiler type/name fields and emit them as generated source. The wrapper routes generated calls to asn1ct_func:call/3 with fixed module atom ber; its fixed dynamicsort MFA requests are table lookups. No atom constructor is present in these reviewed clauses."),
        review("asn1/src/asn1ct_constructed_per.erl", [564..585, 622..660, 743..787, 1300..1342], [
          {"asn1/src/asn1ct_constructed_per.erl:575", "erlang:md5(term_to_binary({decode,ObjSet,RestFieldNames"},
          {"asn1/src/asn1ct_constructed_per.erl:577", "Gen = fun(_Fd, N) ->"},
          {"asn1/src/asn1ct_constructed_per.erl:582", "Prefix = lists:concat([\"dec_os_\",Name])"},
          {"asn1/src/asn1ct_constructed_per.erl:583", "asn1ct_func:call_gen(Prefix, Key, Gen)"},
          {"asn1/src/asn1ct_constructed_per.erl:629", "Prefix = \"dec_outlined_\""},
          {"asn1/src/asn1ct_constructed_per.erl:634", "asn1ct_func:call_gen(Prefix, Key, Gen)"},
          {"asn1/src/asn1ct_constructed_per.erl:751", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"},
          {"asn1/src/asn1ct_constructed_per.erl:764", "asn1ct_func:call_gen(\"dec_fragment\", Key, Gen)"},
          {"asn1/src/asn1ct_constructed_per.erl:784", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"},
          {"asn1/src/asn1ct_constructed_per.erl:1327", "asn1ct_func:call(Mod, skipextensions,"}
        ], "Four local call_gen/3 closures use fixed prefixes and cache keys from generator definitions, except gen_dec_open_type/5, which passes dec_os_ ++ the Name argument. That caller-derived compiler metadata reaches the target atom builder; this task does not trace Name's producer to an external trust boundary and makes no user-controlled-input claim. The local callbacks emit generated function source. The skipextensions route uses a fixed function atom and a module selected from fixed PER alignment atoms."),
        review("asn1/src/asn1ct_gen.erl", [59..93, 741..895, 1072..1104], [
          {"asn1/src/asn1ct_gen.erl:75", "asn1ct_func:start_link()"},
          {"asn1/src/asn1ct_gen.erl:88", "asn1ct_func:generate(Fd)"},
          {"asn1/src/asn1ct_gen.erl:763", "asn1ct_func:need({per,complete,1})"},
          {"asn1/src/asn1ct_gen.erl:849", "asn1ct_func:need({ber,ber_decode_nif,1})"},
          {"asn1/src/asn1ct_gen.erl:1085", "do_emit({call,M,F,A}) ->"},
          {"asn1/src/asn1ct_gen.erl:1087", "asn1ct_func:need(MFA)"}
        ], "pgen/3 brackets source generation with fixed server startup and data emission. Dispatcher branches request fixed helper MFAs from the RTT table. do_emit/1 receives an internal call tuple with existing module/function atoms, checks that MFA, then serializes a source call; emitted text is not converted back into an atom here."),
        review("asn1/src/asn1ct_gen_ber_bin_v2.erl", [93..108, 1591..1593], [
          {"asn1/src/asn1ct_gen_ber_bin_v2.erl:97", "suppress({M,F,_}=MFA, Args) ->"},
          {"asn1/src/asn1ct_gen_ber_bin_v2.erl:98", "asn1ct_func:is_used(MFA)"},
          {"asn1/src/asn1ct_gen_ber_bin_v2.erl:102", ~S/emit(["    _ = ",{call,M,F,Args},com,nl])/},
          {"asn1/src/asn1ct_gen_ber_bin_v2.erl:1592", "asn1ct_func:call(ber, F, Args)"}
        ], "suppress/2 checks a structured MFA against the fixed used set and, on a hit, places existing M/F atoms in the generated-call tuple. Its call/2 wrapper passes the fixed ber module atom. This path does not intern names derived from caller strings.")
      ],
      incoming_edges: incoming_edges()
    }
  end

  def incoming_edges do
    [
      edge({:asn1ct_constructed_ber_bin_v2, :call, 2}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:1493", "asn1ct_func:call(ber, F, Args)"}]),
      edge({:asn1ct_constructed_ber_bin_v2, :gen_dec_call1, 7}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:1374", "asn1ct_func:need({ber,match_tags,2})"}]),
      edge({:asn1ct_constructed_ber_bin_v2, :gen_encode_sequence, 3}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:147", "asn1ct_func:need({ber,dynamicsort_SET_components,1})"}]),
      edge({:asn1ct_constructed_ber_bin_v2, :gen_encode_sof_components, 4}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:591", "asn1ct_func:need({ber,dynamicsort_SETOF,1})"}]),
      edge({:asn1ct_constructed_per, :gen_dec_open_type, 5}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:583", "asn1ct_func:call_gen(Prefix, Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :dec_objset_2, 4}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:634", "asn1ct_func:call_gen(Prefix, Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :do_gen_decode_fragmented, 4}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:751", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :do_gen_dec_fragmented_1, 6}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:764", "asn1ct_func:call_gen(\"dec_fragment\", Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :do_gen_decode_sof_plain, 5}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:784", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :gen_dec_components_call, 6}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_constructed_per.erl:1327", "asn1ct_func:call(Mod, skipextensions,"}]),
      edge({:asn1ct_gen, :pgen, 3}, {:asn1ct_func, :start_link, 0}, [{"asn1/src/asn1ct_gen.erl:75", "asn1ct_func:start_link()"}]),
      edge({:asn1ct_gen, :pgen, 3}, {:asn1ct_func, :generate, 1}, [{"asn1/src/asn1ct_gen.erl:88", "asn1ct_func:generate(Fd)"}]),
      edge({:asn1ct_gen, :pgen_dispatcher, 2}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen.erl:763", "asn1ct_func:need({per,complete,1})"}, {"asn1/src/asn1ct_gen.erl:770", "asn1ct_func:need({uper,complete_NFP,1})"}, {"asn1/src/asn1ct_gen.erl:773", "asn1ct_func:need({uper,complete,1})"}]),
      edge({:asn1ct_gen, :pgen_dispatcher_decode, 3}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen.erl:849", "asn1ct_func:need({ber,ber_decode_nif,1})"}, {"asn1/src/asn1ct_gen.erl:852", "asn1ct_func:need({ber,ber_decode_nif,1})"}]),
      edge({:asn1ct_gen, :do_emit, 1}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen.erl:1087", "asn1ct_func:need(MFA)"}]),
      edge({:asn1ct_gen_ber_bin_v2, :call, 2}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_gen_ber_bin_v2.erl:1592", "asn1ct_func:call(ber, F, Args)"}]),
      edge({:asn1ct_gen_ber_bin_v2, :suppress, 2}, {:asn1ct_func, :is_used, 1}, [{"asn1/src/asn1ct_gen_ber_bin_v2.erl:98", "asn1ct_func:is_used(MFA)"}])
    ]
  end

  defp review(source_path, reviewed_lines, citations, finding) do
    %{source_path: source_path, reviewed_lines: reviewed_lines, citations: citations, finding: finding}
  end

  defp edge(caller, callee, citations), do: %{caller: caller, callee: callee, citations: citations}

  defp elapsed_seconds do
    {:ok, started, _offset} = DateTime.from_iso8601(@started_at)
    {:ok, completed, _offset} = DateTime.from_iso8601(@completed_at)
    DateTime.diff(completed, started)
  end
end

defmodule Fablebook.Test.GeneratorDispatchFloorCallerBEvidence do
  @moduledoc false

  alias Fablebook.Test.GeneratorDispatchFloorEvidence
  alias Fablebook.Test.GeneratorDispatchFloorCallerAEvidence

  @started_at "2026-11-10T18:42:52Z"
  @completed_at "2026-11-10T18:48:32Z"
  @exact_sources [
    {"asn1/src/asn1ct_func.erl", 4347,
     "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"},
    {"asn1/src/asn1ct_gen_check.erl", 10737,
     "80be7185dd900a3b2b890153379ff713a47079fa216aef69b224837f38b3f1b4"},
    {"asn1/src/asn1ct_gen_jer.erl", 21380,
     "5cb747179c6210bfc21d61805708447fca2888e50ef4c6b188a44f0ac2ed1319"},
    {"asn1/src/asn1ct_gen_per.erl", 14868,
     "568dcc2ff43db91e1c6d94d902be06f71696cca02cddcb9cb6b652813552355a"},
    {"asn1/src/asn1ct_imm.erl", 87339,
     "975f8bcf64f4719571e2b49037a6500b7661ed2ee6197d003fdbae98c0d143ca"}
  ]

  def record do
    %{
      lane: "floor",
      original_id: "EX-107",
      owner: "01.1.1.4",
      semantic_status: :pending,
      method: :source_only,
      started_at: @started_at,
      completed_at: @completed_at,
      elapsed_seconds: elapsed_seconds(),
      exact_sources: @exact_sources,
      selected_function_evidence: GeneratorDispatchFloorEvidence.record().selected_function_evidence,
      reviews: [
        review("asn1/src/asn1ct_gen_check.erl", [30..40, 62..130, 146..200, 338..340], [
          {"asn1/src/asn1ct_gen_check.erl:36", "asn1ct_func:call_gen(\"is_default_\", Key, DoGen, [Value])"},
          {"asn1/src/asn1ct_gen_check.erl:75", "need(check_legacy_bitstring, 2)"},
          {"asn1/src/asn1ct_gen_check.erl:84", "need(check_int, 3)"},
          {"asn1/src/asn1ct_gen_check.erl:111", "asn1ct_func:call_gen(\"is_default_choice\", Key, DoGen)"},
          {"asn1/src/asn1ct_gen_check.erl:160", "asn1ct_func:call_gen(\"is_default_cs_\", Key, DoGen)"},
          {"asn1/src/asn1ct_gen_check.erl:179", "asn1ct_func:call_gen(\"is_default_cs_\", Key, DoGen)"},
          {"asn1/src/asn1ct_gen_check.erl:197", "asn1ct_func:call_gen(\"is_default_sof\", Key, DoGen)"},
          {"asn1/src/asn1ct_gen_check.erl:339", "asn1ct_func:need({check,F,A})"}
        ], "All generated function prefixes in the allocated clauses are fixed strings. Keys and local closures capture ASN.1 type/default data and serialize comparison source; the Value is a function argument, not part of the generated atom prefix. need/2 combines an existing helper-function atom with fixed module check for the RTT membership request."),
        review("asn1/src/asn1ct_gen_jer.erl", [353..365], [
          {"asn1/src/asn1ct_gen_jer.erl:354", "asn1ct_func:is_used(MFA)"},
          {"asn1/src/asn1ct_gen_jer.erl:359", ~S/emit(["    _ = ",{call,M,F,Args},com,nl])/}
        ], "suppress/1 queries membership using the structured MFA it receives, then emits a call record containing existing M/F atoms and positional argument text. No string-to-atom operation is in the allocated path."),
        review("asn1/src/asn1ct_gen_per.erl", [55..65], [
          {"asn1/src/asn1ct_gen_per.erl:56", "asn1ct_func:is_used(MFA)"},
          {"asn1/src/asn1ct_gen_per.erl:63", ~S/emit(["    _ = ",{call,M,F,Args},com,nl])/}
        ], "The PER suppress path shares JER's fixed membership check and serializes the existing M/F atoms into generated source. It does not convert names from strings."),
        review("asn1/src/asn1ct_imm.erl", [468..490, 505..538, 2365..2452], [
          {"asn1/src/asn1ct_imm.erl:522", "asn1ct_func:call(per_common,"},
          {"asn1/src/asn1ct_imm.erl:2394", "enc_cg({call,M,F,As0}) ->"},
          {"asn1/src/asn1ct_imm.erl:2396", "asn1ct_func:call(M, F, As)"},
          {"asn1/src/asn1ct_imm.erl:2401", "enc_cg({call_gen,Prefix,Key,Gen,_,As0}) ->"},
          {"asn1/src/asn1ct_imm.erl:2403", "asn1ct_func:call_gen(Prefix, Key, Gen, As)"}
        ], "dec_string/4 builds a local closure for the fixed per_common:decode_fragmented MFA and carries it in intermediate representation. enc_cg/1 forwards pre-existing M/F atoms through call/3, and forwards an IR-supplied Prefix/Key/Gen tuple through call_gen/4. That Prefix producer is outside the allocated spans, so its origin remains unresolved; it reaches the target atom builder, but no user-controlled-input claim is made.")
      ],
      incoming_edges: complete_incoming_edges()
    }
  end

  def complete_incoming_edges do
    caller_a = GeneratorDispatchFloorCallerAEvidence.record().incoming_edges

    caller_b = [
      edge({:asn1ct_gen_check, :do_gen, 3}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_gen_check.erl:111", "asn1ct_func:call_gen(\"is_default_choice\", Key, DoGen)"}]),
      edge({:asn1ct_gen_check, :do_seq_set, 3}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_gen_check.erl:160", "asn1ct_func:call_gen(\"is_default_cs_\", Key, DoGen)"}, {"asn1/src/asn1ct_gen_check.erl:179", "asn1ct_func:call_gen(\"is_default_cs_\", Key, DoGen)"}]),
      edge({:asn1ct_gen_check, :do_sof, 3}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_gen_check.erl:197", "asn1ct_func:call_gen(\"is_default_sof\", Key, DoGen)"}]),
      edge({:asn1ct_gen_check, :emit, 4}, {:asn1ct_func, :call_gen, 4}, [{"asn1/src/asn1ct_gen_check.erl:36", "asn1ct_func:call_gen(\"is_default_\", Key, DoGen, [Value])"}]),
      edge({:asn1ct_gen_check, :need, 2}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen_check.erl:339", "asn1ct_func:need({check,F,A})"}]),
      edge({:asn1ct_gen_jer, :suppress, 1}, {:asn1ct_func, :is_used, 1}, [{"asn1/src/asn1ct_gen_jer.erl:354", "asn1ct_func:is_used(MFA)"}]),
      edge({:asn1ct_gen_per, :suppress, 1}, {:asn1ct_func, :is_used, 1}, [{"asn1/src/asn1ct_gen_per.erl:56", "asn1ct_func:is_used(MFA)"}]),
      edge({:asn1ct_imm, :dec_string, 4}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_imm.erl:522", "asn1ct_func:call(per_common"}]),
      edge({:asn1ct_imm, :enc_cg, 1}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_imm.erl:2396", "asn1ct_func:call(M, F, As)"}]),
      edge({:asn1ct_imm, :enc_cg, 1}, {:asn1ct_func, :call_gen, 4}, [{"asn1/src/asn1ct_imm.erl:2403", "asn1ct_func:call_gen(Prefix, Key, Gen, As)"}]),
      edge({:asn1ct_func, :call, 3}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_func.erl:36", "need(MFA)"}])
    ]

    caller_a ++ caller_b
  end

  defp review(source_path, reviewed_lines, citations, finding) do
    %{source_path: source_path, reviewed_lines: reviewed_lines, citations: citations, finding: finding}
  end

  defp edge(caller, callee, citations), do: %{caller: caller, callee: callee, citations: citations}

  defp elapsed_seconds do
    {:ok, started, _offset} = DateTime.from_iso8601(@started_at)
    {:ok, completed, _offset} = DateTime.from_iso8601(@completed_at)
    DateTime.diff(completed, started)
  end
end

defmodule Fablebook.Test.GeneratorDispatchCallerBEvidence do
  @moduledoc false

  @started_at "2026-11-10T18:07:56Z"
  @completed_at "2026-11-10T18:14:22Z"

  def record do
    %{
      lane: "core",
      original_id: "EX-107",
      owner: "01.1.1.4",
      semantic_status: :pending,
      method: :source_only,
      started_at: @started_at,
      completed_at: @completed_at,
      elapsed_seconds: 386,
      exact_sources: [
        {"asn1/src/asn1ct_func.erl", 4465,
         "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"},
        {"asn1/src/asn1ct_gen_check.erl", 10779,
         "334d7db4ab13c40f51fcfca8d0862d90c39e57d15bdf5eaf37f698aa4fa7f07b"},
        {"asn1/src/asn1ct_gen_jer.erl", 21571,
         "52037ca2e912292971faf5862786f94de7d815910a8545c0f23179d660bae1a0"},
        {"asn1/src/asn1ct_gen_per.erl", 14985,
         "f122289b606aff8c26a978a4a61793b5613ae7f712e86e58e3f53d5dcbdd5068"},
        {"asn1/src/asn1ct_imm.erl", 87381,
         "ff6c00798a44156ca6c42e134036b014db34de63e855eef4471587c14bb01ed7"}
      ],
      reviews: [
        review("asn1/src/asn1ct_gen_check.erl", [32..42, 64..132, 148..202, 340..342],
          [
            {"asn1/src/asn1ct_gen_check.erl:38", ~S|asn1ct_func:call_gen("is_default_", Key, DoGen, [Value])|},
            {"asn1/src/asn1ct_gen_check.erl:77", "need(check_legacy_bitstring, 2)"},
            {"asn1/src/asn1ct_gen_check.erl:86", "need(check_int, 3)"},
            {"asn1/src/asn1ct_gen_check.erl:113", ~S|asn1ct_func:call_gen("is_default_choice", Key, DoGen)|},
            {"asn1/src/asn1ct_gen_check.erl:162", ~S|asn1ct_func:call_gen("is_default_cs_", Key, DoGen)|},
            {"asn1/src/asn1ct_gen_check.erl:181", ~S|asn1ct_func:call_gen("is_default_cs_", Key, DoGen)|},
            {"asn1/src/asn1ct_gen_check.erl:199", ~S|asn1ct_func:call_gen("is_default_sof", Key, DoGen)|},
            {"asn1/src/asn1ct_gen_check.erl:341", "asn1ct_func:need({check,F,A})"}
          ],
          "All call_gen prefixes in the allocated functions are fixed literals. Their cache keys and closures capture the ASN.1 generator's type/default structures and produce comparison source through do_gen/gen_choice/gen_components/gen_map_components/gen_sof; the input value is emitted as a function argument, not concatenated into the generated atom prefix. need/2 wraps an existing helper function atom and arity in the fixed check module for table membership. These callers exercise generated functions and existing-atom lookup, not a caller-text-derived prefix."),
        review("asn1/src/asn1ct_gen_jer.erl", [358..370],
          [{"asn1/src/asn1ct_gen_jer.erl:359", "asn1ct_func:is_used(MFA)"},
           {"asn1/src/asn1ct_gen_jer.erl:364", ~S/{call,M,F,Args}/}],
          "suppress/1 tests a structured MFA with is_used/1, then places its existing M/F atoms and position-derived argument strings in an internal call emission tuple. It does not create an atom from identifier text."),
        review("asn1/src/asn1ct_gen_per.erl", [59..69],
          [{"asn1/src/asn1ct_gen_per.erl:60", "asn1ct_func:is_used(MFA)"},
           {"asn1/src/asn1ct_gen_per.erl:67", ~S/{call,M,F,Args}/}],
          "The PER suppression path has the same existing-MFA membership check and source emission shape as JER; M/F are already atoms in the incoming generator record and no string-to-atom path is present."),
        review("asn1/src/asn1ct_imm.erl", [470..492, 507..540, 2367..2454],
          [{"asn1/src/asn1ct_imm.erl:524", "asn1ct_func:call(per_common"},
           {"asn1/src/asn1ct_imm.erl:2396", "enc_cg({call,M,F,As0}) ->"},
           {"asn1/src/asn1ct_imm.erl:2398", "asn1ct_func:call(M, F, As)"},
           {"asn1/src/asn1ct_imm.erl:2403", "enc_cg({call_gen,Prefix,Key,Gen,_,As0}) ->"},
           {"asn1/src/asn1ct_imm.erl:2405", "asn1ct_func:call_gen(Prefix, Key, Gen, As)"}],
          "dec_string/4 builds an arity-two closure whose captured module/function are the fixed per_common:decode_fragmented pair; the closure is carried in IR and not executed during this review. enc_cg/1 forwards pre-existing M/F atoms through call/3 and an IR-supplied Prefix/Key/Gen closure through call_gen/4. The latter prefix's producer is outside the allocated complete spans, so its origin remains unresolved here; since it reaches handle_call/3's atom builder, it stays an active caller-input trace for later reconciliation, without assigning an invented origin or changing guards.")
      ],
      incoming_edges: incoming_edges()
    }
  end

  def incoming_edges do
    [
      edge({:asn1ct_constructed_ber_bin_v2, :call, 2}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:1503", "asn1ct_func:call(ber, F, Args)"}]),
      edge({:asn1ct_constructed_ber_bin_v2, :gen_dec_call1, 7}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:1384", "asn1ct_func:need({ber,match_tags,2})"}]),
      edge({:asn1ct_constructed_ber_bin_v2, :gen_encode_sequence, 3}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:151", "asn1ct_func:need({ber,dynamicsort_SET_components,1})"}]),
      edge({:asn1ct_constructed_ber_bin_v2, :gen_encode_sof_components, 4}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_constructed_ber_bin_v2.erl:598", "asn1ct_func:need({ber,dynamicsort_SETOF,1})"}]),
      edge({:asn1ct_constructed_per, :dec_objset_2, 4}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:638", "asn1ct_func:call_gen(Prefix, Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :do_gen_dec_fragmented_1, 6}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:768", "asn1ct_func:call_gen(\"dec_fragment\", Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :do_gen_decode_fragmented, 4}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:755", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :do_gen_decode_sof_plain, 5}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:788", "asn1ct_func:call_gen(\"dec_components\", Key, Gen)"}]),
      edge({:asn1ct_constructed_per, :gen_dec_components_call, 6}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_constructed_per.erl:1331", "asn1ct_func:call(Mod, skipextensions"}]),
      edge({:asn1ct_constructed_per, :gen_dec_open_type, 5}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_constructed_per.erl:587", "asn1ct_func:call_gen(Prefix, Key, Gen)"}]),
      edge({:asn1ct_func, :call, 3}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_func.erl:41", "need(MFA)"}]),
      edge({:asn1ct_gen, :do_emit, 1}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen.erl:1100", "asn1ct_func:need(MFA)"}]),
      edge({:asn1ct_gen, :pgen, 3}, {:asn1ct_func, :generate, 1}, [{"asn1/src/asn1ct_gen.erl:92", "asn1ct_func:generate(Fd)"}]),
      edge({:asn1ct_gen, :pgen, 3}, {:asn1ct_func, :start_link, 0}, [{"asn1/src/asn1ct_gen.erl:79", "asn1ct_func:start_link()"}]),
      edge({:asn1ct_gen, :pgen_dispatcher, 2}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen.erl:767", "asn1ct_func:need({per,complete,1})"}, {"asn1/src/asn1ct_gen.erl:774", "asn1ct_func:need({uper,complete_NFP,1})"}, {"asn1/src/asn1ct_gen.erl:777", "asn1ct_func:need({uper,complete,1})"}]),
      edge({:asn1ct_gen, :pgen_dispatcher_decode, 3}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen.erl:853", "asn1ct_func:need({ber,ber_decode_nif,1})"}, {"asn1/src/asn1ct_gen.erl:856", "asn1ct_func:need({ber,ber_decode_nif,1})"}]),
      edge({:asn1ct_gen_ber_bin_v2, :call, 2}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_gen_ber_bin_v2.erl:1596", "asn1ct_func:call(ber, F, Args)"}]),
      edge({:asn1ct_gen_ber_bin_v2, :suppress, 2}, {:asn1ct_func, :is_used, 1}, [{"asn1/src/asn1ct_gen_ber_bin_v2.erl:102", "asn1ct_func:is_used(MFA)"}]),
      edge({:asn1ct_gen_check, :do_gen, 3}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_gen_check.erl:113", "asn1ct_func:call_gen(\"is_default_choice\""}]),
      edge({:asn1ct_gen_check, :do_seq_set, 3}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_gen_check.erl:162", "asn1ct_func:call_gen(\"is_default_cs_\""}, {"asn1/src/asn1ct_gen_check.erl:181", "asn1ct_func:call_gen(\"is_default_cs_\""}]),
      edge({:asn1ct_gen_check, :do_sof, 3}, {:asn1ct_func, :call_gen, 3}, [{"asn1/src/asn1ct_gen_check.erl:199", "asn1ct_func:call_gen(\"is_default_sof\""}]),
      edge({:asn1ct_gen_check, :emit, 4}, {:asn1ct_func, :call_gen, 4}, [{"asn1/src/asn1ct_gen_check.erl:38", "asn1ct_func:call_gen(\"is_default_\""}]),
      edge({:asn1ct_gen_check, :need, 2}, {:asn1ct_func, :need, 1}, [{"asn1/src/asn1ct_gen_check.erl:341", "asn1ct_func:need({check,F,A})"}]),
      edge({:asn1ct_gen_jer, :suppress, 1}, {:asn1ct_func, :is_used, 1}, [{"asn1/src/asn1ct_gen_jer.erl:359", "asn1ct_func:is_used(MFA)"}]),
      edge({:asn1ct_gen_per, :suppress, 1}, {:asn1ct_func, :is_used, 1}, [{"asn1/src/asn1ct_gen_per.erl:60", "asn1ct_func:is_used(MFA)"}]),
      edge({:asn1ct_imm, :dec_string, 4}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_imm.erl:524", "asn1ct_func:call(per_common"}]),
      edge({:asn1ct_imm, :enc_cg, 1}, {:asn1ct_func, :call, 3}, [{"asn1/src/asn1ct_imm.erl:2398", "asn1ct_func:call(M, F, As)"}]),
      edge({:asn1ct_imm, :enc_cg, 1}, {:asn1ct_func, :call_gen, 4}, [{"asn1/src/asn1ct_imm.erl:2405", "asn1ct_func:call_gen(Prefix, Key, Gen, As)"}])
    ]
  end

  defp review(source_path, reviewed_lines, citations, finding) do
    %{source_path: source_path, reviewed_lines: reviewed_lines, citations: citations, finding: finding}
  end

  defp edge(caller, callee, citations), do: %{caller: caller, callee: callee, citations: citations}
end
