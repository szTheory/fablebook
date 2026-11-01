defmodule Fablebook.Test.DebuggerPendingOwnership do
  alias Fablebook.Test.DebuggerSettings

  @baseline_modules [
    :dbg_wx_mon,
    :dbg_wx_mon_win,
    :dbg_wx_filedialog_win,
    :dbg_wx_win,
    :dbg_iload,
    :dbg_ieval
  ]

  def baseline_modules, do: @baseline_modules

  def owners do
    current = DebuggerSettings.pending_owners()
    Map.new(@baseline_modules, &{&1, Map.fetch!(current, Atom.to_string(&1))})
  end

  def validation_error(owners) when is_map(owners) do
    expected = MapSet.new(@baseline_modules)
    assigned = MapSet.new(Map.keys(owners))
    missing = MapSet.difference(expected, assigned)
    unexpected = MapSet.difference(assigned, expected)
    current_owners = owners()

    wrong_owner =
      Enum.filter(@baseline_modules, &(Map.get(owners, &1) != Map.get(current_owners, &1)))

    if MapSet.size(missing) == 0 and MapSet.size(unexpected) == 0 and wrong_owner == [] do
      nil
    else
      "missing owner entries=#{format_owners(missing, owners)}; " <>
        "unexpected owner entries=#{format_owners(unexpected, owners)}; " <>
        "wrong owner entries=#{format_owners(wrong_owner, owners)}"
    end
  end

  def assert_valid!(owners) do
    case validation_error(owners) do
      nil ->
        :ok

      message ->
        raise ExUnit.AssertionError,
          message: "pending debugger ownership map differs; " <> message
    end
  end

  defp format_owners(modules, owners) do
    modules
    |> Enum.sort()
    |> Enum.map_join("; ", fn module ->
      expected = Map.fetch!(owners(), module)
      "#{module} expected=#{expected} actual=#{Map.get(owners, module, "<missing>")}"
    end)
  end
end

defmodule Fablebook.Contract.TierSweepTest do
  use ExUnit.Case, async: false

  alias Fablebook.Credo.BannedCalls
  alias Fablebook.Test.BeamWalker
  alias Fablebook.Test.DebuggerPendingOwnership
  alias Fablebook.Test.DebuggerSettings
  alias Fablebook.Test.InstalledOtp
  alias Fablebook.Test.SweepEvidence
  @compile {:no_warn_undefined, :xref}

  Code.ensure_loaded?(BannedCalls) ||
    Code.require_file(Path.expand("../../credo/checks/banned_calls.ex", __DIR__))

  # Historical active-disposition membership only. Discovery and inspection use the full install.
  @historical_active_otp_apps ~w(
    kernel stdlib compiler erts crypto public_key asn1 ssl inets syntax_tools tools parsetools
    runtime_tools sasl dialyzer xmerl os_mon
  )a
  @elixir_apps [:elixir, :eex, :mix, :iex, :logger, :ex_unit]
  @floor_roots ~w(phoenix phoenix_live_view phoenix_html telemetry nimble_options)
  @reasons %{
    macro: "compile-time macro body; runs only while the caller is being compiled",
    own_native:
      "loads its own NIF or OTP's own trace or scanner driver by a fixed name; no caller-chosen library",
    callback:
      "process callback or loop; reached only through the module's front door, which the sweep judges separately",
    expansion:
      "expansion inside a module being compiled: evaluates only that module's own definitions; AST from input needs a banned parser or atom creation",
    own_clauses:
      "evaluates guards or patterns already compiled into the caller (error blame, assertion diff); takes no source",
    compiler_pass:
      "compiler, analysis or parse-transform pass: returns forms, Core or a binary and loads nothing",
    project_build: "Mix build step over the host project's own mix.exs, sources and lockfile",
    by_name:
      "loads a module by name from the code path; the code-path mutators are banned, so only beams already on the path load",
    cover_server:
      "cover server API over modules already cover-compiled through a banned :cover compile function",
    console: "boot, console or line-editing code of the running VM",
    crypto_key: "reaches only beam_lib's lookup of the fixed .erlang.crypt key file",
    epp_guard:
      "parses source with epp, whose -if conditions run as guard tests only; loads nothing",
    boot_script: "writes c:erlangrc into a generated boot script as data; loads nothing",
    dist_config: "evaluates the VM's own TLS distribution option file named on its command line",
    iex_console:
      "IEx console internal, reached only inside a running IEx through the banned IEx front doors",
    private_front:
      "private implementation reached only through an already tiered public front that the guard rejects",
    fixed_app:
      "puts only a named OTP application or Mix's own archive directory on the code path; loads no caller code",
    fixed_args: "calls a code-loading front door only with arguments fixed in its own source",
    not_compile_module:
      "named compile but compiles only regexes, assets or the host project's own build, as cited",
    pure_data:
      "transforms or queries the caller's data and returns it; loads, evaluates and changes no code or code path, as cited",
    fixed_default:
      "runs Logger.Formatter.new/0 with only the built-in default pattern and no caller options, as cited",
    unrelated_exunit_config:
      "writes only ExUnit plural-rule or after-suite configuration; it does not carry capture_log formatter options, as cited",
    runtime_internal:
      "operates on processes, ports, tables, tracing, counters or code already loaded; prepares, loads and evaluates nothing, as cited"
  }

  @escript_debug_mfa {:escript, :debug, 3}
  @escript_debug_source_assertions_by_lane %{
    "core" => [
      {"stdlib/src/escript.erl:36", "-export([start/0, start/1, parse_file/1])."},
      {"stdlib/src/escript.erl:422", "parse_and_run(File, Args, EscriptOptions);"},
      {"stdlib/src/escript.erl:475", "debug(Module, {Module, File, File, BeamBin}, Args);"},
      {"stdlib/src/escript.erl:889", "debug(Module, AbsMod, Args) ->"},
      {"stdlib/src/escript.erl:890", "hidden_apply(debugger, debugger, start, [])"},
      {"stdlib/src/escript.erl:892", "hidden_apply(debugger, int, i, [AbsMod])"},
      {"stdlib/src/escript.erl:894", "hidden_apply(debugger, debugger, auto_attach, [[init]])"},
      {"stdlib/src/escript.erl:1084", "apply(fun() -> M end(), F, Args)"}
    ],
    "floor" => [
      {"stdlib/src/escript.erl:32", "-export([start/0, start/1, parse_file/1])."},
      {"stdlib/src/escript.erl:418", "parse_and_run(File, Args, EscriptOptions);"},
      {"stdlib/src/escript.erl:471", "debug(Module, {Module, File, File, BeamBin}, Args);"},
      {"stdlib/src/escript.erl:885", "debug(Module, AbsMod, Args) ->"},
      {"stdlib/src/escript.erl:886", "hidden_apply(debugger, debugger, start, [])"},
      {"stdlib/src/escript.erl:888", "hidden_apply(debugger, int, i, [AbsMod])"},
      {"stdlib/src/escript.erl:890", "hidden_apply(debugger, debugger, auto_attach, [[init]])"},
      {"stdlib/src/escript.erl:1080", "apply(fun() -> M end(), F, Args)"}
    ]
  }
  @escript_debug_citations @escript_debug_source_assertions_by_lane
                           |> Map.values()
                           |> List.flatten()
                           |> Enum.map(fn {citation, _expected_source} -> citation end)
                           |> Enum.uniq()

  @ct_make_expected_mfas [
    {:ct_make, :all, 0},
    {:ct_make, :all, 1},
    {:ct_make, :files, 1},
    {:ct_make, :files, 2}
  ]

  @ct_make_expected_reached_mfas @ct_make_expected_mfas ++
                                   [
                                     {:ct_make, :check_includes, 3},
                                     {:ct_make, :check_includes2, 3},
                                     {:ct_make, :do_load, 3},
                                     {:ct_make, :do_make_files, 2},
                                     {:ct_make, :do_recompile, 4},
                                     {:ct_make, :get_opts_from_emakefile, 3},
                                     {:ct_make, :maybe_load, 3},
                                     {:ct_make, :process, 4},
                                     {:ct_make, :read_emakefile, 2},
                                     {:ct_make, :recompile, 4},
                                     {:ct_make, :recompile2, 5},
                                     {:ct_make, :recompilep, 4},
                                     {:ct_make, :recompilep1, 5},
                                     {:ct_make, :recompilep1, 6}
                                   ]

  @ct_make_source_by_lane %{
    "core" => %{
      sha256: "a6d46d0f31e75119b543ba5783782c7c48b358fa024a71763e5a7f2c6ff4d3a3",
      groups: %{
        all0: [
          {"common_test/src/ct_make.erl:37", "-export([all/0,all/1,files/1,files/2])."},
          {"common_test/src/ct_make.erl:43", "all() ->"},
          {"common_test/src/ct_make.erl:44", "all([])."}
        ],
        all1: [
          {"common_test/src/ct_make.erl:46", "all(Options) ->"},
          {"common_test/src/ct_make.erl:47", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:48", "read_emakefile('Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:50", "do_make_files(Files,MakeOpts)"}
        ],
        files1: [
          {"common_test/src/ct_make.erl:55", "files(Fs) ->"},
          {"common_test/src/ct_make.erl:56", "files(Fs, [])."}
        ],
        files2: [
          {"common_test/src/ct_make.erl:58", "files(Fs0, Options) ->"},
          {"common_test/src/ct_make.erl:59", "filename:rootname(F,\".erl\")"},
          {"common_test/src/ct_make.erl:60", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:61",
           "get_opts_from_emakefile(Fs,'Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:63", "do_make_files(Files,MakeOpts)"}
        ],
        emake_read: [
          {"common_test/src/ct_make.erl:94", "read_emakefile(Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:95", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:97", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:101", "filelib:wildcard(\"*.erl\")"},
          {"common_test/src/ct_make.erl:102", "[{Mods, Opts}]"},
          {"common_test/src/ct_make.erl:108",
           "transform([{Mod,ModOpts}|Emake],Opts,Files,Already) ->"},
          {"common_test/src/ct_make.erl:125", "expand(Mod,Already) when is_atom(Mod) ->"}
        ],
        emake_files: [
          {"common_test/src/ct_make.erl:150", "get_opts_from_emakefile(Mods,Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:151", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:153", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:156", "{error,enoent} ->"},
          {"common_test/src/ct_make.erl:157", "[{Mods, Opts}]"}
        ],
        options: [
          {"common_test/src/ct_make.erl:41", "-define(MakeOpts,[noexec,load,netload,noload])."},
          {"common_test/src/ct_make.erl:72", "sort_options([H|T],Make,Comp) ->"},
          {"common_test/src/ct_make.erl:80", "{Make,lists:reverse(Comp)}."},
          {"common_test/src/ct_make.erl:191", "load_opt(Opts) ->"},
          {"common_test/src/ct_make.erl:192", "lists:member(netload,Opts)"},
          {"common_test/src/ct_make.erl:194", "netload"},
          {"common_test/src/ct_make.erl:196", "lists:member(load,Opts)"},
          {"common_test/src/ct_make.erl:198", "load"},
          {"common_test/src/ct_make.erl:200", "noload"}
        ],
        process: [
          {"common_test/src/ct_make.erl:68", "do_make_files(Fs, Opts) ->"},
          {"common_test/src/ct_make.erl:69",
           "process(Fs, lists:member(noexec, Opts), load_opt(Opts), [])"},
          {"common_test/src/ct_make.erl:205",
           "process([{[],_Opts}|Rest], NoExec, Load, Result) ->"},
          {"common_test/src/ct_make.erl:208", "recompilep(coerce_2_list(H), NoExec, Load, Opts)"}
        ],
        compile: [
          {"common_test/src/ct_make.erl:288", "do_recompile(File, false, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:290",
           "compile:file(File, [report_errors, report_warnings |Opts])"},
          {"common_test/src/ct_make.erl:292", "maybe_load(element(2,Ok), Load, Opts)"}
        ],
        recompile: [
          {"common_test/src/ct_make.erl:226", "recompilep(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:235", "case exists(ObjFile) of"},
          {"common_test/src/ct_make.erl:237", "recompilep1(File, NoExec, Load, Opts, ObjFile)"},
          {"common_test/src/ct_make.erl:242",
           "recompilep1(File, NoExec, Load, Opts, ObjFile) ->"},
          {"common_test/src/ct_make.erl:243",
           "file:read_file_info(lists:append(File, \".erl\"))"},
          {"common_test/src/ct_make.erl:247", "recompilep1(Erl, Obj, File, NoExec, Load, Opts)"},
          {"common_test/src/ct_make.erl:252", "recompilep1(#file_info{mtime=Te},"},
          {"common_test/src/ct_make.erl:255",
           "recompilep1(_Erl, #file_info{mtime=To}, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:260",
           "recompile2(ObjMTime, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:261", "IncludePath = include_opt(Opts),"},
          {"common_test/src/ct_make.erl:262",
           "check_includes(lists:append(File, \".erl\"), IncludePath, ObjMTime)"},
          {"common_test/src/ct_make.erl:269", "include_opt([{i,Path}|Rest]) ->"},
          {"common_test/src/ct_make.erl:270", "[Path|include_opt(Rest)];"},
          {"common_test/src/ct_make.erl:271", "include_opt([_First|Rest]) ->"},
          {"common_test/src/ct_make.erl:273", "include_opt([]) ->"},
          {"common_test/src/ct_make.erl:280", "recompile(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:354", "check_includes(File, IncludePath, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:355", "Path = [filename:dirname(File)|IncludePath],"},
          {"common_test/src/ct_make.erl:356", "epp:open(File, Path, [])"},
          {"common_test/src/ct_make.erl:363", "check_includes2(Epp, File, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:365", "epp:parse_erl_form(Epp)"},
          {"common_test/src/ct_make.erl:368", "{IncFile, A1}"},
          {"common_test/src/ct_make.erl:369", "file:read_file_info(IncFile)"}
        ],
        noload: [
          {"common_test/src/ct_make.erl:200", "noload"},
          {"common_test/src/ct_make.erl:297", "maybe_load(_Mod, noload, _Opts) ->"}
        ],
        load_paths: [
          {"common_test/src/ct_make.erl:299", "maybe_load(Mod, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:302", "compile:output_generated(Opts)"},
          {"common_test/src/ct_make.erl:311", "do_load(Dir, Mod, load) ->"},
          {"common_test/src/ct_make.erl:313", "code:load_abs(filename:join(Dir, Mod),Mod)"},
          {"common_test/src/ct_make.erl:319", "do_load(Dir, Mod, netload) ->"},
          {"common_test/src/ct_make.erl:322", "file:read_file(Fname)"},
          {"common_test/src/ct_make.erl:324",
           "rpc:eval_everywhere(code,load_binary,[Mod,Fname,Bin])"}
        ]
      }
    },
    "floor" => %{
      sha256: "7f5dce364ae35232780c7904b6e45475aed4ba0d95105ee114f04e992492e62b",
      groups: %{
        all0: [
          {"common_test/src/ct_make.erl:33", "-export([all/0,all/1,files/1,files/2])."},
          {"common_test/src/ct_make.erl:39", "all() ->"},
          {"common_test/src/ct_make.erl:40", "all([])."}
        ],
        all1: [
          {"common_test/src/ct_make.erl:42", "all(Options) ->"},
          {"common_test/src/ct_make.erl:43", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:44", "read_emakefile('Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:46", "do_make_files(Files,MakeOpts)"}
        ],
        files1: [
          {"common_test/src/ct_make.erl:51", "files(Fs) ->"},
          {"common_test/src/ct_make.erl:52", "files(Fs, [])."}
        ],
        files2: [
          {"common_test/src/ct_make.erl:54", "files(Fs0, Options) ->"},
          {"common_test/src/ct_make.erl:55", "filename:rootname(F,\".erl\")"},
          {"common_test/src/ct_make.erl:56", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:57",
           "get_opts_from_emakefile(Fs,'Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:59", "do_make_files(Files,MakeOpts)"}
        ],
        emake_read: [
          {"common_test/src/ct_make.erl:90", "read_emakefile(Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:91", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:93", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:97", "filelib:wildcard(\"*.erl\")"},
          {"common_test/src/ct_make.erl:98", "[{Mods, Opts}]"},
          {"common_test/src/ct_make.erl:104",
           "transform([{Mod,ModOpts}|Emake],Opts,Files,Already) ->"},
          {"common_test/src/ct_make.erl:121", "expand(Mod,Already) when is_atom(Mod) ->"}
        ],
        emake_files: [
          {"common_test/src/ct_make.erl:146", "get_opts_from_emakefile(Mods,Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:147", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:149", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:152", "{error,enoent} ->"},
          {"common_test/src/ct_make.erl:153", "[{Mods, Opts}]"}
        ],
        options: [
          {"common_test/src/ct_make.erl:37", "-define(MakeOpts,[noexec,load,netload,noload])."},
          {"common_test/src/ct_make.erl:68", "sort_options([H|T],Make,Comp) ->"},
          {"common_test/src/ct_make.erl:76", "{Make,lists:reverse(Comp)}."},
          {"common_test/src/ct_make.erl:187", "load_opt(Opts) ->"},
          {"common_test/src/ct_make.erl:188", "lists:member(netload,Opts)"},
          {"common_test/src/ct_make.erl:190", "netload"},
          {"common_test/src/ct_make.erl:192", "lists:member(load,Opts)"},
          {"common_test/src/ct_make.erl:194", "load"},
          {"common_test/src/ct_make.erl:196", "noload"}
        ],
        process: [
          {"common_test/src/ct_make.erl:64", "do_make_files(Fs, Opts) ->"},
          {"common_test/src/ct_make.erl:65",
           "process(Fs, lists:member(noexec, Opts), load_opt(Opts), [])"},
          {"common_test/src/ct_make.erl:201",
           "process([{[],_Opts}|Rest], NoExec, Load, Result) ->"},
          {"common_test/src/ct_make.erl:204", "recompilep(coerce_2_list(H), NoExec, Load, Opts)"}
        ],
        compile: [
          {"common_test/src/ct_make.erl:284", "do_recompile(File, false, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:286",
           "compile:file(File, [report_errors, report_warnings |Opts])"},
          {"common_test/src/ct_make.erl:288", "maybe_load(element(2,Ok), Load, Opts)"}
        ],
        recompile: [
          {"common_test/src/ct_make.erl:222", "recompilep(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:231", "case exists(ObjFile) of"},
          {"common_test/src/ct_make.erl:233", "recompilep1(File, NoExec, Load, Opts, ObjFile)"},
          {"common_test/src/ct_make.erl:238",
           "recompilep1(File, NoExec, Load, Opts, ObjFile) ->"},
          {"common_test/src/ct_make.erl:239",
           "file:read_file_info(lists:append(File, \".erl\"))"},
          {"common_test/src/ct_make.erl:243", "recompilep1(Erl, Obj, File, NoExec, Load, Opts)"},
          {"common_test/src/ct_make.erl:248", "recompilep1(#file_info{mtime=Te},"},
          {"common_test/src/ct_make.erl:251",
           "recompilep1(_Erl, #file_info{mtime=To}, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:256",
           "recompile2(ObjMTime, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:257", "IncludePath = include_opt(Opts),"},
          {"common_test/src/ct_make.erl:258",
           "check_includes(lists:append(File, \".erl\"), IncludePath, ObjMTime)"},
          {"common_test/src/ct_make.erl:265", "include_opt([{i,Path}|Rest]) ->"},
          {"common_test/src/ct_make.erl:266", "[Path|include_opt(Rest)];"},
          {"common_test/src/ct_make.erl:267", "include_opt([_First|Rest]) ->"},
          {"common_test/src/ct_make.erl:269", "include_opt([]) ->"},
          {"common_test/src/ct_make.erl:276", "recompile(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:350", "check_includes(File, IncludePath, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:351", "Path = [filename:dirname(File)|IncludePath],"},
          {"common_test/src/ct_make.erl:352", "epp:open(File, Path, [])"},
          {"common_test/src/ct_make.erl:359", "check_includes2(Epp, File, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:361", "epp:parse_erl_form(Epp)"},
          {"common_test/src/ct_make.erl:364", "{IncFile, A1}"},
          {"common_test/src/ct_make.erl:365", "file:read_file_info(IncFile)"}
        ],
        noload: [
          {"common_test/src/ct_make.erl:196", "noload"},
          {"common_test/src/ct_make.erl:293", "maybe_load(_Mod, noload, _Opts) ->"}
        ],
        load_paths: [
          {"common_test/src/ct_make.erl:295", "maybe_load(Mod, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:298", "compile:output_generated(Opts)"},
          {"common_test/src/ct_make.erl:307", "do_load(Dir, Mod, load) ->"},
          {"common_test/src/ct_make.erl:309", "code:load_abs(filename:join(Dir, Mod),Mod)"},
          {"common_test/src/ct_make.erl:315", "do_load(Dir, Mod, netload) ->"},
          {"common_test/src/ct_make.erl:318", "file:read_file(Fname)"},
          {"common_test/src/ct_make.erl:320",
           "rpc:eval_everywhere(code,load_binary,[Mod,Fname,Bin])"}
        ]
      }
    }
  }

  @ct_make_family_specs [
    %{
      mfa: {:ct_make, :all, 0},
      source_group: :all0,
      source_groups: [
        :all0,
        :all1,
        :emake_read,
        :options,
        :noload,
        :process,
        :compile,
        :recompile
      ],
      caller_input: :current_directory_emakefile_and_erl_sources,
      defaults: :fixed_empty_options,
      option_paths: [:noload],
      trace: [
        {:ct_make, :all, 0},
        {:ct_make, :all, 1},
        {:ct_make, :sort_options, 3},
        {:ct_make, :read_emakefile, 2},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3}
      ],
      trace_call_sites: [
        {{:ct_make, :all, 1}, "all([])."},
        {{:ct_make, :all, 1}, "all(Options) ->"},
        {{:ct_make, :sort_options, 3}, "sort_options(Options,[],[])"}
      ],
      verdict: :default_compiles_current_directory_sources_without_loading,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe]
    },
    %{
      mfa: {:ct_make, :all, 1},
      source_group: :all1,
      source_groups: [:all1, :emake_read, :options, :load_paths, :process, :compile, :recompile],
      caller_input: :caller_options_and_current_directory_emakefile_sources,
      defaults: :caller_options_choose_compile_and_load_mode,
      option_paths: [:noload, :load, :netload],
      trace: [
        {:ct_make, :all, 1},
        {:ct_make, :sort_options, 3},
        {:ct_make, :read_emakefile, 2},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :load_opt, 1},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3},
        {:ct_make, :do_load, 3},
        {:code, :load_abs, 2},
        {:rpc, :eval_everywhere, 3}
      ],
      verdict: :caller_options_select_compile_and_local_or_remote_load,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe, :discarded_quote_source_only]
    },
    %{
      mfa: {:ct_make, :files, 1},
      source_group: :files1,
      source_groups: [
        :files1,
        :files2,
        :emake_files,
        :options,
        :noload,
        :process,
        :compile,
        :recompile
      ],
      caller_input: :caller_file_list_and_matching_emakefile_options,
      defaults: :fixed_empty_options,
      option_paths: [:noload],
      trace: [
        {:ct_make, :files, 1},
        {:ct_make, :files, 2},
        {:ct_make, :sort_options, 3},
        {:ct_make, :get_opts_from_emakefile, 3},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :get_opts_from_emakefile2, 4},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3}
      ],
      trace_call_sites: [
        {{:ct_make, :files, 2}, "files(Fs, [])."},
        {{:ct_make, :files, 2}, "files(Fs0, Options) ->"},
        {{:ct_make, :sort_options, 3}, "sort_options(Options,[],[])"}
      ],
      verdict: :default_compiles_caller_file_list_without_loading,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe]
    },
    %{
      mfa: {:ct_make, :files, 2},
      source_group: :files2,
      source_groups: [
        :files2,
        :emake_files,
        :options,
        :load_paths,
        :process,
        :compile,
        :recompile
      ],
      caller_input: :caller_file_list_options_and_matching_emakefile_options,
      defaults: :caller_options_choose_compile_and_load_mode,
      option_paths: [:noload, :load, :netload],
      trace: [
        {:ct_make, :files, 2},
        {:ct_make, :get_opts_from_emakefile, 3},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :get_opts_from_emakefile2, 4},
        {:ct_make, :sort_options, 3},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :load_opt, 1},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3},
        {:ct_make, :do_load, 3},
        {:code, :load_abs, 2},
        {:rpc, :eval_everywhere, 3}
      ],
      verdict: :caller_files_and_options_select_compile_and_local_or_remote_load,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe, :discarded_quote_source_only]
    }
  ]

  @ct_make_lanes ~w(core floor)
  @ct_make_expected_ids (for lane <- @ct_make_lanes, spec <- @ct_make_family_specs do
                           {"CT-#{String.upcase(lane)}-ct_make-#{elem(spec.mfa, 1)}-#{elem(spec.mfa, 2)}",
                            lane}
                         end)

  @ct_make_audit (for lane <- @ct_make_lanes, spec <- @ct_make_family_specs do
                    lane_source = Map.fetch!(@ct_make_source_by_lane, lane)

                    citations =
                      Enum.flat_map(spec.source_groups, &Map.fetch!(lane_source.groups, &1))

                    %{
                      original_id:
                        "CT-#{String.upcase(lane)}-ct_make-#{elem(spec.mfa, 1)}-#{elem(spec.mfa, 2)}",
                      original_matcher: {:mfa, spec.mfa},
                      original_reason: :tier,
                      lane: lane,
                      matched_mfas: [spec.mfa],
                      caller_input: spec.caller_input,
                      defaults: spec.defaults,
                      option_paths: spec.option_paths,
                      trace: spec.trace,
                      verdict: spec.verdict,
                      replacements: %{spec.mfa => {:tier, spec.mfa}},
                      tier: [spec.mfa],
                      fixtures: spec.fixtures,
                      citations: citations,
                      source_sha256: lane_source.sha256,
                      applicability: :each_exact_installed_lane,
                      removal_witness: :individual_exact_mfa
                    }
                  end)

  @debugger_family_modules [:dbg_idb, :dbg_istk, :dbg_wx_interpret]
  @saved_settings_changed_modules [:dbg_wx_settings, :dbg_wx_mon, :dbg_iserver, :int, :dbg_icmd]
  @saved_settings_expected_exclusion_matches []
  @debugger_active_modules [:dbg_idb, :dbg_istk, :dbg_wx_interpret]
  @debugger_baseline_active_modules [:dbg_idb, :dbg_istk, :dbg_wx_interpret]
  @debugger_source_only_seed_mfas [
    {:dbg_idb, :insert, 3},
    {:dbg_idb, :lookup, 2},
    {:dbg_idb, :match_object, 2},
    {:dbg_istk, :delayed_to_external, 0}
  ]
  @debugger_expected_exclusion_matches []
  @debugger_selected_file_mfa {:dbg_wx_interpret, :start, 4}
  @debugger_explicit_roots [
    {:dbg_wx_interpret, :start, 4},
    {:dbg_wx_interpret, :filter_files, 2},
    {:dbg_wx_interpret, :interpret_all, 5},
    {:dbg_istk, :from_external, 1}
  ]
  @debugger_baseline_roots [
    {:dbg_wx_interpret, :start, 4},
    {:dbg_wx_interpret, :filter_files, 2},
    {:dbg_wx_interpret, :interpret_all, 5},
    {:dbg_istk, :from_external, 1}
  ]
  @debugger_expected_exports [
    {:dbg_idb, :insert, 3},
    {:dbg_idb, :lookup, 2},
    {:dbg_idb, :match_object, 2},
    {:dbg_istk, :init, 0},
    {:dbg_istk, :delayed_to_external, 0},
    {:dbg_istk, :from_external, 1},
    {:dbg_istk, :push, 3},
    {:dbg_istk, :pop, 0},
    {:dbg_istk, :pop, 1},
    {:dbg_istk, :stack_level, 0},
    {:dbg_istk, :delayed_stacktrace, 0},
    {:dbg_istk, :delayed_stacktrace, 2},
    {:dbg_istk, :bindings, 1},
    {:dbg_istk, :stack_frame, 2},
    {:dbg_istk, :backtrace, 2},
    {:dbg_istk, :in_use_p, 2},
    {:dbg_wx_interpret, :start, 4}
  ]
  @debugger_expected_family_mfas [
    {:dbg_idb, :insert, 3},
    {:dbg_idb, :lookup, 2},
    {:dbg_idb, :match_object, 2},
    {:dbg_istk, :init, 0},
    {:dbg_istk, :delayed_to_external, 0},
    {:dbg_istk, :from_external, 1},
    {:dbg_istk, :init, 1},
    {:dbg_istk, :push, 3},
    {:dbg_istk, :pop, 0},
    {:dbg_istk, :pop, 1},
    {:dbg_istk, :pop, 2},
    {:dbg_istk, :stack_level, 0},
    {:dbg_istk, :stack_level, 1},
    {:dbg_istk, :delayed_stacktrace, 0},
    {:dbg_istk, :delayed_stacktrace, 2},
    {:dbg_istk, :stacktrace, 3},
    {:dbg_istk, :normalize, 1},
    {:dbg_istk, :finalize, 1},
    {:dbg_istk, :line, 1},
    {:dbg_istk, :bindings, 1},
    {:dbg_istk, :bindings, 2},
    {:dbg_istk, :stack_frame, 2},
    {:dbg_istk, :stack_frame, 3},
    {:dbg_istk, :backtrace, 2},
    {:dbg_istk, :in_use_p, 2},
    {:dbg_wx_interpret, :start, 4},
    {:dbg_wx_interpret, :filter_files, 2},
    {:dbg_wx_interpret, :interpret_all, 5},
    {:dbg_wx_interpret, :format_error, 1}
  ]
  @debugger_function_reviews %{
    {:dbg_idb, :insert, 3} => %{
      caller_input: :interpreter_database_reference_key_and_value,
      defaults: :none,
      option_paths: [:local_ets_insert, :remote_rpc_to_fixed_ets_insert],
      trace: [{:dbg_idb, :insert, 3}, {:ets, :insert, 2}],
      verdict: :fixed_ets_storage_dispatch_without_term_execution,
      owner: :plan_02
    },
    {:dbg_idb, :lookup, 2} => %{
      caller_input: :interpreter_database_reference_and_key,
      defaults: :none,
      option_paths: [:local_ets_lookup, :remote_rpc_to_fixed_ets_lookup],
      trace: [{:dbg_idb, :lookup, 2}, {:ets, :lookup, 2}, :ok_or_not_found],
      verdict: :fixed_ets_lookup_with_found_and_missing_results,
      owner: :plan_02
    },
    {:dbg_idb, :match_object, 2} => %{
      caller_input: :interpreter_database_reference_and_match_pattern,
      defaults: :none,
      option_paths: [:local_ets_match_object, :remote_rpc_to_fixed_ets_match_object],
      trace: [{:dbg_idb, :match_object, 2}, {:ets, :match_object, 2}],
      verdict: :fixed_ets_pattern_match_without_term_execution,
      owner: :plan_02
    },
    {:dbg_istk, :init, 0} => %{
      caller_input: :interpreter_process_initialization,
      defaults: :empty_stack,
      option_paths: [:delegate_to_init_1],
      trace: [{:dbg_istk, :init, 0}, {:dbg_istk, :init, 1}],
      verdict: :initializes_process_local_stack,
      owner: :plan_02
    },
    {:dbg_istk, :delayed_to_external, 0} => %{
      caller_input: :current_interpreter_process_stack,
      defaults: :none,
      option_paths: [:deferred_term_to_binary],
      trace: [{:dbg_istk, :delayed_to_external, 0}, {:erlang, :term_to_binary, 1}],
      verdict: :internal_stack_encoder_only,
      owner: :plan_02
    },
    {:dbg_istk, :from_external, 1} => %{
      caller_input: :caller_supplied_stack_binary,
      defaults: :no_validation_or_safe_decode_option,
      option_paths: [:binary_to_term_without_safe_option],
      trace: [
        {:dbg_istk, :from_external, 1},
        {:erlang, :binary_to_term, 1},
        :process_dictionary_stack_write
      ],
      verdict: :caller_binary_reaches_unrestricted_decode,
      owner: :plan_02
    },
    {:dbg_istk, :init, 1} => %{
      caller_input: :interpreter_initial_stack,
      defaults: :none,
      option_paths: [:process_dictionary_stack_write],
      trace: [{:dbg_istk, :init, 1}, :process_dictionary_stack_write],
      verdict: :initializes_internal_process_local_state,
      owner: :plan_02
    },
    {:dbg_istk, :push, 3} => %{
      caller_input: :bindings_ieval_frame_and_tail_call_flag,
      defaults: :trace_stack_mode_from_process_dictionary,
      option_paths: [:trace_stack_false, :no_tail_tail_call, :record_frame],
      trace: [{:dbg_istk, :push, 3}, :process_dictionary_stack_read_write],
      verdict: :records_internal_interpreter_frames_by_trace_mode,
      owner: :plan_02
    },
    {:dbg_istk, :pop, 0} => %{
      caller_input: :current_interpreter_stack,
      defaults: :trace_stack_mode_from_process_dictionary,
      option_paths: [:trace_stack_false, :pop_head, :empty_stack_ignore],
      trace: [{:dbg_istk, :pop, 0}, :process_dictionary_stack_read_write],
      verdict: :removes_internal_frame_or_ignores_empty_stack,
      owner: :plan_02
    },
    {:dbg_istk, :pop, 1} => %{
      caller_input: :requested_interpreter_level,
      defaults: :trace_stack_mode_from_process_dictionary,
      option_paths: [:trace_stack_false, :recursive_level_trim],
      trace: [{:dbg_istk, :pop, 1}, {:dbg_istk, :pop, 2}, :process_dictionary_stack_write],
      verdict: :trims_internal_frames_to_requested_level,
      owner: :plan_02
    },
    {:dbg_istk, :pop, 2} => %{
      caller_input: :requested_level_and_internal_stack,
      defaults: :none,
      option_paths: [:discard_frame_when_level_is_not_greater],
      trace: [{:dbg_istk, :pop, 2}, :recursive_stack_walk],
      verdict: :internal_recursive_stack_trimming,
      owner: :plan_02
    },
    {:dbg_istk, :stack_level, 0} => %{
      caller_input: :current_interpreter_stack,
      defaults: :empty_stack_level_is_one,
      option_paths: [:delegate_to_stack_level_1],
      trace: [{:dbg_istk, :stack_level, 0}, {:dbg_istk, :stack_level, 1}],
      verdict: :reports_top_internal_call_level,
      owner: :plan_02
    },
    {:dbg_istk, :stack_level, 1} => %{
      caller_input: :internal_stack_list,
      defaults: :empty_stack_level_is_one,
      option_paths: [:empty_stack, :top_frame_level],
      trace: [{:dbg_istk, :stack_level, 1}],
      verdict: :reads_internal_stack_level_only,
      owner: :plan_02
    },
    {:dbg_istk, :delayed_stacktrace, 0} => %{
      caller_input: :current_interpreter_stack,
      defaults: :none,
      option_paths: [:return_deferred_stacktrace_function],
      trace: [{:dbg_istk, :delayed_stacktrace, 0}, {:dbg_istk, :stacktrace, 3}],
      verdict: :converts_internal_frames_on_deferred_invocation,
      owner: :plan_02
    },
    {:dbg_istk, :delayed_stacktrace, 2} => %{
      caller_input: :argument_flag_and_interpreter_frame,
      defaults: :none,
      option_paths: [:include_args, :no_args],
      trace: [{:dbg_istk, :delayed_stacktrace, 2}, {:dbg_istk, :stacktrace, 3}],
      verdict: :returns_deferred_stacktrace_for_internal_frames,
      owner: :plan_02
    },
    {:dbg_istk, :stacktrace, 3} => %{
      caller_input: :entry_limit_internal_stack_and_accumulator,
      defaults: :none,
      option_paths: [:skip_tail_call_frames, :collapse_repeated_frames, :stop_at_limit],
      trace: [{:dbg_istk, :stacktrace, 3}, {:dbg_istk, :normalize, 1}],
      verdict: :formats_internal_stacktrace_without_invoking_frames,
      owner: :plan_02
    },
    {:dbg_istk, :normalize, 1} => %{
      caller_input: :internal_stack_entry,
      defaults: :none,
      option_paths: [:function_valued_frame, :module_function_frame],
      trace: [{:dbg_istk, :normalize, 1}],
      verdict: :converts_frame_to_trace_data_without_invocation,
      owner: :plan_02
    },
    {:dbg_istk, :finalize, 1} => %{
      caller_input: :normalized_internal_frame,
      defaults: :none,
      option_paths: [:module_tuple_frame, :function_frame],
      trace: [{:dbg_istk, :finalize, 1}, {:dbg_istk, :line, 1}],
      verdict: :formats_frame_metadata,
      owner: :plan_02
    },
    {:dbg_istk, :line, 1} => %{
      caller_input: :internal_location_metadata,
      defaults: :nonpositive_line_has_no_file_line_fields,
      option_paths: [:positive_line, :no_line],
      trace: [{:dbg_istk, :line, 1}, {:erlang, :atom_to_list, 1}],
      verdict: :formats_internal_source_location,
      owner: :plan_02
    },
    {:dbg_istk, :bindings, 1} => %{
      caller_input: :requested_internal_stack_pointer,
      defaults: :empty_stack_uses_new_bindings,
      option_paths: [:delegate_to_bindings_2],
      trace: [{:dbg_istk, :bindings, 1}, {:dbg_istk, :bindings, 2}],
      verdict: :reads_internal_interpreter_bindings,
      owner: :plan_02
    },
    {:dbg_istk, :bindings, 2} => %{
      caller_input: :stack_pointer_and_internal_stack_list,
      defaults: :empty_stack_uses_new_bindings,
      option_paths: [:matching_frame, :skip_frame, :empty_stack],
      trace: [{:dbg_istk, :bindings, 2}, {:erl_eval, :new_bindings, 0}],
      verdict: :reads_bindings_or_returns_empty_interpreter_bindings,
      owner: :plan_02
    },
    {:dbg_istk, :stack_frame, 2} => %{
      caller_input: :direction_and_internal_stack_pointer,
      defaults: :none,
      option_paths: [:up, :down_with_reversed_stack],
      trace: [{:dbg_istk, :stack_frame, 2}, {:dbg_istk, :stack_frame, 3}],
      verdict: :selects_adjacent_internal_frame_or_boundary,
      owner: :plan_02
    },
    {:dbg_istk, :stack_frame, 3} => %{
      caller_input: :stack_pointer_direction_and_internal_stack_list,
      defaults: :none,
      option_paths: [:next_lower_level, :next_higher_level, :top, :bottom],
      trace: [{:dbg_istk, :stack_frame, 3}],
      verdict: :walks_internal_frames_without_executing_them,
      owner: :plan_02
    },
    {:dbg_istk, :backtrace, 2} => %{
      caller_input: :entry_count_or_all_and_interpreter_frame,
      defaults: :none,
      option_paths: [:all_frames, :lists_sublist_count],
      trace: [{:dbg_istk, :backtrace, 2}, {:lists, :sublist, 2}],
      verdict: :returns_internal_frame_data,
      owner: :plan_02
    },
    {:dbg_istk, :in_use_p, 2} => %{
      caller_input: :module_atoms_and_internal_stack,
      defaults: :trace_disabled_treats_module_as_in_use,
      option_paths: [:same_module_true, :trace_stack_false_true, :scan_stack],
      trace: [{:dbg_istk, :in_use_p, 2}, {:lists, :any, 2}],
      verdict: :checks_internal_stack_module_presence,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :start, 4} => %{
      caller_input: :caller_selected_filenames_directory_and_mode,
      defaults: :monitor_supplied_local_or_global_mode,
      option_paths: [:dialog_accept, :dialog_cancel],
      trace: [{:dbg_wx_interpret, :start, 4}, {:dbg_wx_interpret, :interpret_all, 5}],
      verdict: :caller_selected_files_reach_interpreter,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :filter_files, 2} => %{
      caller_input: :file_dialog_directory_and_name,
      defaults: :other_extension_is_generic_file,
      option_paths: [:erl_source, :header, :beam, :other],
      trace: [{:dbg_wx_interpret, :filter_files, 2}, {:int, :interpretable, 1}],
      verdict: :filters_dialog_names_but_does_not_bound_interpreter_input,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :interpret_all, 5} => %{
      caller_input: :caller_selected_directory_files_and_mode,
      defaults: :empty_file_list_returns_or_reports_errors,
      option_paths: [:local_int_i, :global_int_ni, :per_file_error],
      trace: [
        {:dbg_wx_interpret, :interpret_all, 5},
        {:filename, :join, 2},
        {:int, :i, 1},
        {:int, :ni, 1}
      ],
      verdict: :selected_file_path_reaches_interpreter_entry_points,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :format_error, 1} => %{
      caller_input: :interpreter_error_result,
      defaults: :unknown_error_tuple_has_no_clause,
      option_paths: [:known_file_or_debug_info_errors, :missing_file_error, :app_error],
      trace: [{:dbg_wx_interpret, :format_error, 1}],
      verdict: :maps_interpreter_failures_to_fixed_messages,
      owner: :plan_02
    }
  }

  @debugger_core_source %{
    sha256: %{
      "debugger/src/dbg_idb.erl" =>
        "3505ba8ce32c8ca147a1195a183cc78a841b28de479c29b5e92822afefea3593",
      "debugger/src/dbg_istk.erl" =>
        "a71cef371ac1875a22e851d44e4e47b5a1b87309709fca32073e78d51825e01c",
      "debugger/src/dbg_ieval.erl" =>
        "60362d2aa47470b70a9264c5a4f7c5e60e8362f844e3ec4171cc3733d2ff31d1",
      "debugger/src/dbg_wx_filedialog_win.erl" =>
        "d9a2e6bffb2f673d830c1c76585076c8510681a356a57c31547f838eaa9d858e",
      "debugger/src/dbg_wx_interpret.erl" =>
        "0731379c05425123893f08dab6d149f2e42f095f9245ff18d098691ab87520bb",
      "debugger/src/dbg_wx_mon.erl" =>
        "c47574e6f066df305154bbd893762011cf04ecb8315d8263cab415befbab22ff",
      "debugger/src/dbg_wx_mon_win.erl" =>
        "914439f252dc785d467980e163f001969a484cda8ae485b5833a3fcb65cbea30",
      "debugger/src/dbg_iload.erl" =>
        "a2dd4ad09550a866e5cc16834c0f006a146a21c3abc983f72d8ed44dd1a4b250",
      "debugger/src/dbg_wx_win.erl" =>
        "109bffa861fa1e6d71310a8ca91d57f2b2aa941d7220dfd440a79ad4bc286599"
    },
    citations: [
      {"debugger/src/dbg_wx_mon.erl:338", "gui_cmd('Interpret...', State) ->"},
      {"debugger/src/dbg_wx_interpret.erl:44", "start(Win, Pos, SDir, Mode) ->"},
      {"debugger/src/dbg_wx_interpret.erl:51", "{filter, fun filter_files/2}"},
      {"debugger/src/dbg_wx_interpret.erl:53", "case wxFileDialog:showModal(FD) of"},
      {"debugger/src/dbg_wx_interpret.erl:55", "Files = dbg_wx_filedialog_win:getFilenames(FD)"},
      {"debugger/src/dbg_wx_interpret.erl:56", "Dir   = dbg_wx_filedialog_win:getDirectory(FD)"},
      {"debugger/src/dbg_wx_interpret.erl:58", "interpret_all(Dir, Files, Mode, Win, [])"},
      {"debugger/src/dbg_wx_interpret.erl:59", "self() ! {dbg_ui_interpret, Dir}"},
      {"debugger/src/dbg_wx_filedialog_win.erl:79", "getFilenames(FD) ->"},
      {"debugger/src/dbg_wx_filedialog_win.erl:81", "getDirectory(FD) ->"},
      {"debugger/src/dbg_wx_interpret.erl:108", "File = filename:join(Dir, File0),"},
      {"debugger/src/dbg_wx_interpret.erl:110", "local -> int:i(File);"}
    ],
    export_citations: [
      {"debugger/src/dbg_idb.erl:26", "-export([insert/3, lookup/2, match_object/2])."},
      {"debugger/src/dbg_istk.erl:27", "-export([init/0,delayed_to_external/0,from_external/1,"},
      {"debugger/src/dbg_istk.erl:28", "push/3,pop/0,pop/1,stack_level/0,"},
      {"debugger/src/dbg_istk.erl:29", "delayed_stacktrace/0,delayed_stacktrace/2,"},
      {"debugger/src/dbg_istk.erl:30", "bindings/1,stack_frame/2,backtrace/2,"},
      {"debugger/src/dbg_istk.erl:31", "in_use_p/2])."},
      {"debugger/src/dbg_wx_interpret.erl:31", "-export([start/4])."}
    ],
    family_function_sources: [
      {{:dbg_idb, :insert, 3}, {"debugger/src/dbg_idb.erl:32", "insert(DbRef, Key, Value) ->"}},
      {{:dbg_idb, :lookup, 2}, {"debugger/src/dbg_idb.erl:40", "lookup(DbRef, Key) ->"}},
      {{:dbg_idb, :match_object, 2},
       {"debugger/src/dbg_idb.erl:52", "match_object(DbRef, Key) ->"}},
      {{:dbg_istk, :init, 0}, {"debugger/src/dbg_istk.erl:46", "init() ->"}},
      {{:dbg_istk, :delayed_to_external, 0},
       {"debugger/src/dbg_istk.erl:49", "delayed_to_external() ->"}},
      {{:dbg_istk, :from_external, 1},
       {"debugger/src/dbg_istk.erl:53", "from_external({stack,Stk}) ->"}},
      {{:dbg_istk, :init, 1}, {"debugger/src/dbg_istk.erl:56", "init(Stack) ->"}},
      {{:dbg_istk, :push, 3},
       {"debugger/src/dbg_istk.erl:73", "push(Bs, #ieval{level=Le,module=Mod,function=Name,"}},
      {{:dbg_istk, :pop, 0}, {"debugger/src/dbg_istk.erl:86", "pop() ->"}},
      {{:dbg_istk, :pop, 1}, {"debugger/src/dbg_istk.erl:98", "pop(Le) ->"}},
      {{:dbg_istk, :pop, 2},
       {"debugger/src/dbg_istk.erl:105", "pop(Level, [#e{level=Le}|Stack]) when Level =< Le ->"}},
      {{:dbg_istk, :stack_level, 0}, {"debugger/src/dbg_istk.erl:113", "stack_level() ->"}},
      {{:dbg_istk, :stack_level, 1}, {"debugger/src/dbg_istk.erl:116", "stack_level([]) -> 1;"}},
      {{:dbg_istk, :delayed_stacktrace, 0},
       {"debugger/src/dbg_istk.erl:127", "delayed_stacktrace() ->"}},
      {{:dbg_istk, :delayed_stacktrace, 2},
       {"debugger/src/dbg_istk.erl:134", "delayed_stacktrace(include_args, Ieval) ->"}},
      {{:dbg_istk, :stacktrace, 3},
       {"debugger/src/dbg_istk.erl:155", "stacktrace(N, [#e{lc=true}|T], Acc) ->"}},
      {{:dbg_istk, :normalize, 1},
       {"debugger/src/dbg_istk.erl:169",
        "normalize(#e{mfa={M,Fun,As},line=Li,error_info=ErrorInfo}) when is_function(Fun) ->"}},
      {{:dbg_istk, :finalize, 1},
       {"debugger/src/dbg_istk.erl:176", "finalize({M,F,A,Loc}) -> {M,F,A,line(Loc)};"}},
      {{:dbg_istk, :line, 1}, {"debugger/src/dbg_istk.erl:179", "line({Mod,Line,ErrorInfo}) ->"}},
      {{:dbg_istk, :bindings, 1}, {"debugger/src/dbg_istk.erl:190", "bindings(SP) ->"}},
      {{:dbg_istk, :bindings, 2},
       {"debugger/src/dbg_istk.erl:193", "bindings(SP, [#e{level=SP,bindings=Bs}|_]) ->"}},
      {{:dbg_istk, :stack_frame, 2}, {"debugger/src/dbg_istk.erl:209", "stack_frame(up, SP) ->"}},
      {{:dbg_istk, :stack_frame, 3},
       {"debugger/src/dbg_istk.erl:214",
        "stack_frame(SP, up, [#e{level=Le,mfa={Cm,_,_},line=Li,bindings=Bs}|_])"}},
      {{:dbg_istk, :backtrace, 2},
       {"debugger/src/dbg_istk.erl:236", "backtrace(HowMany, Ieval) ->"}},
      {{:dbg_istk, :in_use_p, 2},
       {"debugger/src/dbg_istk.erl:250", "in_use_p(Mod, Mod) -> true;"}},
      {{:dbg_wx_interpret, :start, 4},
       {"debugger/src/dbg_wx_interpret.erl:44", "start(Win, Pos, SDir, Mode) ->"}},
      {{:dbg_wx_interpret, :filter_files, 2},
       {"debugger/src/dbg_wx_interpret.erl:66", "filter_files(Dir, Name) ->"}},
      {{:dbg_wx_interpret, :interpret_all, 5},
       {"debugger/src/dbg_wx_interpret.erl:107",
        "interpret_all(Dir, [File0|Files], Mode, Window, Errors) ->"}},
      {{:dbg_wx_interpret, :format_error, 1},
       {"debugger/src/dbg_wx_interpret.erl:131",
        "format_error({error,no_beam}) -> \"No BEAM file\";"}}
    ],
    branch_citations: %{
      database_dispatch: [
        {"debugger/src/dbg_idb.erl:33", "case DbRef of"},
        {"debugger/src/dbg_idb.erl:35",
         "rpc:block_call(Node, ets, insert, [ModDb, {Key, Value}]);"},
        {"debugger/src/dbg_idb.erl:37", "ets:insert(ModDb, {Key, Value})"},
        {"debugger/src/dbg_idb.erl:42", "{Node, ModDb} ->"},
        {"debugger/src/dbg_idb.erl:43", "rpc:block_call(Node, ets, lookup, [ModDb, Key]);"},
        {"debugger/src/dbg_idb.erl:45", "ets:lookup(ModDb, Key)"},
        {"debugger/src/dbg_idb.erl:48", "[{Key, Value}] -> {ok, Value};"},
        {"debugger/src/dbg_idb.erl:49", "_ -> not_found"},
        {"debugger/src/dbg_idb.erl:55", "rpc:block_call(Node, ets, match_object, [ModDb, Key]);"},
        {"debugger/src/dbg_idb.erl:57", "ets:match_object(ModDb, Key)"}
      ],
      stack_lifecycle: [
        {"debugger/src/dbg_istk.erl:47", "init([])."},
        {"debugger/src/dbg_istk.erl:50", "Stack = get(?STACK),"},
        {"debugger/src/dbg_istk.erl:51", "fun() -> {stack,term_to_binary(Stack)} end."},
        {"debugger/src/dbg_istk.erl:54", "put(?STACK, binary_to_term(Stk))."},
        {"debugger/src/dbg_istk.erl:57", "put(?STACK, Stack)."},
        {"debugger/src/dbg_istk.erl:76", "case get(trace_stack) of"},
        {"debugger/src/dbg_istk.erl:77", "false ->"},
        {"debugger/src/dbg_istk.erl:79", "no_tail when Lc ->"},
        {"debugger/src/dbg_istk.erl:82", "put(?STACK, [Entry|get(?STACK)]),"},
        {"debugger/src/dbg_istk.erl:91", "[_Entry|Entries] ->"},
        {"debugger/src/dbg_istk.erl:93", "[] ->"},
        {"debugger/src/dbg_istk.erl:102", "put(?STACK, pop(Le, get(?STACK)))"},
        {"debugger/src/dbg_istk.erl:105", "pop(Level, [#e{level=Le}|Stack]) when Level =< Le ->"},
        {"debugger/src/dbg_istk.erl:107", "pop(_Level, Stack) ->"},
        {"debugger/src/dbg_istk.erl:116", "stack_level([]) -> 1;"},
        {"debugger/src/dbg_istk.erl:117", "stack_level([#e{level=Le}|_]) -> Le."}
      ],
      stack_trace: [
        {"debugger/src/dbg_istk.erl:134", "delayed_stacktrace(include_args, Ieval) ->"},
        {"debugger/src/dbg_istk.erl:147", "delayed_stacktrace(no_args, Ieval) ->"},
        {"debugger/src/dbg_istk.erl:155", "stacktrace(N, [#e{lc=true}|T], Acc) ->"},
        {"debugger/src/dbg_istk.erl:159", "stacktrace(N, [E|T], [{P,_}|_]=Acc) when N > 0 ->"},
        {"debugger/src/dbg_istk.erl:166", "stacktrace(_, _, Acc) ->"},
        {"debugger/src/dbg_istk.erl:169",
         "normalize(#e{mfa={M,Fun,As},line=Li,error_info=ErrorInfo}) when is_function(Fun) ->"},
        {"debugger/src/dbg_istk.erl:172",
         "normalize(#e{mfa={M,F,As},line=Li,error_info=ErrorInfo}) ->"},
        {"debugger/src/dbg_istk.erl:176", "finalize({M,F,A,Loc}) -> {M,F,A,line(Loc)};"},
        {"debugger/src/dbg_istk.erl:179", "line({Mod,Line,ErrorInfo}) ->"},
        {"debugger/src/dbg_istk.erl:185", "line(_) -> []."},
        {"debugger/src/dbg_istk.erl:193", "bindings(SP, [#e{level=SP,bindings=Bs}|_]) ->"},
        {"debugger/src/dbg_istk.erl:195", "bindings(SP, [_Entry|Entries]) ->"},
        {"debugger/src/dbg_istk.erl:197", "bindings(_SP, []) ->"},
        {"debugger/src/dbg_istk.erl:209", "stack_frame(up, SP) ->"},
        {"debugger/src/dbg_istk.erl:211", "stack_frame(down, SP) ->"},
        {"debugger/src/dbg_istk.erl:214",
         "stack_frame(SP, up, [#e{level=Le,mfa={Cm,_,_},line=Li,bindings=Bs}|_])"},
        {"debugger/src/dbg_istk.erl:217",
         "stack_frame(SP, down, [#e{level=Le,mfa={Cm,_,_},line=Li,bindings=Bs}|_])"},
        {"debugger/src/dbg_istk.erl:220", "stack_frame(SP, Dir, [#e{level=SP}|Stack]) ->"},
        {"debugger/src/dbg_istk.erl:239", "Stack = case HowMany of"},
        {"debugger/src/dbg_istk.erl:250", "in_use_p(Mod, Mod) -> true;"},
        {"debugger/src/dbg_istk.erl:252", "case get(trace_stack) of"},
        {"debugger/src/dbg_istk.erl:255",
         "lists:any(fun(#e{mfa={M,_,_}}) when M =:= Mod -> true;"}
      ],
      dialog_return: [
        {"debugger/src/dbg_wx_interpret.erl:53", "case wxFileDialog:showModal(FD) of"},
        {"debugger/src/dbg_wx_interpret.erl:54", "?wxID_OK ->"},
        {"debugger/src/dbg_wx_interpret.erl:55",
         "Files = dbg_wx_filedialog_win:getFilenames(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:56",
         "Dir   = dbg_wx_filedialog_win:getDirectory(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:57", "dbg_wx_filedialog_win:destroy(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:58", "interpret_all(Dir, Files, Mode, Win, [])"},
        {"debugger/src/dbg_wx_interpret.erl:59", "self() ! {dbg_ui_interpret, Dir}"},
        {"debugger/src/dbg_wx_filedialog_win.erl:79", "getFilenames(FD) ->"},
        {"debugger/src/dbg_wx_filedialog_win.erl:80", "wx_object:call(FD, getFilenames)"},
        {"debugger/src/dbg_wx_filedialog_win.erl:81", "getDirectory(FD) ->"},
        {"debugger/src/dbg_wx_filedialog_win.erl:82", "wx_object:call(FD, getDirectory)"},
        {"debugger/src/dbg_wx_filedialog_win.erl:83", "destroy(FD) ->"},
        {"debugger/src/dbg_wx_filedialog_win.erl:84", "wx_object:call(FD, destroy)"}
      ],
      dialog_cancel: [
        {"debugger/src/dbg_wx_interpret.erl:61", "_ ->"},
        {"debugger/src/dbg_wx_interpret.erl:62", "dbg_wx_filedialog_win:destroy(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:63", "cancel"}
      ],
      parser_filter: [
        {"debugger/src/dbg_wx_interpret.erl:66", "filter_files(Dir, Name) ->"},
        {"debugger/src/dbg_wx_interpret.erl:67", "case filename:extension(Name) of"},
        {"debugger/src/dbg_wx_interpret.erl:68", "\".erl\" ->"},
        {"debugger/src/dbg_wx_interpret.erl:69", "File = filename:join(Dir, Name),"},
        {"debugger/src/dbg_wx_interpret.erl:70", "case int:interpretable(File) of"},
        {"debugger/src/dbg_wx_interpret.erl:71", "true ->"},
        {"debugger/src/dbg_wx_interpret.erl:73", "_ ->"},
        {"debugger/src/dbg_wx_interpret.erl:76", "\".hrl\" ->"},
        {"debugger/src/dbg_wx_interpret.erl:78", "\".beam\" ->"},
        {"debugger/src/dbg_wx_interpret.erl:80", "_ ->"}
      ],
      selected_files: [
        {"debugger/src/dbg_wx_interpret.erl:107",
         "interpret_all(Dir, [File0|Files], Mode, Window, Errors) ->"},
        {"debugger/src/dbg_wx_interpret.erl:108", "File = filename:join(Dir, File0),"},
        {"debugger/src/dbg_wx_interpret.erl:110", "local -> int:i(File);"},
        {"debugger/src/dbg_wx_interpret.erl:111", "global -> int:ni(File)"},
        {"debugger/src/dbg_wx_interpret.erl:114", "{module, _Mod} ->"},
        {"debugger/src/dbg_wx_interpret.erl:115",
         "interpret_all(Dir, Files, Mode, Window, Errors);"},
        {"debugger/src/dbg_wx_interpret.erl:116", "error ->"},
        {"debugger/src/dbg_wx_interpret.erl:117",
         "interpret_all(Dir, Files, Mode, Window, [File0|Errors])"}
      ],
      empty_and_errors: [
        {"debugger/src/dbg_wx_interpret.erl:119",
         "interpret_all(_Dir, [], _Mode, _Window, []) ->"},
        {"debugger/src/dbg_wx_interpret.erl:120", "true;"},
        {"debugger/src/dbg_wx_interpret.erl:121",
         "interpret_all(Dir, [], _Mode, Window, Errors) ->"},
        {"debugger/src/dbg_wx_interpret.erl:124",
         "Error = format_error(int:interpretable(File)),"},
        {"debugger/src/dbg_wx_interpret.erl:128",
         "dbg_wx_win:confirm(Window, lists:flatten(All)),"},
        {"debugger/src/dbg_wx_win.erl:231", "confirm(Win,Message) ->"},
        {"debugger/src/dbg_wx_interpret.erl:131",
         "format_error({error,no_beam}) -> \"No BEAM file\";"},
        {"debugger/src/dbg_wx_interpret.erl:132",
         "format_error({error,no_debug_info}) -> \"No debug_info in BEAM file\";"},
        {"debugger/src/dbg_wx_interpret.erl:133",
         "format_error({error,badarg}) -> \"File does not exist\";"},
        {"debugger/src/dbg_wx_interpret.erl:134", "format_error({error,{app,App}}) ->"}
      ]
    },
    ui_provenance_citations: [
      {"debugger/src/dbg_wx_mon.erl:173", "State3 = init_contents(int:interpreted(),"},
      {"debugger/src/dbg_wx_mon_win.erl:311",
       "MenuBtn = wxMenu:append(Menu, ?wxID_ANY, atom_to_list(Mod), Sub),"},
      {"debugger/src/dbg_wx_mon_win.erl:312",
       "wxListBox:append(WinInfo#winInfo.listbox, atom_to_list(Mod)),"},
      {"debugger/src/dbg_wx_mon_win.erl:120",
       "Fbtn = wxCheckBox:new(Panel, ?autoId, \"First Call\"),"},
      {"debugger/src/dbg_wx_mon_win.erl:122",
       "Bbtn = wxCheckBox:new(Panel, ?autoId, \"On Break\"),"},
      {"debugger/src/dbg_wx_mon_win.erl:124",
       "Ebtn = wxCheckBox:new(Panel, ?autoId, \"On Exit\"),"},
      {"debugger/src/dbg_wx_mon_win.erl:530",
       "handle_event(_Ev = #wx{event=#wxKey{keyCode=Key, controlDown=true}}, _WinInfo) ->"},
      {"debugger/src/dbg_wx_mon_win.erl:534", "{shortcut, list_to_atom([Key+($a-$A)])}"},
      {"debugger/src/dbg_wx_mon_win.erl:555",
       "handle_event(#wx{event=#wxCommand{type=command_listbox_doubleclicked, cmdString=ModS}},"},
      {"debugger/src/dbg_wx_mon_win.erl:557", "{module, list_to_atom(ModS), view};"},
      {"debugger/src/dbg_wx_mon_win.erl:573", "Check = fun(Button, NamesAcc) ->"},
      {"debugger/src/dbg_wx_mon_win.erl:577", "[list_to_atom(Name)|NamesAcc];"}
    ],
    cross_owner_support_citations: [
      {"debugger/src/dbg_iload.erl:78", "dbg_idb:insert(Db, mod_file, File),"},
      {"debugger/src/dbg_iload.erl:88", "store_forms(Forms, Mod, Db,"},
      {"debugger/src/dbg_iload.erl:97",
       "NewBinary = store_mod_line_no(Mod, Db, binary_to_list(Src)),"},
      {"debugger/src/dbg_iload.erl:98", "dbg_idb:insert(Db, mod_bin, NewBinary),"},
      {"debugger/src/dbg_iload.erl:99",
       "dbg_idb:insert(Db, mod_raw, <<Src/binary,0:8>>). %% Add eos"},
      {"debugger/src/dbg_iload.erl:162", "dbg_idb:insert(Db, {Mod,Name,Arity,Exported}, Cs),"},
      {"debugger/src/dbg_iload.erl:164",
       "store_forms([{attribute,_,record,{Name,Defs}}|Fs], Mod, Db, St) ->"},
      {"debugger/src/dbg_iload.erl:167",
       "dbg_idb:insert(Db, {record,Mod,Name,length(Fields)}, Fields),"},
      {"debugger/src/dbg_ieval.erl:538",
       "case dbg_idb:match_object(DbRef, {{Mod,Name,Arity,'_'},'_'}) of"},
      {"debugger/src/dbg_ieval.erl:546", "get_function(Mod, Name, Args, extern) ->"},
      {"debugger/src/dbg_ieval.erl:554", "case dbg_idb:lookup(DbRef, {Mod,Name,Arity,true}) of"},
      {"debugger/src/dbg_ieval.erl:558", "not_found ->"}
    ],
    seed_citations: [
      {"debugger/src/dbg_idb.erl:32", "insert(DbRef, Key, Value) ->"},
      {"debugger/src/dbg_idb.erl:40", "lookup(DbRef, Key) ->"},
      {"debugger/src/dbg_idb.erl:52", "match_object(DbRef, Key) ->"},
      {"debugger/src/dbg_istk.erl:49", "delayed_to_external() ->"}
    ],
    decoder_citations: [
      {"debugger/src/dbg_istk.erl:27", "-export([init/0,delayed_to_external/0,from_external/1,"},
      {"debugger/src/dbg_istk.erl:53", "from_external({stack,Stk}) ->"},
      {"debugger/src/dbg_istk.erl:54", "put(?STACK, binary_to_term(Stk))."}
    ],
    decoder_provenance_citations: [
      {"debugger/src/dbg_ieval.erl:68", "exit_info(Int, AttPid, OrigPid, Reason, ExitInfo) ->"},
      {"debugger/src/dbg_ieval.erl:76", "{{Mod,Line},Bs,S} ->"},
      {"debugger/src/dbg_ieval.erl:77", "dbg_istk:from_external(S),"},
      {"debugger/src/dbg_istk.erl:49", "delayed_to_external() ->"},
      {"debugger/src/dbg_istk.erl:51", "fun() -> {stack,term_to_binary(Stack)} end."},
      {"debugger/src/dbg_ieval.erl:149", "StackExternal = (dbg_istk:delayed_to_external())(),"},
      {"debugger/src/dbg_ieval.erl:150", "{{Mod, Li}, Bs, StackExternal};"},
      {"debugger/src/dbg_ieval.erl:188",
       "do_exception(Class, Reason, Stacktrace, Bs, #ieval{module=M, line=Line}) ->"},
      {"debugger/src/dbg_ieval.erl:189", "StackFun = dbg_istk:delayed_to_external(),"},
      {"debugger/src/dbg_ieval.erl:190", "ExitInfo = fun() ->"},
      {"debugger/src/dbg_ieval.erl:191", "{{M,Line},Bs,StackFun()}"},
      {"debugger/src/dbg_ieval.erl:193", "put(exit_info, ExitInfo),"}
    ]
  }

  @debugger_core_source Map.put(
                          @debugger_core_source,
                          :family_function_audit,
                          Enum.map(@debugger_expected_family_mfas, fn mfa ->
                            {^mfa, citation} =
                              Enum.find(@debugger_core_source.family_function_sources, fn
                                {candidate, _citation} -> candidate == mfa
                              end)

                            Map.merge(Map.fetch!(@debugger_function_reviews, mfa), %{
                              mfa: mfa,
                              citations: [citation]
                            })
                          end)
                        )

  @debugger_floor_source (
                           shift = fn {citation, expected} ->
                             [path, line] = String.split(citation, ":", parts: 2)

                             offset =
                               cond do
                                 String.ends_with?(path, "dbg_istk.erl") ->
                                   5

                                 String.ends_with?(path, "dbg_wx_mon.erl") ->
                                   4

                                 String.ends_with?(path, "dbg_wx_mon_win.erl") ->
                                   4

                                 String.ends_with?(path, "dbg_iload.erl") and
                                     String.to_integer(line) >= 160 ->
                                   17

                                 String.ends_with?(path, "dbg_iload.erl") ->
                                   1

                                 true ->
                                   2
                               end

                             {"#{path}:#{String.to_integer(line) - offset}", expected}
                           end

                           floor_hashes = %{
                             "debugger/src/dbg_idb.erl" =>
                               "990726cde6815d7616b01d13adf4f8cacc7540b702507ba0fea8ca349bbbe2c5",
                             "debugger/src/dbg_istk.erl" =>
                               "4f68bca517244f361bb915000fe299259242d6a8d733b064ed47d2f8872b8f66",
                             "debugger/src/dbg_ieval.erl" =>
                               "393085c1fc6324687bc12b5184b5a501491f07c8f55dc293ee07774ea96d0b6a",
                             "debugger/src/dbg_wx_filedialog_win.erl" =>
                               "4c4f8d9af1f3f326a952c1b4e181d1533c692f08b8954fd884233f7b2500ab2a",
                             "debugger/src/dbg_wx_interpret.erl" =>
                               "d41c9d6225a8817bd792abb202916020782d72b59e439a891b0ebc4864e38098",
                             "debugger/src/dbg_wx_mon.erl" =>
                               "8beded69315466f8b941d4395e4047453667c31404226a8e53ab229b47a6a05e",
                             "debugger/src/dbg_wx_mon_win.erl" =>
                               "971779c05b5d7c08317c04d33d7354a24a701ed35c2f96c9eef67d77d5a4cb25",
                             "debugger/src/dbg_iload.erl" =>
                               "530955c6525821e0382d53375ce5750cb4fd290ce4c323dd38521538452dae03",
                             "debugger/src/dbg_wx_win.erl" =>
                               "31b4f35b2f1c871404ce5d261aff965d630f6347edcfc9b084e1f8dc90ad061e"
                           }

                           Map.merge(@debugger_core_source, %{
                             sha256: floor_hashes,
                             citations: Enum.map(@debugger_core_source.citations, shift),
                             export_citations:
                               Enum.map(@debugger_core_source.export_citations, shift),
                             family_function_sources:
                               Enum.map(@debugger_core_source.family_function_sources, fn {mfa,
                                                                                           citation} ->
                                 {mfa, shift.(citation)}
                               end),
                             family_function_audit:
                               Enum.map(@debugger_core_source.family_function_audit, fn review ->
                                 %{review | citations: Enum.map(review.citations, shift)}
                               end),
                             branch_citations:
                               Map.new(@debugger_core_source.branch_citations, fn {group,
                                                                                   citations} ->
                                 {group, Enum.map(citations, shift)}
                               end),
                             seed_citations:
                               Enum.map(@debugger_core_source.seed_citations, shift),
                             decoder_citations:
                               Enum.map(@debugger_core_source.decoder_citations, shift),
                             decoder_provenance_citations:
                               Enum.map(@debugger_core_source.decoder_provenance_citations, shift),
                             ui_provenance_citations:
                               Enum.map(@debugger_core_source.ui_provenance_citations, shift),
                             cross_owner_support_citations:
                               Enum.map(
                                 @debugger_core_source.cross_owner_support_citations,
                                 shift
                               )
                           })
                         )

  @debugger_source_by_lane %{
    "core" => @debugger_core_source,
    "floor" => @debugger_floor_source
  }

  @debugger_audit (for lane <- @ct_make_lanes do
                     source = Map.fetch!(@debugger_source_by_lane, lane)
                     mfa = @debugger_selected_file_mfa

                     %{
                       original_id:
                         "NEW-DEBUGGER-#{String.upcase(lane)}-dbg_wx_interpret-start-4",
                       original_matcher: {:mfa, mfa},
                       original_reason: :tier,
                       lane: lane,
                       matched_mfas: [mfa],
                       caller_input: :caller_selected_filenames_and_directory,
                       defaults: :monitor_supplied_local_or_global_mode,
                       option_paths: [:local, :global],
                       trace: [
                         {:dbg_wx_mon, :gui_cmd, 2},
                         {:dbg_wx_interpret, :start, 4},
                         {:dbg_wx_filedialog_win, :getFilenames, 1},
                         {:dbg_wx_filedialog_win, :getDirectory, 1},
                         {:dbg_wx_interpret, :interpret_all, 5},
                         {:filename, :join, 2},
                         {:int, :i, 1},
                         {:int, :ni, 1}
                       ],
                       verdict: :caller_selected_files_reach_interpreter,
                       replacements: %{mfa => {:tier, mfa}},
                       tier: [mfa],
                       fixtures: [
                         :direct,
                         :capture,
                         :apply,
                         :utf8_literal,
                         :discarded_quote,
                         :uninvoked_macro
                       ],
                       citations: source.citations,
                       seed_citations: source.seed_citations,
                       decoder_mfa: {:dbg_istk, :from_external, 1},
                       decoder_caller_input: :arbitrary_exported_stack_binary,
                       decoder_options: :binary_to_term_without_safe_option,
                       decoder_trace: [
                         {:dbg_ieval, :exit_info, 5},
                         {:dbg_istk, :from_external, 1},
                         {:erlang, :binary_to_term, 1},
                         :process_dictionary_stack_write
                       ],
                       decoder_verdict: :caller_binary_is_unconstrained_at_export,
                       decoder_fixtures: [
                         :direct,
                         :capture,
                         :apply,
                         :discarded_quote,
                         :uninvoked_macro,
                         :serializing_only_control
                       ],
                       decoder_removal_witness: :uncalled_probe_mfa_tier_reduction,
                       decoder_citations: source.decoder_citations,
                       decoder_provenance_citations: source.decoder_provenance_citations,
                       internal_provenance: %{
                         producer: {:dbg_istk, :delayed_to_external, 0},
                         encoder: {:erlang, :term_to_binary, 1},
                         observed_consumer: {:dbg_ieval, :exit_info, 5},
                         verdict: :observed_internal_round_trip_does_not_constrain_public_input
                       },
                       export_citations: source.export_citations,
                       family_function_sources: source.family_function_sources,
                       family_function_audit: source.family_function_audit,
                       branch_citations: source.branch_citations,
                       ui_provenance_citations: source.ui_provenance_citations,
                       cross_owner_support_citations: source.cross_owner_support_citations,
                       seed_dispositions:
                         Enum.zip(@debugger_source_only_seed_mfas, source.seed_citations)
                         |> Enum.map(fn {mfa, citation} ->
                           %{
                             mfa: mfa,
                             reached: false,
                             verdict: :source_disposed_without_graph_hit,
                             citation: citation
                           }
                         end),
                       ui_provenance: %{
                         module_list_origin: {:int, :interpreted, 0},
                         module_name_display: :atom_to_list,
                         checkbox_labels: ["First Call", "On Break", "On Exit"],
                         label_conversion: :list_to_atom,
                         callback_owner: :phase_01_1_1_3_1,
                         callback_verdict: :synthetic_events_and_keyboard_inputs_pending
                       },
                       cross_owner_support: %{
                         dbg_iload: :cited_support_only_whole_module_review_pending,
                         dbg_ieval: :decoder_consumer_provenance_only,
                         dbg_wx_filedialog_win: :dialog_getters_only,
                         dbg_wx_mon: :module_list_origin_only,
                         dbg_wx_mon_win: :labels_and_callback_boundary_only,
                         dbg_wx_win: :error_dialog_provenance_only
                       },
                       exclusion_matches: @debugger_expected_exclusion_matches,
                       exclusion_identity_replacements: %{},
                       source_sha256: source.sha256,
                       empty_selection: :source_disposed_without_invocation,
                       limitations: [
                         :no_runtime_filename_decoding_claim,
                         :no_computed_dispatch_claim,
                         :no_write_then_load_claim,
                         :no_runtime_atom_count_claim
                       ],
                       applicability: :each_exact_installed_lane,
                       removal_witness: :uncalled_probe_mfa_tier_reduction
                     }
                   end)

  @debugger_expected_ids Enum.map(@ct_make_lanes, fn lane ->
                           {"NEW-DEBUGGER-#{String.upcase(lane)}-dbg_wx_interpret-start-4", lane}
                         end)

  @escript_debug_exclusion {{:mfa, @escript_debug_mfa}, :private_front, @escript_debug_citations}

  @call_name_exclusions [
    {{Mix.Compilers.Protocol, [:compile]}, :not_compile_module,
     ["mix/lib/mix/compilers/protocol.ex:107", "mix/lib/mix/compilers/protocol.ex:162"]},
    {{Phoenix.Digester, [:compile]}, :not_compile_module,
     ["phoenix/lib/phoenix/digester.ex:20", "phoenix/lib/phoenix/digester.ex:93"]},
    {{Phoenix.LiveView.ColocatedAssets, [:compile]}, :not_compile_module,
     [
       "phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:48",
       "phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:93"
     ]},
    {{Plug.Builder, [:compile]}, :not_compile_module,
     [
       "plug/lib/plug/builder.ex:324",
       "plug/lib/plug/builder.ex:358",
       "plug/lib/plug/builder.ex:382"
     ]},
    {{Regex, [:compile]}, :not_compile_module,
     ["elixir/lib/regex.ex:219", "elixir/lib/regex.ex:223"]},
    {{:re, [:compile]}, :not_compile_module,
     [
       "stdlib/src/re.erl:128",
       "stdlib/src/re.erl:288",
       "stdlib/src/re.erl:86",
       "stdlib/src/re.erl:236"
     ]}
  ]

  @call_name_lane_specific [{{Mix.Compilers.Protocol, [:compile]}, :latest}]

  @exclusions [
    {{:fun_prefix, "MACRO-"}, :macro},
    {:erl_tracer, :own_native},
    {:prim_buffer, :own_native},
    {:prim_file, :own_native},
    {:prim_net, :own_native},
    {:prim_socket, :own_native},
    {:prim_tty, :own_native},
    {:zlib, :own_native},
    {{:dbg, [:trace_port]}, :own_native},
    {{:inets, [:enable_trace]}, :own_native},
    {:inets_trace, :own_native},
    {:fprof, :own_native},
    {:erl_compile_server, :callback},
    {:peer, :callback},
    {{IEx.Introspection, [:decompose]}, :expansion},
    {{Kernel.Typespec, [:translate_typespecs_for_module]}, :expansion},
    {{Kernel.Utils, [:defguard]}, :expansion},
    {{Macro, [:expand, :expand_once, :expand_literal, :expand_literals]}, :expansion},
    {{Macro.Env, [:expand_import]}, :expansion},
    {{Module, [:add_doc, :compile_definition_attributes]}, :expansion},
    {{Protocol, [:__derive__, :__impl__]}, :expansion},
    {{Record, [:__access__]}, :expansion},
    {{ExUnit.Assertions, [:__expand_pattern__, :__match__]}, :expansion},
    {:elixir_bitstring, :expansion},
    {:elixir_clauses, :expansion},
    {:elixir_def, :expansion},
    {:elixir_dispatch, :expansion},
    {:elixir_expand, :expansion},
    {:elixir_fn, :expansion},
    {:elixir_map, :expansion},
    {:elixir_overridable, :expansion},
    {{:elixir_module, [:expand_callback]}, :expansion},
    {{:elixir_erl, [:definition_to_anonymous]}, :expansion},
    {Exception, :own_clauses},
    {FunctionClauseError, :own_clauses},
    {{Protocol, [:consolidate]}, :compiler_pass},
    {{:elixir_erl, [:compile, :consolidate, :debug_info]}, :compiler_pass},
    {:erl_abstract_code, :compiler_pass},
    {:beam_core_to_ssa, :compiler_pass},
    {:beam_ssa_bsm, :compiler_pass},
    {:beam_ssa_opt, :compiler_pass},
    {:beam_ssa_pre_codegen, :compiler_pass},
    {:v3_core, :compiler_pass},
    {:erl_compile, :compiler_pass},
    {:merl_transform, :compiler_pass},
    {:ms_transform, :compiler_pass},
    {{:qlc, [:parse_transform, :transform_from_evaluator]}, :compiler_pass},
    {:qlc_pt, :compiler_pass},
    {{:prefix, ":dialyzer"}, :compiler_pass},
    {:typer, :compiler_pass},
    {:typer_core, :compiler_pass},
    {Mix.AppLoader, :project_build},
    {Mix.Compilers.Elixir, :project_build},
    {Mix.Compilers.Protocol, :project_build},
    {Mix.Dep.Converger, :project_build},
    {Mix.Dep.Fetcher, :project_build},
    {Mix.Dep.Umbrella, :project_build},
    {Mix.Hex, :project_build},
    {{Mix.Project, [:compile, :deps_apps, :deps_paths, :deps_scms, :deps_tree]}, :project_build},
    {Mix.Release, :project_build},
    {Mix.Task.Compiler, :project_build},
    {{:prefix, "Mix.Tasks.App."}, :project_build},
    {{:prefix, "Mix.Tasks.Compile"}, :project_build},
    {{:prefix, "Mix.Tasks.Deps"}, :project_build},
    {Mix.Tasks.Archive.Build, :project_build},
    {Mix.Tasks.Archive.Uninstall, :project_build},
    {Mix.Tasks.Clean, :project_build},
    {Mix.Tasks.Cmd, :project_build},
    {Mix.Tasks.Do, :project_build},
    {Mix.Tasks.Escript.Build, :project_build},
    {Mix.Tasks.Escript.Uninstall, :project_build},
    {Mix.Tasks.Loadpaths, :project_build},
    {Mix.Tasks.Local.Hex, :project_build},
    {Mix.Tasks.New, :project_build},
    {Mix.Tasks.Release, :project_build},
    {Mix.Tasks.Source, :project_build},
    {Mix.Tasks.Xref, :project_build},
    {{:code, [:ensure_loaded, :ensure_modules_loaded, :load_file]}, :by_name},
    {:cover, :cover_server},
    {{:elixir, [:start, :start_cli]}, :console},
    {:erl_init, :console},
    {:edlin_context, :console},
    {:edlin_expand, :console},
    {:group, :console},
    {:standard_error, :console},
    {:user_drv, :console},
    {:beam_lib, :crypto_key},
    {{:escript, [:extract, :parse_file]}, :epp_guard},
    {:systools, :boot_script},
    {:systools_make, :boot_script},
    {{:ssl_dist_sup, [:start_link]}, :dist_config},
    {:inet_tls_dist, :dist_config},
    {:inet6_tls_dist, :dist_config},
    {:inet_epmd_tls_socket, :dist_config},
    {IEx.Autocomplete, :iex_console},
    {IEx.CLI, :iex_console},
    {IEx.Config, :iex_console},
    {IEx.Info.Atom, :iex_console},
    {IEx.Introspection, :iex_console},
    {{Mix, [:start]}, :callback},
    {:sasl, :callback},
    {{:prefix, "Mix.Tasks.Local."}, :project_build},
    {{Mix.Local,
      [:find_matching_versions!, :find_matching_versions_from_signed_csv!, :decode_pk!]},
     :project_build},
    {{Mix.Utils, [:read_path]}, :fixed_app},
    {:asn1_db, :compiler_pass},
    {{:prefix, ":asn1ct_"}, :compiler_pass},
    {{Mix.Tasks.Phx, [:run]}, :fixed_args, "phoenix/lib/mix/tasks/phx.ex:25"},
    {{Mix.Tasks.Phx.Gen, [:run]}, :fixed_args, "phoenix/lib/mix/tasks/phx.gen.ex:49"},
    {{Mix.Tasks.Phx.Digest, [:run]}, :project_build, "phoenix/lib/mix/tasks/phx.digest.ex:58"},
    {{Mix.Tasks.Phx.Digest.Clean, [:run]}, :project_build,
     "phoenix/lib/mix/tasks/phx.digest.clean.ex:43"},
    {{Mix.Phoenix, [:context_app_path, :context_lib_path, :context_test_path]}, :project_build,
     [
       "phoenix/lib/mix/phoenix.ex:230",
       "phoenix/lib/mix/phoenix.ex:249",
       "phoenix/lib/mix/phoenix.ex:256"
     ]},
    {{Mix.Task, [:reenable]}, :project_build, "mix/lib/mix/task.ex:631"},
    {{Mix.Task, [:preferred_cli_env]}, :project_build, "mix/lib/mix/task.ex:270"},
    {{Mix.Tasks.Test.Coverage, [:run]}, :project_build, "mix/lib/mix/tasks/test.coverage.ex:146"},
    {{Mix.Tasks.Test.Coverage, [:generate_cover_results]}, :cover_server,
     "mix/lib/mix/tasks/test.coverage.ex:273"},
    {{Mix.Dep, [:cached, :load_and_cache]}, :project_build,
     ["mix/lib/mix/dep.ex:95", "mix/lib/mix/dep.ex:113"]},
    {{Mix.Dep.Loader, [:children]}, :project_build, "mix/lib/mix/dep/loader.ex:21"},
    {{Mix.Compilers.Erlang, [:compile_entries]}, :project_build,
     "mix/lib/mix/compilers/erlang.ex:107"},
    {{Mix, [:stop]}, :callback, "mix/lib/mix.ex:470"},
    {{Phoenix.LiveView.TagEngine, [:handle_body]}, :callback,
     "phoenix_live_view/lib/phoenix_live_view/tag_engine.ex:275"},
    {{Phoenix.CodeReloader.Server, [:handle_call]}, :callback,
     [
       "phoenix/lib/phoenix/code_reloader/server.ex:90",
       "phoenix/lib/phoenix/code_reloader/server.ex:114"
     ]},
    {{Phoenix.ActionClauseError, [:blame, :message]}, :own_clauses,
     ["phoenix/lib/phoenix/exceptions.ex:50", "phoenix/lib/phoenix/exceptions.ex:57"]},
    {{Plug.Debugger, [:render, :__catch__]}, :own_clauses,
     ["plug/lib/plug/debugger.ex:170", "plug/lib/plug/debugger.ex:205"]},
    {{Plug.Builder, [:compile]}, :expansion, "plug/lib/plug/builder.ex:324"},
    {{Phoenix.Controller.Pipeline, [:__action_fallback__]}, :expansion,
     "phoenix/lib/phoenix/controller/pipeline.ex:39"},
    {{Module.Types.Apply,
      [
        :remote,
        :return_compare,
        :map_update_or_replace_lazy,
        :signature,
        :remote_apply,
        :remote_capture,
        :remote_domain,
        :format_diagnostic
      ]}, :compiler_pass,
     ["elixir/lib/module/types/apply.ex:364", "elixir/lib/module/types/apply.ex:263"]},
    {{Module.Types.Pattern,
      [:of_changed, :of_domain, :of_match_var, :of_match, :of_guard, :of_generator, :of_head]},
     :compiler_pass, ["elixir/lib/module/types/pattern.ex:65"]},
    {{Module.Types.Of, [:bitstring, :struct_info, :struct_instance]}, :compiler_pass,
     ["elixir/lib/module/types/of.ex:549"]},
    {{Module.Types.Expr, [:of_expr]}, :compiler_pass,
     ["elixir/lib/module/types/expr.ex:61", "elixir/lib/module/types/expr.ex:53"]},
    {{Module.Types.Traverse, [:of_expr]}, :compiler_pass,
     ["elixir/lib/module/types/traverse.ex:10"]},
    {{Module.Types, [:infer, :warnings]}, :compiler_pass,
     ["elixir/lib/module/types.ex:37", "elixir/lib/module/types.ex:36"]},
    {{Module.ParallelChecker, [:verify, :spawn]}, :compiler_pass,
     ["elixir/lib/module/parallel_checker.ex:151", "elixir/lib/module/parallel_checker.ex:114"]},
    {{:erl_syntax, [:is_literal, :concrete, :revert_forms, :revert]}, :compiler_pass,
     ["syntax_tools/src/erl_syntax.erl:7503", "syntax_tools/src/erl_syntax.erl:7154"]},
    {{:erl_syntax_lib,
      [:analyze_forms, :to_comment, :analyze_attribute, :analyze_wild_attribute, :analyze_form]},
     :compiler_pass,
     ["syntax_tools/src/erl_syntax_lib.erl:1013", "syntax_tools/src/erl_syntax_lib.erl:952"]},
    {{:erl_prettypr, [:best, :format, :layout]}, :compiler_pass,
     ["syntax_tools/src/erl_prettypr.erl:290", "syntax_tools/src/erl_prettypr.erl:281"]},
    {{:erl_recomment, [:quick_recomment_forms, :recomment_forms]}, :compiler_pass,
     ["syntax_tools/src/erl_recomment.erl:60", "syntax_tools/src/erl_recomment.erl:54"]},
    {{:erl_expand_records, [:module]}, :compiler_pass,
     ["stdlib/src/erl_expand_records.erl:89", "stdlib/src/erl_expand_records.erl:58"]},
    {{:xref_base,
      [
        :add_module,
        :replace_module,
        :add_application,
        :add_release,
        :replace_application,
        :update,
        :add_directory
      ]}, :compiler_pass, ["tools/src/xref_base.erl:130", "tools/src/xref_base.erl:126"]},
    {{:xref, [:d, :m, :handle_call]}, :compiler_pass,
     ["tools/src/xref.erl:791", "tools/src/xref.erl:732"]},
    {{:file_sorter, [:keycheck, :keymerge, :sort, :check, :keysort, :merge]}, :pure_data,
     ["stdlib/src/file_sorter.erl:437", "stdlib/src/file_sorter.erl:432"]},
    {{:systools_relup, [:mk_relup]}, :compiler_pass,
     ["sasl/src/systools_relup.erl:156", "sasl/src/systools_relup.erl:154"]},
    {{:dets, [:fsck, :istart_link, :system_continue, :init]}, :runtime_internal,
     ["stdlib/src/dets.erl:399", "stdlib/src/dets.erl:394"]},
    {{:dets_v9, [:compact_init, :bchunk_init]}, :runtime_internal,
     ["stdlib/src/dets_v9.erl:759", "stdlib/src/dets_v9.erl:754"]},
    {{:dets_sup, [:init]}, :runtime_internal,
     ["stdlib/src/dets_sup.erl:39", "stdlib/src/dets_sup.erl:37"]},
    {{:application_controller, [:start, :test_change_apps]}, :runtime_internal,
     ["kernel/src/application_controller.erl:198", "kernel/src/application_controller.erl:191"]},
    {{:application_controller, [:handle_call]}, :callback,
     ["kernel/src/application_controller.erl:198", "kernel/src/application_controller.erl:191"]},
    {{:httpd, [:reload_config, :start, :serve, :start_service]}, :runtime_internal,
     ["inets/src/http_server/httpd.erl:991", "inets/src/http_server/httpd.erl:955"]},
    {{:httpd_sup, [:start_child, :init]}, :runtime_internal,
     ["inets/src/http_server/httpd_sup.erl:57", "inets/src/http_server/httpd_sup.erl:52"]},
    {{:httpd_manager, [:handle_call]}, :callback,
     [
       "inets/src/http_server/httpd_manager.erl:185",
       "inets/src/http_server/httpd_manager.erl:182"
     ]},
    {{:inets, [:versions, :print_version_info]}, :pure_data,
     ["inets/src/inets_app/inets.erl:338", "inets/src/inets_app/inets.erl:334"]},
    {{:pool, [:start]}, :runtime_internal, ["stdlib/src/pool.erl:93", "stdlib/src/pool.erl:91"]},
    {{:net_adm, [:world, :host_file]}, :runtime_internal,
     ["kernel/src/net_adm.erl:242", "kernel/src/net_adm.erl:235"]},
    {{:inet_db, [:add_rc, :start_link, :start]}, :runtime_internal,
     ["kernel/src/inet_db.erl:283", "kernel/src/inet_db.erl:278"]},
    {{:inet_config, [:init]}, :runtime_internal,
     ["kernel/src/inet_config.erl:52", "kernel/src/inet_config.erl:48"]},
    {{:erts_code_purger, [:wait_for_request, :start]}, :runtime_internal,
     ["erts/src/erts_code_purger.erl:38", "erts/src/erts_code_purger.erl:36"]},
    {{:system_information, [:sanity_check, :from_file, :load_report, :report, :to_file]},
     :pure_data,
     [
       "runtime_tools/src/system_information.erl:207",
       "runtime_tools/src/system_information.erl:200"
     ]},
    {{:erts_debug, [:lc_graph_merge, :lc_graph_to_dot]}, :pure_data,
     ["kernel/src/erts_debug.erl:481", "kernel/src/erts_debug.erl:471"]},
    {{:otp_internal, [:obsolete]}, :pure_data,
     ["stdlib/src/otp_internal.erl:49", "stdlib/src/otp_internal.erl:29"]},
    {{:edlin_type_suggestion, [:get_atoms, :get_arity, :get_types]}, :console,
     ["stdlib/src/edlin_type_suggestion.erl:340", "stdlib/src/edlin_type_suggestion.erl:321"]},
    {{:shell, [:erl_pp_format_func]}, :console,
     ["stdlib/src/shell.erl:2158", "stdlib/src/shell.erl:2043"]},
    {{:beam_doc, [:main]}, :compiler_pass,
     ["compiler/src/beam_doc.erl:245", "compiler/src/beam_doc.erl:240"]},
    {{:elixir_errors, [:parse_error]}, :compiler_pass,
     ["elixir/lib/code.ex:1468", "elixir/lib/code.ex:1453"]},
    {{:leex, [:file]}, :compiler_pass,
     ["parsetools/src/leex.erl:473", "parsetools/src/leex.erl:467"]},
    {{:systools_lib, [:read_term, :read_term_from_stream, :file_term2binary]}, :compiler_pass,
     ["sasl/src/systools_lib.erl:56", "sasl/src/systools_lib.erl:54"]},
    {{:qlc, [:info]}, :pure_data, ["stdlib/src/qlc.erl:521", "stdlib/src/qlc.erl:514"]},
    {{:dbg, [:rtp]}, :console,
     ["runtime_tools/src/dbg.erl:979", "runtime_tools/src/dbg.erl:1197"]},
    {{:dbg, [:fun2ms]}, :compiler_pass,
     ["runtime_tools/src/dbg.erl:979", "runtime_tools/src/dbg.erl:1197"]},
    {{:ets, [:fun2ms]}, :compiler_pass, ["stdlib/src/ets.erl:2447", "stdlib/src/ets.erl:2022"]},
    {{:msacc, [:from_file]}, :pure_data,
     ["runtime_tools/src/msacc.erl:209", "runtime_tools/src/msacc.erl:204"]},
    {{ExUnit.DocTest, [:__doctest_file__, :__doctests__]}, :compiler_pass,
     ["ex_unit/lib/ex_unit/doc_test.ex:297", "ex_unit/lib/ex_unit/doc_test.ex:269"]},
    {{UndefinedFunctionError, [:blame, :hint_for_loaded_module]}, :runtime_internal,
     ["elixir/lib/exception.ex:216", "elixir/lib/exception.ex:189"]},
    {{Mix.Generator, [:create_file, :copy_file]}, :project_build,
     ["mix/lib/mix/generator.ex:100", "mix/lib/mix/generator.ex:88"]},
    {{Mix.Phoenix.Context, [:function_count]}, :compiler_pass,
     ["phoenix/lib/mix/phoenix/context.ex:70"]},
    {{Mix.Tasks.Release.Init, [:run]}, :project_build,
     ["mix/lib/mix/tasks/release.init.ex:32", "mix/lib/mix/tasks/release.init.ex:28"]},
    {{Mix.Tasks.Phx.Gen.Context, [:prompt_for_code_injection]}, :project_build,
     ["phoenix/lib/mix/tasks/phx.gen.context.ex:445"]},
    {{Mix.Tasks.Phx.Gen.Cert, [:run]}, :project_build,
     ["phoenix/lib/mix/tasks/phx.gen.cert.ex:47"]},
    {{Phoenix.LiveView.HTMLAlgebra, [:build]}, :pure_data,
     ["phoenix_live_view/lib/phoenix_live_view/html_algebra.ex:24"]},
    {{Phoenix.Component.MacroComponent, [:build_ast]}, :compiler_pass,
     ["phoenix_live_view/lib/phoenix_component/macro_component.ex:214"]},
    {{:c, [:xm]}, :compiler_pass, ["stdlib/src/c.erl:1406", "stdlib/src/c.erl:1372"]},
    {{:kernel, [:init]}, :callback},
    {{:mfa, {Logger.Formatter, :new, 0}}, :fixed_default,
     [
       "logger/lib/logger/formatter.ex:117",
       "logger/lib/logger/formatter.ex:170",
       "logger/lib/logger/formatter.ex:436",
       "logger/lib/logger/formatter.ex:99",
       "logger/lib/logger/formatter.ex:152",
       "logger/lib/logger/formatter.ex:399"
     ]},
    {{:mfa, {ExUnit, :plural_rule, 2}}, :unrelated_exunit_config,
     [
       "ex_unit/lib/ex_unit.ex:456",
       "ex_unit/lib/ex_unit.ex:461",
       "ex_unit/lib/ex_unit.ex:392",
       "ex_unit/lib/ex_unit.ex:397"
     ]},
    {{:mfa, {ExUnit, :after_suite, 1}}, :unrelated_exunit_config,
     [
       "ex_unit/lib/ex_unit.ex:530",
       "ex_unit/lib/ex_unit.ex:532",
       "ex_unit/lib/ex_unit.ex:466",
       "ex_unit/lib/ex_unit.ex:468"
     ]}
  ]

  @creator_expected_lanes ~w(core floor)
  @creator_expected_original_mfas [{:file, :consult, 1}, {:file, :path_consult, 2}]
  @creator_expected_trace [
    {:file, :consult, 1},
    {:file, :path_consult, 2},
    {:file, :consult_stream, 1},
    {:file, :consult_stream, 3},
    {:io, :read, 3},
    {:io, :read, 4},
    {:erl_scan, :scan_atom, 6},
    {:erl_scan, :scan_qatom, 6}
  ]
  @creator_expected_fixtures [
    :path_consult_regression,
    :consult_direct,
    :consult_capture,
    :consult_apply,
    :consult_source_only_quote,
    :generated_mfa_probe
  ]
  @creator_expected_citation_lines %{
    "core" => ~w(
      kernel/src/file.erl:2272 kernel/src/file.erl:2273
      kernel/src/file.erl:2314 kernel/src/file.erl:2315 kernel/src/file.erl:2317
      kernel/src/file.erl:2900 kernel/src/file.erl:2905
      stdlib/src/io.erl:731 stdlib/src/io.erl:732 stdlib/src/io.erl:765
      stdlib/src/erl_scan.erl:788 stdlib/src/erl_scan.erl:1618
    ),
    "floor" => ~w(
      kernel/src/file.erl:2262 kernel/src/file.erl:2263
      kernel/src/file.erl:2304 kernel/src/file.erl:2305 kernel/src/file.erl:2307
      kernel/src/file.erl:2890 kernel/src/file.erl:2895
      stdlib/src/io.erl:700 stdlib/src/io.erl:701 stdlib/src/io.erl:734
      stdlib/src/erl_scan.erl:761 stdlib/src/erl_scan.erl:1591
    )
  }
  @creator_expected_ids for lane <- @creator_expected_lanes, do: {"EX-159", lane}

  @consult_creator_audit Enum.map(@creator_expected_lanes, fn lane ->
                           citations =
                             if lane == "core" do
                               [
                                 {"kernel/src/file.erl:2272", "consult(File) ->"},
                                 {"kernel/src/file.erl:2273", "open(File, [read])"},
                                 {"kernel/src/file.erl:2314", "path_consult(Path, File)"},
                                 {"kernel/src/file.erl:2315", "path_open(Path, File, [read])"},
                                 {"kernel/src/file.erl:2317", "consult_stream(Fd)"},
                                 {"kernel/src/file.erl:2900", "consult_stream(Fd) ->"},
                                 {"kernel/src/file.erl:2905", "io:read(Fd, '', Line)"},
                                 {"stdlib/src/io.erl:731", "read(Io, Prompt, Pos0) ->"},
                                 {"stdlib/src/io.erl:732", "read(Io, Prompt, Pos0, [])"},
                                 {"stdlib/src/io.erl:765", "erl_scan,tokens"},
                                 {"stdlib/src/erl_scan.erl:788", "list_to_atom(Wcs)"},
                                 {"stdlib/src/erl_scan.erl:1618",
                                  "list_to_atom(lists:reverse(Nwcs))"}
                               ]
                             else
                               [
                                 {"kernel/src/file.erl:2262", "consult(File) ->"},
                                 {"kernel/src/file.erl:2263", "open(File, [read])"},
                                 {"kernel/src/file.erl:2304", "path_consult(Path, File)"},
                                 {"kernel/src/file.erl:2305", "path_open(Path, File, [read])"},
                                 {"kernel/src/file.erl:2307", "consult_stream(Fd)"},
                                 {"kernel/src/file.erl:2890", "consult_stream(Fd) ->"},
                                 {"kernel/src/file.erl:2895", "io:read(Fd, '', Line)"},
                                 {"stdlib/src/io.erl:700", "read(Io, Prompt, Pos0) ->"},
                                 {"stdlib/src/io.erl:701", "read(Io, Prompt, Pos0, [])"},
                                 {"stdlib/src/io.erl:734", "erl_scan,tokens"},
                                 {"stdlib/src/erl_scan.erl:761", "list_to_atom(Wcs)"},
                                 {"stdlib/src/erl_scan.erl:1591",
                                  "list_to_atom(lists:reverse(Nwcs))"}
                               ]
                             end

                           %{
                             original_id: "EX-159",
                             original_matcher: {:file, [:path_consult, :consult]},
                             original_reason: :pure_data,
                             lane: lane,
                             matched_mfas: @creator_expected_original_mfas,
                             trace: @creator_expected_trace,
                             verdict: :caller_term_text_reaches_atom_creation,
                             replacements: @creator_expected_original_mfas,
                             tier: @creator_expected_original_mfas,
                             fixtures: @creator_expected_fixtures,
                             citations: citations,
                             applicability: :each_exact_installed_lane,
                             removal_witness: :not_applicable_tiered
                           }
                         end)

  @yecc_expected_original_mfas [
    {:yecc, :compile, 3},
    {:yecc, :file, 1},
    {:yecc, :file, 2},
    {:yecc, :format_error, 1},
    {:yecc, :yecc, 2},
    {:yecc, :yecc, 3},
    {:yecc, :yecc, 4}
  ]
  @yecc_expected_tier [
    {:yecc, :compile, 3},
    {:yecc, :file, 1},
    {:yecc, :file, 2},
    {:yecc, :yecc, 2},
    {:yecc, :yecc, 3},
    {:yecc, :yecc, 4}
  ]
  @yecc_expected_trace [
    {:yecc, :compile, 3},
    {:yecc, :file, 1},
    {:yecc, :file, 2},
    {:yecc, :yecc, 2},
    {:yecc, :yecc, 3},
    {:yecc, :yecc, 4},
    {:yecc, :infile, 3},
    {:yecc, :start, 2},
    {:yecc, :generate, 1},
    {:yecc, :read_grammar, 3},
    {:yecc, :parse_grammar, 2},
    {:yecc, :subst_pseudo_vars, 3},
    {:yecc, :write_file, 1},
    {:yecc, :output_state_actions, 5},
    {:yecc, :inlined_function_name, 3},
    {String, :to_atom, 1}
  ]
  @yecc_expected_replacements %{
    {:yecc, :compile, 3} => {:tier, {:yecc, :compile, :_}},
    {:yecc, :file, 1} => {:tier, {:yecc, :file, 1}},
    {:yecc, :file, 2} => {:tier, {:yecc, :file, 2}},
    {:yecc, :yecc, 2} => {:tier, {:yecc, :yecc, 2}},
    {:yecc, :yecc, 3} => {:tier, {:yecc, :yecc, 3}},
    {:yecc, :yecc, 4} => {:tier, {:yecc, :yecc, 4}},
    {:yecc, :format_error, 1} => {:semantic, :module_error_formatter_dispatch_not_atom_creation}
  }
  @yecc_expected_verdict %{
    atom_creator_fronts: :caller_paths_reach_list_to_atom,
    format_error: :formats_descriptors_with_module_supplied_error_callback
  }
  @yecc_expected_fixtures [
    :yecc_direct,
    :yecc_capture,
    :yecc_apply,
    :yecc_discarded_quote_source_only,
    :generated_mfa_probe
  ]
  @yecc_expected_citation_lines %{
    "core" => ~w(
      parsetools/src/yecc.erl:493 parsetools/src/yecc.erl:498
      parsetools/src/yecc.erl:617 parsetools/src/yecc.erl:633
      parsetools/src/yecc.erl:649 parsetools/src/yecc.erl:665 parsetools/src/yecc.erl:666
      parsetools/src/yecc.erl:711 parsetools/src/yecc.erl:748 parsetools/src/yecc.erl:749
      parsetools/src/yecc.erl:823 parsetools/src/yecc.erl:837 parsetools/src/yecc.erl:845
      parsetools/src/yecc.erl:850 parsetools/src/yecc.erl:854 parsetools/src/yecc.erl:858
      parsetools/src/yecc.erl:860 parsetools/src/yecc.erl:938 parsetools/src/yecc.erl:990
      parsetools/src/yecc.erl:1006 parsetools/src/yecc.erl:1008 parsetools/src/yecc.erl:1011
      parsetools/src/yecc.erl:1020 parsetools/src/yecc.erl:1041 parsetools/src/yecc.erl:1111
      parsetools/src/yecc.erl:1144 parsetools/src/yecc.erl:1167 parsetools/src/yecc.erl:1199
      parsetools/src/yecc.erl:1200 parsetools/src/yecc.erl:1212 parsetools/src/yecc.erl:1421
      parsetools/src/yecc.erl:1437 parsetools/src/yecc.erl:1624 parsetools/src/yecc.erl:2756
      parsetools/src/yecc.erl:2774 parsetools/src/yecc.erl:2968 parsetools/src/yecc.erl:2973
      parsetools/src/yecc.erl:2975 parsetools/src/yecc.erl:2977
    ),
    "floor" => ~w(
      parsetools/src/yecc.erl:488 parsetools/src/yecc.erl:493
      parsetools/src/yecc.erl:612 parsetools/src/yecc.erl:628
      parsetools/src/yecc.erl:644 parsetools/src/yecc.erl:660 parsetools/src/yecc.erl:661
      parsetools/src/yecc.erl:706 parsetools/src/yecc.erl:743 parsetools/src/yecc.erl:744
      parsetools/src/yecc.erl:818 parsetools/src/yecc.erl:832 parsetools/src/yecc.erl:840
      parsetools/src/yecc.erl:845 parsetools/src/yecc.erl:849 parsetools/src/yecc.erl:853
      parsetools/src/yecc.erl:855 parsetools/src/yecc.erl:933 parsetools/src/yecc.erl:985
      parsetools/src/yecc.erl:1001 parsetools/src/yecc.erl:1003 parsetools/src/yecc.erl:1006
      parsetools/src/yecc.erl:1015 parsetools/src/yecc.erl:1036 parsetools/src/yecc.erl:1106
      parsetools/src/yecc.erl:1139 parsetools/src/yecc.erl:1162 parsetools/src/yecc.erl:1194
      parsetools/src/yecc.erl:1195 parsetools/src/yecc.erl:1207 parsetools/src/yecc.erl:1416
      parsetools/src/yecc.erl:1432 parsetools/src/yecc.erl:1619 parsetools/src/yecc.erl:2750
      parsetools/src/yecc.erl:2768 parsetools/src/yecc.erl:2962 parsetools/src/yecc.erl:2967
      parsetools/src/yecc.erl:2969 parsetools/src/yecc.erl:2971
    )
  }
  @yecc_expected_ids for lane <- @creator_expected_lanes, do: {"EX-089", lane}

  @yecc_audit Enum.map(@creator_expected_lanes, fn lane ->
                citations =
                  if lane == "core" do
                    [
                      {"parsetools/src/yecc.erl:493",
                       "-export([compile/3, file/1, file/2, format_error/1])."},
                      {"parsetools/src/yecc.erl:498", "-export([yecc/2, yecc/3, yecc/4])."},
                      {"parsetools/src/yecc.erl:617", "case file(Input, Opts) of"},
                      {"parsetools/src/yecc.erl:633", "format_error(bad_declaration) ->"},
                      {"parsetools/src/yecc.erl:649", "atom_to_list(Tag)"},
                      {"parsetools/src/yecc.erl:665", "format_error({error, Module, Error}) ->"},
                      {"parsetools/src/yecc.erl:666", "Module:format_error(Error);"},
                      {"parsetools/src/yecc.erl:711", "format_error(cannot_parse) ->"},
                      {"parsetools/src/yecc.erl:748", "file(GrammarFile) ->"},
                      {"parsetools/src/yecc.erl:749",
                       "file(GrammarFile, [report_errors, report_warnings])."},
                      {"parsetools/src/yecc.erl:823",
                       "file(File, Options0) when is_list(Options0) ->"},
                      {"parsetools/src/yecc.erl:837",
                       "Pid = spawn_link(fun() -> infile(Self, File, OptionValues) end),"},
                      {"parsetools/src/yecc.erl:845", "file(File, Option) ->"},
                      {"parsetools/src/yecc.erl:850", "yecc(Infile, Outfile) ->"},
                      {"parsetools/src/yecc.erl:854", "yecc(Infile, Outfile, Verbose) ->"},
                      {"parsetools/src/yecc.erl:858",
                       "yecc(Infilex, Outfilex, Verbose, Includefilex) ->"},
                      {"parsetools/src/yecc.erl:860",
                       "case file(Infilex, [{parserfile, Outfilex},"},
                      {"parsetools/src/yecc.erl:938",
                       "when Option =:= includefile; Option =:= parserfile ->"},
                      {"parsetools/src/yecc.erl:990", "is_filename(T) ->"},
                      {"parsetools/src/yecc.erl:1006", "start(Infilex, Options) ->"},
                      {"parsetools/src/yecc.erl:1008",
                       "{_, Outfilex0} = lists:keyfind(parserfile, 1, Options),"},
                      {"parsetools/src/yecc.erl:1011",
                       "[] -> filename:rootname(Infilex, \".yrl\");"},
                      {"parsetools/src/yecc.erl:1020",
                       "Module = list_to_atom(filename:basename(Outfile, \".erl\")),"},
                      {"parsetools/src/yecc.erl:1041", "St0 = start(Infilex, Options),"},
                      {"parsetools/src/yecc.erl:1111", "generate(St0) ->"},
                      {"parsetools/src/yecc.erl:1144",
                       "{NextLocation, Grammar} = read_grammar(Inport, St, Location),"},
                      {"parsetools/src/yecc.erl:1167",
                       "{Tokens1, St} = subst_pseudo_vars(AllTokens,"},
                      {"parsetools/src/yecc.erl:1199", "read_grammar(Inport, St, Location) ->"},
                      {"parsetools/src/yecc.erl:1200",
                       "case yeccscan:scan(Inport, '', Location) of"},
                      {"parsetools/src/yecc.erl:1212", "case yeccparser:parse(Input) of"},
                      {"parsetools/src/yecc.erl:1421", "write_file(St0) ->"},
                      {"parsetools/src/yecc.erl:1437",
                       "St50 = output_actions(St40, StateJumps, StateInfo),"},
                      {"parsetools/src/yecc.erl:1624",
                       "{{var, NewAnno, list_to_atom(PseudoVarName)}, St0};"},
                      {"parsetools/src/yecc.erl:2756",
                       "output_state_actions(St_0, State, IState,"},
                      {"parsetools/src/yecc.erl:2774",
                       "jump_some -> list_to_atom(lists:concat([cont_, To]));"},
                      {"parsetools/src/yecc.erl:2968",
                       "inlined_function_name(St, State, Terminal) ->"},
                      {"parsetools/src/yecc.erl:2973",
                       "list_to_atom(concat([yeccpars2_, State, '_'] ++ End))."},
                      {"parsetools/src/yecc.erl:2975",
                       "-compile({nowarn_unused_function,function_name/3})."},
                      {"parsetools/src/yecc.erl:2977",
                       "list_to_atom(concat([Name, '_', safe_atom_chars(St, Suf)]))."}
                    ]
                  else
                    [
                      {"parsetools/src/yecc.erl:488",
                       "-export([compile/3, file/1, file/2, format_error/1])."},
                      {"parsetools/src/yecc.erl:493", "-export([yecc/2, yecc/3, yecc/4])."},
                      {"parsetools/src/yecc.erl:612", "case file(Input, Opts) of"},
                      {"parsetools/src/yecc.erl:628", "format_error(bad_declaration) ->"},
                      {"parsetools/src/yecc.erl:644", "atom_to_list(Tag)"},
                      {"parsetools/src/yecc.erl:660", "format_error({error, Module, Error}) ->"},
                      {"parsetools/src/yecc.erl:661", "Module:format_error(Error);"},
                      {"parsetools/src/yecc.erl:706", "format_error(cannot_parse) ->"},
                      {"parsetools/src/yecc.erl:743", "file(GrammarFile) ->"},
                      {"parsetools/src/yecc.erl:744",
                       "file(GrammarFile, [report_errors, report_warnings])."},
                      {"parsetools/src/yecc.erl:818",
                       "file(File, Options0) when is_list(Options0) ->"},
                      {"parsetools/src/yecc.erl:832",
                       "Pid = spawn_link(fun() -> infile(Self, File, OptionValues) end),"},
                      {"parsetools/src/yecc.erl:840", "file(File, Option) ->"},
                      {"parsetools/src/yecc.erl:845", "yecc(Infile, Outfile) ->"},
                      {"parsetools/src/yecc.erl:849", "yecc(Infile, Outfile, Verbose) ->"},
                      {"parsetools/src/yecc.erl:853",
                       "yecc(Infilex, Outfilex, Verbose, Includefilex) ->"},
                      {"parsetools/src/yecc.erl:855",
                       "case file(Infilex, [{parserfile, Outfilex},"},
                      {"parsetools/src/yecc.erl:933",
                       "when Option =:= includefile; Option =:= parserfile ->"},
                      {"parsetools/src/yecc.erl:985", "is_filename(T) ->"},
                      {"parsetools/src/yecc.erl:1001", "start(Infilex, Options) ->"},
                      {"parsetools/src/yecc.erl:1003",
                       "{_, Outfilex0} = lists:keyfind(parserfile, 1, Options),"},
                      {"parsetools/src/yecc.erl:1006",
                       "[] -> filename:rootname(Infilex, \".yrl\");"},
                      {"parsetools/src/yecc.erl:1015",
                       "Module = list_to_atom(filename:basename(Outfile, \".erl\")),"},
                      {"parsetools/src/yecc.erl:1036", "St0 = start(Infilex, Options),"},
                      {"parsetools/src/yecc.erl:1106", "generate(St0) ->"},
                      {"parsetools/src/yecc.erl:1139",
                       "{NextLocation, Grammar} = read_grammar(Inport, St, Location),"},
                      {"parsetools/src/yecc.erl:1162",
                       "{Tokens1, St} = subst_pseudo_vars(AllTokens,"},
                      {"parsetools/src/yecc.erl:1194", "read_grammar(Inport, St, Location) ->"},
                      {"parsetools/src/yecc.erl:1195",
                       "case yeccscan:scan(Inport, '', Location) of"},
                      {"parsetools/src/yecc.erl:1207", "case yeccparser:parse(Input) of"},
                      {"parsetools/src/yecc.erl:1416", "write_file(St0) ->"},
                      {"parsetools/src/yecc.erl:1432",
                       "St50 = output_actions(St40, StateJumps, StateInfo),"},
                      {"parsetools/src/yecc.erl:1619",
                       "{{var, NewAnno, list_to_atom(PseudoVarName)}, St0};"},
                      {"parsetools/src/yecc.erl:2750",
                       "output_state_actions(St_0, State, IState,"},
                      {"parsetools/src/yecc.erl:2768",
                       "jump_some -> list_to_atom(lists:concat([cont_, To]));"},
                      {"parsetools/src/yecc.erl:2962",
                       "inlined_function_name(St, State, Terminal) ->"},
                      {"parsetools/src/yecc.erl:2967",
                       "list_to_atom(concat([yeccpars2_, State, '_'] ++ End))."},
                      {"parsetools/src/yecc.erl:2969",
                       "-compile({nowarn_unused_function,function_name/3})."},
                      {"parsetools/src/yecc.erl:2971",
                       "list_to_atom(concat([Name, '_', safe_atom_chars(St, Suf)]))."}
                    ]
                  end

                %{
                  original_id: "EX-089",
                  original_matcher: {:yecc, :epp_guard},
                  original_reason: :epp_guard,
                  lane: lane,
                  matched_mfas: @yecc_expected_original_mfas,
                  trace: @yecc_expected_trace,
                  verdict: @yecc_expected_verdict,
                  replacements: @yecc_expected_replacements,
                  tier: @yecc_expected_tier,
                  fixtures: @yecc_expected_fixtures,
                  citations: citations,
                  applicability: :each_exact_installed_lane,
                  removal_witness: :not_applicable_blanket_retired
                }
              end)

  # Independent boundary for the source-reviewed MFA family on each pinned lane.
  # This inventory deliberately does not come from @logger_family_specs: if a
  # spec and the records generated from it disappear together, the audit must
  # still detect the omitted export. The active graph below checks these
  # version-pinned MFAs against the exports present on the exact installed lane.
  @logger_family_universe %{
    "core" => [
      {"LOGGER", {Logger.Formatter, :compile, 1}},
      {"LOGGER", {Logger.Formatter, :new, 1}},
      {"LOGGER", {Logger, :configure_backend, 2}},
      {"LOGGER", {Logger, :default_formatter, 0}},
      {"LOGGER", {Logger, :default_formatter, 1}},
      {"LOGGER", {Logger.Formatter, :new, 0}},
      {"LOGGER", {Logger.App, :start, 0}},
      {"LOGGER", {Logger.App, :start, 2}},
      {"EXUNIT", {ExUnit.CaptureServer, :handle_call, 3}},
      {"EXUNIT", {ExUnit.CaptureServer, :log_capture_on, 3}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 2}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 2}},
      {"EXUNIT", {ExUnit, :configure, 1}},
      {"EXUNIT", {ExUnit, :start, 0}},
      {"EXUNIT", {ExUnit, :start, 1}},
      {"EXUNIT", {ExUnit, :run, 0}},
      {"EXUNIT", {ExUnit, :run, 1}},
      {"EXUNIT", {ExUnit, :async_run, 0}},
      {"EXUNIT", {ExUnit.Runner, :run, 2}},
      {"EXUNIT", {ExUnit, :plural_rule, 2}},
      {"EXUNIT", {ExUnit, :after_suite, 1}}
    ],
    "floor" => [
      {"LOGGER", {Logger.Formatter, :compile, 1}},
      {"LOGGER", {Logger.Formatter, :new, 1}},
      {"LOGGER", {Logger, :configure_backend, 2}},
      {"LOGGER", {Logger, :default_formatter, 0}},
      {"LOGGER", {Logger, :default_formatter, 1}},
      {"LOGGER", {Logger.Formatter, :new, 0}},
      {"LOGGER", {Logger.App, :start, 0}},
      {"LOGGER", {Logger.App, :start, 2}},
      {"EXUNIT", {ExUnit.CaptureServer, :handle_call, 3}},
      {"EXUNIT", {ExUnit.CaptureServer, :log_capture_on, 3}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 2}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 2}},
      {"EXUNIT", {ExUnit, :configure, 1}},
      {"EXUNIT", {ExUnit, :start, 0}},
      {"EXUNIT", {ExUnit, :start, 1}},
      {"EXUNIT", {ExUnit, :run, 0}},
      {"EXUNIT", {ExUnit, :run, 1}},
      {"EXUNIT", {ExUnit, :async_run, 0}},
      {"EXUNIT", {ExUnit.Runner, :run, 2}},
      {"EXUNIT", {ExUnit, :plural_rule, 2}},
      {"EXUNIT", {ExUnit, :after_suite, 1}}
    ]
  }

  @logger_family_modules [
    Logger,
    Logger.App,
    Logger.Formatter,
    ExUnit,
    ExUnit.CaptureServer,
    ExUnit.CaptureLog,
    ExUnit.Runner
  ]

  @logger_expected_mfas_by_lane Map.new(@logger_family_universe, fn {lane, rows} ->
                                  {lane, MapSet.new(Enum.map(rows, &elem(&1, 1)))}
                                end)

  @logger_expected_ids (for {lane, rows} <- @logger_family_universe,
                            {family, {module, function, arity}} <- rows do
                          {"NEW-#{family}-#{lane}-#{inspect(module)}-#{function}-#{arity}", lane}
                        end)

  @logger_family_specs [
    %{
      family: "LOGGER",
      mfa: {Logger.Formatter, :compile, 1},
      disposition: :tier,
      provenance: :caller_format_pattern,
      trace: [{Logger.Formatter, :compile, 1}, {String, :to_atom, 1}],
      verdict: :caller_format_pattern_reaches_atom_creation,
      evidence: [:formatter_compile],
      fixtures: [:generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger.Formatter, :new, 1},
      disposition: :tier,
      provenance: :caller_format_options,
      trace: [
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_format_text_reaches_atom_creation,
      evidence: [:formatter_input],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe, :discarded_quote_source_only],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger, :configure_backend, 2},
      disposition: :tier,
      provenance: :caller_options_and_logger_console_config,
      trace: [
        {Logger, :configure_backend, 2},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :console_options_reach_formatter_parser_other_backends_delegate,
      evidence: [:logger_configure_backend],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger, :default_formatter, 0},
      disposition: :tier,
      provenance: :logger_default_formatter_application_config,
      trace: [
        {Logger, :default_formatter, 0},
        {Application, :get_env, 3},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :application_formatter_config_reaches_atom_creation,
      evidence: [:logger_default_formatter],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger, :default_formatter, 1},
      disposition: :tier,
      provenance: :caller_overrides_and_logger_default_formatter_config,
      trace: [
        {Logger, :default_formatter, 1},
        {Application, :get_env, 3},
        {Keyword, :merge, 2},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_override_and_application_config_reach_atom_creation,
      evidence: [:logger_default_formatter],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger.Formatter, :new, 0},
      disposition: :exact_exclusion,
      provenance: :fixed_builtin_default_pattern,
      trace: [
        {Logger.Formatter, :new, 0},
        {Logger.Formatter, :compile, 1},
        {Logger.Formatter, :compile_code, 1}
      ],
      verdict: :fixed_default_pattern_has_no_caller_text,
      reason: :fixed_default,
      evidence: [:formatter_fixed_default],
      fixtures: [:fixed_default_source_trace, :individual_exact_removal_witness],
      removal_witness: :individual_exact_mfa
    },
    %{
      family: "LOGGER",
      mfa: {Logger.App, :start, 0},
      disposition: :tier,
      provenance: :logger_application_environment,
      trace: [
        {Logger.App, :start, 0},
        {Application, :start, 1},
        {Logger.App, :start, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :starting_logger_uses_configured_formatter_options,
      evidence: [:logger_app_start_zero, :logger_app_start],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger.App, :start, 2},
      disposition: :tier,
      provenance: :logger_application_environment,
      trace: [
        {Logger.App, :start, 2},
        {Application, :get_env, 3},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :application_start_reads_configured_formatter_options,
      evidence: [:logger_app_start],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureServer, :handle_call, 3},
      disposition: :tier,
      provenance: :caller_process_message_options,
      trace: [
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :log_capture_message_options_reach_atom_creation,
      evidence: [:capture_server_handler],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureServer, :log_capture_on, 3},
      disposition: :tier,
      provenance: :caller_options_forwarded_in_genserver_message,
      trace: [
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {:gen_server, :call, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :log_capture_options_cross_process_message_to_formatter,
      evidence: [:capture_server_wrapper, :capture_server_handler],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :capture_log, 1},
      disposition: :tier,
      provenance: :logger_environment_via_default_capture_options,
      trace: [
        {ExUnit.CaptureLog, :capture_log, 1},
        {ExUnit.CaptureLog, :with_log, 1},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :default_capture_reads_configured_formatter,
      evidence: [:capture_log_capture, :capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :capture_log, 2},
      disposition: :tier,
      provenance: :caller_capture_options,
      trace: [
        {ExUnit.CaptureLog, :capture_log, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_capture_options_reach_formatter_parser,
      evidence: [:capture_log_capture, :capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :with_log, 1},
      disposition: :tier,
      provenance: :logger_environment_via_default_capture_options,
      trace: [
        {ExUnit.CaptureLog, :with_log, 1},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :default_capture_reads_configured_formatter,
      evidence: [:capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :with_log, 2},
      disposition: :tier,
      provenance: :caller_capture_options,
      trace: [
        {ExUnit.CaptureLog, :with_log, 2},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_capture_options_reach_formatter_parser,
      evidence: [:capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :configure, 1},
      disposition: :tier,
      provenance: :caller_exunit_configuration,
      trace: [
        {ExUnit, :configure, 1},
        {Application, :put_env, 3},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :capture_log_configuration_reaches_formatter_parser,
      evidence: [:exunit_configure, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :start, 0},
      disposition: :tier,
      provenance: :exunit_default_start_and_application_configuration,
      trace: [
        {ExUnit, :start, 0},
        {ExUnit, :start, 1},
        {ExUnit, :configure, 1},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :default_start_uses_configured_capture_log_options,
      evidence: [:exunit_start, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :start, 1},
      disposition: :tier,
      provenance: :caller_exunit_configuration,
      trace: [
        {ExUnit, :start, 1},
        {ExUnit, :configure, 1},
        {Application, :put_env, 3},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_start_options_reach_formatter_parser,
      evidence: [:exunit_start, :exunit_configure, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :run, 0},
      disposition: :tier,
      provenance: :exunit_application_configuration,
      trace: [
        {ExUnit, :run, 0},
        {ExUnit, :configuration, 0},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :run_reads_configured_capture_log_options,
      evidence: [:exunit_run, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :run, 1},
      disposition: :tier,
      provenance: :caller_module_list_and_exunit_application_configuration,
      trace: [
        {ExUnit, :run, 1},
        {ExUnit, :configuration, 0},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :run_reads_configured_capture_log_options,
      evidence: [:exunit_run, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :async_run, 0},
      disposition: :tier,
      provenance: :exunit_application_configuration,
      trace: [
        {ExUnit, :async_run, 0},
        {ExUnit, :configuration, 0},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :async_run_reads_configured_capture_log_options,
      evidence: [:exunit_async_run, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.Runner, :run, 2},
      disposition: :tier,
      provenance: :exunit_config_and_test_tag_options,
      trace: [
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :capture_log_config_and_test_tags_reach_formatter_parser,
      evidence: [:exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :plural_rule, 2},
      disposition: :exact_exclusion,
      provenance: :pluralization_text_only,
      trace: [{ExUnit, :plural_rule, 2}, {ExUnit, :configure, 1}],
      verdict: :pluralization_config_does_not_set_capture_log,
      reason: :unrelated_exunit_config,
      evidence: [:exunit_plural_rule],
      fixtures: [:source_trace, :individual_exact_removal_witness],
      removal_witness: :individual_exact_mfa
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :after_suite, 1},
      disposition: :exact_exclusion,
      provenance: :suite_callback_registration,
      trace: [{ExUnit, :after_suite, 1}, {ExUnit, :configure, 1}],
      verdict: :after_suite_callback_config_does_not_set_capture_log,
      reason: :unrelated_exunit_config,
      evidence: [:exunit_after_suite],
      fixtures: [:source_trace, :individual_exact_removal_witness],
      removal_witness: :individual_exact_mfa
    }
  ]

  @logger_source_evidence %{
    "core" => %{
      formatter_compile: [
        {"logger/lib/logger/formatter.ex:434", "def compile(pattern_or_function)"},
        {"logger/lib/logger/formatter.ex:444", "String.to_atom(code)"}
      ],
      formatter_input: [
        {"logger/lib/logger/formatter.ex:170", "def new(options"},
        {"logger/lib/logger/formatter.ex:171", "template = compile(options[:format])"},
        {"logger/lib/logger/formatter.ex:444", "String.to_atom(code)"}
      ],
      formatter_fixed_default: [
        {"logger/lib/logger/formatter.ex:117", "@default_pattern"},
        {"logger/lib/logger/formatter.ex:170", "def new(options"},
        {"logger/lib/logger/formatter.ex:436", "def compile(nil), do: compile(@default_pattern)"}
      ],
      logger_configure_backend: [
        {"logger/lib/logger.ex:953", "def configure_backend(:console, options)"},
        {"logger/lib/logger.ex:954",
         "Keyword.merge(Application.get_env(:logger, :console, []), options)"},
        {"logger/lib/logger.ex:957", "Logger.Formatter.new(without_level)"},
        {"logger/lib/logger.ex:961", "def configure_backend(backend, options)"},
        {"logger/lib/logger.ex:962", "Logger.Backends.Internal.configure(backend, options)"}
      ],
      logger_default_formatter: [
        {"logger/lib/logger.ex:578", "def default_formatter(overrides"},
        {"logger/lib/logger.ex:579", "Application.get_env(:logger, :default_formatter, [])"},
        {"logger/lib/logger.ex:580", "Keyword.merge(overrides)"},
        {"logger/lib/logger.ex:581", "Logger.Formatter.new()"}
      ],
      logger_app_start: [
        {"logger/lib/logger/app.ex:11", "def start(_type, _args)"},
        {"logger/lib/logger/app.ex:42", "Application.get_env(:logger, :console)"},
        {"logger/lib/logger/app.ex:45", "Application.fetch_env(:logger, :default_formatter)"},
        {"logger/lib/logger/app.ex:149",
         "Keyword.put_new_lazy(:formatter, &Logger.default_formatter/0)"}
      ],
      logger_app_start_zero: [
        {"logger/lib/logger/app.ex:84", "def start do"},
        {"logger/lib/logger/app.ex:85", "Application.start(:logger)"}
      ],
      capture_server_handler: [
        {"ex_unit/lib/ex_unit/capture_server.ex:73",
         "def handle_call({:log_capture_on, pid, string_io, opts}"},
        {"ex_unit/lib/ex_unit/capture_server.ex:77", "Keyword.pop(opts, :level)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:80", "Logger.default_formatter(opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:82", ":ets.insert(@ets"}
      ],
      capture_server_wrapper: [
        {"ex_unit/lib/ex_unit/capture_server.ex:30", "def log_capture_on(pid, string_io, opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:31",
         "GenServer.call(@name, {:log_capture_on, pid, string_io, opts}"}
      ],
      capture_log_capture: [
        {"ex_unit/lib/ex_unit/capture_log.ex:88", "def capture_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:89", "with_log(opts, fun)"}
      ],
      capture_log_with: [
        {"ex_unit/lib/ex_unit/capture_log.ex:112", "def with_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:124",
         "ExUnit.CaptureServer.log_capture_on(self(), string_io, opts)"}
      ],
      exunit_configure: [
        {"ex_unit/lib/ex_unit.ex:420", "def configure(options)"},
        {"ex_unit/lib/ex_unit.ex:422", "Application.put_env(:ex_unit, k, v)"}
      ],
      exunit_start: [
        {"ex_unit/lib/ex_unit.ex:279", "def start(options"},
        {"ex_unit/lib/ex_unit.ex:282", "configure(options)"}
      ],
      exunit_run: [
        {"ex_unit/lib/ex_unit.ex:476", "def run(additional_modules"},
        {"ex_unit/lib/ex_unit.ex:487", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:575", "ExUnit.Runner.run(options, load_us)"}
      ],
      exunit_async_run: [
        {"ex_unit/lib/ex_unit.ex:499", "def async_run()"},
        {"ex_unit/lib/ex_unit.ex:501", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:503", "Task.async(fn ->"}
      ],
      exunit_runner: [
        {"ex_unit/lib/ex_unit/runner.ex:12", "def run(opts, load_us)"},
        {"ex_unit/lib/ex_unit/runner.ex:79", "capture_log: opts[:capture_log]"},
        {"ex_unit/lib/ex_unit/runner.ex:452", "Map.get(context, :capture_log, capture_log)"},
        {"ex_unit/lib/ex_unit/runner.ex:482", "ExUnit.CaptureLog.with_log(capture_log_opts, fun)"}
      ],
      exunit_plural_rule: [
        {"ex_unit/lib/ex_unit.ex:456", "def plural_rule(word, pluralization)"},
        {"ex_unit/lib/ex_unit.ex:458", "Application.get_env(:ex_unit, :plural_rules, %{})"},
        {"ex_unit/lib/ex_unit.ex:461", "configure(plural_rules: plural_rules)"}
      ],
      exunit_after_suite: [
        {"ex_unit/lib/ex_unit.ex:530", "def after_suite(function)"},
        {"ex_unit/lib/ex_unit.ex:531", "Application.fetch_env!(:ex_unit, :after_suite)"},
        {"ex_unit/lib/ex_unit.ex:532", "configure(after_suite: [function | current_callbacks])"}
      ]
    },
    "floor" => %{
      formatter_compile: [
        {"logger/lib/logger/formatter.ex:397", "def compile(pattern_or_function)"},
        {"logger/lib/logger/formatter.ex:407", "String.to_atom(code)"}
      ],
      formatter_input: [
        {"logger/lib/logger/formatter.ex:152", "def new(options"},
        {"logger/lib/logger/formatter.ex:153", "template = compile(options[:format])"},
        {"logger/lib/logger/formatter.ex:407", "String.to_atom(code)"}
      ],
      formatter_fixed_default: [
        {"logger/lib/logger/formatter.ex:99", "@default_pattern"},
        {"logger/lib/logger/formatter.ex:152", "def new(options"},
        {"logger/lib/logger/formatter.ex:399", "def compile(nil), do: compile(@default_pattern)"}
      ],
      logger_configure_backend: [
        {"logger/lib/logger.ex:880", "def configure_backend(:console, options)"},
        {"logger/lib/logger.ex:881",
         "Keyword.merge(Application.get_env(:logger, :console, []), options)"},
        {"logger/lib/logger.ex:884", "Logger.Formatter.new(without_level)"},
        {"logger/lib/logger.ex:888", "def configure_backend(backend, options)"},
        {"logger/lib/logger.ex:889", "Logger.Backends.Internal.configure(backend, options)"}
      ],
      logger_default_formatter: [
        {"logger/lib/logger.ex:524", "def default_formatter(overrides"},
        {"logger/lib/logger.ex:525", "Application.get_env(:logger, :default_formatter, [])"},
        {"logger/lib/logger.ex:526", "Keyword.merge(overrides)"},
        {"logger/lib/logger.ex:527", "Logger.Formatter.new()"}
      ],
      logger_app_start: [
        {"logger/lib/logger/app.ex:8", "def start(_type, _args)"},
        {"logger/lib/logger/app.ex:22", "Application.get_env(:logger, :console)"},
        {"logger/lib/logger/app.ex:25", "Application.fetch_env(:logger, :default_formatter)"},
        {"logger/lib/logger/app.ex:129",
         "Keyword.put_new_lazy(:formatter, &Logger.default_formatter/0)"}
      ],
      logger_app_start_zero: [
        {"logger/lib/logger/app.ex:64", "def start do"},
        {"logger/lib/logger/app.ex:65", "Application.start(:logger)"}
      ],
      capture_server_handler: [
        {"ex_unit/lib/ex_unit/capture_server.ex:69",
         "def handle_call({:log_capture_on, pid, string_io, opts}"},
        {"ex_unit/lib/ex_unit/capture_server.ex:73", "Keyword.pop(opts, :level)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:74", "Logger.default_formatter(opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:75", ":ets.insert(@ets"}
      ],
      capture_server_wrapper: [
        {"ex_unit/lib/ex_unit/capture_server.ex:26", "def log_capture_on(pid, string_io, opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:27",
         "GenServer.call(@name, {:log_capture_on, pid, string_io, opts}"}
      ],
      capture_log_capture: [
        {"ex_unit/lib/ex_unit/capture_log.ex:74", "def capture_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:75", "with_log(opts, fun)"}
      ],
      capture_log_with: [
        {"ex_unit/lib/ex_unit/capture_log.ex:98", "def with_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:110",
         "ExUnit.CaptureServer.log_capture_on(self(), string_io, opts)"}
      ],
      exunit_configure: [
        {"ex_unit/lib/ex_unit.ex:356", "def configure(options)"},
        {"ex_unit/lib/ex_unit.ex:358", "Application.put_env(:ex_unit, k, v)"}
      ],
      exunit_start: [
        {"ex_unit/lib/ex_unit.ex:217", "def start(options"},
        {"ex_unit/lib/ex_unit.ex:220", "configure(options)"}
      ],
      exunit_run: [
        {"ex_unit/lib/ex_unit.ex:412", "def run(additional_modules"},
        {"ex_unit/lib/ex_unit.ex:423", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:509", "ExUnit.Runner.run(options, load_us)"}
      ],
      exunit_async_run: [
        {"ex_unit/lib/ex_unit.ex:435", "def async_run()"},
        {"ex_unit/lib/ex_unit.ex:437", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:439", "Task.async(fn ->"}
      ],
      exunit_runner: [
        {"ex_unit/lib/ex_unit/runner.ex:8", "def run(opts, load_us)"},
        {"ex_unit/lib/ex_unit/runner.ex:75", "capture_log: opts[:capture_log]"},
        {"ex_unit/lib/ex_unit/runner.ex:430", "Map.get(context, :capture_log, capture_log)"},
        {"ex_unit/lib/ex_unit/runner.ex:460", "ExUnit.CaptureLog.with_log(capture_log_opts, fun)"}
      ],
      exunit_plural_rule: [
        {"ex_unit/lib/ex_unit.ex:392", "def plural_rule(word, pluralization)"},
        {"ex_unit/lib/ex_unit.ex:394", "Application.get_env(:ex_unit, :plural_rules, %{})"},
        {"ex_unit/lib/ex_unit.ex:397", "configure(plural_rules: plural_rules)"}
      ],
      exunit_after_suite: [
        {"ex_unit/lib/ex_unit.ex:466", "def after_suite(function)"},
        {"ex_unit/lib/ex_unit.ex:467", "Application.fetch_env!(:ex_unit, :after_suite)"},
        {"ex_unit/lib/ex_unit.ex:468", "configure(after_suite: [function | current_callbacks])"}
      ]
    }
  }

  @logger_audit (for lane <- @creator_expected_lanes, spec <- @logger_family_specs do
                   {module, function, arity} = mfa = spec.mfa

                   source =
                     Enum.flat_map(spec.evidence, &Map.fetch!(@logger_source_evidence[lane], &1))

                   %{
                     original_id:
                       "NEW-#{spec.family}-#{lane}-#{inspect(module)}-#{function}-#{arity}",
                     original_matcher: {:mfa, mfa},
                     original_reason: spec.disposition,
                     lane: lane,
                     matched_mfas: [mfa],
                     trace: spec.trace,
                     provenance: spec.provenance,
                     verdict: spec.verdict,
                     replacements:
                       if(spec.disposition == :tier,
                         do: %{mfa => {:tier, mfa}},
                         else: %{mfa => {:exact_exclusion, spec.reason}}
                       ),
                     tier: if(spec.disposition == :tier, do: [mfa], else: []),
                     fixtures: spec.fixtures,
                     citations: source,
                     evidence_groups: spec.evidence,
                     applicability: :each_exact_installed_lane,
                     removal_witness: spec.removal_witness
                   }
                 end)

  @creator_audit @consult_creator_audit ++ @yecc_audit ++ @logger_audit

  @eval_funs [:eval_str, :expr, :expr_list, :exprs, :match_clause]
  @barrier_modules [:code_server, :error_handler, :erl_prim_loader, :init, :erl_lint]
  @barrier_functions [
    {:code, :ensure_loaded},
    {:code, :load_file},
    {:code, :ensure_modules_loaded}
  ]
  @citation_re ~r/^[a-z_]+\/[^\s:]+\.(ex|erl|hrl):\d+$/
  @base_sinks [
                {:erlang, :load_module},
                {:erlang, :prepare_loading},
                {:erlang, :load_nif},
                {:erl_ddll, :try_load}
              ] ++ for(fun <- @eval_funs, do: {:erl_eval, fun})
  @boundary_lane_specific [
    {:ordsets, :floor},
    {:sets, :floor},
    {:erl_features, :floor},
    {:records, :floor}
  ]
  @boundary_exclusions [
    {{:code,
      [
        :all_available,
        :all_loaded,
        :clash,
        :clear_cache,
        :delete,
        :get_mode,
        :get_path,
        :is_loaded,
        :is_sticky,
        :modified_modules,
        :module_status,
        :purge,
        :soft_purge,
        :start_link,
        :stick_dir,
        :stick_mod,
        :stop,
        :unstick_dir,
        :unstick_mod
      ]}, :runtime_internal,
     [
       "kernel/src/code.erl:797",
       "kernel/src/code.erl:811",
       "kernel/src/code.erl:1296",
       "kernel/src/code.erl:1669",
       "kernel/src/code.erl:1984",
       "kernel/src/code.erl:2055",
       "kernel/src/code.erl:2153",
       "kernel/src/code.erl:767",
       "kernel/src/code.erl:781",
       "kernel/src/code.erl:1266",
       "kernel/src/code.erl:1639",
       "kernel/src/code.erl:1947",
       "kernel/src/code.erl:2018",
       "kernel/src/code.erl:2116"
     ]},
    {{:code,
      [
        :compiler_dir,
        :get_doc,
        :get_object_code,
        :lib_dir,
        :priv_dir,
        :root_dir,
        :where_is_file,
        :which
      ]}, :pure_data,
     [
       "kernel/src/code.erl:778",
       "kernel/src/code.erl:885",
       "kernel/src/code.erl:927",
       "kernel/src/code.erl:959",
       "kernel/src/code.erl:967",
       "kernel/src/code.erl:1839",
       "kernel/src/code.erl:1782",
       "kernel/src/code.erl:748",
       "kernel/src/code.erl:855",
       "kernel/src/code.erl:897",
       "kernel/src/code.erl:950",
       "kernel/src/code.erl:937",
       "kernel/src/code.erl:1809",
       "kernel/src/code.erl:1752"
     ]},
    {{:code, [:ensure_loaded, :ensure_modules_loaded, :load_file]}, :by_name,
     [
       "kernel/src/code.erl:559",
       "kernel/src/code.erl:581",
       "kernel/src/code.erl:1319",
       "kernel/src/code.erl:533",
       "kernel/src/code.erl:554",
       "kernel/src/code.erl:1289"
     ]},
    {{:erlang,
      [
        :decode_packet,
        :get_module_info,
        :loaded,
        :module_loaded,
        :pre_loaded
      ]}, :pure_data,
     [
       "erts/src/erlang.erl:1983",
       "erts/src/erlang.erl:3271",
       "erts/src/erlang.erl:4286",
       "erts/src/erlang.erl:4497",
       "erts/src/erlang.erl:5474",
       "erts/src/erlang.erl:1882",
       "erts/src/erlang.erl:3065",
       "erts/src/erlang.erl:4000",
       "erts/src/erlang.erl:4188",
       "erts/src/erlang.erl:5094"
     ]},
    {{:erlang,
      [
        :check_old_code,
        :check_process_code,
        :delete_module,
        :has_prepared_code_on_load,
        :nif_error,
        :purge_module
      ]}, :runtime_internal,
     [
       "erts/src/erlang.erl:1591",
       "erts/src/erlang.erl:1601",
       "erts/src/erlang.erl:2021",
       "erts/src/erlang.erl:3508",
       "erts/src/erlang.erl:4884",
       "erts/src/erlang.erl:5689",
       "erts/src/erlang.erl:1511",
       "erts/src/erlang.erl:1521",
       "erts/src/erlang.erl:1921",
       "erts/src/erlang.erl:3302",
       "erts/src/erlang.erl:4554",
       "erts/src/erlang.erl:5243"
     ]},
    {{:kernel, [:init]}, :callback, ["kernel/src/kernel.erl:91", "kernel/src/kernel.erl:89"]},
    {{:error_handler, [:undefined_function, :undefined_lambda]}, :by_name,
     [
       "kernel/src/error_handler.erl:85",
       "kernel/src/error_handler.erl:117",
       "kernel/src/error_handler.erl:83",
       "kernel/src/error_handler.erl:115"
     ]},
    {{:error_handler, [:raise_undef_exception, :stub_function]}, :runtime_internal,
     [
       "kernel/src/error_handler.erl:146",
       "kernel/src/error_handler.erl:203",
       "kernel/src/error_handler.erl:144",
       "kernel/src/error_handler.erl:201"
     ]},
    {{:erts_internal,
      [
        :beamfile_chunk,
        :beamfile_module_md5,
        :binary_to_integer,
        :cmp_term,
        :list_to_integer,
        :map_hashmap_children,
        :map_next,
        :map_to_tuple_keys,
        :mc_iterator,
        :mc_refill,
        :term_to_string,
        :term_type,
        :time_unit,
        :perf_counter_unit
      ]}, :pure_data,
     [
       "erts/src/erts_internal.erl:1097",
       "erts/src/erts_internal.erl:1101",
       "erts/src/erts_internal.erl:1114",
       "erts/src/erts_internal.erl:414",
       "erts/src/erts_internal.erl:1123",
       "erts/src/erts_internal.erl:445",
       "erts/src/erts_internal.erl:457",
       "erts/src/erts_internal.erl:422",
       "erts/src/erts_internal.erl:467",
       "erts/src/erts_internal.erl:512",
       "erts/src/erts_internal.erl:1152",
       "erts/src/erts_internal.erl:436",
       "erts/src/erts_internal.erl:550",
       "erts/src/erts_internal.erl:555",
       "erts/src/erts_internal.erl:1083",
       "erts/src/erts_internal.erl:1087",
       "erts/src/erts_internal.erl:1105",
       "erts/src/erts_internal.erl:1109",
       "erts/src/erts_internal.erl:1130",
       "erts/src/erts_internal.erl:410",
       "erts/src/erts_internal.erl:1110",
       "erts/src/erts_internal.erl:1100",
       "erts/src/erts_internal.erl:1119",
       "erts/src/erts_internal.erl:417",
       "erts/src/erts_internal.erl:1127",
       "erts/src/erts_internal.erl:427",
       "erts/src/erts_internal.erl:449",
       "erts/src/erts_internal.erl:461",
       "erts/src/erts_internal.erl:475",
       "erts/src/erts_internal.erl:520",
       "erts/src/erts_internal.erl:1140",
       "erts/src/erts_internal.erl:1159",
       "erts/src/erts_internal.erl:1150",
       "erts/src/erts_internal.erl:555",
       "erts/src/erts_internal.erl:545"
     ]},
    {{:erts_internal,
      [
        :"@flush_monitor_messages_refopt",
        :abort_pending_connection,
        :atomics_new,
        :await_microstate_accounting_modifications,
        :await_port_send_result,
        :await_result,
        :await_sched_wall_time_modifications,
        :breakpoint,
        :check_dirty_process_code,
        :check_process_code,
        :counters_add,
        :counters_get,
        :counters_info,
        :counters_new,
        :counters_put,
        :crasher,
        :create_dist_channel,
        :dirty_process_handle_signals,
        :dist_ctrl_put_data,
        :dist_spawn_init,
        :dist_spawn_request,
        :dynamic_node_name,
        :erase_persistent_terms,
        :ets_info_binary,
        :ets_lookup_binary_info,
        :ets_raw_first,
        :ets_raw_next,
        :ets_super_user,
        :flush_monitor_messages,
        :garbage_collect,
        :gather_alloc_histograms,
        :gather_carrier_info,
        :gather_io_bytes,
        :gather_microstate_accounting_result,
        :gather_sched_wall_time_result,
        :gather_system_check_result,
        :get_creation,
        :get_dflags,
        :get_internal_state_blocked,
        :group_leader,
        :is_process_alive,
        :is_process_executing_dirty,
        :is_system_process,
        :new_connection,
        :no_aux_work_threads,
        :notify_breakpoint_hit,
        :open_port,
        :port_call,
        :port_close,
        :port_command,
        :port_connect,
        :port_control,
        :port_info,
        :process_display,
        :process_flag,
        :processes_next,
        :purge_module,
        :request_system_task,
        :scheduler_wall_time,
        :set_code_and_literal_cleaner_prio,
        :spawn_init,
        :spawn_request,
        :spawn_system_process,
        :suspend_process,
        :system_check,
        :system_flag_scheduler_wall_time,
        :system_monitor,
        :trace,
        :trace_info,
        :trace_pattern,
        :trace_session_create,
        :trace_session_destroy,
        :wait_release_literal_area_switch
      ]}, :runtime_internal,
     [
       "erts/src/erts_internal.erl:183",
       "erts/src/erts_internal.erl:287",
       "erts/src/erts_internal.erl:393",
       "erts/src/erts_internal.erl:616",
       "erts/src/erts_internal.erl:885",
       "erts/src/erts_internal.erl:889",
       "erts/src/erts_internal.erl:1002",
       "erts/src/erts_internal.erl:1091",
       "erts/src/erts_internal.erl:1177",
       "erts/src/erts_internal.erl:183",
       "erts/src/erts_internal.erl:287",
       "erts/src/erts_internal.erl:393",
       "erts/src/erts_internal.erl:616",
       "erts/src/erts_internal.erl:885",
       "erts/src/erts_internal.erl:889",
       "erts/src/erts_internal.erl:1002",
       "erts/src/erts_internal.erl:1091",
       "erts/src/erts_internal.erl:1177"
     ]},
    {{:init,
      [
        :archive_extension,
        :code_path_choice,
        :fetch_loaded,
        :get_argument,
        :get_arguments,
        :get_configfd,
        :get_plain_arguments,
        :get_status,
        :objfile_extension,
        :script_id,
        :script_name
      ]}, :pure_data,
     [
       "erts/src/init.erl:1834",
       "erts/src/init.erl:641",
       "erts/src/init.erl:451",
       "erts/src/init.erl:391",
       "erts/src/init.erl:340",
       "erts/src/init.erl:325",
       "erts/src/init.erl:368",
       "erts/src/init.erl:446",
       "erts/src/init.erl:1824",
       "erts/src/init.erl:402",
       "erts/src/init.erl:412",
       "erts/src/init.erl:1834",
       "erts/src/init.erl:630",
       "erts/src/init.erl:441",
       "erts/src/init.erl:386",
       "erts/src/init.erl:335",
       "erts/src/init.erl:320",
       "erts/src/init.erl:362",
       "erts/src/init.erl:446",
       "erts/src/init.erl:1824",
       "erts/src/init.erl:397",
       "erts/src/init.erl:407"
     ]},
    {{:init, [:reboot, :set_configfd, :stop, :notify_when_started, :wait_until_started]},
     :runtime_internal,
     [
       "erts/src/init.erl:532",
       "erts/src/init.erl:330",
       "erts/src/init.erl:531",
       "erts/src/init.erl:469",
       "erts/src/init.erl:474",
       "erts/src/init.erl:527",
       "erts/src/init.erl:325",
       "erts/src/init.erl:546",
       "erts/src/init.erl:464",
       "erts/src/init.erl:469"
     ]},
    {{:init, [:ensure_loaded]}, :by_name, ["erts/src/init.erl:463", "erts/src/init.erl:458"]},
    {{:erl_prim_loader,
      [
        :get_cwd,
        :get_file,
        :get_path,
        :is_basename,
        :list_dir,
        :prim_get_cwd,
        :prim_list_dir,
        :prim_read_file,
        :prim_read_file_info,
        :read_file,
        :read_file_info,
        :read_link_info
      ]}, :pure_data,
     [
       "erts/src/erl_prim_loader.erl:242",
       "erts/src/erl_prim_loader.erl:262",
       "erts/src/erl_prim_loader.erl:298",
       "erts/src/erl_prim_loader.erl:344",
       "erts/src/erl_prim_loader.erl:390",
       "erts/src/erl_prim_loader.erl:1405",
       "erts/src/erl_prim_loader.erl:281",
       "erts/src/erl_prim_loader.erl:1225",
       "erts/src/erl_prim_loader.erl:1135",
       "erts/src/erl_prim_loader.erl:1107",
       "erts/src/erl_prim_loader.erl:1189",
       "erts/src/erl_prim_loader.erl:298",
       "erts/src/erl_prim_loader.erl:318",
       "erts/src/erl_prim_loader.erl:335",
       "erts/src/erl_prim_loader.erl:238",
       "erts/src/erl_prim_loader.erl:258",
       "erts/src/erl_prim_loader.erl:294",
       "erts/src/erl_prim_loader.erl:340",
       "erts/src/erl_prim_loader.erl:386",
       "erts/src/erl_prim_loader.erl:1398",
       "erts/src/erl_prim_loader.erl:277",
       "erts/src/erl_prim_loader.erl:1230",
       "erts/src/erl_prim_loader.erl:1128",
       "erts/src/erl_prim_loader.erl:1100",
       "erts/src/erl_prim_loader.erl:1182",
       "erts/src/erl_prim_loader.erl:294",
       "erts/src/erl_prim_loader.erl:318",
       "erts/src/erl_prim_loader.erl:335"
     ]},
    {{:erl_prim_loader, [:start, :prim_init, :purge_archive_cache]}, :runtime_internal,
     [
       "erts/src/erl_prim_loader.erl:153",
       "erts/src/erl_prim_loader.erl:1037",
       "erts/src/erl_prim_loader.erl:381",
       "erts/src/erl_prim_loader.erl:149",
       "erts/src/erl_prim_loader.erl:1030",
       "erts/src/erl_prim_loader.erl:377"
     ]},
    {{:prim_eval, [:receive]}, :runtime_internal,
     ["erts/src/prim_eval.erl:30", "erts/src/prim_eval.erl:30"]},
    {{:qlc,
      [
        :all_selections,
        :append,
        :aux_name,
        :format_error,
        :info,
        :keysort,
        :name_suffix,
        :parse_transform_info,
        :q,
        :sort,
        :table,
        :template_state,
        :var_fold,
        :var_ufold,
        :vars
      ]}, :pure_data,
     [
       "stdlib/src/qlc.erl:1344",
       "stdlib/src/qlc.erl:210",
       "stdlib/src/qlc.erl:1310",
       "stdlib/src/qlc.erl:1470",
       "stdlib/src/qlc.erl:521",
       "stdlib/src/qlc.erl:672",
       "stdlib/src/qlc.erl:266",
       "stdlib/src/qlc.erl:149",
       "stdlib/src/qlc.erl:766",
       "stdlib/src/qlc.erl:975",
       "stdlib/src/qlc.erl:1284",
       "stdlib/src/qlc.erl:163",
       "stdlib/src/qlc.erl:1361",
       "stdlib/src/qlc.erl:1372",
       "stdlib/src/qlc.erl:1336",
       "stdlib/src/qlc.erl:1336",
       "stdlib/src/qlc.erl:203",
       "stdlib/src/qlc.erl:1302",
       "stdlib/src/qlc.erl:1463",
       "stdlib/src/qlc.erl:514",
       "stdlib/src/qlc.erl:665",
       "stdlib/src/qlc.erl:259",
       "stdlib/src/qlc.erl:141",
       "stdlib/src/qlc.erl:759",
       "stdlib/src/qlc.erl:968",
       "stdlib/src/qlc.erl:1277",
       "stdlib/src/qlc.erl:157",
       "stdlib/src/qlc.erl:1353",
       "stdlib/src/qlc.erl:1364",
       "stdlib/src/qlc.erl:1328",
       "stdlib/src/qlc.erl:1328"
     ]},
    {{:qlc, [:delete_cursor]}, :runtime_internal,
     ["stdlib/src/qlc.erl:297", "stdlib/src/qlc.erl:290"]},
    {{:qlc, [:parse_transform, :transform_from_evaluator]}, :compiler_pass,
     [
       "stdlib/src/qlc.erl:751",
       "stdlib/src/qlc.erl:1317",
       "stdlib/src/qlc.erl:744",
       "stdlib/src/qlc.erl:1309"
     ]},
    {{:zlib, [:on_load]}, :own_native, ["erts/src/zlib.erl:176", "erts/src/zlib.erl:174"]},
    {{:zlib,
      [
        :open,
        :close,
        :set_controlling_process,
        :deflateInit,
        :deflateSetDictionary,
        :deflateReset,
        :deflateParams,
        :deflate,
        :deflateEnd,
        :inflateInit,
        :inflateSetDictionary,
        :inflateGetDictionary,
        :inflateReset,
        :inflate,
        :inflateEnd,
        :safeInflate
      ]}, :runtime_internal,
     [
       "erts/src/zlib.erl:183",
       "erts/src/zlib.erl:191",
       "erts/src/zlib.erl:201",
       "erts/src/zlib.erl:209",
       "erts/src/zlib.erl:445",
       "erts/src/zlib.erl:183",
       "erts/src/zlib.erl:189",
       "erts/src/zlib.erl:199",
       "erts/src/zlib.erl:207",
       "erts/src/zlib.erl:443"
     ]},
    {{:zlib, [:compress, :uncompress, :zip, :unzip, :gzip, :gunzip]}, :pure_data,
     [
       "erts/src/zlib.erl:683",
       "erts/src/zlib.erl:699",
       "erts/src/zlib.erl:727",
       "erts/src/zlib.erl:743",
       "erts/src/zlib.erl:759",
       "erts/src/zlib.erl:775",
       "erts/src/zlib.erl:681",
       "erts/src/zlib.erl:697",
       "erts/src/zlib.erl:725",
       "erts/src/zlib.erl:741",
       "erts/src/zlib.erl:757",
       "erts/src/zlib.erl:773"
     ]},
    {:lists, :pure_data, ["stdlib/src/lists.erl:49", "stdlib/src/lists.erl:47"]},
    {:maps, :pure_data, ["stdlib/src/maps.erl:33", "stdlib/src/maps.erl:31"]},
    {:orddict, :pure_data, ["stdlib/src/orddict.erl:43", "stdlib/src/orddict.erl:65"]},
    {:ordsets, :pure_data, ["stdlib/src/ordsets.erl:45", "stdlib/src/ordsets.erl:43"]},
    {:sets, :pure_data, ["stdlib/src/sets.erl:121", "stdlib/src/sets.erl:119"]},
    {:io_lib, :pure_data, ["stdlib/src/io_lib.erl:74", "stdlib/src/io_lib.erl:72"]},
    {:erl_anno, :pure_data, ["stdlib/src/erl_anno.erl:76", "stdlib/src/erl_anno.erl:74"]},
    {:erl_features, :pure_data,
     ["stdlib/src/erl_features.erl:35", "stdlib/src/erl_features.erl:30"]},
    {:erl_internal, :pure_data,
     ["stdlib/src/erl_internal.erl:59", "stdlib/src/erl_internal.erl:57"]},
    {:erl_lint, :pure_data, ["stdlib/src/erl_lint.erl:75", "stdlib/src/erl_lint.erl:71"]},
    {:records, :pure_data, ["stdlib/src/records.erl:38"]}
  ]

  setup_all do
    graph = build_graph()
    {:ok, graph: graph}
  end

  @exclusions @exclusions ++ [@escript_debug_exclusion]

  test "discovers and traces a compile-only app outside historical active membership", ctx do
    dir =
      Path.join(
        System.tmp_dir!(),
        "fablebook-inventory-probe-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)

    otp_lib = Path.join(dir, "lib")
    app = "mix_pruned_probe"
    app_atom = :mix_pruned_probe
    module = :fablebook_inventory_pruned_probe
    install_probe_app!(otp_lib, app, app_atom, "1.2.3", module)

    installed = InstalledOtp.discover!(otp_lib)

    discovered = Enum.find(installed, &(&1.app == app))

    assert discovered != nil, "installation discovery omitted #{app}"
    assert discovered.version == "1.2.3"
    assert Enum.any?(discovered.beams, &(&1.module == Atom.to_string(module)))
    assert :code.is_loaded(module) == false

    known = Enum.find(ctx.graph.discovered, &(&1.app == "kernel"))
    assert known != nil, "installed discovery omitted kernel"
    assert Enum.any?(known.beams, &(&1.module == "application"))

    inspected = InstalledOtp.inspect!([discovered], lane: ctx.graph.lane.name)
    {:ok, _} = :xref.start(:inventory_probe, xref_mode: :functions)

    try do
      :ok = :xref.set_default(:inventory_probe, warnings: false, verbose: false, builtins: true)

      ingested =
        InstalledOtp.add_directory!(:inventory_probe, discovered, lane: ctx.graph.lane.name)

      assert InstalledOtp.assert_parity!(
               [discovered],
               inspected,
               ingested,
               ctx.graph.lane.name
             ) == :ok

      receipt = %{
        lane: ctx.graph.lane,
        lock_sha256: ctx.graph.lock_sha256,
        discovered: [discovered],
        inspected: inspected,
        ingested: ingested
      }

      lines = InstalledOtp.receipt_lines(receipt)
      verified = InstalledOtp.verify_receipt_lines!(lines)
      assert verified.lane == ctx.graph.lane.name
      assert Enum.any?(verified.beams, &(&1["module"] == Atom.to_string(module)))

      assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
        InstalledOtp.assert_parity!(
          [discovered],
          inspected,
          [],
          ctx.graph.lane.name
        )
      end
    after
      :stopped = :xref.stop(:inventory_probe)
    end
  end

  test "full installed graph preserves the historical active view and exposes pending apps",
       ctx do
    graph = ctx.graph
    discovered_apps = MapSet.new(graph.discovered, & &1.app)
    historical_apps = MapSet.new(graph.historical_active_otp_apps)

    active_ct_exports =
      graph.exported
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    assert MapSet.subset?(historical_apps, discovered_apps)
    assert graph.pending_apps != []
    assert Enum.all?(graph.pending_apps, &(not MapSet.member?(historical_apps, &1.app)))
    assert Enum.any?(graph.pending_apps, &(&1.app == "common_test"))
    refute "common_test" in graph.historical_active_otp_apps
    assert MapSet.member?(graph.active_modules, :ct_make)
    refute Enum.any?(graph.pending_modules, &(&1.module_atom == :ct_make))
    assert active_ct_exports == MapSet.new(@ct_make_expected_mfas)
    assert MapSet.subset?(graph.historical_active_exported, graph.exported)
    assert MapSet.subset?(MapSet.new(graph.historical_active_edges), MapSet.new(graph.edges))
    assert MapSet.size(graph.exported) > MapSet.size(graph.historical_active_exported)

    active_apps =
      graph.active_membership
      |> Enum.filter(&(&1["kind"] == "active_app"))
      |> Enum.map(& &1["app"])
      |> MapSet.new()

    expected_active_apps =
      graph.historical_active_otp_apps ++
        Enum.map(@elixir_apps, &Atom.to_string/1) ++ graph.closure

    assert active_apps == MapSet.new(expected_active_apps)

    refute Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_app" and row["app"] == "common_test"
           end)

    assert Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_module" and row["app"] == "common_test" and
               row["module"] == "ct_make"
           end)

    assert MapSet.subset?(graph.historical_active_exported, graph.full_exported)
    assert MapSet.subset?(MapSet.new(graph.historical_active_edges), MapSet.new(graph.full_edges))
    assert MapSet.size(graph.historical_active_modules) > 0
  end

  test "source evidence rejects a wrong runtime patch before resolving citations" do
    error =
      assert_raise Fablebook.Test.SweepEvidence.Error, fn ->
        SweepEvidence.lane!(%{elixir: "1.20.4", otp: "29.1.1"})
      end

    assert error.reason == :runtime_identity
  end

  test "source evidence resolves the caller-file atom trace on the exact running lane" do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    resolved = SweepEvidence.resolve!(evidence, "kernel/src/file.erl:1")

    assert resolved.line == 1
    assert resolved.sha256 =~ ~r/^[a-f0-9]{64}$/
    assert resolved.origin in [:installed, :archive]
    assert evidence.lane.otp in ["29.1.2", "27.3.4.9"]

    trailing = SweepEvidence.resolve!(evidence, "kernel/src/inet_config.erl:1")
    data = File.read!(trailing.path)
    assert String.ends_with?(data, "\n\n")
    last_line = length(String.split(data, "\n")) - 1
    assert SweepEvidence.resolve!(evidence, "kernel/src/inet_config.erl:#{last_line}").text == ""

    trace =
      if evidence.lane.name == "core" do
        [
          {"kernel/src/file.erl:2314", "path_consult(Path, File)"},
          {"kernel/src/file.erl:2317", "consult_stream(Fd)"},
          {"kernel/src/file.erl:2905", "io:read(Fd"},
          {"stdlib/src/io.erl:765", "erl_scan,tokens"},
          {"stdlib/src/erl_scan.erl:788", "list_to_atom(Wcs)"}
        ]
      else
        [
          {"kernel/src/file.erl:2304", "path_consult(Path, File)"},
          {"kernel/src/file.erl:2307", "consult_stream(Fd)"},
          {"kernel/src/file.erl:2895", "io:read(Fd"},
          {"stdlib/src/io.erl:734", "erl_scan,tokens"},
          {"stdlib/src/erl_scan.erl:761", "list_to_atom(Wcs)"}
        ]
      end

    for {citation, expected} <- trace do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected
    end

    assert SweepEvidence.resolve!(evidence, "elixir/src/elixir_aliases.erl:1").origin == :archive
  end

  test "ct_make four-export caller, default and load traces resolve from exact sources", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    lane = evidence.lane.name
    expected = Map.fetch!(@ct_make_source_by_lane, lane)
    otp_ref = evidence.manifest["refs"][lane]["otp"] |> Enum.at(1)
    records = Enum.filter(@ct_make_audit, &(&1.lane == lane))

    source =
      Enum.find(
        evidence.manifest["files"],
        &(&1["path"] == "#{lane}/common_test/src/ct_make.erl")
      )

    assert source["lane"] == lane
    assert source["source_path"] == "common_test/src/ct_make.erl"
    assert source["sha256"] == expected.sha256
    assert source["status"] == "present"
    assert source["url"] =~ "/#{otp_ref}/lib/common_test/src/ct_make.erl"

    assert MapSet.new(Enum.map(records, &hd(&1.matched_mfas))) ==
             MapSet.new(@ct_make_expected_mfas)

    assert MapSet.new(
             ctx.graph.full_exported
             |> Enum.filter(&(elem(&1, 0) == :ct_make))
           ) == MapSet.new(@ct_make_expected_mfas)

    for record <- records, {citation, expected_source} <- record.citations do
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.origin in [:archive, :installed], citation
      assert resolved.sha256 == expected.sha256, citation
      assert resolved.text =~ expected_source, citation
    end
  end

  test "CT audit maps each export and rejects incomplete matches, sources and redundant retention",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = @ct_make_audit
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()

    assert_ct_make_audit!(records, ctx.graph, tier, evidence)

    lane_records = Enum.filter(records, &(&1.lane == evidence.lane.name))
    record = Enum.find(lane_records, &(&1.matched_mfas == [{:ct_make, :all, 0}]))
    record_index = Enum.find_index(records, &(&1.original_id == record.original_id))

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(
        Enum.reject(records, &(&1.original_id == record.original_id)),
        ctx.graph,
        tier,
        evidence
      )
    end

    wrong_lane = %{record | lane: "wrong-lane"}
    missing_mfa = %{record | matched_mfas: []}
    two_tuple = %{record | matched_mfas: [{:ct_make, :all}]}
    missing_verdict = %{record | verdict: :unreviewed}
    missing_citations = %{record | citations: []}

    for malformed <- [wrong_lane, missing_mfa, two_tuple, missing_verdict, missing_citations] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_ct_make_audit!(
          List.replace_at(records, record_index, malformed),
          ctx.graph,
          tier,
          evidence
        )
      end
    end

    missing_source = %{
      record
      | citations: [{"common_test/src/ct_make.erl:999999", "all() ->"}]
    }

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      SweepEvidence.resolve!(evidence, "common_test/src/ct_make.erl:999999")
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(
        List.replace_at(records, record_index, missing_source),
        ctx.graph,
        tier,
        evidence
      )
    end

    omitted_tier = Enum.reject(tier, &(&1 == {:ct_make, :all, 0}))

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(records, ctx.graph, omitted_tier, evidence)
    end

    redundant_retention =
      {{:mfa, {:ct_make, :all, 0}}, :private_front, [hd(record.citations) |> elem(0)]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(
        records,
        ctx.graph,
        tier,
        evidence,
        @exclusions ++ [redundant_retention]
      )
    end

    for mfa <- @ct_make_expected_mfas do
      assert mfa in undisposed(ctx.graph, Enum.reject(tier, &(&1 == mfa)), names),
             "removing only #{inspect(mfa)} must expose that previously covered front"
    end
  end

  test "saved-settings monitor source retains a private replay initializer and pending ownership" do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    {export_line, init_line, read_line, decode_line} =
      if evidence.lane.name == "core",
        do: {33, 115, 676, 678},
        else: {29, 111, 672, 674}

    resolve = fn line ->
      SweepEvidence.resolve!(evidence, "debugger/src/dbg_wx_mon.erl:#{line}")
    end

    assert resolve.(export_line).text == "-export([start/2, stop/0])."
    assert resolve.(init_line).text == "init(CallingPid, Mode, SFile) ->"
    assert resolve.(read_line).text =~ "file:read_file(SFile)"
    assert resolve.(decode_line).text =~ "binary_to_term(Binary)"
    assert {:dbg_wx_mon, :start, 2} in BannedCalls.banned_mfas()
    refute {:dbg_wx_mon, :init, 3} in BannedCalls.banned_mfas()
    assert :dbg_wx_mon in DebuggerPendingOwnership.baseline_modules()
    assert DebuggerPendingOwnership.owners()[:dbg_wx_mon] == "01.1.1.3.1.2"
  end

  @tag :tmp_dir
  @tag :saved_settings_source
  test "installed successor rows resolve and source corruption controls reject", %{
    tmp_dir: tmp_dir
  } do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    assert SweepEvidence.archive_sha256() ==
             "27c45913ed03b510f2f44ccef8f65a95d932c9fb917e6c4e942b0cfd18a73894"

    lane = evidence.lane.name

    expected_paths =
      for module <- ~w(dbg_icmd dbg_iserver dbg_wx_settings debugger),
          do: "#{lane}/debugger/src/#{module}.erl"

    rows = Enum.filter(evidence.manifest["files"], &(&1["path"] in expected_paths))
    assert Enum.map(rows, & &1["path"]) |> Enum.sort() == Enum.sort(expected_paths)

    archive_evidence = %{
      evidence
      | installed:
          Map.put(
            evidence.installed,
            "debugger",
            Path.join(evidence.archive_root, "missing-debugger")
          )
    }

    for row <- rows do
      citation = row["source_path"] <> ":1"
      assert SweepEvidence.resolve!(archive_evidence, citation).sha256 == row["sha256"]
    end

    settings_row = Enum.find(rows, &(&1["source_path"] == "debugger/src/dbg_wx_settings.erl"))
    settings_citation = settings_row["source_path"] <> ":1"

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      SweepEvidence.resolve!(archive_evidence, settings_row["source_path"] <> ":999999")
    end

    outside_source = Path.join(tmp_dir, "outside-settings.erl")
    File.write!(outside_source, "outside source")
    installed_root = Path.join(tmp_dir, "untrusted-debugger")
    symlink_path = Path.join(installed_root, "src/dbg_wx_settings.erl")
    File.mkdir_p!(Path.dirname(symlink_path))
    assert :ok = File.ln_s(outside_source, symlink_path)

    escaped_evidence = %{
      evidence
      | installed: Map.put(evidence.installed, "debugger", installed_root)
    }

    assert_raise SweepEvidence.Error, ~r/source_escape/, fn ->
      SweepEvidence.resolve!(escaped_evidence, settings_citation)
    end

    archive_source = Path.join(evidence.archive_root, settings_row["path"])
    File.write!(archive_source, "corrupt source bytes")

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(archive_evidence, settings_citation)
    end
  end

  @tag :saved_settings_audit
  test "saved-settings dialog and replay have exact lane source and branch coverage", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    assert Code.ensure_loaded?(DebuggerSettings),
           "the settings audit must provide source-backed records for the complete dialog and replay path"

    record = DebuggerSettings.records(evidence.lane.name)
    changed_universe = saved_settings_changed_family_universe(ctx.graph, record)
    exclusion_matches = DebuggerSettings.exclusion_matches(changed_universe, @exclusions)

    assert exclusion_matches == @saved_settings_expected_exclusion_matches,
           "changed saved-settings exclusions differ from the measured exact set: #{inspect(exclusion_matches)}"

    record = %{record | exclusion_matches: exclusion_matches}

    DebuggerSettings.assert_audit!(
      record,
      ctx.graph,
      BannedCalls.banned_mfas(),
      evidence,
      @exclusions
    )

    assert :ok ==
             DebuggerSettings.assert_exclusion_witnesses!(
               exclusion_matches,
               ctx.graph,
               BannedCalls.banned_mfas(),
               BannedCalls.banned_names(),
               @exclusions
             )

    monitor_front = {:dbg_wx_mon, :start, 2}

    monitor_front_citation =
      record.roots
      |> Enum.find(&(&1.mfa == monitor_front))
      |> Map.fetch!(:citations)
      |> hd()

    source_disposition = ["#{monitor_front_citation.path}:#{monitor_front_citation.line}"]

    exact_overlap =
      {{:mfa, monitor_front}, :redundant_tier_overlap, source_disposition}

    overlap_matches =
      DebuggerSettings.exclusion_matches(changed_universe, @exclusions ++ [exact_overlap])

    [overlap_match] = overlap_matches
    assert overlap_match.matched_mfas == [monitor_front]

    assert_raise ExUnit.AssertionError, ~r/no individual active removal witness/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        overlap_matches,
        ctx.graph,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        @exclusions ++ [exact_overlap]
      )
    end

    assert_raise ExUnit.AssertionError, ~r/incomplete matches/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        [%{overlap_match | matched_mfas: []}],
        ctx.graph,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        @exclusions ++ [exact_overlap]
      )
    end

    blanket_overlap = {{:dbg_wx_mon, :_}, :blanket_overlap, source_disposition}

    blanket_matches =
      DebuggerSettings.exclusion_matches(changed_universe, [blanket_overlap])

    assert_raise ExUnit.AssertionError, ~r/blanket or non-exact/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        blanket_matches,
        ctx.graph,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        [blanket_overlap]
      )
    end

    assert MapSet.new(DebuggerSettings.branch_ids()) ==
             MapSet.new(Map.keys(record.branch_citations))

    assert_invalid_audit = Function.capture(DebuggerSettings, :assert_audit!, 5)

    assert_raise ExUnit.AssertionError, ~r/required audit fields/, fn ->
      assert_invalid_audit.(
        Map.new(),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    branchless = %{record | branch_citations: %{}, source_branches: []}

    assert_raise ExUnit.AssertionError, ~r/complete settings and replay branch map/, fn ->
      DebuggerSettings.assert_audit!(
        branchless,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    for omitted_branch <- [
          :default_path,
          :settings_read_error,
          :conditional_callback_clause
        ] do
      incomplete_branches = %{
        record
        | branch_citations: Map.delete(record.branch_citations, omitted_branch),
          source_branches: Enum.reject(record.source_branches, &(&1.id == omitted_branch))
      }

      assert_raise ExUnit.AssertionError, ~r/complete settings and replay branch map/, fn ->
        DebuggerSettings.assert_audit!(
          incomplete_branches,
          ctx.graph,
          BannedCalls.banned_mfas(),
          evidence,
          @exclusions
        )
      end
    end

    incomplete_functions = %{
      record
      | function_sources: tl(record.function_sources),
        function_audit: tl(record.function_audit)
    }

    omitted_function_error =
      assert_raise ExUnit.AssertionError, ~r/missing_source=/, fn ->
        DebuggerSettings.assert_audit!(
          incomplete_functions,
          ctx.graph,
          BannedCalls.banned_mfas(),
          evidence,
          @exclusions
        )
      end

    assert omitted_function_error.message =~ "lane #{evidence.lane.name}"
    assert omitted_function_error.message =~ "dbg_wx_settings:default_settings_dir/1"
    assert omitted_function_error.message =~ "owner=01.1.1.3.1.1"
    assert omitted_function_error.message =~ "caller-chain="
    assert omitted_function_error.message =~ "remedy="

    wrong_lane = if evidence.lane.name == "core", do: "floor", else: "core"
    wrong_lane_evidence = %{evidence | lane: Map.put(evidence.lane, :name, wrong_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph lane/, fn ->
      DebuggerSettings.assert_audit!(
        record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        wrong_lane_evidence,
        @exclusions
      )
    end

    first_source = hd(record.function_sources)
    [first_citation | rest_citations] = first_source.citation

    wrong_source_record = %{
      record
      | function_sources: [
          %{
            first_source
            | citation: [
                %{first_citation | expected_text: "not the source line"} | rest_citations
              ]
          }
          | tl(record.function_sources)
        ]
    }

    assert_raise ExUnit.AssertionError, ~r/restore matching branch text/, fn ->
      DebuggerSettings.assert_audit!(
        wrong_source_record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    wrong_hash_record = %{
      record
      | function_sources: [
          %{
            first_source
            | citation: [%{first_citation | sha256: String.duplicate("0", 64)} | rest_citations]
          }
          | tl(record.function_sources)
        ]
    }

    assert_raise ExUnit.AssertionError, ~r/restore exact lane SHA/, fn ->
      DebuggerSettings.assert_audit!(
        wrong_hash_record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    wrong_line_record = %{
      record
      | function_sources: [
          %{first_source | citation: [%{first_citation | line: 999_999} | rest_citations]}
          | tl(record.function_sources)
        ]
    }

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      DebuggerSettings.assert_audit!(
        wrong_line_record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end
  end

  @tag :debugger_remainder_tracer
  test "auto-attach setter route binds exact source, installed BEAM and adopted owners", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)

    assert :ok ==
             DebuggerSettings.assert_auto_attach_trace!(
               record,
               ctx.graph,
               BannedCalls.banned_mfas(),
               evidence
             )

    missing_store = %{
      record
      | auto_attach_trace: Map.delete(record.auto_attach_trace, :stored_value)
    }

    assert_raise ExUnit.AssertionError, ~r/stored tuple/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_store,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    missing_gate = %{
      record
      | auto_attach_trace: Map.delete(record.auto_attach_trace, :event_gate)
    }

    assert_raise ExUnit.AssertionError, ~r/event gate/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_gate,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    missing_tuple = %{
      record
      | source_branches: Enum.reject(record.source_branches, &(&1.id == :auto_attach_two_tuple)),
        branch_citations: Map.delete(record.branch_citations, :auto_attach_two_tuple)
    }

    assert_raise ExUnit.AssertionError, ~r/missing source branches/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_tuple,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    missing_dispatch = %{
      record
      | source_branches:
          Enum.reject(record.source_branches, &(&1.id == :auto_attach_event_match_spawn)),
        branch_citations: Map.delete(record.branch_citations, :auto_attach_event_match_spawn)
    }

    assert_raise ExUnit.AssertionError, ~r/missing source branches/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_dispatch,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    wrong_owner = %{
      record
      | source_branches:
          Enum.map(record.source_branches, fn branch ->
            if branch.id == :auto_attach_tuple_store,
              do: %{branch | owner: "01.1.1.3.1.1"},
              else: branch
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/retain the adopted remainder owner/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        wrong_owner,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    [store_citation | remaining_store_citations] =
      record.branch_citations.auto_attach_tuple_store

    wrong_hash = %{
      record
      | branch_citations:
          Map.put(record.branch_citations, :auto_attach_tuple_store, [
            %{store_citation | sha256: String.duplicate("0", 64)} | remaining_store_citations
          ])
    }

    assert_raise ExUnit.AssertionError, ~r/restore exact lane SHA/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        wrong_hash,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end
  end

  @tag :debugger_remainder_monitor
  test "monitor and file-window source branches include exact defaults and routes", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(ctx.graph.lane.name)

    result =
      DebuggerSettings.assert_function_dispositions!(ctx.graph, evidence, record, :monitor)

    assert result.status == :verified

    assert result.module_names == [
             "dbg_wx_filedialog_win",
             "dbg_wx_mon",
             "dbg_wx_mon_win",
             "dbg_wx_win"
           ]

    required_branch_ids = [
      :monitor_start_error,
      :monitor_start_already_started,
      :startup_graphics_error,
      :startup_graphics_ready,
      :startup_init2_stop,
      :startup_init2_error,
      :startup_default_no_replay,
      :startup_default_loop,
      :startup_selected_replay,
      :load_menu_cancel,
      :load_menu_selected,
      :trace_windows_selected,
      :trace_windows_unselected,
      :monitor_dialog_default_path,
      :monitor_dialog_filter_default,
      :monitor_dialog_sort_default,
      :monitor_dialog_cancel,
      :monitor_dialog_selected,
      :monitor_dialog_filter_dispatch,
      :monitor_window_shortcut_atom,
      :monitor_window_module_atom,
      :monitor_window_reload_module_atom,
      :monitor_window_checkbox_atoms,
      :monitor_window_strings_checkbox_atom,
      :monitor_process_pid_parse,
      :monitor_backtrace_integer_scanner,
      :monitor_backtrace_integer_token_match,
      :monitor_edit_variable_term_scanner,
      :monitor_edit_variable_term_parser
    ]

    assert Enum.map(result.source_branches, & &1.id) == Enum.sort(required_branch_ids)

    prior_root_rows = Map.new(record.roots, &{&1.mfa, &1})

    assert Enum.all?(
             [
               {:dbg_wx_mon, :start, 2},
               {:dbg_wx_mon, :load_settings, 2},
               {:dbg_wx_mon, :load_settings2, 2}
             ],
             fn mfa ->
               root = Map.fetch!(prior_root_rows, mfa)
               root.owner == "01.1.1.3.1.1" and root.completion == :pending
             end
           )

    assert result.cross_owner.selected_roots
           |> Enum.any?(&(&1.mfa == "dbg_wx_mon:start/2" and &1.changed_route))

    assert result.cross_owner.selected_branches
           |> Enum.map(& &1.id)
           |> Enum.sort() == [
             :monitor_start_already_started,
             :monitor_start_error,
             :trace_windows_selected,
             :trace_windows_unselected
           ]

    source_functions =
      result.modules
      |> Enum.flat_map(& &1.dispositions)
      |> Map.new(&{&1.mfa, &1})

    expected_atom_lines =
      if ctx.graph.lane.name == "core",
        do: [534, 557, 565, 577, 596],
        else: [530, 553, 561, 573, 592]

    actual_atom_lines =
      source_functions["dbg_wx_mon_win:handle_event/2"].sink_facts
      |> Enum.filter(&(&1.kind == :atom_construction))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    assert actual_atom_lines == expected_atom_lines

    assert Enum.any?(
             source_functions["dbg_wx_mon_win:clear_processes/2"].sink_facts,
             &(&1.kind == :pid_parser)
           )

    assert Enum.any?(
             source_functions["dbg_wx_filedialog_win:get_file_info/5"].sink_facts,
             &(&1.kind == :dynamic_fun_call)
           )

    verify_note = source_functions["dbg_wx_win:verify/2"]
    expected_verify_scanner_line = if ctx.graph.lane.name == "core", do: 279, else: 277
    expected_verify_parser_line = if ctx.graph.lane.name == "core", do: 281, else: 279

    assert Enum.any?(
             verify_note.sink_facts,
             &(&1.kind == :token_scanner and &1.line == expected_verify_scanner_line)
           )

    assert Enum.any?(
             verify_note.sink_facts,
             &(&1.kind == :term_parser and &1.line == expected_verify_parser_line)
           )

    assert String.contains?(verify_note.guard_remedy, "cannot intern")
    assert String.contains?(verify_note.defaults_and_options, "non-term clause")
    assert String.contains?(verify_note.defaults_and_options, "extended_parse_term")
  end

  @tag :debugger_remainder_trace
  test "trace and breakpoint routes reconcile exact sources and current owner links", ctx do
    required_branch_ids = [
      :trace_breakpoint_menu_dispatch,
      :trace_edit_variable_term_entry,
      :trace_edit_variable_assignment,
      :trace_user_command_eval_dispatch,
      :trace_backtrace_integer_entry,
      :break_dialog_module_atom_live_edit,
      :break_dialog_module_atom_function_submit,
      :break_dialog_module_atom_line_submit,
      :break_dialog_atom_input_types,
      :break_dialog_module_list_lookup,
      :break_dialog_typed_input_wrapper,
      :break_dialog_typed_input_scanner,
      :break_dialog_conditional_callback_tuple,
      :trace_shortcut_atom,
      :trace_resize_fixed_closure_calls,
      :trace_resize_code_fixed_changeh_closure,
      :trace_resize_trace_fixed_changeh_closure,
      :trace_code_area_fixed_style_closure,
      :trace_source_view_fixed_style_closure,
      :trace_output_fixed_callback_invocation,
      :trace_eval_entry_user_command,
      :trace_view_module_source_lookup,
      :trace_trace_module_source_lookup,
      :view_breakpoint_action_dispatch,
      :break_process_fixed_worker,
      :view_process_fixed_worker
    ]

    actual_branch_ids = MapSet.new(DebuggerSettings.branch_ids())
    missing_branch_ids = MapSet.difference(MapSet.new(required_branch_ids), actual_branch_ids)

    assert MapSet.size(missing_branch_ids) == 0,
           "trace and breakpoint source routes are incomplete: #{inspect(MapSet.to_list(missing_branch_ids))}"

    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)

    result =
      DebuggerSettings.assert_function_dispositions!(ctx.graph, evidence, record, :trace)

    assert result.status == :verified
    assert result.group == :trace

    assert result.module_names == [
             "dbg_wx_break",
             "dbg_wx_break_win",
             "dbg_wx_code",
             "dbg_wx_src_view",
             "dbg_wx_trace",
             "dbg_wx_trace_win",
             "dbg_wx_view",
             "dbg_wx_winman"
           ]

    assert Enum.map(result.source_branches, & &1.id) == Enum.sort(required_branch_ids)

    refute Enum.any?(result.modules, fn module ->
             Enum.any?(module.dispositions, &(&1.mfa == "dbg_wx_win:verify/2"))
           end)

    assert result.cross_owner.prior_owner_break_branch == %{
             id: :conditional_callback_clause,
             mfa: "dbg_icmd:break_p/4",
             owner: "01.1.1.3.1.1"
           }

    assert result.cross_owner.remainder_break_dispatch_branch == %{
             id: :condition_break_p_called,
             mfa: "dbg_icmd:cmd/4",
             owner: "01.1.1.3.1.2"
           }

    assert result.cross_owner.current_callback_branch == %{
             id: :break_dialog_conditional_callback_tuple,
             mfa: "dbg_wx_break:gui_cmd/2",
             owner: "01.1.1.3.1.2"
           }

    assert Enum.map(result.cross_owner.interpreter_roots, & &1.mfa) == [
             "dbg_wx_interpret:filter_files/2",
             "dbg_wx_interpret:interpret_all/5",
             "dbg_wx_interpret:start/4"
           ]

    assert Enum.all?(result.cross_owner.interpreter_roots, &(&1.owner == "01.1.1.3.1.2"))
    refute "dbg_wx_interpret" in result.module_names

    source_functions =
      result.modules
      |> Enum.flat_map(& &1.dispositions)
      |> Map.new(&{&1.mfa, &1})

    expected_break_atom_lines =
      if ctx.graph.lane.name == "core", do: [192, 215, 224], else: [188, 211, 220]

    actual_break_atom_lines =
      source_functions["dbg_wx_break_win:handle_event/2"].sink_facts
      |> Enum.filter(&(&1.kind == :atom_construction))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    assert actual_break_atom_lines == expected_break_atom_lines

    expected_shortcut_atom_line = if ctx.graph.lane.name == "core", do: 799, else: 795

    assert Enum.any?(
             source_functions["dbg_wx_trace_win:handle_event/2"].sink_facts,
             &(&1.kind == :atom_construction and &1.line == expected_shortcut_atom_line)
           )

    assert Enum.any?(
             source_functions["dbg_wx_break_win:check_input/2"].sink_facts,
             &(&1.kind == :token_scanner)
           )

    edit_route = source_functions["dbg_wx_trace:gui_cmd/2"]
    break_input = source_functions["dbg_wx_break_win:check_input/2"]
    break_wrapper = source_functions["dbg_wx_break_win:check_input/1"]
    break_route = source_functions["dbg_wx_break:gui_cmd/2"]
    trace_output = source_functions["dbg_wx_trace:meta_cmd/2"]
    code_style = source_functions["dbg_wx_code:code_area/1"]
    source_style = source_functions["dbg_wx_src_view:code_area/2"]
    trace_window = source_functions["dbg_wx_trace_win:handle_event/2"]

    assert String.contains?(trace_output.caller_input_origin, "dbg_ieval:trace/3")
    assert String.contains?(trace_output.caller_input_origin, "dbg_icmd:tell_attached/1")
    assert String.contains?(trace_output.guard_remedy, "resolved cross-owner fixed callback")
    assert String.contains?(code_style.guard_remedy, "resolved benign local capability")
    assert String.contains?(source_style.guard_remedy, "resolved benign local capability")
    assert String.contains?(trace_window.guard_remedy, "resolved benign local capability")

    resolved_fun_sites =
      result.resolved_dynamic
      |> Enum.filter(&(&1.kind == :dynamic_fun_call))
      |> Enum.map(&{&1.mfa, &1.line, &1.status})
      |> Enum.sort()

    expected_resolved_fun_sites =
      if ctx.graph.lane.name == "core" do
        [
          {"dbg_wx_code:code_area/1", 98, :resolved_fixed_local_closure},
          {"dbg_wx_src_view:code_area/2", 59, :resolved_fixed_local_closure},
          {"dbg_wx_trace:meta_cmd/2", 711, :resolved_cross_owner_fixed_callback},
          {"dbg_wx_trace_win:handle_event/2", 706, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 734, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 735, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 736, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 767, :resolved_fixed_local_closure}
        ]
      else
        [
          {"dbg_wx_code:code_area/1", 96, :resolved_fixed_local_closure},
          {"dbg_wx_src_view:code_area/2", 57, :resolved_fixed_local_closure},
          {"dbg_wx_trace:meta_cmd/2", 709, :resolved_cross_owner_fixed_callback},
          {"dbg_wx_trace_win:handle_event/2", 702, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 730, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 731, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 732, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 763, :resolved_fixed_local_closure}
        ]
      end

    assert resolved_fun_sites == Enum.sort(expected_resolved_fun_sites)

    refute Enum.any?(result.unresolved_dynamic, &(&1.kind == :dynamic_fun_call))
    break_inputs = source_functions["dbg_wx_break_win:create_win/5"]
    assert String.contains?(break_inputs.defaults_and_options, "integer")
    assert String.contains?(break_inputs.defaults_and_options, "C-Module")
    assert String.contains?(break_inputs.defaults_and_options, "C-Function")
    assert String.contains?(break_inputs.defaults_and_options, "before matching")
    assert String.contains?(edit_route.caller_input_origin, "Edit Variable")
    assert String.contains?(edit_route.guard_remedy, "int:meta")
    assert String.contains?(break_input.guard_remedy, "tokenization")
    assert String.contains?(break_input.guard_remedy, "existing-atom")
    assert String.contains?(break_input.guard_remedy, "whitelist")
    assert String.contains?(break_input.defaults_and_options, "before matching")
    assert String.contains?(break_wrapper.caller_input_origin, "check_input/2")
    assert String.contains?(break_route.caller_input_origin, "int:functions/1")
    assert String.contains?(break_route.guard_remedy, "membership")
  end

  @tag :debugger_remainder_callbacks
  test "callback and breakpoint function dispositions reconcile exact lane sources and ownership",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)

    assert function_exported?(DebuggerSettings, :assert_function_dispositions!, 4),
           "callback and breakpoint routes need complete exact-lane function dispositions"

    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)

    dispositions =
      apply(DebuggerSettings, :assert_function_dispositions!, [
        ctx.graph,
        evidence,
        record,
        :callbacks
      ])

    assert dispositions.status == :verified
    assert dispositions.group == :callbacks
    assert dispositions.lane == evidence.lane.name

    assert dispositions.module_names ==
             Enum.sort(["int", "i", "debugger", "dbg_iserver", "dbg_icmd"])

    assert Enum.all?(dispositions.modules, fn module ->
             inventory_module = Enum.find(inventory.modules, &(&1.module == module.module))

             module.owner == "01.1.1.3.1.2" and module.functions == inventory_module.functions and
               module.exports == inventory_module.exports and
               module.dispositions |> Enum.map(& &1.mfa) |> Enum.sort() ==
                 Enum.sort(inventory_module.functions)
           end)

    assert dispositions.source_branches != []
    assert dispositions.cross_owner == [{{:dbg_icmd, :break_p, 4}, "01.1.1.3.1.1", :pending}]
    assert dispositions.unresolved_dynamic != []
  end

  @tag :debugger_remainder_interpreter
  test "interpreter evaluator, loader and debugged-process dispositions reconcile exact lane sources and ownership",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)

    dispositions =
      apply(DebuggerSettings, :assert_function_dispositions!, [
        ctx.graph,
        evidence,
        record,
        :interpreter
      ])

    assert dispositions.status == :verified
    assert dispositions.group == :interpreter
    assert dispositions.lane == evidence.lane.name
    assert dispositions.module_names == ["dbg_debugged", "dbg_ieval", "dbg_iload"]

    assert Enum.all?(dispositions.modules, fn module ->
             inventory_module = Enum.find(inventory.modules, &(&1.module == module.module))
             function_mfas = Enum.map(module.dispositions, & &1.mfa) |> Enum.sort()

             module.owner == "01.1.1.3.1.2" and module.functions == inventory_module.functions and
               module.exports == inventory_module.exports and
               function_mfas == Enum.sort(inventory_module.functions) and
               Enum.all?(module.dispositions, &(&1.owner == "01.1.1.3.1.2"))
           end)

    assert MapSet.new(Enum.map(dispositions.source_branches, & &1.id)) ==
             MapSet.new([
               :interpreter_eval_reentry,
               :interpreter_eval_spawn_meta,
               :interpreter_meta_initial_eval,
               :interpreter_uninterpreted_top_apply,
               :interpreter_uninterpreted_nested_apply,
               :interpreter_external_function_lookup,
               :interpreter_remote_call,
               :interpreter_apply_fun,
               :interpreter_apply_three,
               :interpreter_safe_bif_dispatch,
               :interpreter_debugged_ready_apply,
               :interpreter_debugged_command_dispatch,
               :interpreter_debugged_reply_apply,
               :interpreter_debugged_reply_eval,
               :interpreter_loader_worker,
               :interpreter_loader_envelope_decode,
               :interpreter_loader_abstract_decode,
               :interpreter_load_package,
               :interpreter_server_loader_call
             ])

    assert Enum.all?(dispositions.source_branches, &(&1.owner == "01.1.1.3.1.2"))
    assert dispositions.cross_owner == []

    assert Enum.any?(dispositions.unresolved_dynamic, &(&1.kind == :dynamic_apply))
    assert Enum.any?(dispositions.unresolved_dynamic, &(&1.kind == :dynamic_remote_dispatch))

    find_function = fn mfa ->
      dispositions.modules
      |> Enum.flat_map(& &1.dispositions)
      |> Enum.find(&(&1.mfa == mfa))
    end

    assert Enum.any?(find_function.("dbg_ieval:expr/3").sink_facts, &(&1.kind == :dynamic_apply))

    assert Enum.any?(
             find_function.("dbg_iload:store_module/4").sink_facts,
             &(&1.kind == :term_decoder)
           )

    assert Enum.any?(
             find_function.("dbg_debugged:reply/1").sink_facts,
             &(&1.kind == :dynamic_apply)
           )

    assert find_function.("dbg_ieval:eval/3").caller_input_origin =~ "int:eval/3"
    assert find_function.("dbg_iload:store_module/4").caller_input_origin =~ "int:load/2"
    assert Enum.all?(dispositions.unresolved_dynamic, &(&1.status == :unresolved_static_target))
  end

  @tag :debugger_remainder_inventory
  test "assigned remainder universe has a fail-closed exact-lane reconciliation contract" do
    assert Code.ensure_loaded?(DebuggerSettings)

    assert function_exported?(DebuggerSettings, :assert_remainder_inventory!, 3),
           "the current remainder universe needs an exact-lane source, function, export, root, and owner reconciliation contract"
  end

  @tag :debugger_remainder_inventory
  test "remainder inventory retains exact sources, private functions, graph sets and both owner namespaces",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)

    assert inventory.status == :verified
    assert inventory.lane == evidence.lane.name
    assert inventory.owner == "01.1.1.3.1.2"
    assert inventory.module_names == Enum.sort(DebuggerSettings.required_source_modules())
    assert inventory.modules != []

    assert Enum.all?(inventory.modules, fn module ->
             module.owner == "01.1.1.3.1.2" and module.source.origin == :installed and
               module.source.sha256 == module.source_assignment["sha256"] and
               module.function_count == length(module.functions) and
               module.export_count == length(module.exports) and
               Enum.all?(module.zero_hit_functions, &(&1 in module.functions)) and
               Enum.all?(module.private_functions, &(&1 in module.functions))
           end)

    original_root_ids =
      MapSet.new(
        inventory.original_roots,
        &{&1["app"], &1["module"], &1["function"], &1["arity"]}
      )

    observed_root_ids =
      MapSet.new(
        inventory.observed_roots,
        &{&1["app"], &1["module"], &1["function"], &1["arity"]}
      )

    assert original_root_ids == observed_root_ids
    assert inventory.interpreter_root_observations != []
    assert Enum.all?(inventory.interpreter_root_observations, &(&1["owner"] == "01.1.1.3.1.2"))
    assert inventory.overlaps != []

    assert inventory.overlap_occurrence_count ==
             Enum.sum(Enum.map(inventory.overlaps, &length(&1["occurrences"] || [])))

    assert MapSet.new(inventory.selected_roots) ==
             MapSet.new([
               {"debugger", "dbg_wx_mon", "start", 2},
               {"debugger", "dbg_wx_mon", "load_settings", 2},
               {"debugger", "dbg_wx_mon", "load_settings2", 2}
             ])

    [break_p] = inventory.source_branches
    assert break_p["owner"] == "01.1.1.3.1.1"
    assert break_p["completion"] == "pending"

    assert inventory.graph.full_edge_count == length(ctx.graph.full_edges)
    assert inventory.graph.full_reached_count == MapSet.size(ctx.graph.full_reached)
    assert inventory.graph.full_export_count == MapSet.size(ctx.graph.full_exported)
    assert inventory.graph.assigned_edge_count == length(inventory.graph.assigned_edges)
    assert inventory.graph.assigned_reached_count == length(inventory.graph.assigned_reached)
    assert inventory.graph.assigned_export_count == length(inventory.graph.assigned_exports)
    assert String.length(inventory.graph.full_edges_sha256) == 64
    assert String.length(inventory.graph.full_reached_sha256) == 64
    assert String.length(inventory.graph.full_exports_sha256) == 64
  end

  @tag :debugger_remainder_inventory
  test "installed remainder source citations reject lane, path, digest, file, line and text drift" do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    %{records: rows} = DebuggerSettings.load_delegation!()

    source =
      Enum.find(
        rows,
        &(&1["t"] == "exact_source" and &1["lane"] == evidence.lane.name and
            &1["owner"] == "01.1.1.3.1.2")
      )

    module = source["module"]

    declaration =
      String.split(
        File.read!(
          Path.join(
            evidence.installed["debugger"],
            String.replace_prefix(source["source_path"], "debugger/", "")
          )
        ),
        "\n",
        trim: false
      )
      |> Enum.find_index(&String.contains?(&1, "-module(#{module}"))

    citation = %{line: declaration + 1, expected_text: "-module(#{module}"}

    assert DebuggerSettings.assert_remainder_source!(evidence, source, citation).origin ==
             :installed

    wrong_lane =
      Map.put(source, "lane", if(evidence.lane.name == "core", do: "floor", else: "core"))

    assert_raise ExUnit.AssertionError, ~r/exact_source row/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, wrong_lane, citation)
    end

    escaped_path = Map.put(source, "source_path", "debugger/src/../outside.erl")

    assert_raise ExUnit.AssertionError, ~r/installed source path/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, escaped_path, citation)
    end

    wrong_digest = Map.put(source, "sha256", String.duplicate("0", 64))

    assert_raise ExUnit.AssertionError, ~r/exact_source digest/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, wrong_digest, citation)
    end

    missing_source =
      source
      |> Map.put("module", "fablebook_missing_probe")
      |> Map.put("source_path", "debugger/src/fablebook_missing_probe.erl")

    assert_raise ExUnit.AssertionError, ~r/installed source read=enoent/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, missing_source, citation)
    end

    assert_raise ExUnit.AssertionError, ~r/source citation remedy=use an existing line/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, source, %{citation | line: 999_999})
    end

    assert_raise ExUnit.AssertionError,
                 ~r/source citation remedy=restore expected source text/,
                 fn ->
                   DebuggerSettings.assert_remainder_source!(evidence, source, %{
                     citation
                     | expected_text: "missing text"
                   })
                 end
  end

  @tag :debugger_remainder_inventory
  test "remainder inventory rejects omitted functions, exports, roots and duplicate identities",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)
    first_module = hd(inventory.modules).module
    inspection = Enum.find(ctx.graph.inspected, &(&1.module == first_module))
    [omitted_function | _] = inspection.function_mfas

    incomplete_inspection = %{
      ctx.graph
      | inspected:
          Enum.map(ctx.graph.inspected, fn current ->
            if current.module == first_module,
              do: %{current | function_mfas: List.delete(current.function_mfas, omitted_function)},
              else: current
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/function universe/, fn ->
      DebuggerSettings.assert_remainder_inventory!(incomplete_inspection, evidence, record)
    end

    [omitted_export | _] =
      Enum.filter(
        ctx.graph.full_exported,
        &(Atom.to_string(elem(&1, 0)) in inventory.module_names)
      )

    incomplete_exports = %{
      ctx.graph
      | full_exported: MapSet.delete(ctx.graph.full_exported, omitted_export)
    }

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_inventory!(incomplete_exports, evidence, record)
    end

    loaded = DebuggerSettings.load_delegation!()

    omitted_root_rows =
      Enum.reject(loaded.records, fn row ->
        row["t"] == "root" and row["lane"] == evidence.lane.name and
          row["owner"] == "01.1.1.3.1.2"
      end)

    omitted_root_record =
      Map.merge(record, %{
        delegation_metadata: loaded.metadata,
        delegation_records: omitted_root_rows
      })

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, omitted_root_record)
    end

    [first_row | _] = loaded.records

    duplicated_record =
      Map.merge(record, %{
        delegation_metadata: loaded.metadata,
        delegation_records: loaded.records ++ [first_row]
      })

    assert_raise ExUnit.AssertionError, ~r/duplicate typed identities/, fn ->
      DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, duplicated_record)
    end
  end

  @tag :debugger_remainder_ownership
  test "remainder source branch route edits are rejected by the current validator", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    target_id = :monitor_edit_variable_term_parser
    original = Enum.find(record.source_branches, &(&1.id == target_id))
    assert original != nil

    forged = %{
      record
      | source_branches:
          Enum.map(record.source_branches, fn branch ->
            if branch.id == target_id,
              do: %{branch | trace: "forged route with no source link"},
              else: branch
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/branch route trace/, fn ->
      DebuggerSettings.assert_function_dispositions!(
        ctx.graph,
        evidence,
        forged,
        :monitor
      )
    end
  end

  @tag :saved_settings_audit
  test "deferred callback routes have distinct source branch identities" do
    assert Code.ensure_loaded?(DebuggerSettings)
    branch_ids = DebuggerSettings.branch_ids() |> MapSet.new()

    required =
      MapSet.new([
        :auto_attach_init_event,
        :auto_attach_break_event,
        :auto_attach_exit_event,
        :auto_attach_event_match_spawn,
        :auto_attach_event_nonmatch_ignore,
        :auto_attach_already_attached_ignore,
        :conditional_callback_clause,
        :condition_user_eval_suppressed,
        :condition_null_true,
        :condition_tuple_callback,
        :condition_callback_exception_false,
        :condition_action_disable,
        :condition_action_delete
      ])

    assert MapSet.subset?(required, branch_ids),
           "deferred callback source disposition is missing #{inspect(MapSet.to_list(MapSet.difference(required, branch_ids)))}"
  end

  @tag :saved_settings_ownership
  test "saved-settings ownership resolves selected and remainder identities from the live lane",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(ctx.graph.lane.name)
    ownership = DebuggerSettings.assert_ownership!(ctx.graph, evidence, record)
    control_names = DebuggerSettings.ownership_controls!(ctx.graph, evidence, record)

    expected_controls = [
      "missing-selected-module-original:rejected",
      "missing-selected-module-observed:rejected",
      "missing-remainder-module-original:rejected",
      "missing-remainder-module-observed:rejected",
      "missing-selected-root-original:rejected",
      "missing-selected-root-observed:rejected",
      "missing-remainder-root-original:rejected",
      "missing-remainder-root-observed:rejected",
      "duplicate-canonical-root:rejected",
      "wrong-selected-owner:rejected",
      "changed-canonical-chain:rejected",
      "changed-current-reference:rejected",
      "missing-overlap-occurrence:rejected",
      "missing-source-branch:rejected",
      "empty-settings-audit:rejected",
      "changed-settings-source-digest:rejected",
      "escaping-settings-citation:rejected",
      "graph-new-settings-export:rejected",
      "graph-new-debugger-root:rejected",
      "graph-omitted-debugger-beam:rejected",
      "graph-omitted-debugger-export:rejected",
      "graph-omitted-active-baseline:rejected"
    ]

    assert Enum.sort(control_names) == Enum.sort(expected_controls)

    if audit_path = System.get_env("FABLEBOOK_SETTINGS_AUDIT_OUT") do
      File.write!(
        audit_path,
        JSON.encode!(%{
          "lane" => ctx.graph.lane.name,
          "receipt_sha256" => ownership.receipt_sha256,
          "pending_observed_delta_count" => ownership.pending_observed_delta_count,
          "observations" => ownership.observations
        }) <> "\n"
      )
    end

    owners = DebuggerPendingOwnership.owners()

    assert MapSet.new(Map.values(owners)) == MapSet.new(["01.1.1.3.1.2"]),
           "pending debugger modules must resolve to current remainder owner 01.1.1.3.1.2"

    assert :ok = DebuggerPendingOwnership.assert_valid!(owners)
    assert ownership.status == :verified
    assert ownership.selected_module == :dbg_wx_settings
    assert length(ownership.selected_roots) == 3
    assert ownership.remainder_module_count == 20
    assert ownership.remainder_root_count == if(ctx.graph.lane.name == "core", do: 233, else: 224)

    module_app = Map.new(ctx.graph.ingested, &{&1.module_atom, &1.app})

    active_debugger_modules =
      ctx.graph.active_modules
      |> Enum.filter(&(Map.get(module_app, &1) == "debugger"))
      |> MapSet.new()

    assert active_debugger_modules ==
             MapSet.new(@debugger_baseline_active_modules ++ [:dbg_wx_settings]),
           "the audited settings module must be the sole addition to the earlier three-module debugger seed"

    pending_debugger_modules =
      ctx.graph.pending_modules
      |> Enum.filter(&(&1.app == "debugger"))
      |> MapSet.new(& &1.module_atom)

    assert MapSet.subset?(
             MapSet.new([:dbg_wx_mon, :dbg_iserver, :dbg_icmd, :debugger]),
             pending_debugger_modules
           ),
           "broad monitor, server, command, and debugger modules remain pending with 01.1.1.3.1.2"

    selected_root_observations =
      Enum.filter(ownership.observations, fn row ->
        identity = row["identity"]

        identity["module"] == "dbg_wx_mon" and
          identity["function"] in ["start", "load_settings", "load_settings2"]
      end)

    assert length(selected_root_observations) == 6
    assert ownership.pending_observed_delta_count > 0

    new_root_observations =
      Enum.filter(ownership.observations, fn row ->
        row["identity"]["kind"] == "root" and is_nil(row["origin_record_sha256"])
      end)

    assert new_root_observations != []

    assert Enum.all?(
             new_root_observations,
             &(&1["owner"] == "01.1.1.3.1.2" and &1["completion"] == "pending")
           )

    assert Enum.count(
             ownership.observations,
             &(&1["completion"] == "selected_settings_functions_exports_and_source_verified")
           ) == 2
  end

  @tag :saved_settings_receipt
  test "saved-settings receipt acceptance binds the live graph to current source and ownership",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    records = DebuggerSettings.records(ctx.graph.lane.name)
    receipt_lines = ctx.graph.receipt_lines

    assert function_exported?(DebuggerSettings, :assert_receipt!, 4),
           "expected a public validator for the current lane's installed receipt"

    ownership =
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, receipt_lines)

    assert ownership.status == :verified
    assert ownership.lane == ctx.graph.lane.name

    assert ownership.receipt_sha256 ==
             InstalledOtp.verify_receipt_lines!(receipt_lines).sha256

    assert ownership.selected_module == :dbg_wx_settings
    assert ownership.remainder_module_count == 20

    assert_raise InstalledOtp.Error, fn ->
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, [])
    end

    other_lane = if ctx.graph.lane.name == "core", do: "floor", else: "core"

    wrong_lane =
      rewrite_settings_receipt(receipt_lines, fn [meta | rest] ->
        [Map.put(meta, "lane", other_lane) | rest]
      end)

    assert_raise InstalledOtp.Error, fn ->
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, wrong_lane)
    end

    wrong_lock =
      rewrite_settings_receipt(receipt_lines, fn [meta | rest] ->
        [Map.put(meta, "lock_sha256", String.duplicate("0", 64)) | rest]
      end)

    assert_raise InstalledOtp.Error, fn ->
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, wrong_lock)
    end

    wrong_source_records = Map.put(records, :source_sha256, String.duplicate("0", 64))

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_receipt!(
        ctx.graph,
        evidence,
        wrong_source_records,
        receipt_lines
      )
    end
  end

  defp rewrite_settings_receipt(lines, transform) do
    marker = "FABLEBOOK_OTP_INVENTORY_V2 "

    body =
      lines
      |> Enum.drop(-1)
      |> Enum.map(fn line ->
        {:ok, row} = JSON.decode(String.replace_prefix(line, marker, ""))
        row
      end)
      |> transform.()

    encoded = Enum.map(body, &(marker <> JSON.encode!(&1)))

    digest =
      :crypto.hash(:sha256, Enum.join(encoded, "\n") <> "\n") |> Base.encode16(case: :lower)

    {:ok, footer} = JSON.decode(String.replace_prefix(List.last(lines), marker, ""))

    encoded ++ [marker <> JSON.encode!(Map.put(footer, "sha256", digest))]
  end

  test "debugger selected-file audit resolves its exact source, export and tier witness", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = @debugger_audit
    tier = BannedCalls.banned_mfas()

    assert_debugger_audit!(records, ctx.graph, tier, evidence, @exclusions)

    lane_record = Enum.find(records, &(&1.lane == evidence.lane.name))

    assert Map.has_key?(lane_record, :family_function_audit),
           "the debugger audit must source-dispose every discovered assigned function"

    record_index = Enum.find_index(records, &(&1.original_id == lane_record.original_id))

    assert Map.get(lane_record, :branch_citations) != nil,
           "the selected-file audit must cover local/global, cancel, empty/error and parser-filter branches"

    actual_family_universe = debugger_family_universe(ctx.graph, tier, @exclusions)
    omitted_mfa = {:dbg_istk, :from_external, 1}

    source_rows_without_mfa =
      lane_record.family_function_sources
      |> Enum.reject(&(elem(&1, 0) == omitted_mfa))
      |> Enum.map(&elem(&1, 0))

    review_rows_without_mfa =
      lane_record.family_function_audit
      |> Enum.reject(&(&1.mfa == omitted_mfa))
      |> Enum.map(& &1.mfa)

    expected_rows_without_mfa = Enum.reject(@debugger_expected_family_mfas, &(&1 == omitted_mfa))

    omission_error =
      assert_raise ExUnit.AssertionError, ~r/assigned function inventory differs/, fn ->
        assert_debugger_function_inventory!(
          actual_family_universe,
          source_rows_without_mfa,
          review_rows_without_mfa,
          expected_rows_without_mfa,
          evidence.lane.name
        )
      end

    assert omission_error.message =~ "owner=plan_02"
    assert omission_error.message =~ "caller-chain="

    graph_candidates = debugger_graph_candidates(ctx.graph)
    omitted_roots = Enum.reject(@debugger_explicit_roots, &(&1 == omitted_mfa))

    root_omission_error =
      assert_raise ExUnit.AssertionError, ~r/assigned root inventory differs/, fn ->
        assert_debugger_root_inventory!(graph_candidates, omitted_roots, evidence.lane.name)
      end

    assert root_omission_error.message =~ "owner=plan_02"
    assert root_omission_error.message =~ "caller-chain="

    assert_raise ExUnit.AssertionError, ~r/active debugger slice omitted baseline modules/, fn ->
      assert_debugger_active_scope!(
        ctx.graph,
        List.delete(@debugger_active_modules, :dbg_istk),
        evidence.lane.name
      )
    end

    assert_raise ExUnit.AssertionError, ~r/pending debugger modules are active/, fn ->
      assert_debugger_active_scope!(
        %{ctx.graph | active_modules: MapSet.put(ctx.graph.active_modules, :dbg_ieval)},
        @debugger_active_modules,
        evidence.lane.name
      )
    end

    new_name_export = {:dbg_istk, :unreviewed_family_entry, 0}

    graph_with_new_name_export = %{
      ctx.graph
      | full_exported: MapSet.put(ctx.graph.full_exported, new_name_export)
    }

    assert_raise ExUnit.AssertionError, ~r/independent installed universe/, fn ->
      assert_debugger_function_inventory!(
        debugger_family_universe(graph_with_new_name_export, tier, @exclusions),
        Enum.map(lane_record.family_function_sources, &elem(&1, 0)),
        Enum.map(lane_record.family_function_audit, & &1.mfa),
        @debugger_expected_family_mfas,
        evidence.lane.name
      )
    end

    wrong_lane_name = if evidence.lane.name == "core", do: "floor", else: "core"
    wrong_lane = %{evidence | lane: Map.put(evidence.lane, :name, wrong_lane_name)}

    assert_raise ExUnit.AssertionError, ~r/does not match inspected graph lane/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, wrong_lane, @exclusions)
    end

    missing_source_path = "#{evidence.lane.name}/debugger/src/dbg_idb.erl"

    missing_source_evidence = %{
      evidence
      | manifest:
          Map.update!(evidence.manifest, "files", fn files ->
            Enum.reject(files, &(&1["path"] == missing_source_path))
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/missing exact-lane source record/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, missing_source_evidence, @exclusions)
    end

    absent_source_evidence = %{
      evidence
      | manifest:
          Map.update!(evidence.manifest, "files", fn files ->
            Enum.map(files, fn
              %{"path" => ^missing_source_path} = row -> Map.put(row, "status", "absent")
              row -> row
            end)
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/claims absence or non-present status/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, absent_source_evidence, @exclusions)
    end

    corrupt_evidence =
      SweepEvidence.load_archive!(
        Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__),
        SweepEvidence.archive_sha256()
      )
      |> Map.merge(%{lane: evidence.lane, lock_sha256: evidence.lock_sha256})

    corrupt_evidence =
      Map.put(
        corrupt_evidence,
        :installed,
        %{"debugger" => Path.join(corrupt_evidence.archive_root, "missing-installed")}
      )

    on_exit(fn -> File.rm_rf!(corrupt_evidence.archive_root) end)

    File.write!(
      Path.join(
        corrupt_evidence.archive_root,
        "#{evidence.lane.name}/debugger/src/dbg_idb.erl"
      ),
      "corrupt source bytes"
    )

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, corrupt_evidence, @exclusions)
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        List.delete_at(records, record_index),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        records,
        %{
          ctx.graph
          | full_exported: MapSet.delete(ctx.graph.full_exported, @debugger_selected_file_mfa)
        },
        tier,
        evidence,
        @exclusions
      )
    end

    filter_mfa = {:dbg_wx_interpret, :filter_files, 2}

    graph_without_filter_root = %{
      ctx.graph
      | full_reached: MapSet.delete(ctx.graph.full_reached, filter_mfa),
        full_edges:
          Enum.reject(ctx.graph.full_edges, fn {caller, callee} ->
            caller == filter_mfa or callee == filter_mfa
          end)
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(records, graph_without_filter_root, tier, evidence, @exclusions)
    end

    unreviewed_export = {:dbg_wx_interpret, :unreviewed_selected_file_front, 0}

    graph_with_unreviewed_export = %{
      ctx.graph
      | full_exported: MapSet.put(ctx.graph.full_exported, unreviewed_export)
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(records, graph_with_unreviewed_export, tier, evidence, @exclusions)
    end

    branchless_record = %{lane_record | branch_citations: %{}}

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        List.replace_at(records, record_index, branchless_record),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    missing_function_source = %{
      lane_record
      | family_function_sources: List.delete_at(lane_record.family_function_sources, 0)
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        List.replace_at(records, record_index, missing_function_source),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      SweepEvidence.resolve!(evidence, "debugger/src/dbg_wx_interpret.erl:999999")
    end

    omitted_tier = Enum.reject(tier, &(&1 == @debugger_selected_file_mfa))

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(records, ctx.graph, omitted_tier, evidence, @exclusions)
    end

    omitted_decoder_tier = Enum.reject(tier, &(&1 == {:dbg_istk, :from_external, 1}))

    assert_raise ExUnit.AssertionError,
                 ~r/exported stack decoder must retain its exact MFA tier/,
                 fn ->
                   assert_debugger_audit!(
                     records,
                     ctx.graph,
                     omitted_decoder_tier,
                     evidence,
                     @exclusions
                   )
                 end

    missing_seed_disposition = %{
      lane_record
      | seed_dispositions: List.delete_at(lane_record.seed_dispositions, 0)
    }

    assert_raise ExUnit.AssertionError, ~r/omitted or invented a source-only debugger seed/, fn ->
      assert_debugger_audit!(
        List.replace_at(records, record_index, missing_seed_disposition),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    redundant_retention =
      {{:mfa, @debugger_selected_file_mfa}, :private_front,
       [hd(lane_record.citations) |> elem(0)]}

    assert_raise ExUnit.AssertionError, ~r/changed debugger exclusion match set/, fn ->
      assert_debugger_audit!(
        records,
        ctx.graph,
        tier,
        evidence,
        @exclusions ++ [redundant_retention]
      )
    end
  end

  test "escript debugger code is a private path behind its already tiered public front", ctx do
    graph = ctx.graph
    debug_mfa = @escript_debug_mfa
    parse_and_run = {:escript, :parse_and_run, 3}
    start = {:escript, :start, 1}

    assert MapSet.member?(graph.full_reached, debug_mfa)
    refute MapSet.member?(graph.historical_reached, debug_mfa)
    refute MapSet.member?(graph.full_exported, debug_mfa)
    refute MapSet.member?(graph.full_exported, {:escript, :hidden_apply, 4})
    assert MapSet.member?(graph.full_exported, start)
    assert {:escript, :start, :_} in BannedCalls.banned_mfas()
    assert MapSet.member?(graph.historical_reached, start)

    assert(
      disposition(
        debug_mfa,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        @exclusions
      ) == :private_front
    )

    debug_callers =
      for {caller, {:escript, :debug}} <- graph.full_edges, into: MapSet.new(), do: caller

    parse_callers =
      for {caller, {:escript, :parse_and_run}} <- graph.full_edges,
          into: MapSet.new(),
          do: caller

    assert debug_callers == MapSet.new([parse_and_run])
    assert parse_callers == MapSet.new([start])

    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    expected_citations =
      Map.fetch!(@escript_debug_source_assertions_by_lane, evidence.lane.name)

    record_citations = @escript_debug_exclusion |> elem(2) |> MapSet.new()

    expected_record_citations =
      @escript_debug_source_assertions_by_lane
      |> Map.values()
      |> List.flatten()
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    assert record_citations == expected_record_citations

    for {citation, expected} <- expected_citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
    end

    without_private_front = List.delete(@exclusions, @escript_debug_exclusion)

    assert_raise RuntimeError, ~r/escript, :debug, 3/, fn ->
      assert_no_new_active_failures!(
        graph.full_reached,
        graph.historical_reached,
        graph.historical_active_modules,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        graph.lane.name,
        without_private_front
      )
    end
  end

  test "EX-159 maps its original caller-file functions to exact-lane atom evidence", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &(&1.original_id == "EX-159"))

    assert_creator_audit!(
      records,
      ctx.graph,
      BannedCalls.banned_mfas(),
      evidence
    )

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        Enum.reject(records, &(&1.original_id == "EX-159" and &1.lane == "core")),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    lane_record = Enum.find(records, &(&1.lane == evidence.lane.name))
    without_consult = %{lane_record | matched_mfas: [{:file, :path_consult, 2}]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.lane == lane_record.lane)),
          without_consult
        ),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    graph_without_consult = %{
      ctx.graph
      | exported: MapSet.delete(ctx.graph.exported, {:file, :consult, 1})
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        records,
        graph_without_consult,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    false_safe =
      {{:file, [:consult]}, :pure_data, ["kernel/src/file.erl:2272"]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        records,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions ++ [false_safe]
      )
    end

    malformed_source =
      update_in(lane_record.citations, fn [{_citation, expected} | rest] ->
        [{"kernel/src/file.erl:9999999", expected} | rest]
      end)

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      assert_creator_audit!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.lane == lane_record.lane)),
          malformed_source
        ),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end
  end

  test "EX-089 maps Yecc caller fronts and formatter semantics to exact-lane evidence", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &(&1.original_id == "EX-089"))
    tier = BannedCalls.banned_mfas()

    assert_yecc_audit!(records, ctx.graph, tier, evidence)

    lane_record = Enum.find(records, &(&1.lane == evidence.lane.name))
    lane_index = Enum.find_index(records, &(&1.lane == lane_record.lane))

    wrong_lane = %{lane_record | lane: "latest"}

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, wrong_lane),
        ctx.graph,
        tier,
        evidence
      )
    end

    empty_citations = %{lane_record | citations: []}

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, empty_citations),
        ctx.graph,
        tier,
        evidence
      )
    end

    two_tuple = %{
      lane_record
      | matched_mfas: List.replace_at(lane_record.matched_mfas, 1, {:yecc, :file})
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, two_tuple),
        ctx.graph,
        tier,
        evidence
      )
    end

    omitted_mfa = %{
      lane_record
      | matched_mfas: List.delete(lane_record.matched_mfas, {:yecc, :format_error, 1})
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, omitted_mfa),
        ctx.graph,
        tier,
        evidence
      )
    end

    redundant_retention = {{:yecc, [:format_error]}, :by_name}

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(records, ctx.graph, tier, evidence, @exclusions ++ [redundant_retention])
    end
  end

  test "Logger and ExUnit format fronts have exact-lane records and necessary arity dispositions",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &String.starts_with?(&1.original_id, "NEW-"))
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()

    assert_logger_audit!(records, ctx.graph, tier, evidence)

    omitted_spec_mfa = {Logger.Formatter, :new, 1}
    specs_without_front = Enum.reject(@logger_family_specs, &(&1.mfa == omitted_spec_mfa))
    records_without_front = Enum.reject(records, &(&1.matched_mfas == [omitted_spec_mfa]))

    assert covered?(omitted_spec_mfa, tier, names)
    assert length(records) - length(records_without_front) == length(@creator_expected_lanes)

    assert_raise ExUnit.AssertionError, ~r/spec MFA set differs from pinned lane universe/, fn ->
      assert_logger_audit!(
        records_without_front,
        ctx.graph,
        tier,
        evidence,
        @exclusions,
        specs_without_front
      )
    end

    lane_records = Enum.filter(records, &(&1.lane == evidence.lane.name))
    safe_spec = Enum.find(@logger_family_specs, &(&1.disposition == :exact_exclusion))
    safe_record = Enum.find(lane_records, &(&1.matched_mfas == [safe_spec.mfa]))

    assert_raise ExUnit.AssertionError, fn ->
      assert_logger_audit!(
        Enum.reject(records, &(&1.original_id == safe_record.original_id)),
        ctx.graph,
        tier,
        evidence
      )
    end

    lane_index = Enum.find_index(records, &(&1.original_id == safe_record.original_id))
    wrong_lane = %{safe_record | lane: "wrong-lane"}
    omitted_mfa = %{safe_record | matched_mfas: []}
    two_tuple = %{safe_record | matched_mfas: [Tuple.delete_at(safe_spec.mfa, 2)]}
    empty_citations = %{safe_record | citations: []}

    for malformed <- [wrong_lane, omitted_mfa, two_tuple, empty_citations] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_logger_audit!(
          List.replace_at(records, lane_index, malformed),
          ctx.graph,
          tier,
          evidence
        )
      end
    end

    malformed_source = %{
      safe_record
      | citations: [{"logger/lib/logger/formatter.ex:999999", "@default_pattern"}]
    }

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      assert_logger_audit!(
        List.replace_at(records, lane_index, malformed_source),
        ctx.graph,
        tier,
        evidence
      )
    end

    missing_tier = Enum.reject(tier, &(&1 == {Logger.Formatter, :new, 1}))

    assert_raise ExUnit.AssertionError, fn ->
      assert_logger_audit!(records, ctx.graph, missing_tier, evidence)
    end

    redundant_retention =
      {{:mfa, {Logger.Formatter, :new, 1}}, :fixed_default,
       ["logger/lib/logger/formatter.ex:170"]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_logger_audit!(
        records,
        ctx.graph,
        tier,
        evidence,
        @exclusions ++ [redundant_retention]
      )
    end

    for spec <- @logger_family_specs, spec.disposition == :exact_exclusion do
      {module, function, _arity} = spec.mfa
      mfa = spec.mfa
      entry = Enum.find(@exclusions, &match?({{:mfa, ^mfa}, _, _}, &1))

      assert entry != nil
      assert exact_mfa_exclusion_reason(mfa, @exclusions) == spec.reason
      assert exclusion_reason(module, function, @exclusions) == nil
      assert mfa in undisposed(ctx.graph, tier, names, List.delete(@exclusions, entry))
    end
  end

  test "Logger and ExUnit audit rejects newly named reached and explicitly disposed exports",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &String.starts_with?(&1.original_id, "NEW-"))
    tier = BannedCalls.banned_mfas()
    new_front = {Logger.Formatter, :public_format_front, 1}
    graph_with_new_front = add_exported_sink_caller(ctx.graph, new_front)

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(records, graph_with_new_front, tier, evidence)
    end

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(records, graph_with_new_front, tier ++ [new_front], evidence)
    end

    explicit_exclusion =
      {{:mfa, new_front}, :pure_data, ["logger/lib/logger/formatter.ex:170"]}

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(
        records,
        graph_with_new_front,
        tier,
        evidence,
        @exclusions ++ [explicit_exclusion]
      )
    end

    graph_with_unreached_export = %{
      ctx.graph
      | exported: MapSet.put(ctx.graph.exported, new_front)
    }

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(records, graph_with_unreached_export, tier ++ [new_front], evidence)
    end

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(
        records,
        graph_with_unreached_export,
        tier,
        evidence,
        @exclusions ++ [explicit_exclusion]
      )
    end
  end

  @tag :tmp_dir
  test "source citations reject missing, escaped, unreadable and altered evidence", %{
    tmp_dir: dir
  } do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    evidence = %{evidence | installed: Map.put(evidence.installed, "kernel", dir)}
    citation = "kernel/src/file.erl:1"
    assert SweepEvidence.resolve!(evidence, citation).origin == :archive

    for {invalid, reason} <- [
          {"kernel/src/../file.erl:1", :citation_path},
          {"/kernel/src/file.erl:1", :citation_format},
          {"kernel/src/file.erl:0", :citation_format},
          {"kernel/src/file.erl:9999999", :source_line},
          {"wrong/src/file.erl:1", :unknown_app},
          {"kernel/src/not-installed.erl:1", :missing_source}
        ] do
      error =
        assert_raise SweepEvidence.Error, fn -> SweepEvidence.resolve!(evidence, invalid) end

      assert error.reason == reason
    end

    missing_manifest =
      Map.update!(evidence.manifest, "files", fn rows ->
        Enum.reject(rows, &(&1["source_path"] == "kernel/src/file.erl"))
      end)

    assert_raise SweepEvidence.Error, ~r/missing_source/, fn ->
      SweepEvidence.resolve!(%{evidence | manifest: missing_manifest}, citation)
    end

    source = Path.join([dir, "src", "file.erl"])
    File.mkdir_p!(Path.dirname(source))
    resolved = SweepEvidence.resolve!(evidence, citation)
    File.cp!(resolved.path, source)
    assert SweepEvidence.resolve!(evidence, citation).origin == :installed
    File.chmod!(source, 0o000)

    assert_raise SweepEvidence.Error, ~r/unreadable_source/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end

    File.chmod!(source, 0o644)
    File.write!(source, "different app/source bytes\n")

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end

    debugger_root = Path.join(dir, "debugger")

    debugger_evidence = %{
      evidence
      | installed: Map.put(evidence.installed, "debugger", debugger_root)
    }

    debugger_citation = "debugger/src/dbg_wx_interpret.erl:44"
    debugger_archived = SweepEvidence.resolve!(debugger_evidence, debugger_citation)
    assert debugger_archived.origin == :archive

    debugger_source = Path.join(debugger_root, "src/dbg_wx_interpret.erl")
    File.mkdir_p!(Path.dirname(debugger_source))
    File.cp!(debugger_archived.path, debugger_source)
    assert SweepEvidence.resolve!(debugger_evidence, debugger_citation).origin == :installed

    File.write!(debugger_source, <<>>)

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(debugger_evidence, debugger_citation)
    end

    File.write!(debugger_source, "different exact-lane source bytes\n")

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(debugger_evidence, debugger_citation)
    end

    File.rm!(debugger_source)
    empty_archive = Path.join(dir, "empty-source-archive")
    File.mkdir_p!(empty_archive)
    debugger_missing = %{debugger_evidence | archive_root: empty_archive}

    assert_raise SweepEvidence.Error, ~r/unreadable_source/, fn ->
      SweepEvidence.resolve!(debugger_missing, debugger_citation)
    end

    File.rm!(source)
    File.ln_s!(resolved.path, source)

    assert_raise SweepEvidence.Error, ~r/source_escape/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end

    File.rm!(source)
    File.rm!(resolved.path)

    assert_raise SweepEvidence.Error, ~r/unreadable_source/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end
  end

  @tag :tmp_dir
  test "source archives reject traversal, duplicate paths, links and corrupt bytes before extraction",
       %{tmp_dir: dir} do
    original = Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
    {:ok, files} = :erl_tar.extract(String.to_charlist(original), [:compressed, :memory])

    for {name, entries, reason} <- [
          {"traversal", [{~c"../escape", "bad"} | files], :archive_path},
          {"duplicate", [hd(files) | files], :archive_duplicate},
          {"corrupt",
           List.keyreplace(
             files,
             ~c"core/kernel/src/file.erl",
             0,
             {~c"core/kernel/src/file.erl", "corrupted"}
           ), :source_digest}
        ] do
      path = Path.join(dir, name <> ".tar.gz")
      :ok = :erl_tar.create(String.to_charlist(path), entries, [:compressed])
      sha = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)
      error = assert_raise SweepEvidence.Error, fn -> SweepEvidence.load_archive!(path, sha) end
      assert error.reason == reason
    end

    for {name, transform, reason} <- [
          {"version", &put_in(&1["refs"]["core"]["otp"], ["29.1.1", "wrong"]), :source_identity},
          {"root",
           fn manifest ->
             Map.update!(manifest, "files", fn rows ->
               Enum.map(rows, fn row ->
                 if row["path"] == "core/kernel/src/file.erl",
                   do: Map.put(row, "lane", "floor"),
                   else: row
               end)
             end)
           end, :source_root}
        ] do
      entries =
        Enum.map(files, fn
          {~c"manifest.json", data} ->
            {~c"manifest.json", data |> JSON.decode!() |> transform.() |> JSON.encode!()}

          entry ->
            entry
        end)

      path = Path.join(dir, name <> ".tar.gz")
      :ok = :erl_tar.create(String.to_charlist(path), entries, [:compressed])
      sha = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)
      error = assert_raise SweepEvidence.Error, fn -> SweepEvidence.load_archive!(path, sha) end
      assert error.reason == reason
    end

    link = Path.join(dir, "link")
    File.ln_s!(original, link)
    path = Path.join(dir, "symlink.tar.gz")

    :ok =
      :erl_tar.create(String.to_charlist(path), [{~c"link", String.to_charlist(link)}], [
        :compressed
      ])

    sha = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)

    assert_raise SweepEvidence.Error, ~r/archive_link_or_type/, fn ->
      SweepEvidence.load_archive!(path, sha)
    end

    assert_raise SweepEvidence.Error, ~r/archive_digest/, fn ->
      SweepEvidence.load_archive!(original, "wrong")
    end
  end

  test "every in-scope OTP app, Elixir app and prod-closure dependency has an ebin", ctx do
    graph = ctx.graph

    assert graph.missing_apps == [], "missing ebin: #{inspect(graph.missing_apps)}"
    assert Enum.all?(@floor_roots, &(&1 in graph.roots)), "derived roots: #{inspect(graph.roots)}"
    assert Enum.all?(~w(phoenix phoenix_live_view plug), &(&1 in graph.closure))
  end

  test "every in-scope beam carries debug info", ctx do
    assert ctx.graph.no_debug == [], "beams without debug info: #{inspect(ctx.graph.no_debug)}"
  end

  test "every function named like a wholly banned module is covered or excluded with a cited reason",
       ctx do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()

    whole_modules =
      for {module, :_, :_} <- tier, do: module

    named =
      ctx.graph.exported
      |> Enum.filter(&banned_module_named?(&1, whole_modules))
      |> Enum.reject(fn {_module, function, _arity} ->
        function in [:__info__, :module_info] or
          String.starts_with?(Atom.to_string(function), "MACRO-")
      end)

    uncovered = Enum.reject(named, &covered?(&1, tier, names))
    matched = matched_uncovered(uncovered, @call_name_exclusions)
    undisposed = Enum.reject(uncovered, &MapSet.member?(matched, &1))

    assert {Regex, :compile, 1} in named
    assert {Logger.Formatter, :compile, 1} in named

    logger_without_entry = Enum.reject(tier, &(&1 == {Logger.Formatter, :compile, :_}))

    assert {Logger.Formatter, :compile, 1} in Enum.reject(
             named,
             &covered?(&1, logger_without_entry, names)
           )

    unmatched_exclusions =
      Enum.reject(@call_name_exclusions, fn entry ->
        matched_uncovered(uncovered, [entry]) |> MapSet.size() > 0 or
          lane_specific_call_name?(entry, named)
      end)

    assert undisposed == [],
           "undisposed banned-module-named functions: #{inspect(Enum.sort(undisposed))}"

    assert unmatched_exclusions == [],
           "call-name exclusions matching no uncovered function: #{inspect(unmatched_exclusions)}"
  end

  test "every barrier-module and sink-delegate export is covered or excluded with a cited reason",
       ctx do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    boundary = boundary_set(ctx.graph, tier, names)
    delegates = delegate_modules(ctx.graph)
    front = front_of_barrier(ctx.graph, tier, names)
    uncovered = Enum.reject(boundary, &covered?(&1, tier, names))
    matched = matched_boundary(uncovered, @boundary_exclusions)
    undisposed = Enum.reject(uncovered, &MapSet.member?(matched, &1))

    assert :erts_internal in delegates,
           "derived sink delegates: #{inspect(Enum.sort(delegates))}"

    assert {:code, :get_path, 0} in front
    assert {:code, :add_patha, 1} in boundary

    assert {:erts_internal, :prepare_loading, 2} in boundary_undisposed(
             boundary,
             Enum.reject(tier, &(&1 == {:erts_internal, :prepare_loading, :_})),
             names
           )

    assert {:code_server, :call, 1} in boundary_undisposed(
             boundary,
             Enum.reject(tier, &(&1 == {:code_server, :_, :_})),
             names
           )

    assert {:code, :add_patha, 1} in boundary_undisposed(
             boundary,
             Enum.reject(tier, &(&1 == {:code, :add_patha, :_})),
             names
           )

    assert undisposed == [],
           "undisposed boundary exports:\n" <>
             Enum.map_join(Enum.sort(undisposed), "\n", &inspect/1) <>
             "\nundisposed sizes by module: #{inspect(Enum.frequencies_by(undisposed, &elem(&1, 0)))}" <>
             "\nderived delegate set: #{inspect(Enum.sort(delegates), limit: :infinity)}"

    module_exclusion = Enum.find(@boundary_exclusions, &is_atom(elem(&1, 0)))
    assert module_exclusion != nil, "expected at least one module-level boundary exclusion"
    {matcher, _reason, _citation} = module_exclusion
    matched_by_module = Enum.filter(uncovered, &boundary_match?(matcher, &1))
    without_module_exclusion = List.delete(@boundary_exclusions, module_exclusion)

    undisposed_without_module =
      Enum.reject(
        uncovered,
        &MapSet.member?(matched_boundary(uncovered, without_module_exclusion), &1)
      )

    assert matched_by_module != []
    assert Enum.all?(matched_by_module, &(&1 in undisposed_without_module))

    unmatched_exclusions =
      Enum.reject(@boundary_exclusions, fn entry ->
        Enum.any?(uncovered, &boundary_match?(elem(entry, 0), &1)) or
          lane_specific_boundary?(entry, boundary)
      end)

    assert unmatched_exclusions == [],
           "boundary exclusions matching no uncovered export: #{inspect(unmatched_exclusions)}"
  end

  test "removing a tier entry leaves its front door undisposed", ctx do
    tier = Enum.reject(BannedCalls.banned_mfas(), &(&1 == {Mix.Tasks.Run, :_, :_}))
    undisposed = undisposed(ctx.graph, tier, BannedCalls.banned_names())

    assert {Mix.Tasks.Run, :run, 1} in undisposed
  end

  test "every function the sweep reaches is covered by the tier or excluded with a reason", ctx do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    rows = dispositions(ctx.graph, tier, names)
    undisposed = for {mfa, nil} <- rows, do: mfa
    counts = counts(ctx.graph, rows, undisposed)

    assert undisposed == [],
           "#{counts}\n" <> Enum.map_join(undisposed, "\n", &witness_line(ctx.graph, &1))
  end

  test "every exclusion names a known reason and every citation is an app-relative source line" do
    invalid =
      Enum.reject(
        @exclusions ++ @call_name_exclusions ++ @boundary_exclusions,
        &valid_exclusion?/1
      )

    assert invalid == [], "invalid exclusion records: #{inspect(invalid)}"
  end

  defp build_graph do
    evidence = SweepEvidence.source_roots!()

    try do
      build_graph(evidence)
    after
      File.rm_rf!(evidence.archive_root)
    end
  end

  defp build_graph(evidence) do
    graph_started = System.monotonic_time()
    Mix.ensure_application!(:tools)
    otp_lib = :code.lib_dir() |> to_string()
    discovery_started = System.monotonic_time()
    discovered = InstalledOtp.discover!(otp_lib, lane: evidence.lane.name)
    :ok = InstalledOtp.assert_discovery_complete!(otp_lib, discovered, lane: evidence.lane.name)
    discovery_ms = elapsed_ms(discovery_started)

    inspection_started = System.monotonic_time()
    inspected = InstalledOtp.inspect!(discovered, lane: evidence.lane.name)
    inspection_ms = elapsed_ms(inspection_started)

    source_scan_started = System.monotonic_time()

    sources =
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: evidence.lane.name,
        required_modules:
          Enum.uniq(~w(file io erl_scan yecc) ++ DebuggerSettings.required_source_modules())
      )

    source_scan_ms = elapsed_ms(source_scan_started)
    otp_apps = discovered
    elixir_dirs = for app <- @elixir_apps, do: app_dir(app)
    roots = dependency_roots()
    closure = dependency_closure(roots)
    dep_dirs = for app <- closure, do: Path.join([Mix.Project.build_path(), "lib", app, "ebin"])

    extra_apps =
      Enum.map(@elixir_apps, &%{app: Atom.to_string(&1), ebin: app_dir(&1)}) ++
        Enum.map(
          closure,
          &%{app: &1, ebin: Path.join([Mix.Project.build_path(), "lib", &1, "ebin"])}
        )

    dirs = Enum.map(otp_apps, & &1.ebin) ++ elixir_dirs ++ dep_dirs
    missing_apps = missing_apps(otp_lib, elixir_dirs, dep_dirs)
    otp_active_names = Enum.map(@historical_active_otp_apps, &Atom.to_string/1) |> MapSet.new()
    historical_otp_apps = Enum.filter(otp_apps, &MapSet.member?(otp_active_names, &1.app))
    pending_apps = Enum.reject(otp_apps, &MapSet.member?(otp_active_names, &1.app))

    historical_otp_dirs = Enum.map(historical_otp_apps, & &1.ebin)
    historical_app_names = MapSet.new(historical_otp_apps, & &1.app)
    {historical_otp_edges, no_debug_otp} = form_edges(historical_otp_dirs)
    {other_form_edges, no_debug_other} = form_edges(elixir_dirs ++ dep_dirs)
    {other_xref_edges, _no_debug_other_xref} = xref_form_edges(elixir_dirs ++ dep_dirs)
    otp_form_edges = Enum.flat_map(inspected, & &1.edges)
    otp_xref_edges = Enum.flat_map(inspected, & &1.xref_edges)

    expected_historical_edges =
      Enum.flat_map(inspected, fn inspection ->
        if MapSet.member?(historical_app_names, inspection.app),
          do: inspection.xref_edges,
          else: []
      end) ++ other_xref_edges

    expected_full_edges = otp_xref_edges ++ other_xref_edges
    historical_graph_dirs = historical_otp_dirs ++ elixir_dirs ++ dep_dirs
    full_graph_dirs = Enum.map(otp_apps, & &1.ebin) ++ elixir_dirs ++ dep_dirs

    expected_historical_exports =
      InstalledOtp.export_inventory!(historical_graph_dirs,
        lane: evidence.lane.name,
        edges: expected_historical_edges
      )

    expected_full_exports =
      InstalledOtp.export_inventory!(full_graph_dirs,
        lane: evidence.lane.name,
        edges: expected_full_edges
      )

    xref_started = System.monotonic_time()

    xref_graph =
      checked_xref_graph(
        historical_otp_apps ++ extra_apps,
        pending_apps,
        evidence.lane.name,
        expected_historical_edges,
        expected_historical_exports,
        expected_full_edges,
        expected_full_exports
      )

    xref_ms = elapsed_ms(xref_started)

    InstalledOtp.assert_parity!(
      discovered,
      inspected,
      Enum.filter(xref_graph.ingested, &(&1.app in Enum.map(otp_apps, fn app -> app.app end))),
      evidence.lane.name
    )

    historical_xref_edges =
      for {caller, {m, f, _}} <- xref_graph.historical_edges, do: {caller, {m, f}}

    full_xref_edges = for {caller, {m, f, _}} <- xref_graph.full_edges, do: {caller, {m, f}}
    historical_edges = historical_otp_edges ++ other_form_edges ++ historical_xref_edges
    full_edges = otp_form_edges ++ other_form_edges ++ full_xref_edges
    full_reverse = reverse(full_edges)
    full_forward = forward(full_edges)
    historical_modules = MapSet.new(xref_graph.historical_ingested, & &1.module_atom)
    historical_exported = MapSet.new(xref_graph.historical_exports)
    full_exported = MapSet.new(xref_graph.full_exports)
    module_app = Map.new(xref_graph.ingested, &{&1.module_atom, &1.app})
    no_debug = no_debug_otp ++ no_debug_other

    historical_reached_graph = %{
      reverse: reverse(historical_edges),
      exported: historical_exported
    }

    full_reached_graph = %{reverse: full_reverse, exported: full_exported}
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    {historical_reached, _historical_parent} = reach(historical_reached_graph, tier, names)
    {full_reached, full_parent} = reach(full_reached_graph, tier, names)

    settings_audit_graph = %{
      lane: evidence.lane,
      inspected: inspected,
      full_edges: full_edges,
      full_exported: full_exported,
      full_reached: full_reached
    }

    :ok =
      DebuggerSettings.assert_audit!(
        DebuggerSettings.records(evidence.lane.name),
        settings_audit_graph,
        tier,
        evidence,
        @exclusions
      )

    active_modules =
      Enum.reduce(
        @debugger_active_modules,
        MapSet.put(historical_modules, :ct_make),
        &MapSet.put(&2, &1)
      )
      |> MapSet.put(:dbg_wx_settings)

    active_ingested =
      Enum.filter(xref_graph.ingested, &MapSet.member?(active_modules, &1.module_atom))

    active_edges =
      Enum.filter(full_edges, fn {{module, _, _}, _} ->
        MapSet.member?(active_modules, module)
      end)

    active_exported =
      Enum.filter(full_exported, fn {module, _, _} ->
        MapSet.member?(active_modules, module)
      end)

    active_reverse = reverse(active_edges)
    active_forward = forward(active_edges)
    active_exported = MapSet.new(active_exported)
    active_reached_graph = %{reverse: active_reverse, exported: active_exported}
    {active_reached, _active_parent} = reach(active_reached_graph, tier, names)

    assert_active_sets_preserved!(
      %{reached: historical_reached, exported: historical_exported, edges: historical_edges},
      %{reached: active_reached, exported: active_exported, edges: active_edges},
      %{reached: full_reached, exported: full_exported, edges: full_edges},
      evidence.lane.name
    )

    active_expansion_failures =
      assert_no_new_active_failures!(
        full_reached,
        historical_reached,
        historical_modules,
        tier,
        names,
        evidence.lane.name
      )

    active_membership =
      active_membership_records(
        xref_graph.historical_ingested,
        active_ingested,
        active_exported,
        active_edges,
        module_app
      )

    export_records = mfa_records("export", full_exported, module_app)
    reached_records = mfa_records("reached", full_reached, module_app)

    boundary_graph = %{
      edges: full_edges,
      exported: full_exported,
      forward: full_forward,
      reverse: full_reverse
    }

    boundary_mfas = boundary_set(boundary_graph, tier, names)
    boundary_records = boundary_inventory_records(boundary_mfas, module_app)

    sources_by_module =
      Map.new(sources, fn source ->
        {source.app, Map.new(source.beams, &{&1.module, &1})}
      end)

    pending_modules =
      for inspection <- inspected,
          not MapSet.member?(active_modules, inspection.module_atom),
          do: inspection

    pending_mfas = MapSet.difference(full_reached, active_reached)

    pending_records =
      pending_inventory_records(
        pending_apps,
        pending_modules,
        pending_mfas,
        full_parent,
        full_edges,
        module_app,
        sources_by_module
      )

    discovery_count = length(discovered)
    beam_count = length(inspected)
    function_count = Enum.sum(Enum.map(inspected, & &1.function_count))
    function_bytes = Enum.sum(Enum.map(inspected, & &1.function_bytes))
    beam_bytes = Enum.sum(Enum.map(inspected, fn beam -> File.stat!(beam.path).size end))
    source_file_count = Enum.sum(Enum.map(sources, & &1.source_file_count))
    source_bytes = Enum.sum(Enum.map(sources, & &1.source_bytes))
    mapped_beams = Enum.sum(Enum.map(sources, & &1.mapped_beams))
    missing_source_beams = Enum.sum(Enum.map(sources, & &1.missing_source_beams))
    unavailable_source_beams = Enum.sum(Enum.map(sources, & &1.unavailable_source_beams))

    metrics = %{
      "app_count" => discovery_count,
      "beam_count" => beam_count,
      "function_count" => function_count,
      "function_bytes" => function_bytes,
      "beam_bytes" => beam_bytes,
      "source_file_count" => source_file_count,
      "source_bytes" => source_bytes,
      "mapped_beams" => mapped_beams,
      "missing_source_beams" => missing_source_beams,
      "unavailable_source_beams" => unavailable_source_beams,
      "exported_matches" => MapSet.size(full_exported),
      "reached_matches" => MapSet.size(full_reached),
      "boundary_matches" => length(boundary_records),
      "active_app_count" => Enum.count(active_membership, &(&1["kind"] == "active_app")),
      "active_module_count" => Enum.count(active_membership, &(&1["kind"] == "active_module")),
      "active_export_count" => Enum.count(active_membership, &(&1["kind"] == "active_export")),
      "active_edge_count" => Enum.count(active_membership, &(&1["kind"] == "active_edge")),
      "pending_app_count" => Enum.count(pending_records, &(&1["kind"] == "pending_app")),
      "pending_module_count" => Enum.count(pending_records, &(&1["kind"] == "pending_module")),
      "pending_mfa_count" => Enum.count(pending_records, &(&1["kind"] == "pending_mfa")),
      "discovery_ms" => discovery_ms,
      "inspection_ms" => inspection_ms,
      "source_scan_ms" => source_scan_ms,
      "xref_ms" => xref_ms,
      "graph_ms" => elapsed_ms(graph_started),
      "pending_owner" => "01.1.1.3"
    }

    receipt = %{
      lane: evidence.lane,
      lock_sha256: evidence.lock_sha256,
      discovered: discovered,
      inspected: inspected,
      sources: sources,
      ingested:
        Enum.filter(xref_graph.ingested, &(&1.app in Enum.map(otp_apps, fn app -> app.app end))),
      active_membership: active_membership,
      export_records: export_records,
      reached_records: reached_records,
      boundary_records: boundary_records,
      pending_records: pending_records,
      metrics: metrics
    }

    receipt_lines = InstalledOtp.receipt_lines(receipt)
    Enum.each(receipt_lines, &IO.puts/1)

    pending_apps = Enum.reject(discovered, &MapSet.member?(otp_active_names, &1.app))

    %{
      dirs: dirs,
      edges: active_edges,
      exported: active_exported,
      reverse: active_reverse,
      forward: active_forward,
      no_debug: no_debug,
      missing_apps: missing_apps,
      roots: roots,
      closure: closure,
      out_of_scope: Enum.map(pending_apps, & &1.app),
      historical_active_otp_apps: MapSet.to_list(otp_active_names),
      historical_active_modules: historical_modules,
      historical_active_edges: historical_edges,
      historical_active_exported: historical_exported,
      active_modules: active_modules,
      active_edges: active_edges,
      active_exported: active_exported,
      active_membership: active_membership,
      active_reached: active_reached,
      discovered: discovered,
      inspected: inspected,
      ingested: receipt.ingested,
      full_edges: full_edges,
      full_exported: full_exported,
      full_reverse: full_reverse,
      full_forward: full_forward,
      pending_apps: pending_apps,
      sources: sources,
      metrics: metrics,
      historical_reached: historical_reached,
      full_reached: full_reached,
      pending_mfas: pending_mfas,
      pending_modules: pending_modules,
      boundary_records: boundary_records,
      active_expansion_failures: active_expansion_failures,
      receipt_lines: receipt_lines,
      lane: evidence.lane,
      lock_sha256: evidence.lock_sha256
    }
  end

  defp assert_active_sets_preserved!(historical, active, full, lane) do
    preserved =
      MapSet.subset?(historical.reached, active.reached) and
        MapSet.subset?(active.reached, full.reached) and
        MapSet.subset?(historical.exported, active.exported) and
        MapSet.subset?(active.exported, full.exported) and
        MapSet.subset?(MapSet.new(historical.edges), MapSet.new(active.edges)) and
        MapSet.subset?(MapSet.new(active.edges), MapSet.new(full.edges))

    unless preserved,
      do:
        raise(
          "installed OTP active projection lost historical or full-scope coverage for #{lane}"
        )
  end

  defp assert_no_new_active_failures!(
         full_reached,
         historical_reached,
         historical_modules,
         tier,
         names,
         lane,
         exclusions \\ @exclusions
       ) do
    failures =
      full_reached
      |> MapSet.difference(historical_reached)
      |> Enum.filter(fn {module, _function, _arity} = mfa ->
        MapSet.member?(historical_modules, module) and
          disposition(mfa, tier, names, exclusions) == nil
      end)

    if failures != [] do
      raise "installed OTP expansion reached undisposed historical active MFAs on #{lane}: " <>
              Enum.map_join(failures, ", ", &inspect/1)
    end

    failures
  end

  defp elapsed_ms(started) do
    System.monotonic_time()
    |> Kernel.-(started)
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp active_membership_records(
         historical_ingested,
         active_ingested,
         active_exports,
         active_edges,
         module_app
       ) do
    apps =
      historical_ingested
      |> Enum.map(& &1.app)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(&%{"kind" => "active_app", "app" => &1})

    modules =
      active_ingested
      |> Enum.uniq_by(&{&1.app, &1.module})
      |> Enum.map(
        &%{"kind" => "active_module", "app" => &1.app, "module" => Atom.to_string(&1.module_atom)}
      )
      |> Enum.sort_by(&{&1["app"], &1["module"]})

    exports = mfa_records("active_export", active_exports, module_app)

    edges =
      active_edges
      |> Enum.uniq()
      |> Enum.map(fn {{module, function, arity}, {callee_module, callee_function}} ->
        %{
          "kind" => "active_edge",
          "app" => Map.fetch!(module_app, module),
          "module" => Atom.to_string(module),
          "function" => Atom.to_string(function),
          "arity" => arity,
          "callee_app" => Map.get(module_app, callee_module),
          "callee_module" => Atom.to_string(callee_module),
          "callee_function" => Atom.to_string(callee_function)
        }
      end)
      |> Enum.sort_by(
        &{&1["app"], &1["module"], &1["function"], &1["arity"], &1["callee_module"],
         &1["callee_function"]}
      )

    apps ++ modules ++ exports ++ edges
  end

  defp mfa_records(kind, mfas, module_app) do
    mfas
    |> Enum.sort_by(fn {module, function, arity} ->
      {Atom.to_string(module), Atom.to_string(function), arity}
    end)
    |> Enum.map(fn {module, function, arity} ->
      %{
        "kind" => kind,
        "app" => Map.fetch!(module_app, module),
        "module" => Atom.to_string(module),
        "function" => Atom.to_string(function),
        "arity" => arity
      }
    end)
  end

  defp boundary_inventory_records(mfas, module_app) do
    mfas
    |> Enum.sort_by(fn {module, function, arity} ->
      {Atom.to_string(module), Atom.to_string(function), arity}
    end)
    |> Enum.map(fn {module, function, arity} = mfa ->
      record =
        mfa_records("boundary", [mfa], module_app)
        |> hd()

      explicit_exclusion =
        Enum.any?(@boundary_exclusions, fn {matcher, _reason, _citations} ->
          boundary_match?(matcher, mfa)
        end)

      record
      |> Map.put("explicit_boundary_exclusion", explicit_exclusion)
      |> Map.put("function", Atom.to_string(function))
      |> Map.put("module", Atom.to_string(module))
      |> Map.put("arity", arity)
    end)
  end

  defp pending_inventory_records(
         pending_apps,
         pending_modules,
         pending_mfas,
         parent,
         edges,
         module_app,
         sources_by_module
       ) do
    app_records =
      pending_apps
      |> Enum.sort_by(& &1.app)
      |> Enum.map(fn app ->
        %{"kind" => "pending_app", "app" => app.app, "owner" => "01.1.1.3"}
      end)

    module_records =
      pending_modules
      |> Enum.sort_by(&{&1.app, &1.module})
      |> Enum.map(fn beam ->
        source = get_in(sources_by_module, [beam.app, beam.module])

        %{
          "kind" => "pending_module",
          "app" => beam.app,
          "module" => beam.module,
          "function_count" => beam.function_count,
          "function_bytes" => beam.function_bytes,
          "source_status" => source.status,
          "source" => source.source,
          "source_bytes" => source.bytes,
          "owner" => "01.1.1.3"
        }
      end)

    mfa_records =
      pending_mfas
      |> Enum.sort_by(fn {module, function, arity} ->
        {Atom.to_string(module), Atom.to_string(function), arity}
      end)
      |> Enum.map(fn {module, function, arity} ->
        caller_chain =
          parent
          |> caller_chain({module, function, arity}, edges)
          |> Enum.map(fn {caller_module, caller_function, caller_arity} ->
            "#{Atom.to_string(caller_module)}.#{Atom.to_string(caller_function)}/#{caller_arity}"
          end)

        %{
          "kind" => "pending_mfa",
          "app" => Map.fetch!(module_app, module),
          "module" => Atom.to_string(module),
          "function" => Atom.to_string(function),
          "arity" => arity,
          "caller_chain" => caller_chain,
          "owner" => "01.1.1.3"
        }
      end)

    app_records ++ module_records ++ mfa_records
  end

  defp caller_chain(parent, {module, function, _arity} = start_mfa, edges) do
    path = witness(parent, {module, function}, []) |> Enum.reverse()

    callers =
      path
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.with_index()
      |> Enum.map(fn
        {[{start_module, start_function}, _next], 0} ->
          {start_module, start_function, elem(start_mfa, 2)}

        {[caller_pair, next], _index} ->
          edges
          |> Enum.flat_map(fn
            {{caller_module, caller_function, caller_arity}, ^next}
            when {caller_module, caller_function} == caller_pair ->
              [{caller_module, caller_function, caller_arity}]

            _edge ->
              []
          end)
          |> Enum.uniq()
          |> Enum.sort_by(fn {caller_module, caller_function, caller_arity} ->
            {Atom.to_string(caller_module), Atom.to_string(caller_function), caller_arity}
          end)
          |> List.first()
          |> case do
            nil ->
              raise "installed OTP inventory caller-chain edge missing for #{inspect(caller_pair)} -> #{inspect(next)}"

            caller_mfa ->
              caller_mfa
          end
      end)

    if callers == [], do: [start_mfa], else: callers
  end

  defp checked_xref_graph(
         historical_apps,
         pending_apps,
         lane,
         expected_historical_edges,
         expected_historical_exports,
         expected_full_edges,
         expected_full_exports
       ) do
    start_xref!(lane)

    try do
      set_xref_defaults!(lane)
      historical_ingested = ingest_xref_apps!(historical_apps, lane)

      historical_edges =
        xref_query!(
          ~c"E",
          :historical_edges,
          lane,
          expected_historical_edges,
          &xref_edge_identity!/1
        )

      historical_exports =
        xref_query!(~c"X", :historical_exports, lane, expected_historical_exports)

      pending_ingested = ingest_xref_apps!(pending_apps, lane)

      full_edges =
        xref_query!(~c"E", :full_edges, lane, expected_full_edges, &xref_edge_identity!/1)

      full_exports = xref_query!(~c"X", :full_exports, lane, expected_full_exports)

      %{
        historical_ingested: historical_ingested,
        historical_edges: historical_edges,
        historical_exports: historical_exports,
        pending_ingested: pending_ingested,
        ingested: historical_ingested ++ pending_ingested,
        full_edges: full_edges,
        full_exports: full_exports
      }
    after
      stop_xref!(lane)
    end
  end

  defp ingest_xref_apps!(apps, lane) do
    Enum.flat_map(apps, &InstalledOtp.add_directory!(:tier_sweep, &1, lane: lane))
  end

  defp start_xref!(lane) do
    case :xref.start(:tier_sweep, xref_mode: :functions) do
      {:ok, _} -> :ok
      result -> raise "installed OTP inventory xref start failed for #{lane}: #{inspect(result)}"
    end
  end

  defp set_xref_defaults!(lane) do
    case :xref.set_default(:tier_sweep, warnings: false, verbose: false, builtins: true) do
      :ok ->
        :ok

      result ->
        raise "installed OTP inventory xref defaults failed for #{lane}: #{inspect(result)}"
    end
  end

  defp xref_query!(query, label, lane, expected_rows, normalize \\ &Function.identity/1) do
    InstalledOtp.assert_xref_query!(
      fn -> :xref.q(:tier_sweep, query) end,
      label,
      lane,
      expected_rows,
      normalize
    )
  end

  defp xref_edge_identity!({caller, {module, function}} = row)
       when is_tuple(caller) and is_atom(module) and is_atom(function),
       do: row

  defp xref_edge_identity!({caller, {module, function, _arity}})
       when is_tuple(caller) and is_atom(module) and is_atom(function),
       do: {caller, {module, function}}

  defp xref_edge_identity!(row),
    do: raise("unexpected installed OTP Xref edge row: #{inspect(row)}")

  defp stop_xref!(lane) do
    case :xref.stop(:tier_sweep) do
      :stopped -> :ok
      result -> raise "installed OTP inventory xref stop failed for #{lane}: #{inspect(result)}"
    end
  end

  defp missing_apps(otp_lib, elixir_dirs, dep_dirs) do
    otp_apps = Enum.map(@historical_active_otp_apps, &Atom.to_string/1)
    installed = otp_lib |> File.ls!() |> Enum.map(&String.replace(&1, ~r/-[0-9][0-9.]*$/, ""))

    Enum.reject(otp_apps, &(&1 in installed)) ++
      for(dir <- elixir_dirs ++ dep_dirs, not File.dir?(dir), do: dir)
  end

  defp app_dir(app) do
    app
    |> :code.lib_dir()
    |> to_string()
    |> Path.join("ebin")
  end

  defp dependency_roots do
    Mix.Project.config()[:deps]
    |> Enum.filter(fn dep ->
      opts = dependency_options(dep)

      opts[:runtime] != false and
        :prod in List.wrap(Keyword.get(opts, :only, :prod))
    end)
    |> Enum.map(&(elem(&1, 0) |> Atom.to_string()))
  end

  defp dependency_options({_app, opts}) when is_list(opts), do: opts
  defp dependency_options({_app, _version, opts}), do: opts
  defp dependency_options(_dep), do: []

  defp dependency_closure(roots), do: dependency_walk(roots, [], &hex_requirements/1)
  defp dependency_walk([], seen, _requirements), do: Enum.reverse(seen)

  defp dependency_walk([app | rest], seen, requirements) do
    if app in seen,
      do: dependency_walk(rest, seen, requirements),
      else: dependency_walk(rest ++ requirements.(app), [app | seen], requirements)
  end

  defp hex_requirements(app) do
    {:ok, metadata} =
      :file.consult(Path.join([Mix.Project.deps_path(), app, "hex_metadata.config"]))

    "requirements"
    |> :proplists.get_value(metadata, [])
    |> Enum.flat_map(fn
      {name, entry} -> required_app(Map.put_new(Map.new(entry), "app", name))
      entry when is_list(entry) -> required_app(Map.new(entry))
    end)
  end

  defp required_app(%{"optional" => false} = entry), do: [entry["app"] || entry["name"]]
  defp required_app(_entry), do: []

  defp form_edges(dirs) do
    beams =
      for dir <- dirs, file <- File.ls!(dir), String.ends_with?(file, ".beam"), do: {dir, file}

    Enum.reduce(beams, {[], []}, fn {dir, file}, acc -> collect_beam_edges(dir, file, acc) end)
  end

  defp xref_form_edges(dirs) do
    beams =
      for dir <- dirs, file <- File.ls!(dir), String.ends_with?(file, ".beam"), do: {dir, file}

    Enum.reduce(beams, {[], []}, fn {dir, file}, {edges, missing} ->
      case BeamWalker.xref_edges(Path.join(dir, file)) do
        {:ok, found} -> {found ++ edges, missing}
        {:error, _reason} -> {edges, [file | missing]}
      end
    end)
  end

  defp collect_beam_edges(dir, file, {edges, missing}) do
    path = String.to_charlist(Path.join(dir, file))

    case debug_edges(path) do
      {:ok, found} -> {found ++ edges, missing}
      :error -> {edges, [file | missing]}
    end
  end

  defp debug_edges(path) do
    with {:ok, {mod, [debug_info: {:debug_info_v1, backend, data}]}} when data != :none <-
           :beam_lib.chunks(path, [:debug_info]),
         {:ok, forms} <- backend.debug_info(:erlang_v1, mod, data, []) do
      found =
        Enum.flat_map(forms, fn
          {:function, _, name, arity, _} = form when {name, arity} != {:__info__, 1} ->
            function_edges(mod, form)

          _form ->
            []
        end)

      {:ok, found}
    else
      _result -> :error
    end
  end

  defp reverse(edges) do
    Enum.reduce(edges, %{}, fn {caller, callee}, acc ->
      if barrier?(callee), do: acc, else: Map.update(acc, callee, [caller], &[caller | &1])
    end)
  end

  defp add_exported_sink_caller(graph, {module, function, arity} = mfa) do
    sink = {:erlang, :load_module}

    %{
      graph
      | exported: MapSet.put(graph.exported, mfa),
        reverse: Map.update(graph.reverse, sink, [{module, function, arity}], &[mfa | &1])
    }
  end

  defp forward(edges) do
    Enum.reduce(edges, %{}, fn {{module, function, _arity}, callee}, acc ->
      Map.update(acc, {module, function}, [callee], &[callee | &1])
    end)
  end

  defp barrier?({m, f}) do
    {m, f} in @barrier_functions or m in @barrier_modules
  end

  defp walk(reverse, initial) do
    sink_keys = initial
    parents = Map.new(sink_keys, &{&1, nil})
    do_walk(:queue.from_list(sink_keys), reverse, parents, MapSet.new())
  end

  defp do_walk(queue, reverse, parents, reached) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        {reached, parents}

      {{:value, key}, rest} ->
        callers = Map.get(reverse, key, [])

        new_keys =
          callers
          |> Enum.map(fn {m, f, _arity} -> {m, f} end)
          |> Enum.uniq()
          |> Enum.reject(&Map.has_key?(parents, &1))

        next_queue = Enum.reduce(new_keys, rest, &:queue.in/2)
        next_parents = Enum.reduce(new_keys, parents, &Map.put(&2, &1, key))
        next_reached = Enum.reduce(callers, reached, &MapSet.put(&2, &1))
        do_walk(next_queue, reverse, next_parents, next_reached)
    end
  end

  defp undisposed(graph, tier, names, exclusions \\ @exclusions) do
    graph
    |> dispositions(tier, names, exclusions)
    |> Enum.filter(&(elem(&1, 1) == nil))
    |> Enum.map(&elem(&1, 0))
  end

  defp dispositions(graph, tier, names, exclusions \\ @exclusions) do
    {reached, _parent} = reach(graph, tier, names)

    reached
    |> Enum.filter(&MapSet.member?(graph.exported, &1))
    |> Enum.reject(fn {m, f, _arity} ->
      m in [:erlang, :erl_eval, :erl_ddll] or f == :module_info
    end)
    |> Enum.map(fn mfa -> {mfa, disposition(mfa, tier, names, exclusions)} end)
  end

  defp disposition({m, f, _a} = mfa, tier, names, exclusions) do
    if covered?(mfa, tier, names) do
      :tier
    else
      exact_mfa_exclusion_reason(mfa, exclusions) || exclusion_reason(m, f, exclusions)
    end
  end

  defp debugger_family_universe(graph, tier, exclusions) do
    inspections = Enum.filter(graph.inspected, &(&1.module_atom in @debugger_family_modules))
    inspected_modules = MapSet.new(inspections, & &1.module_atom)

    assert inspected_modules == MapSet.new(@debugger_family_modules),
           "lane #{graph.lane.name} app debugger is missing an assigned inspected BEAM"

    scanned_functions =
      Enum.reduce(inspections, MapSet.new(), fn inspection, functions ->
        case BeamWalker.scan(inspection.path) do
          {:ok, scan} ->
            assert scan.module == inspection.module_atom,
                   "lane #{graph.lane.name} app #{inspection.app} module #{inspection.module} " <>
                     "scanned as #{inspect(scan.module)}"

            scanned_family_functions =
              scan.function_mfas
              |> Enum.filter(&debugger_family_mfa?/1)
              |> MapSet.new()

            MapSet.union(functions, scanned_family_functions)

          {:error, reason} ->
            flunk(
              "lane #{graph.lane.name} app #{inspection.app} module #{inspection.module} " <>
                "could not be inventoried from #{inspection.path}: #{inspect(reason)}"
            )
        end
      end)

    graph_candidates =
      graph
      |> debugger_graph_candidates()
      |> Enum.filter(&debugger_family_mfa?/1)
      |> MapSet.new()

    all_candidates = MapSet.union(scanned_functions, graph_candidates)
    names = BannedCalls.banned_names()

    tier_roots =
      Enum.filter(all_candidates, &covered?(&1, tier, names))
      |> MapSet.new()

    exclusion_roots =
      Enum.filter(all_candidates, fn {module, function, _arity} = mfa ->
        exact_mfa_exclusion_reason(mfa, exclusions) != nil or
          exclusion_reason(module, function, exclusions) != nil
      end)
      |> MapSet.new()

    MapSet.new()
    |> MapSet.union(scanned_functions)
    |> MapSet.union(graph_candidates)
    |> MapSet.union(MapSet.new(@debugger_explicit_roots))
    |> MapSet.union(tier_roots)
    |> MapSet.union(exclusion_roots)
  end

  defp saved_settings_changed_family_universe(graph, record) do
    inspections =
      Enum.filter(graph.inspected, &(&1.module_atom in @saved_settings_changed_modules))

    inspected_modules = MapSet.new(inspections, & &1.module_atom)

    assert inspected_modules == MapSet.new(@saved_settings_changed_modules),
           "lane #{graph.lane.name} must inspect every source module in the saved-settings callback family"

    scanned_functions =
      Enum.reduce(inspections, MapSet.new(), fn inspection, functions ->
        assert {:ok, scan} = BeamWalker.scan(inspection.path)
        assert scan.module == inspection.module_atom
        MapSet.union(functions, MapSet.new(scan.function_mfas))
      end)

    graph_candidates =
      graph
      |> debugger_graph_candidates()
      |> Enum.filter(fn {module, _function, _arity} ->
        module in @saved_settings_changed_modules
      end)
      |> MapSet.new()

    source_only_obligations = MapSet.new(record.source_branches, & &1.mfa)

    scanned_functions
    |> MapSet.union(graph_candidates)
    |> MapSet.union(source_only_obligations)
    |> MapSet.to_list()
    |> Enum.sort()
  end

  defp debugger_family_mfa?({module, _function, _arity}),
    do: module in @debugger_family_modules

  defp debugger_family_mfa?(_candidate), do: false

  defp debugger_graph_candidates(graph) do
    graph.full_edges
    |> Enum.flat_map(fn {caller, callee} -> [caller, callee] end)
    |> Kernel.++(MapSet.to_list(graph.full_reached))
    |> Kernel.++(MapSet.to_list(graph.full_exported))
    |> Enum.filter(&match?({_, _, _}, &1))
    |> MapSet.new()
  end

  defp debugger_exclusion_matches(universe, exclusions) do
    Enum.flat_map(exclusions, &debugger_exclusion_match(universe, &1))
  end

  defp debugger_exclusion_match(universe, exclusion) do
    matches = Enum.filter(universe, &debugger_exclusion_matches_mfa?(&1, exclusion))
    debugger_exclusion_record(exclusion, matches)
  end

  defp debugger_exclusion_matches_mfa?({module, function, _arity} = mfa, exclusion) do
    exact_mfa_exclusion_reason(mfa, [exclusion]) != nil or
      exclusion_reason(module, function, [exclusion]) != nil
  end

  defp debugger_exclusion_matches_mfa?(_mfa, _exclusion), do: false

  defp debugger_exclusion_record(_exclusion, []), do: []

  defp debugger_exclusion_record(exclusion, matches) do
    reason = if tuple_size(exclusion) >= 2, do: elem(exclusion, 1), else: :unknown
    citations = if tuple_size(exclusion) >= 3, do: elem(exclusion, 2), else: []

    [
      %{
        original_identity: exclusion,
        cited_triple: {elem(exclusion, 0), reason, citations},
        matched_mfas: Enum.sort(matches)
      }
    ]
  end

  defp assert_debugger_exclusion_witnesses!(matches, graph, tier, names, exclusions) do
    active = %{reverse: graph.reverse, exported: graph.exported}

    for match <- matches do
      without_original = List.delete(exclusions, match.original_identity)
      newly_uncovered = undisposed(active, tier, names, without_original)

      assert Enum.any?(match.matched_mfas, &(&1 in newly_uncovered)),
             "lane #{graph.lane.name} retained exclusion #{inspect(match.original_identity)} " <>
               "has no individual active removal witness for its complete matched set " <>
               "#{inspect(match.matched_mfas)}"
    end
  end

  defp assert_debugger_function_inventory!(
         actual_universe,
         source_mfas,
         review_mfas,
         expected_mfas,
         lane
       ) do
    source_set = MapSet.new(source_mfas)
    review_set = MapSet.new(review_mfas)
    expected_set = MapSet.new(expected_mfas)

    assert length(source_mfas) == MapSet.size(source_set),
           "lane #{lane} app debugger source inventory contains duplicate functions"

    assert length(review_mfas) == MapSet.size(review_set),
           "lane #{lane} app debugger semantic inventory contains duplicate functions"

    assert length(expected_mfas) == MapSet.size(expected_set),
           "lane #{lane} app debugger expected function specification contains duplicates"

    missing_source = MapSet.difference(actual_universe, source_set)
    missing_review = MapSet.difference(actual_universe, review_set)
    missing_expected = MapSet.difference(actual_universe, expected_set)
    not_installed = MapSet.difference(MapSet.union(source_set, review_set), actual_universe)

    assert source_set == review_set and source_set == expected_set and
             actual_universe == source_set,
           "lane #{lane} app debugger assigned function inventory differs from the independent " <>
             "installed universe; missing source=#{debugger_function_diagnostics(missing_source)}; " <>
             "missing semantic review=#{debugger_function_diagnostics(missing_review)}; " <>
             "missing expected spec=#{debugger_function_diagnostics(missing_expected)}; " <>
             "not installed=#{debugger_function_diagnostics(not_installed)}"
  end

  defp assert_debugger_root_inventory!(graph_candidates, assigned_roots, lane) do
    baseline = MapSet.new(@debugger_baseline_roots)
    assigned = MapSet.new(assigned_roots)
    missing_assignment = MapSet.difference(baseline, assigned)
    missing_graph = MapSet.difference(assigned, graph_candidates)

    assert MapSet.size(missing_assignment) == 0 and MapSet.size(missing_graph) == 0,
           "lane #{lane} app debugger assigned root inventory differs from the pinned baseline " <>
             "or independent graph; omitted assigned roots=#{debugger_function_diagnostics(missing_assignment)}; " <>
             "roots absent from graph=#{debugger_function_diagnostics(missing_graph)}"
  end

  defp assert_debugger_active_scope!(graph, assigned_modules, lane) do
    assigned = MapSet.new(assigned_modules)
    baseline = MapSet.new(@debugger_baseline_active_modules)
    active = graph.active_modules
    pending = MapSet.new(DebuggerPendingOwnership.baseline_modules())
    pending_rows = MapSet.new(graph.pending_modules, & &1.module_atom)

    pending_owner_error =
      DebuggerPendingOwnership.validation_error(DebuggerPendingOwnership.owners())

    omitted_baseline = MapSet.difference(baseline, assigned)
    inactive_assigned = MapSet.difference(assigned, active)
    active_pending = MapSet.intersection(active, pending)
    missing_pending_rows = MapSet.difference(pending, pending_rows)

    assert MapSet.size(omitted_baseline) == 0 and MapSet.size(inactive_assigned) == 0 and
             MapSet.size(active_pending) == 0 and MapSet.size(missing_pending_rows) == 0 and
             is_nil(pending_owner_error),
           "lane #{lane} app debugger active/pending ownership differs; " <>
             "active debugger slice omitted baseline modules=#{inspect(Enum.sort(omitted_baseline))}; " <>
             "assigned modules absent from active view=#{inspect(Enum.sort(inactive_assigned))}; " <>
             "pending debugger modules are active=#{debugger_pending_diagnostics(active_pending)}; " <>
             "pending modules absent from pending rows=#{debugger_pending_diagnostics(missing_pending_rows)}; " <>
             "pending debugger ownership map differs=#{pending_owner_error || "none"}"
  end

  defp debugger_function_diagnostics(mfas) do
    mfas
    |> Enum.sort()
    |> Enum.map_join("; ", &debugger_function_diagnostic/1)
  end

  defp debugger_function_diagnostic({module, function, arity} = mfa) do
    case Map.get(@debugger_function_reviews, mfa) do
      %{owner: owner, trace: trace} ->
        "#{module}:#{function}/#{arity} owner=#{Atom.to_string(owner)} " <>
          "caller-chain=#{debugger_trace_diagnostic(trace)}"

      _ ->
        "#{module}:#{function}/#{arity} owner=unassigned caller-chain=unrecorded"
    end
  end

  defp debugger_trace_diagnostic(trace) do
    Enum.map_join(trace, " -> ", fn
      {module, function, arity} -> "#{module}:#{function}/#{arity}"
      other -> inspect(other)
    end)
  end

  defp debugger_pending_diagnostics(modules) do
    modules
    |> Enum.sort()
    |> Enum.map_join("; ", fn module ->
      "#{module} owner=#{Map.get(DebuggerPendingOwnership.owners(), module, "unassigned")}"
    end)
  end

  defp assert_debugger_audit!(records, graph, tier, evidence, exclusions) do
    lane = evidence.lane.name
    lane_source = Map.fetch!(@debugger_source_by_lane, lane)
    lane_records = Enum.filter(records, &(&1.lane == lane))
    mfa = @debugger_selected_file_mfa
    family_universe = debugger_family_universe(graph, tier, exclusions)

    assert graph.lane.name == lane,
           "evidence lane #{lane} does not match inspected graph lane #{graph.lane.name}"

    assert length(records) == length(@debugger_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@debugger_expected_ids)

    assert length(lane_records) == 1

    assert MapSet.new(Enum.map(lane_records, &{&1.original_id, &1.lane})) ==
             MapSet.new(Enum.filter(@debugger_expected_ids, &(elem(&1, 1) == lane)))

    expected_exports = MapSet.new(@debugger_expected_exports)

    actual_exports =
      graph.full_exported
      |> Enum.filter(&(elem(&1, 0) in @debugger_family_modules))
      |> MapSet.new()

    assert actual_exports == expected_exports,
           "the complete exact-lane debugger family export set differs from reviewed sources"

    graph_candidates = debugger_graph_candidates(graph)
    assert_debugger_root_inventory!(graph_candidates, @debugger_explicit_roots, lane)

    assert MapSet.member?(graph.full_reached, mfa)

    decoder_mfa = {:dbg_istk, :from_external, 1}
    assert MapSet.member?(graph.full_exported, decoder_mfa)
    assert decoder_mfa in @debugger_explicit_roots

    active_exports =
      graph.exported
      |> Enum.filter(&(elem(&1, 0) in @debugger_family_modules))
      |> MapSet.new()

    assert active_exports == expected_exports,
           "lane #{lane} active debugger exports do not preserve the exact assigned family"

    assert_debugger_active_scope!(graph, @debugger_active_modules, lane)

    record = hd(lane_records)
    assert record.original_id == "NEW-DEBUGGER-#{String.upcase(lane)}-dbg_wx_interpret-start-4"
    assert record.original_matcher == {:mfa, mfa}
    assert record.original_reason == :tier
    assert record.matched_mfas == [mfa]
    assert record.caller_input == :caller_selected_filenames_and_directory
    assert record.defaults == :monitor_supplied_local_or_global_mode
    assert record.option_paths == [:local, :global]

    assert record.trace == [
             {:dbg_wx_mon, :gui_cmd, 2},
             {:dbg_wx_interpret, :start, 4},
             {:dbg_wx_filedialog_win, :getFilenames, 1},
             {:dbg_wx_filedialog_win, :getDirectory, 1},
             {:dbg_wx_interpret, :interpret_all, 5},
             {:filename, :join, 2},
             {:int, :i, 1},
             {:int, :ni, 1}
           ]

    assert record.verdict == :caller_selected_files_reach_interpreter
    assert record.replacements == %{mfa => {:tier, mfa}}
    assert record.tier == [mfa]

    assert record.fixtures == [
             :direct,
             :capture,
             :apply,
             :utf8_literal,
             :discarded_quote,
             :uninvoked_macro
           ]

    assert record.applicability == :each_exact_installed_lane
    assert record.removal_witness == :uncalled_probe_mfa_tier_reduction
    assert record.source_sha256 == lane_source.sha256
    assert record.citations == lane_source.citations
    assert record.export_citations == lane_source.export_citations
    assert record.family_function_sources == lane_source.family_function_sources
    assert record.family_function_audit == lane_source.family_function_audit
    assert record.branch_citations == lane_source.branch_citations
    assert record.ui_provenance_citations == lane_source.ui_provenance_citations
    assert record.cross_owner_support_citations == lane_source.cross_owner_support_citations
    assert record.empty_selection == :source_disposed_without_invocation
    assert record.decoder_mfa == decoder_mfa
    assert record.decoder_caller_input == :arbitrary_exported_stack_binary
    assert record.decoder_options == :binary_to_term_without_safe_option

    assert record.decoder_trace == [
             {:dbg_ieval, :exit_info, 5},
             {:dbg_istk, :from_external, 1},
             {:erlang, :binary_to_term, 1},
             :process_dictionary_stack_write
           ]

    assert record.decoder_verdict == :caller_binary_is_unconstrained_at_export

    assert record.decoder_fixtures == [
             :direct,
             :capture,
             :apply,
             :discarded_quote,
             :uninvoked_macro,
             :serializing_only_control
           ]

    assert record.decoder_removal_witness == :uncalled_probe_mfa_tier_reduction

    assert record.internal_provenance == %{
             producer: {:dbg_istk, :delayed_to_external, 0},
             encoder: {:erlang, :term_to_binary, 1},
             observed_consumer: {:dbg_ieval, :exit_info, 5},
             verdict: :observed_internal_round_trip_does_not_constrain_public_input
           }

    assert record.decoder_citations == lane_source.decoder_citations
    assert record.decoder_provenance_citations == lane_source.decoder_provenance_citations

    assert record.limitations == [
             :no_runtime_filename_decoding_claim,
             :no_computed_dispatch_claim,
             :no_write_then_load_claim,
             :no_runtime_atom_count_claim
           ]

    assert MapSet.new(Map.keys(record.branch_citations)) ==
             MapSet.new([
               :database_dispatch,
               :stack_lifecycle,
               :stack_trace,
               :dialog_return,
               :dialog_cancel,
               :parser_filter,
               :selected_files,
               :empty_and_errors
             ])

    assert Enum.all?(record.branch_citations, fn {_group, citations} -> citations != [] end)

    source_function_mfas = Enum.map(record.family_function_sources, &elem(&1, 0))
    reviewed_function_mfas = Enum.map(record.family_function_audit, & &1.mfa)
    actual_function_mfas = family_universe

    assert_debugger_function_inventory!(
      actual_function_mfas,
      source_function_mfas,
      reviewed_function_mfas,
      @debugger_expected_family_mfas,
      lane
    )

    assert MapSet.new(source_function_mfas) == MapSet.new(@debugger_expected_family_mfas),
           "lane #{lane} app debugger source identities differ from the assigned reviewed set"

    assert debugger_function_audit_complete?(record.family_function_audit),
           "lane #{lane} app debugger has a function row without input/default/option/trace/verdict/source/owner"

    expected_seed_dispositions =
      Enum.zip(@debugger_source_only_seed_mfas, lane_source.seed_citations)
      |> Enum.map(fn {seed_mfa, citation} ->
        %{
          mfa: seed_mfa,
          reached: false,
          verdict: :source_disposed_without_graph_hit,
          citation: citation
        }
      end)

    assert record.seed_dispositions == expected_seed_dispositions,
           "lane #{lane} omitted or invented a source-only debugger seed disposition"

    for seed_mfa <- @debugger_source_only_seed_mfas do
      refute MapSet.member?(graph.full_reached, seed_mfa),
             "lane #{lane} source-only seed #{inspect(seed_mfa)} was absent from full_reached"
    end

    assert record.ui_provenance == %{
             module_list_origin: {:int, :interpreted, 0},
             module_name_display: :atom_to_list,
             checkbox_labels: ["First Call", "On Break", "On Exit"],
             label_conversion: :list_to_atom,
             callback_owner: :phase_01_1_1_3_1,
             callback_verdict: :synthetic_events_and_keyboard_inputs_pending
           }

    assert record.cross_owner_support == %{
             dbg_iload: :cited_support_only_whole_module_review_pending,
             dbg_ieval: :decoder_consumer_provenance_only,
             dbg_wx_filedialog_win: :dialog_getters_only,
             dbg_wx_mon: :module_list_origin_only,
             dbg_wx_mon_win: :labels_and_callback_boundary_only,
             dbg_wx_win: :error_dialog_provenance_only
           }

    exclusion_matches = debugger_exclusion_matches(actual_function_mfas, exclusions)
    assert record.exclusion_matches == @debugger_expected_exclusion_matches

    assert exclusion_matches == record.exclusion_matches,
           "lane #{lane} changed debugger exclusion match set or original identity"

    assert record.exclusion_identity_replacements == %{}

    assert_debugger_exclusion_witnesses!(
      exclusion_matches,
      graph,
      tier,
      BannedCalls.banned_names(),
      exclusions
    )

    for {relative_path, expected_sha} <- lane_source.sha256 do
      archived_path = "#{lane}/#{relative_path}"

      row = Enum.find(evidence.manifest["files"], &(&1["path"] == archived_path))
      assert row != nil, "missing exact-lane source record #{archived_path}"

      assert row["status"] == "present",
             "lane #{lane} source record #{archived_path} claims absence or non-present status"

      assert row["source_path"] == relative_path
      assert row["sha256"] == expected_sha
    end

    assert map_size(lane_source.sha256) == 9

    branch_citations = record.branch_citations |> Map.values() |> List.flatten()
    family_citations = Enum.map(record.family_function_sources, &elem(&1, 1))
    function_citations = Enum.flat_map(record.family_function_audit, & &1.citations)

    all_source_citations =
      record.citations ++
        record.export_citations ++
        family_citations ++
        function_citations ++
        branch_citations ++
        record.decoder_citations ++
        record.decoder_provenance_citations ++
        record.ui_provenance_citations ++
        record.cross_owner_support_citations

    for {citation, expected_source} <- all_source_citations do
      [relative_file, _line] = String.split(citation, ":", parts: 2)
      expected_sha = Map.fetch!(lane_source.sha256, relative_file)
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.origin in [:archive, :installed], citation
      assert resolved.sha256 == expected_sha, citation
      assert resolved.text =~ expected_source, citation
    end

    assert covered?(mfa, tier, BannedCalls.banned_names()),
           "lane #{lane} selected-file root must retain its exact MFA tier"

    assert exact_mfa_exclusion_reason(mfa, exclusions) == nil
    assert exclusion_reason(elem(mfa, 0), elem(mfa, 1), exclusions) == nil

    assert covered?(decoder_mfa, tier, BannedCalls.banned_names()),
           "lane #{lane} exported stack decoder must retain its exact MFA tier"

    assert {:dbg_istk, :from_external, 1} in BannedCalls.banned_mfas()
    assert :binary_to_term in BannedCalls.banned_names()
    assert exact_mfa_exclusion_reason(decoder_mfa, exclusions) == nil
    assert exclusion_reason(elem(decoder_mfa, 0), elem(decoder_mfa, 1), exclusions) == nil
  end

  defp debugger_function_audit_complete?(reviews) do
    Enum.all?(reviews, fn review ->
      review.caller_input != nil and review.defaults != nil and review.option_paths != nil and
        review.trace != [] and review.verdict != nil and review.owner == :plan_02 and
        review.citations != []
    end)
  end

  defp assert_ct_make_audit!(records, graph, tier, evidence, exclusions \\ @exclusions) do
    lane = evidence.lane.name
    lane_source = Map.fetch!(@ct_make_source_by_lane, lane)
    lane_records = Enum.filter(records, &(&1.lane == lane))

    expected_ids =
      @ct_make_expected_ids
      |> Enum.filter(&(elem(&1, 1) == lane))
      |> MapSet.new()

    assert length(records) == length(@ct_make_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@ct_make_expected_ids)

    assert length(lane_records) == length(@ct_make_family_specs)
    assert MapSet.new(Enum.map(lane_records, &{&1.original_id, &1.lane})) == expected_ids

    actual_exports =
      graph.full_exported
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    active_exports =
      graph.exported
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    reached_exports = MapSet.intersection(actual_exports, graph.full_reached)
    active_reached_exports = MapSet.intersection(active_exports, graph.active_reached)
    expected_exports = MapSet.new(@ct_make_expected_mfas)
    expected_reached = MapSet.new(@ct_make_expected_reached_mfas)

    actual_reached =
      graph.full_reached
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    active_reached =
      graph.active_reached
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    assert actual_exports == expected_exports,
           "the complete exact-lane ct_make export set differs from its four audited rows"

    assert MapSet.new(Enum.flat_map(lane_records, & &1.matched_mfas)) == actual_exports
    assert reached_exports == expected_exports
    assert active_exports == expected_exports
    assert active_reached_exports == expected_exports

    assert actual_reached == expected_reached,
           "the exact-lane ct_make reached set differs from the reviewed caller/load paths"

    assert active_reached == expected_reached
    assert MapSet.member?(graph.active_modules, :ct_make)
    assert Enum.any?(graph.pending_apps, &(&1.app == "common_test"))
    refute Enum.any?(graph.pending_modules, &(&1.module_atom == :ct_make))

    refute Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_app" and row["app"] == "common_test"
           end)

    assert Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_module" and row["app"] == "common_test" and
               row["module"] == "ct_make"
           end)

    for spec <- @ct_make_family_specs do
      mfa = spec.mfa
      {module, function, _arity} = mfa

      record =
        Enum.find(
          lane_records,
          &(&1.original_id == "CT-#{String.upcase(lane)}-ct_make-#{function}-#{elem(mfa, 2)}")
        )

      assert record != nil, "missing CT record for #{inspect(mfa)} on #{lane}"
      assert record.original_matcher == {:mfa, mfa}
      assert record.original_reason == :tier
      assert record.matched_mfas == [mfa]
      assert record.caller_input == spec.caller_input
      assert record.defaults == spec.defaults
      assert record.option_paths == spec.option_paths
      assert record.trace == spec.trace
      assert record.verdict == spec.verdict
      assert record.replacements == %{mfa => {:tier, mfa}}
      assert record.tier == [mfa]
      assert record.fixtures == spec.fixtures
      assert record.applicability == :each_exact_installed_lane
      assert record.removal_witness == :individual_exact_mfa
      assert record.source_sha256 == lane_source.sha256

      assert covered?(mfa, tier, BannedCalls.banned_names()),
             "#{inspect(mfa)} has no replacement tier"

      assert exact_mfa_exclusion_reason(mfa, exclusions) == nil,
             "#{inspect(mfa)} has a redundant exact exclusion"

      assert exclusion_reason(module, function, exclusions) == nil,
             "#{inspect(mfa)} has a redundant broad exclusion"

      expected_citations = Enum.flat_map(spec.source_groups, &Map.fetch!(lane_source.groups, &1))
      assert record.citations == expected_citations
      assert_ct_make_trace_call_sites!(spec, record, mfa)

      for {citation, expected_source} <- record.citations do
        resolved = SweepEvidence.resolve!(evidence, citation)
        assert resolved.origin in [:archive, :installed], citation
        assert resolved.sha256 == lane_source.sha256, citation
        assert resolved.text =~ expected_source, citation
      end

      tier_without_front = Enum.reject(tier, &(&1 == mfa))

      assert mfa in undisposed(graph, tier_without_front, BannedCalls.banned_names(), exclusions),
             "removing only #{inspect(mfa)} must expose that previously covered front"
    end
  end

  defp assert_ct_make_trace_call_sites!(spec, record, mfa) do
    for {target_mfa, expected_callsite} <- Map.get(spec, :trace_call_sites, []) do
      assert target_mfa in record.trace,
             "#{inspect(target_mfa)} is missing from the trace for #{inspect(mfa)}"

      assert Enum.any?(record.citations, fn {_citation, source_line} ->
               String.contains?(source_line, expected_callsite)
             end),
             "#{inspect(mfa)} lacks an exact source citation for #{inspect(target_mfa)}"
    end
  end

  defp assert_creator_audit!(records, graph, tier, evidence, exclusions \\ @exclusions) do
    assert length(records) == length(@creator_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@creator_expected_ids)

    record = Enum.find(records, &(&1.lane == evidence.lane.name))
    assert record != nil, "no creator audit row for #{evidence.lane.name}"
    assert record.original_id == "EX-159"
    assert record.original_matcher == {:file, [:path_consult, :consult]}
    assert record.original_reason == :pure_data
    assert MapSet.new(record.matched_mfas) == MapSet.new(@creator_expected_original_mfas)
    assert record.trace == @creator_expected_trace
    assert record.verdict == :caller_term_text_reaches_atom_creation
    assert MapSet.new(record.replacements) == MapSet.new(@creator_expected_original_mfas)
    assert MapSet.new(record.tier) == MapSet.new(@creator_expected_original_mfas)
    assert record.fixtures == @creator_expected_fixtures
    assert record.applicability == :each_exact_installed_lane
    assert record.removal_witness == :not_applicable_tiered

    for {citation, expected} <- record.citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
    end

    citation_lines = MapSet.new(Enum.map(record.citations, &elem(&1, 0)))

    assert citation_lines ==
             MapSet.new(Map.fetch!(@creator_expected_citation_lines, evidence.lane.name))

    live_matches =
      graph.exported
      |> Enum.filter(&creator_original_match?(record.original_matcher, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> MapSet.new()

    assert live_matches == MapSet.new(record.matched_mfas),
           "#{record.original_id} original matcher differs from live exports"

    for {module, function, arity} = mfa <- record.matched_mfas do
      assert covered?(mfa, tier, BannedCalls.banned_names()),
             "#{inspect(mfa)} has no replacement tier"

      assert exclusion_reason(module, function, exclusions) == nil,
             "#{inspect(mfa)} was given a false safe disposition"

      assert arity > 0
    end
  end

  defp assert_yecc_audit!(records, graph, tier, evidence, exclusions \\ @exclusions) do
    assert length(records) == length(@yecc_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@yecc_expected_ids)

    record = Enum.find(records, &(&1.lane == evidence.lane.name))
    assert record != nil, "no Yecc audit row for #{evidence.lane.name}"
    assert record.original_id == "EX-089"
    assert record.original_matcher == {:yecc, :epp_guard}
    assert record.original_reason == :epp_guard
    assert MapSet.new(record.matched_mfas) == MapSet.new(@yecc_expected_original_mfas)
    assert record.trace == @yecc_expected_trace
    assert record.verdict == @yecc_expected_verdict
    assert record.replacements == @yecc_expected_replacements
    assert MapSet.new(record.tier) == MapSet.new(@yecc_expected_tier)
    assert record.fixtures == @yecc_expected_fixtures
    assert record.applicability == :each_exact_installed_lane
    assert record.removal_witness == :not_applicable_blanket_retired
    refute {:yecc, :epp_guard} in exclusions

    for {citation, expected} <- record.citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
    end

    citation_lines = MapSet.new(Enum.map(record.citations, &elem(&1, 0)))

    assert citation_lines ==
             MapSet.new(Map.fetch!(@yecc_expected_citation_lines, evidence.lane.name))

    live_matches =
      graph.exported
      |> Enum.filter(&yecc_original_match?(record.original_matcher, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> MapSet.new()

    assert live_matches == MapSet.new(record.matched_mfas),
           "#{record.original_id} original matcher differs from exact-lane exports"

    for {module, function, arity} = mfa <- @yecc_expected_tier do
      assert covered?(mfa, tier, BannedCalls.banned_names()),
             "#{inspect(mfa)} has no replacement tier"

      assert exclusion_reason(module, function, exclusions) == nil,
             "#{inspect(mfa)} was given a false safe disposition"

      assert arity > 0
    end

    {reached, _parents} = reach(graph, tier, BannedCalls.banned_names())
    formatter_mfa = {:yecc, :format_error, 1}
    refute covered?(formatter_mfa, tier, BannedCalls.banned_names())
    assert exclusion_reason(:yecc, :format_error, exclusions) == nil

    refute MapSet.member?(reached, formatter_mfa),
           "format_error/1 was retained although the changed atom-creator fronts do not reach it"
  end

  defp assert_logger_audit!(
         records,
         graph,
         tier,
         evidence,
         exclusions \\ @exclusions,
         family_specs \\ @logger_family_specs
       ) do
    spec_mfas = MapSet.new(Enum.map(family_specs, & &1.mfa))

    for lane <- @creator_expected_lanes do
      expected_mfas = Map.fetch!(@logger_expected_mfas_by_lane, lane)

      assert spec_mfas == expected_mfas,
             "Logger/ExUnit spec MFA set differs from pinned lane universe for #{lane}; " <>
               "missing=#{inspect(MapSet.difference(expected_mfas, spec_mfas))} " <>
               "unexpected=#{inspect(MapSet.difference(spec_mfas, expected_mfas))}"
    end

    lane_universe = Map.fetch!(@logger_expected_mfas_by_lane, evidence.lane.name)
    missing_exports = MapSet.difference(lane_universe, MapSet.new(graph.exported))

    assert MapSet.size(missing_exports) == 0,
           "pinned Logger/ExUnit MFA universe is absent from #{evidence.lane.name} exports: " <>
             inspect(missing_exports)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@logger_expected_ids)

    lane_records = Enum.filter(records, &(&1.lane == evidence.lane.name))
    recorded_mfas = lane_records |> Enum.flat_map(& &1.matched_mfas) |> MapSet.new()
    assert recorded_mfas == lane_universe

    for spec <- family_specs do
      {module, function, _arity} = mfa = spec.mfa

      id =
        "NEW-#{spec.family}-#{evidence.lane.name}-#{inspect(module)}-#{function}-#{elem(mfa, 2)}"

      record = Enum.find(lane_records, &(&1.original_id == id))
      assert record != nil, "missing #{id}"

      for {citation, expected} <- record.citations do
        assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
      end

      expected_citations =
        Enum.flat_map(spec.evidence, &Map.fetch!(@logger_source_evidence[evidence.lane.name], &1))

      assert record.original_matcher == {:mfa, mfa}
      assert record.original_reason == spec.disposition
      assert record.matched_mfas == [mfa]
      assert record.trace == spec.trace
      assert record.provenance == spec.provenance
      assert record.verdict == spec.verdict
      assert record.fixtures == spec.fixtures
      assert record.citations == expected_citations
      assert record.evidence_groups == spec.evidence
      assert record.applicability == :each_exact_installed_lane
      assert record.removal_witness == spec.removal_witness

      if spec.disposition == :tier do
        assert record.tier == [mfa]
        assert record.replacements == %{mfa => {:tier, mfa}}
        assert covered?(mfa, tier, BannedCalls.banned_names()), "#{inspect(mfa)} lacks a tier"

        assert exact_mfa_exclusion_reason(mfa, exclusions) == nil,
               "#{inspect(mfa)} has a redundant safe exclusion"

        assert exclusion_reason(module, function, exclusions) == nil,
               "#{inspect(mfa)} overlaps a broad safe exclusion"
      else
        assert record.tier == []
        assert record.replacements == %{mfa => {:exact_exclusion, spec.reason}}
        refute covered?(mfa, tier, BannedCalls.banned_names())
        assert exact_mfa_exclusion_reason(mfa, exclusions) == spec.reason
        assert exclusion_reason(module, function, exclusions) == nil
      end
    end

    {reached, _parents} = reach(graph, tier, BannedCalls.banned_names())
    family_modules = MapSet.new(@logger_family_modules)

    family_exports =
      graph.exported
      |> Enum.filter(fn {module, _function, _arity} -> MapSet.member?(family_modules, module) end)
      |> MapSet.new()

    reached_family = MapSet.intersection(reached, family_exports)

    explicit_tier_roots =
      family_tier_roots(tier, family_modules, family_exports, BannedCalls.banned_names())

    explicit_exclusion_roots = explicit_family_exclusion_roots(exclusions, family_exports)

    live_family =
      reached_family
      |> MapSet.union(MapSet.new(explicit_tier_roots))
      |> MapSet.union(MapSet.new(explicit_exclusion_roots))

    recorded_family = recorded_mfas
    unrecorded_family = MapSet.difference(live_family, lane_universe)
    missing_family = MapSet.difference(lane_universe, live_family)

    assert live_family == lane_universe,
           "Logger/ExUnit family live MFA set differs from exact-lane universe; " <>
             "unrecorded=#{inspect(unrecorded_family)} " <>
             "roots=#{inspect(Enum.filter(unrecorded_family, &covered?(&1, tier, BannedCalls.banned_names())))} " <>
             "paths=#{inspect(Enum.map(unrecorded_family, &witness_line(graph, &1)))} " <>
             "missing=#{inspect(missing_family)}"

    assert live_family == recorded_family,
           "Logger/ExUnit family records differ from reached exact-lane exports; " <>
             "unrecorded=#{inspect(MapSet.difference(live_family, recorded_family))} " <>
             "stale=#{inspect(MapSet.difference(recorded_family, live_family))}"
  end

  defp yecc_original_match?({:yecc, :epp_guard}, {:yecc, function, _arity})
       when function not in [:module_info, :__info__],
       do: true

  defp yecc_original_match?(_matcher, _mfa), do: false

  defp creator_original_match?({module, functions}, {module, function, _arity})
       when is_list(functions),
       do: function in functions

  defp creator_original_match?(_matcher, _mfa), do: false

  defp covered?({m, f, a}, tier, names) do
    f in names or m in names or
      Enum.any?(tier, fn {pm, pf, pa} -> pm == m and pf in [:_, f] and pa in [:_, a] end)
  end

  defp banned_module_named?({_module, function, _arity}, whole_modules),
    do: function in whole_modules

  defp matched_uncovered(uncovered, entries) do
    Enum.reduce(entries, MapSet.new(), fn {matcher, _reason, _citation}, matched ->
      matched_for_entry =
        uncovered
        |> Enum.filter(&call_name_exclusion_match?(matcher, &1))
        |> MapSet.new()

      MapSet.union(matched, matched_for_entry)
    end)
  end

  defp call_name_exclusion_match?({module, functions}, {module, function, _arity})
       when is_list(functions),
       do: function in functions

  defp call_name_exclusion_match?(_matcher, _mfa), do: false

  defp matched_boundary(uncovered, entries) do
    Enum.reduce(entries, MapSet.new(), fn {matcher, _reason, _citation}, matched ->
      matched_for_entry =
        uncovered
        |> Enum.filter(&boundary_match?(matcher, &1))
        |> MapSet.new()

      MapSet.union(matched, matched_for_entry)
    end)
  end

  defp boundary_match?(matcher, {module, _function, _arity}) when is_atom(matcher),
    do: matcher == module

  defp boundary_match?({module, functions}, {module, function, _arity})
       when is_list(functions),
       do: function in functions

  defp boundary_match?(_matcher, _mfa), do: false

  defp boundary_set(graph, tier, names) do
    delegates = delegate_modules(graph)
    front = MapSet.new(front_of_barrier(graph, tier, names))

    graph.exported
    |> Enum.reject(fn {_module, function, _arity} ->
      function in [:__info__, :module_info] or
        String.starts_with?(Atom.to_string(function), "MACRO-")
    end)
    |> Enum.filter(fn {module, function, _arity} = mfa ->
      module in @barrier_modules or {module, function} in @barrier_functions or
        module in delegates or (module == :erlang and erlang_boundary_function?(function)) or
        MapSet.member?(front, mfa)
    end)
  end

  defp erlang_boundary_function?(function) do
    name = Atom.to_string(function)
    Enum.any?(["load", "module", "code", "nif", "purge", "path"], &String.contains?(name, &1))
  end

  defp delegate_modules(graph) do
    exported_modules = Enum.map(graph.exported, &elem(&1, 0)) |> MapSet.new()

    Enum.reduce(@base_sinks, MapSet.new(), fn {module, function}, delegates ->
      walk_module_calls(
        [{module, function}],
        module,
        graph.forward,
        exported_modules,
        MapSet.new(),
        delegates
      )
    end)
  end

  defp walk_module_calls([], _module, _forward, _exported_modules, _visited, delegates),
    do: delegates

  defp walk_module_calls(
         [current | rest],
         root,
         forward,
         exported_modules,
         visited,
         delegates
       ) do
    if MapSet.member?(visited, current) do
      walk_module_calls(rest, root, forward, exported_modules, visited, delegates)
    else
      {local, external} =
        Enum.split_with(Map.get(forward, current, []), fn {callee_module, _callee_function} ->
          callee_module == root
        end)

      external_modules =
        external
        |> Enum.map(&elem(&1, 0))
        |> Enum.reject(&(&1 == :erlang))
        |> Enum.filter(&MapSet.member?(exported_modules, &1))

      walk_module_calls(
        rest ++ local,
        root,
        forward,
        exported_modules,
        MapSet.put(visited, current),
        Enum.reduce(external_modules, delegates, &MapSet.put(&2, &1))
      )
    end
  end

  defp front_of_barrier(graph, tier, names) do
    barrier_targets =
      graph.exported
      |> Enum.filter(fn {module, function, _arity} = mfa ->
        barrier?({module, function}) and covered?(mfa, tier, names)
      end)
      |> Enum.map(fn {module, function, _arity} -> {module, function} end)
      |> MapSet.new()

    local_reverse =
      Enum.reduce(graph.edges, %{}, fn
        {{module, function, _arity}, {module, callee_function}}, acc ->
          Map.update(
            acc,
            {module, callee_function},
            [{module, function}],
            &[{module, function} | &1]
          )

        _edge, acc ->
          acc
      end)

    roots =
      Enum.flat_map(graph.edges, fn
        {{module, function, _arity}, callee} ->
          if MapSet.member?(barrier_targets, callee), do: [{module, function}], else: []
      end)

    in_front = local_callers(:queue.from_list(Enum.uniq(roots)), local_reverse, MapSet.new())

    Enum.filter(graph.exported, fn {module, function, _arity} ->
      MapSet.member?(in_front, {module, function})
    end)
  end

  defp local_callers(queue, reverse, visited) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        visited

      {{:value, current}, rest} ->
        if MapSet.member?(visited, current) do
          local_callers(rest, reverse, visited)
        else
          next_queue = Enum.reduce(Map.get(reverse, current, []), rest, &:queue.in/2)
          local_callers(next_queue, reverse, MapSet.put(visited, current))
        end
    end
  end

  defp boundary_undisposed(boundary, tier, names) do
    Enum.reject(boundary, fn mfa ->
      covered?(mfa, tier, names) or
        Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp lane_specific_boundary?({matcher, _reason, _citation}, boundary) do
    module = if is_atom(matcher), do: matcher, else: elem(matcher, 0)
    lane = if System.get_env("FABLEBOOK_FLOOR") in [nil, ""], do: :latest, else: :floor

    Enum.any?(@boundary_lane_specific, fn {only_module, only_lane} ->
      only_module == module and only_lane == lane and
        not Enum.any?(boundary, &(elem(&1, 0) == module))
    end)
  end

  defp lane_specific_call_name?({matcher, _reason, _citation}, named) do
    case List.keyfind(@call_name_lane_specific, matcher, 0) do
      {^matcher, :latest} ->
        System.get_env("FABLEBOOK_FLOOR") not in [nil, ""] and
          not Enum.any?(named, &call_name_exclusion_match?(matcher, &1))

      _entry ->
        false
    end
  end

  defp exact_mfa_exclusion_reason(mfa, exclusions) do
    Enum.find_value(exclusions, fn
      {{:mfa, ^mfa}, reason, _citations} -> known_reason(reason)
      _entry -> nil
    end)
  end

  defp explicit_family_exclusion_roots(exclusions, family_exports) do
    exact_roots =
      Enum.flat_map(exclusions, fn
        {{:mfa, {module, _function, _arity} = mfa}, _reason, _citations}
        when module in @logger_family_modules ->
          [mfa]

        _entry ->
          []
      end)

    module_scoped_roots =
      Enum.filter(family_exports, fn {module, function, _arity} ->
        Enum.any?(exclusions, &explicit_family_exclusion_match?(&1, module, function))
      end)

    exact_roots ++ module_scoped_roots
  end

  defp family_tier_roots(tier, family_modules, family_exports, names) do
    tier_roots = Enum.flat_map(tier, &family_tier_root(&1, family_modules, family_exports))
    named_roots = Enum.filter(family_exports, &covered?(&1, tier, names))
    tier_roots ++ named_roots
  end

  defp family_tier_root({module, _function, _arity} = root, family_modules, family_exports) do
    if MapSet.member?(family_modules, module) do
      matching_exports = Enum.filter(family_exports, &tier_root_matches?(&1, root))
      if matching_exports == [], do: [root], else: matching_exports
    else
      []
    end
  end

  defp tier_root_matches?(
         {module, function, arity},
         {root_module, root_function, root_arity}
       ),
       do:
         root_module == module and root_function in [:_, function] and
           root_arity in [:_, arity]

  defp explicit_family_exclusion_match?(
         {{matcher_module, matcher_function}, _reason, _citations},
         module,
         function
       )
       when matcher_module in @logger_family_modules and is_atom(matcher_function),
       do: matcher_module == module and matcher_function == function

  defp explicit_family_exclusion_match?(
         {{matcher_module, functions}, _reason, _citations},
         module,
         function
       )
       when matcher_module in @logger_family_modules and is_list(functions),
       do: matcher_module == module and function in functions

  defp explicit_family_exclusion_match?(
         {{:prefix, prefix}, _reason, _citations},
         module,
         _function
       ),
       do: String.starts_with?(inspect(module), prefix)

  defp explicit_family_exclusion_match?({module, _reason}, module, _function)
       when module in @logger_family_modules,
       do: true

  defp explicit_family_exclusion_match?({{:prefix, prefix}, _reason}, module, _function),
    do: String.starts_with?(inspect(module), prefix)

  defp explicit_family_exclusion_match?(_entry, _module, _function), do: false

  defp exclusion_reason(m, f, exclusions) do
    Enum.find_value(exclusions, fn
      {matcher, reason, _citation} ->
        if exclusion_match?(matcher, m, f), do: known_reason(reason)

      {{^m, functions}, reason} when is_list(functions) ->
        if f in functions, do: known_reason(reason)

      {^m, reason} ->
        known_reason(reason)

      {{:prefix, prefix}, reason} ->
        if String.starts_with?(inspect(m), prefix), do: known_reason(reason)

      {{:fun_prefix, prefix}, reason} ->
        if String.starts_with?(Atom.to_string(f), prefix), do: known_reason(reason)

      _entry ->
        nil
    end)
  end

  defp exclusion_match?({matcher_m, functions}, m, f) when is_list(functions),
    do: matcher_m == m and f in functions

  defp exclusion_match?({:prefix, prefix}, m, _f), do: String.starts_with?(inspect(m), prefix)

  defp exclusion_match?({:fun_prefix, prefix}, _m, f),
    do: String.starts_with?(Atom.to_string(f), prefix)

  defp exclusion_match?({matcher_m, matcher_f}, m, f), do: matcher_m == m and matcher_f == f

  defp exclusion_match?(_matcher, _m, _f), do: false

  defp known_reason(reason) do
    if Map.has_key?(@reasons, reason), do: reason
  end

  defp valid_exclusion?({_matcher, reason}), do: Map.has_key?(@reasons, reason)

  defp valid_exclusion?({_matcher, reason, citations}) do
    Map.has_key?(@reasons, reason) and
      Enum.all?(List.wrap(citations), &Regex.match?(@citation_re, &1))
  end

  defp function_edges(mod, {:function, _, name, arity, clauses}) do
    caller = {mod, name, arity}
    for callee <- callees(mod, clauses, []) |> Enum.uniq(), do: {caller, callee}
  end

  defp callees(mod, [{:atom, _, m}, {:atom, _, f} = next | rest], acc),
    do: callees(mod, [next | rest], [{m, f} | acc])

  defp callees(mod, [head | tail], acc), do: callees(mod, tail, callees(mod, head, acc))

  defp callees(mod, {:call, _, {:atom, _, f}, args}, acc),
    do: callees(mod, args, [{mod, f} | acc])

  defp callees(mod, {:fun, _, {:function, f, a}}, acc) when is_atom(f) and is_integer(a),
    do: [{mod, f} | acc]

  defp callees(mod, tuple, acc) when is_tuple(tuple), do: callees(mod, Tuple.to_list(tuple), acc)
  defp callees(_mod, _other, acc), do: acc

  defp parse_only?({m, f, _a}) do
    f in [
      :to_atom,
      :to_existing_atom,
      :binary_to_atom,
      :list_to_atom,
      :binary_to_existing_atom,
      :list_to_existing_atom,
      :binary_to_term,
      :concat,
      :safe_concat
    ] or String.starts_with?(Atom.to_string(f), "string_to_quoted") or
      m in [
        :elixir_tokenizer,
        :elixir_parser,
        :io,
        :io_lib,
        :xmerl_scan,
        :epp_dodger,
        :epp,
        :erl_scan,
        :erl_parse,
        Code.Fragment
      ] or
      (m == :erl_eval and f not in @eval_funs) or
      {m, f} in [
        {Code, :format_string!},
        {Code, :format_file!},
        {:elixir, :string_to_tokens},
        {:elixir, :tokens_to_quoted},
        {Logger.Formatter, :compile},
        {:xref_compiler, :compile},
        {:leex, :compile},
        {:yecc, :compile},
        {EEx.Compiler, :compile}
      ]
  end

  defp reach(graph, tier, names) do
    tier_sinks =
      for {m, f, _a} = mfa <- graph.exported,
          covered?(mfa, tier, names),
          not parse_only?(mfa),
          uniq: true,
          do: {m, f}

    walk(graph.reverse, @base_sinks ++ tier_sinks)
  end

  defp counts(graph, rows, undisposed) do
    {reached_set, _parent} = reach(graph, BannedCalls.banned_mfas(), BannedCalls.banned_names())
    reached = Enum.count(reached_set, &MapSet.member?(graph.exported, &1))
    covered = Enum.count(rows, &(elem(&1, 1) == :tier))
    excluded = Enum.count(rows, &(elem(&1, 1) not in [nil, :tier]))

    "elixir #{System.version()} otp #{:erlang.system_info(:otp_release)}: " <>
      "beams_without_debug_info=#{length(graph.no_debug)} reached=#{reached} " <>
      "covered=#{covered} excluded=#{excluded} undisposed=#{length(undisposed)}"
  end

  defp witness_line(graph, {m, f, _a} = mfa) do
    {_reached, parent} = reach(graph, BannedCalls.banned_mfas(), BannedCalls.banned_names())

    chain =
      witness(parent, {m, f}, [])
      |> Enum.take(-4)
      |> Enum.map_join(" > ", fn {mod, fun} -> "#{inspect(mod)}.#{fun}" end)

    "#{inspect(mfa)} via #{chain}"
  end

  defp witness(parent, key, acc) do
    case parent[key] do
      nil -> [key | acc]
      next -> witness(parent, next, [key | acc])
    end
  end

  defp install_probe_app!(otp_lib, app, app_atom, version, module) do
    app_root = Path.join(otp_lib, "#{app}-#{version}")
    ebin = Path.join(app_root, "ebin")
    File.mkdir_p!(ebin)

    forms = [
      {:attribute, 1, :module, module},
      {:attribute, 1, :export, [probe: 0]},
      {:function, 1, :probe, 0, [{:clause, 1, [], [], [{:atom, 1, :ok}]}]}
    ]

    {:ok, ^module, beam} = :compile.forms(forms, [:debug_info])
    File.write!(Path.join(ebin, "#{Atom.to_string(module)}.beam"), beam)

    app_resource =
      {:application, app_atom, [{:vsn, String.to_charlist(version)}, {:modules, [module]}]}

    File.write!(Path.join(ebin, "#{app}.app"), :io_lib.format("~tp.~n", [app_resource]))
  end
end

defmodule Fablebook.Test.InstalledOtpReceiptTest do
  use ExUnit.Case, async: false
  alias Fablebook.Test.{BeamWalker, DebuggerPendingOwnership, InstalledOtp, SweepEvidence}

  @moduletag :inventory_support
  @marker "FABLEBOOK_OTP_INVENTORY_V2 "
  @probe_app_atoms %{"probe" => :probe, "probe_one" => :probe_one, "probe_two" => :probe_two}

  test "pending debugger ownership controls pin modules and owner assignments" do
    owners = DebuggerPendingOwnership.owners()

    assert :ok = DebuggerPendingOwnership.assert_valid!(owners)

    assert_raise ExUnit.AssertionError,
                 ~r/dbg_ieval expected=01\.1\.1\.3\.1\.2 actual=<missing>/,
                 fn ->
                   DebuggerPendingOwnership.assert_valid!(Map.delete(owners, :dbg_ieval))
                 end

    assert_raise ExUnit.AssertionError,
                 ~r/dbg_ieval expected=01\.1\.1\.3\.1\.2 actual=01\.1\.1\.3\.1\.1/,
                 fn ->
                   DebuggerPendingOwnership.assert_valid!(
                     Map.put(owners, :dbg_ieval, "01.1.1.3.1.1")
                   )
                 end
  end

  test "concurrent source evidence extraction uses isolated roots" do
    tasks = for _ <- 1..2, do: Task.async(fn -> SweepEvidence.source_roots!() end)
    evidences = Task.await_many(tasks, 30_000)
    roots = Enum.map(evidences, & &1.archive_root)
    on_exit(fn -> Enum.each(roots, &File.rm_rf!/1) end)

    assert MapSet.size(MapSet.new(roots)) == 2

    for {root, index} <- Enum.with_index(roots) do
      marker = "concurrent-probe-#{index}"
      path = Path.join(root, marker)
      File.write!(path, Integer.to_string(index))
      assert File.read!(path) == Integer.to_string(index)

      for other_root <- List.delete(roots, root) do
        refute File.exists?(Path.join(other_root, marker))
      end
    end
  end

  test "extracts a receipt from CI lines with job and timestamp prefixes" do
    lines = receipt_lines("core")
    dir = Path.join(System.tmp_dir!(), "fablebook-receipt-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)

    log_path = Path.join(dir, "core.log")
    receipt_path = Path.join(dir, "core.jsonl")
    prefix = "core\tUNKNOWN STEP\t2026-10-30T18:56:49.0917397Z "
    File.write!(log_path, Enum.map_join(lines, "\n", &(prefix <> &1)) <> "\n")

    assert InstalledOtp.extract_receipt!(log_path, receipt_path) == receipt_path
    assert File.read!(receipt_path) == Enum.join(lines, "\n") <> "\n"
    assert InstalledOtp.verify_receipt_lines!(lines).lane == "core"
  end

  test "Xref query parity rejects successful empty and truncated results" do
    expected = [{:probe, :run, 0}, {:probe, :stop, 1}]

    assert InstalledOtp.assert_xref_query!(fn -> {:ok, expected} end, :exports, "core", expected) ==
             expected

    assert_raise InstalledOtp.Error, ~r/xref_query_parity/, fn ->
      InstalledOtp.assert_xref_query!(fn -> {:ok, []} end, :exports, "core", expected)
    end

    assert_raise InstalledOtp.Error, ~r/xref_query_parity/, fn ->
      InstalledOtp.assert_xref_query!(
        fn -> {:ok, Enum.take(expected, 1)} end,
        :exports,
        "core",
        expected
      )
    end
  end

  test "Xref edge query parity normalizes callee arity without losing caller MFA" do
    caller = {:probe, :caller, 2}
    expected = [{caller, {:sink, :run}}]
    returned = [{caller, {:sink, :run, 0}}, {caller, {:sink, :run, 1}}]

    normalize = fn
      {from, {module, function, _arity}} -> {from, {module, function}}
      row -> row
    end

    assert InstalledOtp.assert_xref_query!(
             fn -> {:ok, returned} end,
             :edges,
             "core",
             expected,
             normalize
           ) == returned

    assert_raise InstalledOtp.Error, ~r/xref_query_parity/, fn ->
      InstalledOtp.assert_xref_query!(
        fn -> {:ok, [hd(returned), hd(returned)]} end,
        :edges,
        "core",
        expected,
        normalize
      )
    end
  end

  test "independent beam AST inventory follows local, remote, operator, and dynamic calls" do
    anno = 1

    forms = [
      {:attribute, anno, :module, :probe},
      {:function, anno, :local, 0, [{:clause, anno, [], [], [{:atom, anno, :ok}]}]},
      {:function, anno, :caller, 0,
       [
         {:clause, anno, [], [],
          [
            {:call, anno, {:atom, anno, :local}, []},
            {:call, anno, {:remote, anno, {:atom, anno, :sink}, {:atom, anno, :run}},
             [{:atom, anno, :x}]},
            {:op, anno, :+, {:integer, anno, 1}, {:integer, anno, 2}},
            {:call, anno, {:remote, anno, {:atom, anno, :erlang}, {:atom, anno, :is_list}},
             [{nil, anno}]},
            {:call, anno, {:remote, anno, {:var, anno, :module}, {:atom, anno, :run}},
             [{:atom, anno, :x}]},
            {:call, anno, {:var, anno, :function}, [{:atom, anno, :x}]}
          ]}
       ]}
    ]

    caller = {:probe, :caller, 0}

    assert BeamWalker.xref_edges(:probe, forms) ==
             Enum.sort([
               {caller, {:probe, :local, 0}},
               {caller, {:sink, :run, 1}},
               {caller, {:erlang, :+, 2}},
               {caller, {:"$M_EXPR", :run, 1}},
               {caller, {:"$M_EXPR", :"$F_EXPR", 1}}
             ])
  end

  test "receipts reject missing measurement records even when identity rows are intact" do
    lines =
      receipt_lines("core")
      |> Enum.reject(fn line ->
        case JSON.decode(String.replace_prefix(line, @marker, "")) do
          {:ok, %{"kind" => "metrics"}} -> true
          _ -> false
        end
      end)

    body = Enum.drop(lines, -1)
    {:ok, footer} = JSON.decode(String.replace_prefix(List.last(lines), @marker, ""))
    digest = :crypto.hash(:sha256, Enum.join(body, "\n") <> "\n") |> Base.encode16(case: :lower)
    footer_line = @marker <> JSON.encode!(Map.put(footer, "sha256", digest))

    assert_raise InstalledOtp.Error, ~r/receipt_metrics/, fn ->
      InstalledOtp.verify_receipt_lines!(body ++ [footer_line])
    end
  end

  test "receipts reject wrong lanes, duplicate or missing identities, and inconsistent totals" do
    lines = receipt_lines("core")

    wrong_lane =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "meta"} = row -> Map.put(row, "lane", "nearby")
          row -> row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_lane/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_lane)
    end

    duplicate_beam =
      rewrite_receipt(lines, fn rows ->
        beam = Enum.find(rows, &(&1["kind"] == "beam"))
        rows ++ [beam]
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_beam_records/, fn ->
      InstalledOtp.verify_receipt_lines!(duplicate_beam)
    end

    missing_beam =
      rewrite_receipt(lines, fn rows -> Enum.reject(rows, &(&1["kind"] == "beam")) end)

    assert_raise InstalledOtp.Error, ~r/receipt_empty_inventory/, fn ->
      InstalledOtp.verify_receipt_lines!(missing_beam)
    end

    wrong_total =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "metrics"} = row ->
            Map.put(row, "function_bytes", row["function_bytes"] + 1)

          row ->
            row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_metrics/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_total)
    end

    wrong_membership_link =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "active_module"} = row -> Map.put(row, "module", "missing_probe")
          row -> row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_links/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_membership_link)
    end

    wrong_caller_chain =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "pending_mfa"} = row -> Map.put(row, "caller_chain", ["probe.run"])
          row -> row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_membership_records/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_caller_chain)
    end

    wrong_source_link =
      rewrite_receipt(lines, fn rows ->
        rows =
          Enum.map(rows, fn
            %{"kind" => "app", "app" => "probe"} = row ->
              %{
                row
                | "source_dir_status" => "present",
                  "source_file_count" => 1,
                  "source_bytes" => 1
              }

            %{"kind" => "beam", "app" => "probe"} = row ->
              %{
                row
                | "source" => "src/probe.erl",
                  "source_status" => "present",
                  "source_bytes" => 1
              }

            %{"kind" => "source_app", "app" => "probe"} = row ->
              %{
                row
                | "source_dir_status" => "present",
                  "source_file_count" => 1,
                  "source_bytes" => 1,
                  "mapped_beams" => 1,
                  "unavailable_source_beams" => 0
              }

            %{"kind" => "metrics"} = row ->
              %{
                row
                | "source_file_count" => 1,
                  "source_bytes" => 1,
                  "mapped_beams" => 1,
                  "unavailable_source_beams" => 0
              }

            row ->
              row
          end)

        rows ++
          [%{"kind" => "source_file", "app" => "probe", "path" => "src/other.erl", "bytes" => 1}]
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_links/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_source_link)
    end

    assert_raise InstalledOtp.Error, ~r/receipt_json/, fn ->
      InstalledOtp.verify_receipt_lines!([@marker <> "{"])
    end
  end

  test "source inventory maps every readable installed source file to a BEAM and counts bytes" do
    dir = temp_dir!()
    root = Path.join(dir, "lib")
    app_root = Path.join(root, "probe-1.0.0")
    ebin = Path.join(app_root, "ebin")
    src = Path.join(app_root, "src")
    File.mkdir_p!(ebin)
    File.mkdir_p!(src)
    source = Path.join(src, "probe.erl")

    source_text =
      "-module(probe).\n-export([run/0, behaviour_info/1]).\n" <>
        "behaviour_info(callbacks) -> [].\nrun() -> ok.\n"

    File.write!(source, source_text)
    File.write!(Path.join(ebin, "probe.app"), app_resource(:probe, "1.0.0", [:probe]))

    :ok =
      File.cd!(app_root, fn ->
        {:ok, :probe} =
          :compile.file(~c"src/probe.erl", [:debug_info, {:outdir, String.to_charlist(ebin)}])

        :ok
      end)

    discovered = InstalledOtp.discover!(root, lane: "core")
    assert InstalledOtp.assert_discovery_complete!(root, discovered, lane: "core") == :ok
    inspected = InstalledOtp.inspect!(discovered, lane: "core")
    exports = InstalledOtp.export_inventory!([ebin], lane: "core")

    assert {:probe, :run, 0} in exports
    refute {:probe, :module_info, 0} in exports
    refute {:probe, :module_info, 1} in exports
    assert {:probe, :behaviour_info, 1} in exports

    used_predefined_exports =
      InstalledOtp.export_inventory!([ebin],
        lane: "core",
        edges: [{{:consumer, :run, 0}, {:probe, :module_info, 0}}]
      )

    assert {:probe, :module_info, 0} in used_predefined_exports
    refute {:probe, :module_info, 1} in used_predefined_exports

    [source_app] =
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: "core",
        required_modules: [:probe]
      )

    assert source_app.source_dir_status == "present"
    assert source_app.source_file_count == 1
    assert source_app.source_bytes == byte_size(source_text)
    assert source_app.mapped_beams == 1

    assert source_app.beams == [
             %{
               module: "probe",
               source: "src/probe.erl",
               status: "present",
               bytes: byte_size(source_text)
             }
           ]
  end

  test "source inventory and receipts include contained generated sources outside src" do
    root = temp_dir!() |> Path.join("lib")
    %{ebin: ebin} = create_probe_app!(root, "probe", "1.0.0", :probe, true)
    generated_source = "-module(probe).\n"
    File.write!(Path.join(ebin, "generated_probe.erl"), generated_source)

    discovered = InstalledOtp.discover!(root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")
    inspected = [%{hd(inspected) | source: "src/../ebin/generated_probe.erl"}]

    [source_app] = InstalledOtp.source_inventory!(discovered, inspected, lane: "core")

    assert source_app.source_dir_status == "missing"
    assert source_app.source_file_count == 1
    assert source_app.source_bytes == byte_size(generated_source)
    assert source_app.mapped_beams == 1

    assert source_app.beams == [
             %{
               module: "probe",
               source: "ebin/generated_probe.erl",
               status: "present",
               bytes: byte_size(generated_source)
             }
           ]

    receipt_lines =
      InstalledOtp.receipt_lines(%{
        lane: %{name: "core", elixir: "1.20.4", otp: "29.1.2"},
        lock_sha256: SweepEvidence.lock_digests!()["core"],
        discovered: discovered,
        inspected: inspected,
        ingested: [%{app: "probe", module: "probe", module_atom: :probe}],
        sources: [source_app]
      })

    receipt = InstalledOtp.verify_receipt_lines!(receipt_lines)
    beam = Enum.find(receipt.beams, &(&1["module"] == "probe"))

    assert beam["source"] == "ebin/generated_probe.erl"
    assert beam["source_status"] == "present"

    assert Enum.any?(receipt_lines, fn line ->
             {:ok, row} = JSON.decode(String.replace_prefix(line, @marker, ""))
             row["kind"] == "source_file" and row["path"] == "ebin/generated_probe.erl"
           end)
  end

  test "source inventory fails on unreadable files and required active source gaps" do
    root = temp_dir!() |> Path.join("lib")
    app_root = Path.join(root, "probe-1.0.0")
    ebin = Path.join(app_root, "ebin")
    File.mkdir_p!(ebin)
    File.write!(Path.join(ebin, "probe.app"), app_resource(:probe, "1.0.0", [:probe]))
    write_probe_beam!(ebin, :probe, debug_info: true)
    discovered = InstalledOtp.discover!(root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")

    assert_raise InstalledOtp.Error, ~r/required_source_missing/, fn ->
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: "core",
        required_modules: [:probe]
      )
    end

    source_root = Path.join(app_root, "src")
    File.mkdir_p!(source_root)
    File.write!(Path.join(source_root, "probe.erl"), "source")
    inspected = [%{hd(inspected) | source: "src/probe.erl"}]

    assert_raise InstalledOtp.Error, ~r/source_file_unreadable/, fn ->
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: "core",
        required_modules: [:probe],
        source_reader: fn _path -> {:error, :eacces} end
      )
    end

    escaped = [%{hd(inspected) | source: "../../outside.erl"}]

    assert_raise InstalledOtp.Error, ~r/source_escape/, fn ->
      InstalledOtp.source_inventory!(discovered, escaped, lane: "core")
    end

    outside = Path.join(Path.dirname(app_root), "outside.erl")
    File.write!(outside, "outside")
    source_path = Path.join(source_root, "probe.erl")
    File.rm!(source_path)
    File.ln_s!(outside, source_path)

    assert_raise InstalledOtp.Error, ~r/source_escape/, fn ->
      InstalledOtp.source_inventory!(discovered, inspected, lane: "core")
    end
  end

  test "parity rejects omission of a discovered app or BEAM during inspection and Xref intake" do
    root = temp_dir!() |> Path.join("lib")
    app_one = create_probe_app!(root, "probe_one", "1.0.0", :probe_one, true)
    app_two = create_probe_app!(root, "probe_two", "1.0.0", :probe_two, true)
    discovered = InstalledOtp.discover!(root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")

    assert_raise InstalledOtp.Error, ~r/discovery_parity/, fn ->
      InstalledOtp.assert_discovery_complete!(
        root,
        Enum.reject(discovered, &(&1.app == app_two.app)),
        lane: "core"
      )
    end

    app_one_discovered = Enum.find(discovered, &(&1.app == app_one.app))

    omitted_app_beams = [
      %{app_one_discovered | beams: []} | Enum.reject(discovered, &(&1.app == app_one.app))
    ]

    assert_raise InstalledOtp.Error, ~r/discovery_parity/, fn ->
      InstalledOtp.assert_discovery_complete!(root, omitted_app_beams, lane: "core")
    end

    incomplete_inspection = Enum.reject(inspected, &(&1.app == app_two.app))
    complete_ingestion = Enum.map(inspected, &%{app: &1.app, module: &1.module})

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, incomplete_inspection, complete_ingestion, "core")
    end

    app_one_inspected = Enum.filter(inspected, &(&1.app == app_one.app))
    incomplete_ingestion = Enum.map(app_one_inspected, &%{app: &1.app, module: &1.module})

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, inspected, incomplete_ingestion, "core")
    end

    discovered_one = Enum.find(discovered, &(&1.app == app_one.app))
    [first_beam | _] = discovered_one.beams

    omitted_beam_inspection =
      Enum.reject(inspected, &(&1.app == app_one.app and &1.module == first_beam.module))

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, omitted_beam_inspection, complete_ingestion, "core")
    end
  end

  test "discovery and ingestion reject duplicate, unreadable, corrupt, missing-debug, and incomplete identities" do
    root = temp_dir!() |> Path.join("lib")
    create_probe_app!(root, "probe_one", "1.0.0", :same_probe, true)
    create_probe_app!(root, "probe_two", "1.0.0", :same_probe, true)

    assert_raise InstalledOtp.Error, ~r/duplicate_module/, fn ->
      InstalledOtp.discover!(root, lane: "core")
    end

    clean_root = temp_dir!() |> Path.join("lib")
    app = create_probe_app!(clean_root, "probe", "1.0.0", :probe, true)
    [discovered] = InstalledOtp.discover!(clean_root, lane: "core")
    beam = hd(discovered.beams)

    assert_raise InstalledOtp.Error, ~r/beam_identity/, fn ->
      InstalledOtp.discover!(clean_root,
        lane: "core",
        beam_chunks: fn _path, _chunks -> {:error, :beam_lib, :eacces} end
      )
    end

    File.write!(beam.path, "not a beam")

    assert_raise InstalledOtp.Error, ~r/beam_identity/, fn ->
      InstalledOtp.discover!(clean_root, lane: "core")
    end

    write_probe_beam!(app.ebin, :probe, debug_info: false)
    discovered = InstalledOtp.discover!(clean_root, lane: "core")

    assert_raise InstalledOtp.Error, ~r/inspection_failed/, fn ->
      InstalledOtp.inspect!(discovered, lane: "core")
    end

    write_probe_beam!(app.ebin, :probe, debug_info: true)
    discovered = InstalledOtp.discover!(clean_root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")
    app = hd(discovered)

    assert_raise InstalledOtp.Error, ~r/xref_ingest/, fn ->
      InstalledOtp.add_directory!(:ignored, app,
        lane: "core",
        add_directory: fn _xref, _path -> {:error, :injected_failure} end
      )
    end

    incomplete =
      InstalledOtp.add_directory!(:ignored, app,
        lane: "core",
        add_directory: fn _xref, _path -> {:ok, []} end
      )

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, inspected, incomplete, "core")
    end
  end

  defp receipt_lines(lane) do
    {elixir, otp} =
      case lane do
        "core" -> {"1.20.4", "29.1.2"}
        "floor" -> {"1.18.5", "27.3.4.9"}
      end

    rows = [
      %{
        "kind" => "meta",
        "schema" => "fablebook.otp-inventory.v2",
        "lane" => lane,
        "elixir" => elixir,
        "otp" => otp,
        "lock_sha256" => SweepEvidence.lock_digests!()[lane]
      },
      %{
        "kind" => "app",
        "app" => "probe",
        "version" => "1.0.0",
        "path" => "probe-1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0
      },
      %{
        "kind" => "beam",
        "app" => "probe",
        "version" => "1.0.0",
        "module" => "probe",
        "path" => "probe-1.0.0/ebin/probe.beam",
        "inspection" => "ok",
        "xref" => "ok",
        "function_count" => 1,
        "function_bytes" => 1,
        "beam_bytes" => 1,
        "source" => nil,
        "source_status" => "unavailable",
        "source_bytes" => nil
      },
      %{
        "kind" => "app",
        "app" => "pending_probe",
        "version" => "1.0.0",
        "path" => "pending_probe-1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0
      },
      %{
        "kind" => "beam",
        "app" => "pending_probe",
        "version" => "1.0.0",
        "module" => "pending_probe",
        "path" => "pending_probe-1.0.0/ebin/pending_probe.beam",
        "inspection" => "ok",
        "xref" => "ok",
        "function_count" => 1,
        "function_bytes" => 1,
        "beam_bytes" => 1,
        "source" => "src/pending_probe.erl",
        "source_status" => "missing",
        "source_bytes" => nil
      },
      %{
        "kind" => "source_app",
        "app" => "probe",
        "version" => "1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0,
        "mapped_beams" => 0,
        "missing_source_beams" => 0,
        "unavailable_source_beams" => 1
      },
      %{
        "kind" => "source_app",
        "app" => "pending_probe",
        "version" => "1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0,
        "mapped_beams" => 0,
        "missing_source_beams" => 1,
        "unavailable_source_beams" => 0
      },
      %{"kind" => "active_app", "app" => "probe"},
      %{"kind" => "active_module", "app" => "probe", "module" => "probe"},
      %{
        "kind" => "active_export",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0
      },
      %{
        "kind" => "active_edge",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0,
        "callee_app" => "pending_probe",
        "callee_module" => "pending_probe",
        "callee_function" => "run"
      },
      %{
        "kind" => "export",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0
      },
      %{
        "kind" => "reached",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0
      },
      %{
        "kind" => "boundary",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0,
        "explicit_boundary_exclusion" => true
      },
      %{"kind" => "pending_app", "app" => "pending_probe", "owner" => "01.1.1.3"},
      %{
        "kind" => "pending_module",
        "app" => "pending_probe",
        "module" => "pending_probe",
        "function_count" => 1,
        "function_bytes" => 1,
        "source_status" => "missing",
        "source" => "src/pending_probe.erl",
        "source_bytes" => nil,
        "owner" => "01.1.1.3"
      },
      %{
        "kind" => "pending_mfa",
        "app" => "pending_probe",
        "module" => "pending_probe",
        "function" => "run",
        "arity" => 0,
        "caller_chain" => ["probe.run/0"],
        "owner" => "01.1.1.3"
      },
      %{
        "kind" => "metrics",
        "app_count" => 2,
        "beam_count" => 2,
        "function_count" => 2,
        "function_bytes" => 2,
        "beam_bytes" => 2,
        "source_file_count" => 0,
        "source_bytes" => 0,
        "mapped_beams" => 0,
        "missing_source_beams" => 1,
        "unavailable_source_beams" => 1,
        "exported_matches" => 1,
        "reached_matches" => 1,
        "boundary_matches" => 1,
        "active_app_count" => 1,
        "active_module_count" => 1,
        "active_export_count" => 1,
        "active_edge_count" => 1,
        "pending_app_count" => 1,
        "pending_module_count" => 1,
        "pending_mfa_count" => 1,
        "discovery_ms" => 0,
        "inspection_ms" => 0,
        "source_scan_ms" => 0,
        "xref_ms" => 0,
        "graph_ms" => 0,
        "pending_owner" => "01.1.1.3"
      }
    ]

    body = Enum.map(rows, &(@marker <> JSON.encode!(&1)))
    digest = :crypto.hash(:sha256, Enum.join(body, "\n") <> "\n") |> Base.encode16(case: :lower)

    footer =
      @marker <>
        JSON.encode!(%{
          "kind" => "footer",
          "apps" => 2,
          "beams" => 2,
          "source_files" => 0,
          "active_records" => 4,
          "export_records" => 1,
          "reached_records" => 1,
          "boundary_records" => 1,
          "pending_records" => 3,
          "sha256" => digest
        })

    body ++ [footer]
  end

  defp rewrite_receipt(lines, transform) do
    body =
      lines
      |> Enum.drop(-1)
      |> Enum.map(fn line ->
        {:ok, row} = JSON.decode(String.replace_prefix(line, @marker, ""))
        row
      end)
      |> transform.()

    encoded = Enum.map(body, &(@marker <> JSON.encode!(&1)))
    counts = Enum.frequencies_by(body, & &1["kind"])

    footer = %{
      "kind" => "footer",
      "apps" => counts["app"] || 0,
      "beams" => counts["beam"] || 0,
      "source_files" => counts["source_file"] || 0,
      "active_records" =>
        Enum.sum(
          Enum.map(~w(active_app active_module active_export active_edge), &(counts[&1] || 0))
        ),
      "export_records" => counts["export"] || 0,
      "reached_records" => counts["reached"] || 0,
      "boundary_records" => counts["boundary"] || 0,
      "pending_records" =>
        Enum.sum(Enum.map(~w(pending_app pending_module pending_mfa), &(counts[&1] || 0))),
      "sha256" =>
        :crypto.hash(:sha256, Enum.join(encoded, "\n") <> "\n") |> Base.encode16(case: :lower)
    }

    encoded ++ [@marker <> JSON.encode!(footer)]
  end

  defp temp_dir! do
    dir =
      Path.join(System.tmp_dir!(), "fablebook-inventory-#{System.unique_integer([:positive])}")

    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end

  defp create_probe_app!(root, app, version, module, debug_info?) do
    app_root = Path.join(root, "#{app}-#{version}")
    ebin = Path.join(app_root, "ebin")
    File.mkdir_p!(ebin)

    File.write!(
      Path.join(ebin, "#{app}.app"),
      app_resource(Map.fetch!(@probe_app_atoms, app), version, [module])
    )

    write_probe_beam!(ebin, module, debug_info: debug_info?)
    %{app: app, root: app_root, ebin: ebin}
  end

  defp write_probe_beam!(ebin, module, opts) do
    forms = [
      {:attribute, 1, :module, module},
      {:attribute, 1, :export, [probe: 0]},
      {:function, 1, :probe, 0, [{:clause, 1, [], [], [{:atom, 1, :ok}]}]}
    ]

    compile_opts = if Keyword.get(opts, :debug_info), do: [:debug_info], else: []
    {:ok, ^module, beam} = :compile.forms(forms, compile_opts)
    File.write!(Path.join(ebin, "#{Atom.to_string(module)}.beam"), beam)
  end

  defp app_resource(app, version, modules) do
    resource = {:application, app, [{:vsn, String.to_charlist(version)}, {:modules, modules}]}
    :io_lib.format("~tp.~n", [resource])
  end
end
