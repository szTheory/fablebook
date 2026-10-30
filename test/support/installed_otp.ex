defmodule Fablebook.Test.InstalledOtp do
  @moduledoc false
  @compile {:no_warn_undefined, :xref}

  alias Fablebook.Test.BeamWalker
  alias Fablebook.Test.SweepEvidence

  @marker "FABLEBOOK_OTP_INVENTORY_V1 "
  @lanes %{
    "core" => %{elixir: "1.20.4", otp: "29.1.2"},
    "floor" => %{elixir: "1.18.5", otp: "27.3.4.9"}
  }

  defmodule Error do
    defexception [:reason, :detail]

    @impl true
    def message(%{reason: reason, detail: detail}),
      do: "installed OTP inventory #{reason}: #{inspect(detail)}"
  end

  def discover!(root, opts \\ []) do
    lane = Keyword.get(opts, :lane, lane_name())
    root = Path.expand(root)
    ensure_directory!(root, %{lane: lane, root: root})

    apps =
      root
      |> File.ls!()
      |> Enum.sort()
      |> Enum.flat_map(fn name ->
        path = Path.join(root, name)

        case File.lstat(path) do
          {:ok, %{type: :directory}} ->
            [discover_app!(name, path, lane)]

          {:ok, %{type: :symlink}} ->
            fail!(:app_root_symlink, %{lane: lane, path: relative(root, path)})

          {:ok, %{type: :regular}} ->
            []

          {:ok, stat} ->
            fail!(:app_root_type, %{lane: lane, path: relative(root, path), type: stat.type})

          {:error, reason} ->
            fail!(:app_root_unreadable, %{lane: lane, path: relative(root, path), reason: reason})
        end
      end)

    duplicate_apps =
      apps |> Enum.group_by(& &1.app) |> Enum.filter(fn {_app, rows} -> length(rows) > 1 end)

    if duplicate_apps != [], do: fail!(:duplicate_app, %{lane: lane, apps: duplicate_apps})

    duplicate_modules =
      apps
      |> Enum.flat_map(fn app -> Enum.map(app.beams, &{&1.module, app.app, &1.relative}) end)
      |> Enum.group_by(&elem(&1, 0))
      |> Enum.filter(fn {_module, rows} -> length(rows) > 1 end)

    if duplicate_modules != [],
      do: fail!(:duplicate_module, %{lane: lane, modules: duplicate_modules})

    apps
  rescue
    error in Error ->
      reraise error, __STACKTRACE__

    error ->
      fail!(:discovery_error, %{
        lane: Keyword.get(opts, :lane, lane_name()),
        root: Path.expand(root),
        error: Exception.message(error)
      })
  end

  def app_roots!(root, opts \\ []) do
    root = Path.expand(root)
    lane = Keyword.get(opts, :lane, lane_name())
    ensure_directory!(root, %{lane: lane, root: root})

    apps =
      root
      |> File.ls!()
      |> Enum.sort()
      |> Enum.flat_map(fn name ->
        path = Path.join(root, name)

        case File.lstat(path) do
          {:ok, %{type: :directory}} ->
            record = read_app_resource!(name, path, lane)
            [%{app: record.app, version: record.version, root: path, ebin: record.ebin}]

          {:ok, %{type: :symlink}} ->
            fail!(:app_root_symlink, %{lane: lane, path: name})

          {:ok, %{type: :regular}} ->
            []

          {:ok, stat} ->
            fail!(:app_root_type, %{lane: lane, path: name, type: stat.type})

          {:error, reason} ->
            fail!(:app_root_unreadable, %{lane: lane, path: name, reason: reason})
        end
      end)

    duplicates =
      apps |> Enum.group_by(& &1.app) |> Enum.filter(fn {_app, rows} -> length(rows) > 1 end)

    if duplicates != [], do: fail!(:duplicate_app, %{lane: lane, apps: duplicates})
    apps
  end

  def inspect!(apps, opts \\ []) do
    lane = Keyword.get(opts, :lane, lane_name())
    scanner = Keyword.get(opts, :scan, fn beam -> BeamWalker.scan(beam.path) end)

    Enum.flat_map(apps, fn app ->
      Enum.map(app.beams, &inspect_beam!(&1, app, scanner, lane))
    end)
  end

  def add_directory!(xref, app, opts \\ []) do
    lane = Keyword.get(opts, :lane, lane_name())

    case :xref.add_directory(xref, String.to_charlist(app.ebin)) do
      {:ok, modules} when is_list(modules) ->
        rows = Enum.map(modules, &%{app: app.app, module: Atom.to_string(&1), module_atom: &1})
        assert_unique!(rows, :xref, lane)
        rows

      result ->
        fail!(:xref_ingest, %{lane: lane, app: app.app, ebin: app.ebin, result: inspect(result)})
    end
  end

  def assert_parity!(discovered, inspected, ingested),
    do: assert_parity!(discovered, inspected, ingested, lane_name())

  def assert_parity!(discovered, inspected, ingested, lane) do
    discovered_rows =
      Enum.flat_map(discovered, fn app ->
        Enum.map(app.beams, &%{app: app.app, module: &1.module})
      end)

    inspected_rows = Enum.map(inspected, &%{app: &1.app, module: &1.module})

    assert_unique!(discovered_rows, :discovered, lane)
    assert_unique!(inspected_rows, :inspected, lane)
    assert_unique!(ingested, :ingested, lane)

    sets = %{
      discovered: identities(discovered_rows),
      inspected: identities(inspected_rows),
      ingested: identities(ingested)
    }

    if sets.discovered != sets.inspected or sets.discovered != sets.ingested do
      fail!(:identity_parity, %{
        lane: lane,
        missing_inspected: MapSet.to_list(MapSet.difference(sets.discovered, sets.inspected)),
        extra_inspected: MapSet.to_list(MapSet.difference(sets.inspected, sets.discovered)),
        missing_ingested: MapSet.to_list(MapSet.difference(sets.discovered, sets.ingested)),
        extra_ingested: MapSet.to_list(MapSet.difference(sets.ingested, sets.discovered))
      })
    end

    :ok
  end

  def receipt_lines(
        %{lane: lane, discovered: discovered, inspected: inspected, ingested: ingested} = receipt
      ) do
    assert_parity!(discovered, inspected, ingested, lane.name)
    validate_nonempty_inventory!(discovered, inspected, ingested)
    validate_lane!(lane.name, lane.elixir, lane.otp)
    validate_lock!(lane.name, receipt.lock_sha256, SweepEvidence.lock_digests!())
    inspected_by_id = Map.new(inspected, &{{&1.app, &1.module}, &1})
    ingested_ids = identities(ingested)

    records =
      [
        %{
          "kind" => "meta",
          "schema" => "fablebook.otp-inventory.v1",
          "lane" => lane.name,
          "elixir" => lane.elixir,
          "otp" => lane.otp,
          "lock_sha256" => receipt.lock_sha256
        }
      ] ++
        Enum.flat_map(discovered, fn app ->
          app_record = %{
            "kind" => "app",
            "app" => app.app,
            "version" => app.version,
            "path" => app.relative
          }

          beam_records =
            Enum.map(app.beams, fn beam ->
              inspection = Map.fetch!(inspected_by_id, {app.app, beam.module})

              %{
                "kind" => "beam",
                "app" => app.app,
                "version" => app.version,
                "module" => beam.module,
                "path" => beam.relative,
                "inspection" => "ok",
                "xref" =>
                  if(MapSet.member?(ingested_ids, {app.app, beam.module}),
                    do: "ok",
                    else: "missing"
                  ),
                "function_count" => inspection.function_count,
                "source" => safe_source(app.app, app.relative, inspection.source)
              }
            end)

          [app_record | beam_records]
        end)

    encoded = Enum.map(records, &([@marker, JSON.encode!(&1)] |> IO.iodata_to_binary()))
    digest = sha256(Enum.join(encoded, "\n") <> "\n")

    footer = %{
      "kind" => "footer",
      "apps" => length(discovered),
      "beams" => length(inspected),
      "sha256" => digest
    }

    encoded ++ [@marker <> JSON.encode!(footer)]
  end

  def verify_receipt_lines!(lines) when is_list(lines) do
    verify_receipt_lines!(lines, SweepEvidence.lock_digests!())
  end

  def verify_receipt_lines!(_lines), do: fail!(:receipt_format, :not_a_list)

  defp verify_receipt_lines!(lines, lock_digests) when is_list(lines) do
    records = parse_lines!(lines)
    [meta | _] = records
    footer = List.last(records)
    body = Enum.drop(records, -1)
    beam_rows = Enum.filter(body, &(&1["kind"] == "beam"))
    app_rows = Enum.filter(body, &(&1["kind"] == "app"))

    validate_receipt_meta!(meta)
    validate_receipt_footer!(footer, app_rows, beam_rows, Enum.drop(lines, -1))
    validate_receipt_rows!(app_rows, beam_rows)
    validate_lane!(meta["lane"], meta["elixir"], meta["otp"])
    validate_lock!(meta["lane"], meta["lock_sha256"], lock_digests)

    %{lane: meta["lane"], apps: app_rows, beams: beam_rows, sha256: footer["sha256"]}
  end

  def extract_receipt!(log_path, receipt_path) do
    lines =
      log_path
      |> File.read!()
      |> String.split("\n")
      |> Enum.flat_map(fn line ->
        case String.split(String.trim(line), @marker, parts: 2) do
          [_prefix, payload] -> [@marker <> String.trim(payload)]
          _ -> []
        end
      end)

    verify_receipt_lines!(lines)
    File.write!(receipt_path, Enum.join(lines, "\n") <> "\n")
    receipt_path
  rescue
    error in Error ->
      reraise error, __STACKTRACE__

    error ->
      fail!(:receipt_extract, %{
        log: log_path,
        output: receipt_path,
        error: Exception.message(error)
      })
  end

  def verify_receipt_files!(paths) when is_list(paths) do
    lock_digests = SweepEvidence.lock_digests!()

    receipts =
      Enum.map(paths, fn path ->
        {path,
         verify_receipt_lines!(
           File.read!(path) |> String.split("\n", trim: true),
           lock_digests
         )}
      end)

    lanes = Map.new(receipts, fn {path, receipt} -> {receipt.lane, {path, receipt}} end)

    unless length(receipts) == 2 and map_size(lanes) == 2 and
             Map.keys(lanes) |> Enum.sort() == ["core", "floor"],
           do: fail!(:receipt_set, Map.keys(lanes))

    lanes
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {lane, {path, receipt}} ->
      %{
        lane: lane,
        path: path,
        apps: length(receipt.apps),
        beams: length(receipt.beams),
        sha256: receipt.sha256
      }
    end)
  end

  defp discover_app!(name, path, lane) do
    app = read_app_resource!(name, path, lane)

    beams =
      app.ebin
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".beam"))
      |> Enum.sort()
      |> Enum.map(fn file -> read_beam_identity!(app, file, lane) end)

    duplicate =
      beams
      |> Enum.group_by(& &1.module)
      |> Enum.filter(fn {_module, rows} -> length(rows) > 1 end)

    if duplicate != [],
      do: fail!(:duplicate_module, %{lane: lane, app: app.app, modules: duplicate})

    Map.put(app, :beams, beams)
  rescue
    error in Error ->
      reraise error, __STACKTRACE__

    error ->
      fail!(:app_discovery, %{lane: lane, app_root: name, error: Exception.message(error)})
  end

  defp read_app_resource!(name, path, lane) do
    ebin = Path.join(path, "ebin")

    ensure_directory!(ebin, %{
      lane: lane,
      app_root: name,
      ebin: relative(Path.dirname(path), ebin)
    })

    app_files = File.ls!(ebin) |> Enum.filter(&String.ends_with?(&1, ".app"))

    if length(app_files) != 1,
      do:
        fail!(:app_resource_count, %{
          lane: lane,
          app_root: name,
          ebin: "#{name}/ebin",
          files: app_files
        })

    app_file = Path.join(ebin, hd(app_files))

    ensure_regular_file!(app_file, %{
      lane: lane,
      app_root: name,
      file: "#{name}/ebin/#{hd(app_files)}"
    })

    app_term =
      case :file.consult(String.to_charlist(app_file)) do
        {:ok, [{:application, app_atom, properties}]}
        when is_atom(app_atom) and is_list(properties) ->
          {Atom.to_string(app_atom), properties}

        result ->
          fail!(:app_resource, %{
            lane: lane,
            app_root: name,
            file: "#{name}/ebin/#{hd(app_files)}",
            result: inspect(result)
          })
      end

    {app_name, properties} = app_term
    version = properties |> Keyword.get(:vsn) |> version_string()
    expected_dir = "#{app_name}-#{version}"

    if name != expected_dir or hd(app_files) != "#{app_name}.app",
      do:
        fail!(:app_identity, %{
          lane: lane,
          app_root: name,
          app: app_name,
          version: version,
          resource: hd(app_files)
        })

    %{app: app_name, version: version, root: path, ebin: ebin, relative: name}
  rescue
    error in Error ->
      reraise error, __STACKTRACE__

    error ->
      fail!(:app_resource_read, %{lane: lane, app_root: name, error: Exception.message(error)})
  end

  defp read_beam_identity!(app, file, lane) do
    path = Path.join(app.ebin, file)
    relative_path = Path.join([app.relative, "ebin", file])
    ensure_regular_file!(path, %{lane: lane, app: app.app, beam: relative_path})

    module =
      case :beam_lib.chunks(String.to_charlist(path), []) do
        {:ok, {module, []}} when is_atom(module) ->
          Atom.to_string(module)

        result ->
          fail!(:beam_identity, %{
            lane: lane,
            app: app.app,
            beam: relative_path,
            result: inspect(result)
          })
      end

    expected_module = String.replace_suffix(file, ".beam", "")

    if module != expected_module,
      do:
        fail!(:beam_filename_identity, %{
          lane: lane,
          app: app.app,
          beam: relative_path,
          expected: expected_module,
          actual: module
        })

    %{app: app.app, version: app.version, module: module, path: path, relative: relative_path}
  end

  defp parse_lines!(lines) do
    unless Enum.all?(lines, &String.starts_with?(&1, @marker)),
      do: fail!(:receipt_marker, :missing_or_invalid)

    records =
      Enum.map(lines, fn line ->
        case JSON.decode(String.replace_prefix(line, @marker, "")) do
          {:ok, row} when is_map(row) -> row
          result -> fail!(:receipt_json, inspect(result))
        end
      end)

    kinds = Enum.map(records, & &1["kind"])

    unless length(records) >= 2 and hd(kinds) == "meta" and List.last(kinds) == "footer",
      do: fail!(:receipt_order, kinds)

    unless Enum.count(kinds, &(&1 == "footer")) == 1 and Enum.count(kinds, &(&1 == "meta")) == 1,
      do: fail!(:receipt_duplicate_record, kinds)

    records
  end

  defp validate_receipt_meta!(meta) do
    unless meta["kind"] == "meta" and meta["schema"] == "fablebook.otp-inventory.v1",
      do: fail!(:receipt_meta, meta)
  end

  defp validate_receipt_footer!(footer, app_rows, beam_rows, body_lines) do
    valid =
      footer["kind"] == "footer" and footer["apps"] == length(app_rows) and
        footer["beams"] == length(beam_rows) and
        footer["sha256"] == sha256(Enum.join(body_lines, "\n") <> "\n")

    unless valid, do: fail!(:receipt_footer, footer)
  end

  defp validate_receipt_rows!(app_rows, beam_rows) do
    validate_nonempty_inventory!(app_rows, beam_rows)
    validate_unique_apps!(app_rows)
    validate_unique_beams!(beam_rows)
    validate_beam_app_links!(app_rows, beam_rows)
  end

  defp validate_nonempty_inventory!(discovered, inspected, ingested) do
    if discovered == [] or inspected == [] or ingested == [],
      do:
        fail!(:receipt_empty_inventory, %{
          apps: length(discovered),
          inspected: length(inspected),
          ingested: length(ingested)
        })
  end

  defp validate_nonempty_inventory!(app_rows, beam_rows) do
    if app_rows == [] or beam_rows == [],
      do: fail!(:receipt_empty_inventory, %{apps: length(app_rows), beams: length(beam_rows)})
  end

  defp validate_unique_apps!(app_rows) do
    invalid =
      Enum.reject(app_rows, fn row ->
        app = row["app"]
        version = row["version"]
        path = row["path"]

        valid_app_version?(app, version) and path == "#{app}-#{version}" and
          safe_receipt_path?(path)
      end)

    duplicate =
      app_rows
      |> Enum.group_by(& &1["app"])
      |> Enum.filter(fn {_app, rows} -> length(rows) > 1 end)

    if invalid != [] or duplicate != [],
      do: fail!(:receipt_app_records, %{invalid: invalid, duplicate: duplicate})
  end

  defp validate_unique_beams!(beam_rows) do
    duplicate =
      beam_rows
      |> Enum.group_by(&{&1["app"], &1["module"]})
      |> Enum.filter(fn {_id, rows} -> length(rows) > 1 end)

    invalid = Enum.reject(beam_rows, &valid_beam_row?/1)

    if duplicate != [] or invalid != [],
      do: fail!(:receipt_beam_records, %{duplicate: duplicate, invalid: invalid})
  end

  defp validate_beam_app_links!(app_rows, beam_rows) do
    apps = Map.new(app_rows, &{&1["app"], &1["version"]})

    invalid =
      Enum.reject(beam_rows, fn row ->
        version = apps[row["app"]]

        is_binary(version) and version == row["version"] and
          String.starts_with?(row["path"], "#{row["app"]}-#{version}/ebin/")
      end)

    if invalid != [], do: fail!(:receipt_beam_app, invalid)
  end

  defp valid_beam_row?(row) do
    app = row["app"]
    version = row["version"]
    module = row["module"]
    path = row["path"]

    valid_app_version?(app, version) and valid_module?(module) and valid_beam_path?(path, module) and
      row["inspection"] == "ok" and row["xref"] == "ok" and
      valid_function_count?(row["function_count"])
  end

  defp valid_app_version?(app, version) do
    is_binary(app) and app != "" and is_binary(version) and version != ""
  end

  defp valid_module?(module), do: is_binary(module) and module != ""

  defp valid_beam_path?(path, module) do
    is_binary(path) and safe_receipt_path?(path) and Path.basename(path) == module <> ".beam"
  end

  defp valid_function_count?(count), do: is_integer(count) and count >= 0

  defp validate_lane!(lane, elixir, otp) do
    expected = @lanes[lane]

    unless expected && elixir == expected.elixir && otp == expected.otp,
      do: fail!(:receipt_lane, %{lane: lane, elixir: elixir, otp: otp})
  end

  defp validate_lock!(lane, actual, lock_digests) do
    expected = lock_digests[lane]

    unless is_binary(actual) and Regex.match?(~r/^[a-f0-9]{64}$/, actual) and actual == expected,
      do: fail!(:receipt_lock_identity, %{lane: lane, expected: expected, actual: actual})
  end

  defp safe_receipt_path?(path) do
    is_binary(path) and path != "" and Path.type(path) == :relative and
      not String.contains?(path, ["\\", "\0", ":"]) and
      Enum.all?(String.split(path, "/"), &(&1 not in ["", ".", ".."]))
  end

  defp safe_source(app, app_root, source) when is_binary(source) do
    parts = String.split(String.replace(source, "\\", "/"), "/", trim: true)

    case Enum.find_index(parts, &(&1 == app_root or &1 == app)) do
      nil ->
        if Path.type(source) == :relative and not String.contains?(source, ["..", "\\"]),
          do: source,
          else: nil

      index ->
        Enum.drop(parts, index + 1) |> Path.join() |> safe_relative()
    end
  end

  defp safe_source(_app, _app_root, _source), do: nil

  defp safe_relative(path),
    do:
      if(path != "" and Path.type(path) == :relative and not String.contains?(path, ["..", "\\"]),
        do: path,
        else: nil
      )

  defp version_string(value) when is_binary(value) and value != "", do: value
  defp version_string(value) when is_list(value) and value != [], do: List.to_string(value)
  defp version_string(value), do: fail!(:app_version, inspect(value))

  defp ensure_directory!(path, detail) do
    case File.lstat(path) do
      {:ok, %{type: :directory}} -> :ok
      {:ok, stat} -> fail!(:directory_type, Map.put(detail, :type, stat.type))
      {:error, reason} -> fail!(:directory_missing, Map.put(detail, :reason, reason))
    end
  end

  defp ensure_regular_file!(path, detail) do
    case File.lstat(path) do
      {:ok, %{type: :regular}} -> :ok
      {:ok, stat} -> fail!(:file_type, Map.put(detail, :type, stat.type))
      {:error, reason} -> fail!(:file_unreadable, Map.put(detail, :reason, reason))
    end
  end

  defp identities(rows), do: MapSet.new(rows, &{&1.app, &1.module})

  defp safe_scan!(scanner, beam, app, lane) do
    scanner.(beam)
  rescue
    error ->
      fail!(:inspection_exception, %{
        lane: lane,
        app: app.app,
        beam: beam.relative,
        error: Exception.message(error)
      })
  end

  defp inspect_beam!(beam, app, scanner, lane) do
    case safe_scan!(scanner, beam, app, lane) do
      {:ok, scan} when is_map(scan) ->
        module = Atom.to_string(scan.module)

        if module != beam.module do
          fail!(:inspection_identity, %{
            lane: lane,
            app: app.app,
            beam: beam.relative,
            expected: beam.module,
            actual: module
          })
        end

        Map.merge(beam, %{
          app: app.app,
          version: app.version,
          module_atom: scan.module,
          source: scan.source,
          function_mfas: scan.function_mfas,
          function_count: scan.function_count,
          edges: scan.edges,
          imports: scan.mfas,
          pairs: scan.pairs,
          literals: scan.literals
        })

      {:error, reason} ->
        fail!(:inspection_failed, %{
          lane: lane,
          app: app.app,
          beam: beam.relative,
          reason: reason
        })

      other ->
        fail!(:inspection_result, %{
          lane: lane,
          app: app.app,
          beam: beam.relative,
          result: inspect(other)
        })
    end
  end

  defp assert_unique!(rows, label, lane) do
    duplicate =
      rows
      |> Enum.group_by(&{&1.app, &1.module})
      |> Enum.filter(fn {_id, items} -> length(items) > 1 end)

    if duplicate != [],
      do: fail!(:duplicate_identity, %{lane: lane, source: label, identities: duplicate})
  end

  defp lane_name,
    do: if(System.get_env("FABLEBOOK_FLOOR") in [nil, ""], do: "core", else: "floor")

  defp relative(root, path), do: Path.relative_to(path, root)
  defp sha256(data), do: :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  defp fail!(reason, detail), do: raise(Error, reason: reason, detail: detail)
end
