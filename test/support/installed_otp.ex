defmodule Fablebook.Test.InstalledOtp do
  @moduledoc false
  @compile {:no_warn_undefined, :xref}

  alias Fablebook.Test.BeamWalker
  alias Fablebook.Test.SweepEvidence

  @marker "FABLEBOOK_OTP_INVENTORY_V2 "
  @record_kinds ~w(
                  meta
                  app
                  beam
                  source_app
                  source_file
                  active_app
                  active_module
                  active_export
                  active_edge
                  export
                  reached
                  boundary
                  pending_app
                  pending_module
                  pending_mfa
                  metrics
                  footer
                )
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
    beam_chunks = Keyword.get(opts, :beam_chunks, &:beam_lib.chunks/2)
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
            [discover_app!(name, path, lane, beam_chunks)]

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

  def assert_discovery_complete!(root, discovered, opts \\ []) do
    lane = Keyword.get(opts, :lane, lane_name())
    installed = raw_inventory!(root, lane)

    expected =
      Map.new(discovered, fn app ->
        {app.relative, MapSet.new(app.beams, &Path.basename(&1.relative, ".beam"))}
      end)

    expected_names = MapSet.new(Map.keys(installed))
    actual_names = MapSet.new(Map.keys(expected))

    missing_apps = MapSet.difference(expected_names, actual_names)
    extra_apps = MapSet.difference(actual_names, expected_names)

    beam_mismatches =
      Enum.flat_map(installed, fn {app, modules} ->
        actual_modules = Map.get(expected, app, MapSet.new())
        missing = MapSet.difference(modules, actual_modules)
        extra = MapSet.difference(actual_modules, modules)

        if MapSet.size(missing) + MapSet.size(extra) == 0,
          do: [],
          else: [
            %{
              app: app,
              missing_beams: MapSet.to_list(missing),
              extra_beams: MapSet.to_list(extra)
            }
          ]
      end)

    if MapSet.size(missing_apps) > 0 or MapSet.size(extra_apps) > 0 or beam_mismatches != [] do
      fail!(:discovery_parity, %{
        lane: lane,
        missing_apps: MapSet.to_list(missing_apps),
        extra_apps: MapSet.to_list(extra_apps),
        beam_mismatches: beam_mismatches
      })
    end

    :ok
  end

  def source_inventory!(apps, inspected, opts \\ []) do
    lane = Keyword.get(opts, :lane, lane_name())
    reader = Keyword.get(opts, :source_reader, &File.read/1)
    required_modules = opts |> Keyword.get(:required_modules, []) |> module_names()

    Enum.map(apps, fn app ->
      source_app!(
        app,
        Enum.filter(inspected, &(&1.app == app.app)),
        lane,
        reader,
        required_modules
      )
    end)
  end

  def add_directory!(xref, app, opts \\ []) do
    lane = Keyword.get(opts, :lane, lane_name())
    add_directory = Keyword.get(opts, :add_directory, &:xref.add_directory/2)

    case add_directory.(xref, String.to_charlist(app.ebin)) do
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

  def export_inventory!(directories, opts \\ []) when is_list(directories) do
    lane = Keyword.get(opts, :lane, lane_name())
    beam_chunks = Keyword.get(opts, :beam_chunks, &:beam_lib.chunks/2)

    exports =
      directories
      |> Enum.flat_map(&export_inventory_directory!(&1, lane, beam_chunks))

    duplicate = exports |> Enum.frequencies() |> Enum.filter(fn {_row, count} -> count > 1 end)
    if duplicate != [], do: fail!(:export_inventory_duplicate, %{lane: lane, exports: duplicate})
    exports
  rescue
    error in Error ->
      reraise error, __STACKTRACE__

    error ->
      fail!(:export_inventory_read, %{
        lane: Keyword.get(opts, :lane, lane_name()),
        error: Exception.message(error)
      })
  end

  defp export_inventory_directory!(directory, lane, beam_chunks) do
    directory
    |> File.ls!()
    |> Enum.sort()
    |> Enum.filter(&String.ends_with?(&1, ".beam"))
    |> Enum.flat_map(&export_inventory_beam!(directory, &1, lane, beam_chunks))
  end

  defp export_inventory_beam!(directory, filename, lane, beam_chunks) do
    path = Path.join(directory, filename)
    expected_module = String.replace_suffix(filename, ".beam", "")

    case beam_chunks.(String.to_charlist(path), [:exports]) do
      {:ok, {module, [exports: rows]}} when is_atom(module) and is_list(rows) ->
        if Atom.to_string(module) != expected_module do
          fail!(:export_inventory_identity, %{
            lane: lane,
            beam: Path.join(Path.basename(directory), filename),
            expected: expected_module,
            actual: Atom.to_string(module)
          })
        end

        Enum.map(rows, &export_inventory_row!(&1, directory, filename, lane, module))

      result ->
        fail!(:export_inventory_read, %{
          lane: lane,
          beam: Path.join(Path.basename(directory), filename),
          result: inspect(result)
        })
    end
  end

  defp export_inventory_row!({function, arity}, _directory, _filename, _lane, module)
       when is_atom(function) and is_integer(arity) and arity >= 0,
       do: {module, function, arity}

  defp export_inventory_row!(row, directory, filename, lane, _module) do
    fail!(:export_inventory_row, %{
      lane: lane,
      beam: Path.join(Path.basename(directory), filename),
      row: inspect(row)
    })
  end

  def assert_xref_query!(query_fun, label, lane, expected_rows, normalize \\ &Function.identity/1)
      when is_function(query_fun, 0) and is_list(expected_rows) and is_function(normalize, 1) do
    case query_fun.() do
      {:ok, rows} when is_list(rows) ->
        normalized = Enum.map(rows, normalize)
        expected = MapSet.new(Enum.map(expected_rows, normalize))
        actual = MapSet.new(normalized)

        duplicate_rows =
          rows
          |> Enum.frequencies()
          |> Enum.filter(fn {_row, count} -> count > 1 end)
          |> Enum.map(&elem(&1, 0))

        missing = MapSet.difference(expected, actual) |> MapSet.to_list() |> Enum.sort()
        extra = MapSet.difference(actual, expected) |> MapSet.to_list() |> Enum.sort()

        if duplicate_rows != [] or missing != [] or extra != [] do
          fail!(:xref_query_parity, %{
            lane: lane,
            query: label,
            duplicate_rows: Enum.take(duplicate_rows, 20),
            missing: Enum.take(missing, 20),
            extra: Enum.take(extra, 20),
            expected_count: MapSet.size(expected),
            actual_count: MapSet.size(actual)
          })
        end

        rows

      result ->
        fail!(:xref_query, %{lane: lane, query: label, result: inspect(result)})
    end
  rescue
    error in Error ->
      reraise error, __STACKTRACE__

    error ->
      fail!(:xref_query_row, %{
        lane: lane,
        query: label,
        error: Exception.message(error)
      })
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

    sources =
      Map.get_lazy(receipt, :sources, fn ->
        source_inventory!(discovered, inspected, lane: lane.name)
      end)

    source_apps = Map.new(sources, &{&1.app, &1})

    source_beams =
      Map.new(sources, fn source ->
        {source.app, Map.new(source.beams, &{&1.module, &1})}
      end)

    source_file_records =
      Enum.flat_map(sources, fn source ->
        source.source_files
        |> Enum.sort_by(&elem(&1, 0))
        |> Enum.map(fn {path, bytes} ->
          %{"kind" => "source_file", "app" => source.app, "path" => path, "bytes" => bytes}
        end)
      end)

    active_records = Map.get(receipt, :active_membership, [])
    export_records = Map.get(receipt, :export_records, [])
    reached_records = Map.get(receipt, :reached_records, [])
    boundary_records = Map.get(receipt, :boundary_records, [])
    pending_records = Map.get(receipt, :pending_records, [])

    metrics =
      Map.get_lazy(receipt, :metrics, fn ->
        default_metrics(
          discovered,
          inspected,
          sources,
          active_records,
          export_records,
          reached_records,
          boundary_records,
          pending_records
        )
      end)

    records =
      [
        %{
          "kind" => "meta",
          "schema" => "fablebook.otp-inventory.v2",
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
            "path" => app.relative,
            "source_dir_status" => Map.fetch!(source_apps, app.app).source_dir_status,
            "source_file_count" => Map.fetch!(source_apps, app.app).source_file_count,
            "source_bytes" => Map.fetch!(source_apps, app.app).source_bytes
          }

          beam_records =
            Enum.map(app.beams, fn beam ->
              inspection = Map.fetch!(inspected_by_id, {app.app, beam.module})
              source = Map.fetch!(source_beams[app.app], beam.module)

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
                "function_bytes" => inspection.function_bytes,
                "beam_bytes" => File.stat!(beam.path).size,
                "source" => source.source,
                "source_status" => source.status,
                "source_bytes" => source.bytes
              }
            end)

          [app_record | beam_records]
        end)

    source_app_records =
      Enum.map(sources, fn source ->
        %{
          "kind" => "source_app",
          "app" => source.app,
          "version" => source.version,
          "source_dir_status" => source.source_dir_status,
          "source_file_count" => source.source_file_count,
          "source_bytes" => source.source_bytes,
          "mapped_beams" => source.mapped_beams,
          "missing_source_beams" => source.missing_source_beams,
          "unavailable_source_beams" => source.unavailable_source_beams
        }
      end)

    measurement_record = Map.put(metrics, "kind", "metrics")

    records =
      records ++
        source_app_records ++
        source_file_records ++
        active_records ++
        export_records ++
        reached_records ++ boundary_records ++ pending_records ++ [measurement_record]

    encoded = Enum.map(records, &([@marker, JSON.encode!(&1)] |> IO.iodata_to_binary()))
    digest = sha256(Enum.join(encoded, "\n") <> "\n")

    footer = %{
      "kind" => "footer",
      "apps" => length(discovered),
      "beams" => length(inspected),
      "source_files" => length(source_file_records),
      "active_records" => length(active_records),
      "export_records" => length(export_records),
      "reached_records" => length(reached_records),
      "boundary_records" => length(boundary_records),
      "pending_records" => length(pending_records),
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
    source_app_rows = Enum.filter(body, &(&1["kind"] == "source_app"))
    source_file_rows = Enum.filter(body, &(&1["kind"] == "source_file"))
    active_rows = Enum.filter(body, &String.starts_with?(&1["kind"] || "", "active_"))
    export_rows = Enum.filter(body, &(&1["kind"] == "export"))
    reached_rows = Enum.filter(body, &(&1["kind"] == "reached"))
    boundary_rows = Enum.filter(body, &(&1["kind"] == "boundary"))
    pending_rows = Enum.filter(body, &String.starts_with?(&1["kind"] || "", "pending_"))
    metric_rows = Enum.filter(body, &(&1["kind"] == "metrics"))

    validate_receipt_meta!(meta)

    footer_counts = %{
      "apps" => length(app_rows),
      "beams" => length(beam_rows),
      "source_files" => length(source_file_rows),
      "active_records" => length(active_rows),
      "export_records" => length(export_rows),
      "reached_records" => length(reached_rows),
      "boundary_records" => length(boundary_rows),
      "pending_records" => length(pending_rows)
    }

    validate_receipt_footer!(footer, footer_counts, Enum.drop(lines, -1))

    validate_receipt_rows!(app_rows, beam_rows)
    validate_source_rows!(app_rows, beam_rows, source_app_rows, source_file_rows)
    validate_membership_rows!(active_rows, export_rows, reached_rows, boundary_rows, pending_rows)

    validate_receipt_links!(%{
      apps: app_rows,
      beams: beam_rows,
      source_files: source_file_rows,
      membership: active_rows ++ export_rows ++ reached_rows ++ boundary_rows ++ pending_rows
    })

    validate_receipt_metrics!(metric_rows, %{
      apps: app_rows,
      beams: beam_rows,
      source_files: source_file_rows,
      active: active_rows,
      exports: export_rows,
      reached: reached_rows,
      boundaries: boundary_rows,
      pending: pending_rows
    })

    validate_lane!(meta["lane"], meta["elixir"], meta["otp"])
    validate_lock!(meta["lane"], meta["lock_sha256"], lock_digests)

    %{
      lane: meta["lane"],
      apps: app_rows,
      beams: beam_rows,
      metrics: hd(metric_rows),
      pending: pending_rows,
      sha256: footer["sha256"]
    }
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

  defp discover_app!(name, path, lane, beam_chunks) do
    app = read_app_resource!(name, path, lane)

    beams =
      app.ebin
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".beam"))
      |> Enum.sort()
      |> Enum.map(fn file -> read_beam_identity!(app, file, lane, beam_chunks) end)

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

  defp read_beam_identity!(app, file, lane, beam_chunks) do
    path = Path.join(app.ebin, file)
    relative_path = Path.join([app.relative, "ebin", file])
    ensure_regular_file!(path, %{lane: lane, app: app.app, beam: relative_path})

    module =
      case beam_chunks.(String.to_charlist(path), []) do
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

  defp source_app!(app, inspected, lane, reader, required_modules) do
    source_root = Path.join(app.root, "src")
    {source_dir_status, files} = source_tree!(source_root, app, lane, reader)

    {beams, files} =
      Enum.map_reduce(inspected, files, fn beam, files ->
        relative_source = source_mapping!(app, beam, lane)
        {status, bytes, files} = source_mapping_status!(app, relative_source, files, lane, reader)

        if MapSet.member?(required_modules, beam.module) and status != "present" do
          fail!(:required_source_missing, %{
            lane: lane,
            app: app.app,
            beam: beam.relative,
            source: relative_source,
            status: status
          })
        end

        {%{module: beam.module, source: relative_source, status: status, bytes: bytes}, files}
      end)

    %{
      app: app.app,
      version: app.version,
      source_dir_status: source_dir_status,
      source_file_count: map_size(files),
      source_bytes: Enum.sum(Map.values(files)),
      source_files: files,
      mapped_beams: Enum.count(beams, &(&1.status == "present")),
      missing_source_beams: Enum.count(beams, &(&1.status == "missing")),
      unavailable_source_beams: Enum.count(beams, &(&1.status == "unavailable")),
      beams: beams
    }
  end

  defp source_tree!(source_root, app, lane, reader) do
    case File.lstat(source_root) do
      {:ok, %{type: :directory}} ->
        {"present", walk_source_tree!(app.root, source_root, app, lane, reader, %{})}

      {:error, :enoent} ->
        {"missing", %{}}

      {:error, reason} ->
        fail!(:source_directory_unreadable, %{lane: lane, app: app.app, reason: reason})

      {:ok, stat} ->
        fail!(:source_directory_type, %{lane: lane, app: app.app, type: stat.type})
    end
  end

  defp walk_source_tree!(root, directory, app, lane, reader, files) do
    children =
      case File.ls(directory) do
        {:ok, names} ->
          Enum.sort(names)

        {:error, reason} ->
          fail!(:source_directory_unreadable, %{
            lane: lane,
            app: app.app,
            path: relative(root, directory),
            reason: reason
          })
      end

    Enum.reduce(children, files, fn name, acc ->
      path = Path.join(directory, name)

      case File.lstat(path) do
        {:ok, %{type: :directory}} ->
          walk_source_tree!(root, path, app, lane, reader, acc)

        {:ok, %{type: :regular}} ->
          relative_path = Path.relative_to(path, root)
          Map.put(acc, relative_path, source_file_size!(path, app, lane, reader))

        {:ok, %{type: :symlink}} ->
          validate_source_link!(root, path, app, lane)

        {:ok, stat} ->
          fail!(:source_file_type, %{
            lane: lane,
            app: app.app,
            path: relative(root, path),
            type: stat.type
          })

        {:error, reason} ->
          fail!(:source_file_unreadable, %{
            lane: lane,
            app: app.app,
            path: relative(root, path),
            reason: reason
          })
      end
    end)
  end

  defp source_file_size!(path, app, lane, reader) do
    case reader.(path) do
      {:ok, bytes} when is_binary(bytes) ->
        byte_size(bytes)

      {:error, reason} ->
        fail!(:source_file_unreadable, %{
          lane: lane,
          app: app.app,
          path: Path.basename(path),
          reason: reason
        })

      other ->
        fail!(:source_read_result, %{
          lane: lane,
          app: app.app,
          path: Path.basename(path),
          result: inspect(other)
        })
    end
  rescue
    error ->
      fail!(:source_file_unreadable, %{
        lane: lane,
        app: app.app,
        path: Path.basename(path),
        error: Exception.message(error)
      })
  end

  defp validate_source_link!(root, path, app, lane) do
    target =
      case File.read_link(path) do
        {:ok, link} ->
          Path.expand(link, Path.dirname(path))

        {:error, reason} ->
          fail!(:source_link_unreadable, %{
            lane: lane,
            app: app.app,
            path: relative(root, path),
            reason: reason
          })
      end

    unless path_within?(root, target),
      do:
        fail!(:source_escape, %{
          lane: lane,
          app: app.app,
          path: relative(root, path),
          target: relative(root, target)
        })

    fail!(:source_symlink, %{lane: lane, app: app.app, path: relative(root, path)})
  end

  defp source_mapping!(app, beam, lane) do
    case safe_source(app.app, app.relative, beam.source) do
      nil when beam.source in [nil, ""] ->
        nil

      nil ->
        fail!(:source_escape, %{
          lane: lane,
          app: app.app,
          beam: beam.relative,
          source: beam.source
        })

      path ->
        path
    end
  end

  defp source_mapping_status!(_app, nil, files, _lane, _reader),
    do: {"unavailable", nil, files}

  defp source_mapping_status!(app, relative_source, files, lane, reader) do
    cond do
      Map.has_key?(files, relative_source) ->
        {"present", Map.fetch!(files, relative_source), files}

      String.starts_with?(relative_source, "src/") ->
        {"missing", nil, files}

      true ->
        source_file_status!(app, relative_source, files, lane, reader)
    end
  end

  defp source_file_status!(app, relative_source, files, lane, reader) do
    path = Path.expand(relative_source, app.root)

    unless path_within?(app.root, path) do
      fail!(:source_escape, %{
        lane: lane,
        app: app.app,
        source: relative_source
      })
    end

    case File.lstat(path) do
      {:ok, %{type: :regular}} ->
        bytes = source_file_size!(path, app, lane, reader)
        {"present", bytes, Map.put(files, relative_source, bytes)}

      {:ok, %{type: :symlink}} ->
        validate_source_link!(app.root, path, app, lane)

      {:ok, stat} ->
        fail!(:source_file_type, %{
          lane: lane,
          app: app.app,
          path: relative_source,
          type: stat.type
        })

      {:error, :enoent} ->
        {"missing", nil, files}

      {:error, reason} ->
        fail!(:source_file_unreadable, %{
          lane: lane,
          app: app.app,
          path: relative_source,
          reason: reason
        })
    end
  end

  defp path_within?(root, path) do
    root = Path.expand(root)
    path = Path.expand(path)
    path == root or String.starts_with?(path, root <> "/")
  end

  defp module_names(modules) do
    MapSet.new(modules, fn module ->
      if is_atom(module), do: Atom.to_string(module), else: module
    end)
  end

  defp parse_lines!(lines) do
    unless Enum.all?(lines, &String.starts_with?(&1, @marker)),
      do: fail!(:receipt_marker, :missing_or_invalid)

    records = Enum.map(lines, &decode_receipt_line!/1)

    kinds = Enum.map(records, & &1["kind"])

    unless length(records) >= 2 and hd(kinds) == "meta" and List.last(kinds) == "footer",
      do: fail!(:receipt_order, kinds)

    unless Enum.count(kinds, &(&1 == "footer")) == 1 and Enum.count(kinds, &(&1 == "meta")) == 1,
      do: fail!(:receipt_duplicate_record, kinds)

    unknown = Enum.reject(kinds, &(&1 in @record_kinds))
    if unknown != [], do: fail!(:receipt_record_kind, unknown)

    records
  end

  defp decode_receipt_line!(line) do
    case JSON.decode(String.replace_prefix(line, @marker, "")) do
      {:ok, row} when is_map(row) -> row
      result -> fail!(:receipt_json, inspect(result))
    end
  end

  defp raw_inventory!(root, lane) do
    root = Path.expand(root)
    ensure_directory!(root, %{lane: lane, root: root})

    root
    |> File.ls!()
    |> Enum.sort()
    |> Enum.reduce(%{}, fn name, inventory ->
      path = Path.join(root, name)

      case File.lstat(path) do
        {:ok, %{type: :directory}} ->
          Map.put(inventory, name, raw_app_modules!(path, name, lane))

        {:ok, %{type: :symlink}} ->
          fail!(:app_root_symlink, %{lane: lane, path: name})

        {:ok, %{type: :regular}} ->
          inventory

        {:ok, stat} ->
          fail!(:app_root_type, %{lane: lane, path: name, type: stat.type})

        {:error, reason} ->
          fail!(:app_root_unreadable, %{lane: lane, path: name, reason: reason})
      end
    end)
  rescue
    error in Error -> reraise error, __STACKTRACE__
    error -> fail!(:raw_inventory, %{lane: lane, root: root, error: Exception.message(error)})
  end

  defp raw_app_modules!(path, name, lane) do
    ebin = Path.join(path, "ebin")
    ensure_directory!(ebin, %{lane: lane, app_root: name, ebin: "#{name}/ebin"})

    ebin
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".beam"))
    |> Enum.map(fn file ->
      beam_path = Path.join(ebin, file)

      ensure_regular_file!(beam_path, %{
        lane: lane,
        app_root: name,
        beam: "#{name}/ebin/#{file}"
      })

      String.replace_suffix(file, ".beam", "")
    end)
    |> MapSet.new()
  end

  defp validate_receipt_meta!(meta) do
    unless meta["kind"] == "meta" and meta["schema"] == "fablebook.otp-inventory.v2",
      do: fail!(:receipt_meta, meta)
  end

  defp validate_receipt_footer!(footer, expected_counts, body_lines) do
    count_mismatches =
      Enum.reject(expected_counts, fn {key, expected} -> footer[key] == expected end)

    expected_digest = sha256(Enum.join(body_lines, "\n") <> "\n")

    unless footer["kind"] == "footer" and count_mismatches == [] and
             footer["sha256"] == expected_digest do
      fail!(:receipt_footer, %{footer: footer, count_mismatches: count_mismatches})
    end
  end

  defp validate_receipt_rows!(app_rows, beam_rows) do
    validate_nonempty_inventory!(app_rows, beam_rows)
    validate_unique_apps!(app_rows)
    validate_unique_beams!(beam_rows)
    validate_beam_app_links!(app_rows, beam_rows)
  end

  defp validate_source_rows!(app_rows, beam_rows, source_app_rows, source_file_rows) do
    apps = Map.new(app_rows, &{&1["app"], &1["version"]})
    source_apps = Map.new(source_app_rows, &{&1["app"], &1})

    problems = %{
      source_apps: invalid_source_app_rows(app_rows, source_app_rows),
      source_files: invalid_source_file_rows(apps, source_file_rows),
      file_totals: invalid_source_file_totals(app_rows, source_apps, source_file_rows),
      beam_totals: invalid_source_beam_totals(source_app_rows, beam_rows),
      beam_rows: invalid_source_beam_rows(source_apps, beam_rows)
    }

    if length(source_app_rows) != length(app_rows) or map_size(source_apps) != length(app_rows) or
         Enum.any?(Map.values(problems), &(&1 != [])) do
      fail!(
        :receipt_source_records,
        Map.put(problems, :source_app_count, length(source_app_rows))
      )
    end
  end

  defp invalid_source_app_rows(app_rows, source_rows) do
    app_versions = Map.new(app_rows, &{&1["app"], &1["version"]})

    invalid =
      Enum.reject(source_rows, fn row ->
        app_versions[row["app"]] == row["version"] and
          row["source_dir_status"] in ["present", "missing"] and
          Enum.all?(
            ~w(source_file_count source_bytes mapped_beams missing_source_beams unavailable_source_beams),
            &valid_byte_count?(row[&1])
          )
      end)

    duplicate =
      source_rows
      |> Enum.group_by(& &1["app"])
      |> Enum.filter(fn {_app, rows} -> length(rows) > 1 end)

    invalid ++ duplicate
  end

  defp invalid_source_file_rows(apps, rows) do
    invalid =
      Enum.reject(rows, fn row ->
        is_binary(apps[row["app"]]) and safe_receipt_path?(row["path"]) and
          valid_byte_count?(row["bytes"])
      end)

    duplicate =
      rows
      |> Enum.group_by(&{&1["app"], &1["path"]})
      |> Enum.filter(fn {_path, records} -> length(records) > 1 end)

    invalid ++ duplicate
  end

  defp invalid_source_file_totals(app_rows, source_apps, source_file_rows) do
    grouped_files = Enum.group_by(source_file_rows, & &1["app"])

    Enum.flat_map(app_rows, fn app ->
      source = source_apps[app["app"]]
      files = Map.get(grouped_files, app["app"], [])
      actual_count = length(files)
      actual_bytes = Enum.sum(Enum.map(files, &(&1["bytes"] || 0)))

      if is_map(source) and source["source_file_count"] == actual_count and
           source["source_bytes"] == actual_bytes and app["source_file_count"] == actual_count and
           app["source_bytes"] == actual_bytes do
        []
      else
        [
          %{
            app: app["app"],
            source_app: source,
            actual_files: actual_count,
            actual_bytes: actual_bytes
          }
        ]
      end
    end)
  end

  defp invalid_source_beam_totals(source_app_rows, beam_rows) do
    Enum.flat_map(source_app_rows, fn source ->
      beams = Enum.filter(beam_rows, &(&1["app"] == source["app"]))

      counts = %{
        "mapped_beams" => Enum.count(beams, &(&1["source_status"] == "present")),
        "missing_source_beams" => Enum.count(beams, &(&1["source_status"] == "missing")),
        "unavailable_source_beams" => Enum.count(beams, &(&1["source_status"] == "unavailable"))
      }

      mismatches = Enum.reject(counts, fn {key, value} -> source[key] == value end)
      if mismatches == [], do: [], else: [%{app: source["app"], mismatches: mismatches}]
    end)
  end

  defp invalid_source_beam_rows(source_apps, beam_rows) do
    Enum.reject(beam_rows, fn row ->
      is_map(source_apps[row["app"]]) and valid_source_beam_row?(row)
    end)
  end

  defp validate_receipt_links!(context) do
    app_names = MapSet.new(context.apps, & &1["app"])
    beam_ids = MapSet.new(context.beams, &{&1["app"], &1["module"]})

    source_files =
      Map.new(context.source_files, &{{&1["app"], &1["path"]}, &1["bytes"]})

    invalid_sources = Enum.reject(context.beams, &valid_source_mapping?(&1, source_files))

    invalid_membership =
      Enum.reject(context.membership, &valid_membership_link?(&1, app_names, beam_ids))

    if invalid_sources != [] or invalid_membership != [] do
      fail!(:receipt_links, %{sources: invalid_sources, membership: invalid_membership})
    end
  end

  defp valid_source_mapping?(
         %{"source_status" => "present", "source" => source, "source_bytes" => bytes} = row,
         files
       ),
       do: Map.get(files, {row["app"], source}) == bytes

  defp valid_source_mapping?(
         %{"source_status" => "missing", "source" => source, "source_bytes" => nil} = row,
         files
       ),
       do: not Map.has_key?(files, {row["app"], source})

  defp valid_source_mapping?(
         %{"source_status" => "unavailable", "source" => nil, "source_bytes" => nil},
         _files
       ),
       do: true

  defp valid_source_mapping?(_row, _files), do: false

  defp valid_membership_link?(%{"kind" => "pending_app", "app" => app}, app_names, _beam_ids),
    do: MapSet.member?(app_names, app)

  defp valid_membership_link?(
         %{"kind" => "pending_module", "app" => app, "module" => module},
         _app_names,
         beam_ids
       ),
       do: MapSet.member?(beam_ids, {app, module})

  defp valid_membership_link?(
         %{"kind" => "pending_mfa", "app" => app, "module" => module},
         _app_names,
         beam_ids
       ),
       do: MapSet.member?(beam_ids, {app, module})

  defp valid_membership_link?(%{"kind" => "active_app", "app" => app}, _app_names, _beam_ids),
    do: is_binary(app)

  defp valid_membership_link?(%{"app" => app, "module" => module}, app_names, beam_ids) do
    not MapSet.member?(app_names, app) or MapSet.member?(beam_ids, {app, module})
  end

  defp valid_membership_link?(_row, _app_names, _beam_ids), do: false

  defp validate_membership_rows!(
         active_rows,
         export_rows,
         reached_rows,
         boundary_rows,
         pending_rows
       ) do
    all = active_rows ++ export_rows ++ reached_rows ++ boundary_rows ++ pending_rows
    invalid = Enum.reject(all, &valid_membership_row?/1)

    duplicate =
      all
      |> Enum.group_by(&receipt_membership_key/1)
      |> Enum.filter(fn {_key, rows} -> length(rows) > 1 end)

    pending_invalid = Enum.reject(pending_rows, &valid_pending_record?/1)

    unless invalid == [] and duplicate == [] and pending_invalid == [] do
      fail!(:receipt_membership_records, %{
        invalid: invalid,
        duplicate: duplicate,
        pending_invalid: pending_invalid
      })
    end
  end

  defp valid_membership_row?(%{"kind" => kind, "app" => app})
       when kind in ["active_app", "pending_app"] and is_binary(app),
       do: true

  defp valid_membership_row?(%{"kind" => kind, "app" => app, "module" => module})
       when kind in ["active_module", "pending_module"] and is_binary(app) and is_binary(module),
       do: true

  defp valid_membership_row?(%{"kind" => "active_edge"} = row) do
    is_binary(row["app"]) and valid_mfa_fields?(row) and is_binary(row["callee_module"]) and
      is_binary(row["callee_function"])
  end

  defp valid_membership_row?(%{"kind" => "boundary"} = row) do
    is_binary(row["app"]) and valid_mfa_fields?(row) and
      is_boolean(row["explicit_boundary_exclusion"])
  end

  defp valid_membership_row?(%{"kind" => kind} = row)
       when kind in ["active_export", "export", "reached", "pending_mfa"],
       do: is_binary(row["app"]) and valid_mfa_fields?(row)

  defp valid_membership_row?(_row), do: false

  defp valid_pending_record?(%{"kind" => "pending_app", "owner" => "01.1.1.3", "app" => app}),
    do: is_binary(app)

  defp valid_pending_record?(%{"kind" => "pending_module", "owner" => "01.1.1.3"} = row) do
    is_binary(row["app"]) and is_binary(row["module"]) and
      valid_function_count?(row["function_count"]) and valid_byte_count?(row["function_bytes"]) and
      valid_source_beam_row?(row)
  end

  defp valid_pending_record?(%{"kind" => "pending_mfa", "owner" => "01.1.1.3"} = row) do
    valid_membership_row?(row) and is_list(row["caller_chain"]) and row["caller_chain"] != [] and
      Enum.all?(row["caller_chain"], &valid_mfa_text?/1)
  end

  defp valid_pending_record?(_row), do: false

  defp valid_mfa_fields?(row) do
    is_binary(row["module"]) and is_binary(row["function"]) and
      is_integer(row["arity"]) and row["arity"] >= 0
  end

  defp valid_mfa_text?(value) when is_binary(value) do
    case String.split(value, "/", parts: 2) do
      [identity, arity] when identity != "" ->
        String.contains?(identity, ".") and
          case Integer.parse(arity) do
            {parsed, ""} when parsed >= 0 -> Integer.to_string(parsed) == arity
            _ -> false
          end

      _ ->
        false
    end
  end

  defp valid_mfa_text?(_value), do: false

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
      valid_function_count?(row["function_count"]) and valid_byte_count?(row["function_bytes"]) and
      valid_byte_count?(row["beam_bytes"]) and valid_source_beam_row?(row)
  end

  defp receipt_membership_key(row) do
    case row["kind"] do
      "active_app" ->
        {row["kind"], row["app"]}

      "active_module" ->
        {row["kind"], row["app"], row["module"]}

      "active_export" ->
        {row["kind"], row["app"], row["module"], row["function"], row["arity"]}

      "active_edge" ->
        {row["kind"], row["app"], row["module"], row["function"], row["arity"],
         row["callee_module"], row["callee_function"]}

      "pending_app" ->
        {row["kind"], row["app"]}

      "pending_module" ->
        {row["kind"], row["app"], row["module"]}

      _ ->
        {row["kind"], row["app"], row["module"], row["function"], row["arity"]}
    end
  end

  defp validate_receipt_metrics!(metric_rows, context) do
    [metrics] = metric_rows
    expected = receipt_metric_expectations(context)
    timing_keys = ~w(discovery_ms inspection_ms source_scan_ms xref_ms graph_ms)
    invalid_counts = Enum.reject(expected, fn {key, value} -> metrics[key] == value end)
    invalid_times = Enum.reject(timing_keys, &valid_byte_count?(metrics[&1]))

    unless length(metric_rows) == 1 and metrics["kind"] == "metrics" and
             metrics["pending_owner"] == "01.1.1.3" and invalid_counts == [] and
             invalid_times == [] do
      fail!(:receipt_metrics, %{
        expected: expected,
        actual: metrics,
        invalid_counts: invalid_counts,
        invalid_times: invalid_times
      })
    end
  rescue
    error in MatchError ->
      fail!(:receipt_metrics, %{
        records: length(metric_rows),
        expected: 1,
        error: Exception.message(error)
      })
  end

  defp valid_source_beam_row?(row) do
    source = row["source"]
    status = row["source_status"]
    bytes = row["source_bytes"]

    case status do
      "present" -> valid_mapped_source?(source, bytes)
      "missing" -> valid_missing_source?(source, bytes)
      "unavailable" -> is_nil(source) and is_nil(bytes)
      _ -> false
    end
  end

  defp valid_mapped_source?(source, bytes),
    do: is_binary(source) and safe_receipt_path?(source) and valid_byte_count?(bytes)

  defp valid_missing_source?(source, bytes),
    do: is_binary(source) and safe_receipt_path?(source) and is_nil(bytes)

  defp receipt_metric_expectations(context) do
    active_count = fn kind -> Enum.count(context.active, &(&1["kind"] == kind)) end
    pending_count = fn kind -> Enum.count(context.pending, &(&1["kind"] == kind)) end
    beams = context.beams

    %{
      "app_count" => length(context.apps),
      "beam_count" => length(beams),
      "function_count" => Enum.sum(Enum.map(beams, & &1["function_count"])),
      "function_bytes" => Enum.sum(Enum.map(beams, & &1["function_bytes"])),
      "beam_bytes" => Enum.sum(Enum.map(beams, & &1["beam_bytes"])),
      "source_file_count" => length(context.source_files),
      "source_bytes" => Enum.sum(Enum.map(context.source_files, & &1["bytes"])),
      "mapped_beams" => Enum.count(beams, &(&1["source_status"] == "present")),
      "missing_source_beams" => Enum.count(beams, &(&1["source_status"] == "missing")),
      "unavailable_source_beams" => Enum.count(beams, &(&1["source_status"] == "unavailable")),
      "exported_matches" => length(context.exports),
      "reached_matches" => length(context.reached),
      "boundary_matches" => length(context.boundaries),
      "active_app_count" => active_count.("active_app"),
      "active_module_count" => active_count.("active_module"),
      "active_export_count" => active_count.("active_export"),
      "active_edge_count" => active_count.("active_edge"),
      "pending_app_count" => pending_count.("pending_app"),
      "pending_module_count" => pending_count.("pending_module"),
      "pending_mfa_count" => pending_count.("pending_mfa")
    }
  end

  defp valid_byte_count?(count), do: is_integer(count) and count >= 0

  defp default_metrics(
         discovered,
         inspected,
         sources,
         active,
         exports,
         reached,
         boundaries,
         pending
       ) do
    source_beams = Enum.flat_map(sources, & &1.beams)
    source_files = Enum.flat_map(sources, &Map.values(&1.source_files))
    active_count = fn kind -> Enum.count(active, &(&1["kind"] == kind)) end
    pending_count = fn kind -> Enum.count(pending, &(&1["kind"] == kind)) end

    %{
      "app_count" => length(discovered),
      "beam_count" => length(inspected),
      "function_count" => Enum.sum(Enum.map(inspected, & &1.function_count)),
      "function_bytes" => Enum.sum(Enum.map(inspected, & &1.function_bytes)),
      "beam_bytes" => Enum.sum(Enum.map(inspected, fn beam -> File.stat!(beam.path).size end)),
      "source_file_count" => length(source_files),
      "source_bytes" => Enum.sum(source_files),
      "mapped_beams" => Enum.count(source_beams, &(&1.status == "present")),
      "missing_source_beams" => Enum.count(source_beams, &(&1.status == "missing")),
      "unavailable_source_beams" => Enum.count(source_beams, &(&1.status == "unavailable")),
      "exported_matches" => length(exports),
      "reached_matches" => length(reached),
      "boundary_matches" => length(boundaries),
      "active_app_count" => active_count.("active_app"),
      "active_module_count" => active_count.("active_module"),
      "active_export_count" => active_count.("active_export"),
      "active_edge_count" => active_count.("active_edge"),
      "pending_app_count" => pending_count.("pending_app"),
      "pending_module_count" => pending_count.("pending_module"),
      "pending_mfa_count" => pending_count.("pending_mfa"),
      "discovery_ms" => 0,
      "inspection_ms" => 0,
      "source_scan_ms" => 0,
      "xref_ms" => 0,
      "graph_ms" => 0,
      "pending_owner" => "01.1.1.3"
    }
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
        if Path.type(source) == :relative, do: normalize_source_parts(parts), else: nil

      index ->
        Enum.drop(parts, index + 1) |> normalize_source_parts()
    end
  end

  defp safe_source(_app, _app_root, _source), do: nil

  defp normalize_source_parts(parts) do
    case Enum.reduce_while(parts, [], fn
           ".", stack -> {:cont, stack}
           "..", [] -> {:halt, :escape}
           "..", [_discarded | rest] -> {:cont, rest}
           part, stack -> {:cont, [part | stack]}
         end) do
      :escape ->
        nil

      [] ->
        nil

      reversed ->
        path = reversed |> Enum.reverse() |> Path.join()
        if path != "" and Path.type(path) == :relative, do: path, else: nil
    end
  end

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
          function_bytes: scan.function_bytes,
          edges: scan.edges,
          xref_edges: Map.get(scan, :xref_edges, []),
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
