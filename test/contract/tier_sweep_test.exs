defmodule Fablebook.Contract.TierSweepTest do
  use ExUnit.Case, async: false

  alias Fablebook.Credo.BannedCalls
  alias Fablebook.Test.BeamWalker
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

    assert MapSet.subset?(historical_apps, discovered_apps)
    assert graph.pending_apps != []
    assert Enum.all?(graph.pending_apps, &(not MapSet.member?(historical_apps, &1.app)))
    assert graph.exported == graph.historical_active_exported
    assert MapSet.new(graph.edges) == MapSet.new(graph.historical_active_edges)
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
        required_modules: ~w(file io erl_scan yecc)
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
      InstalledOtp.export_inventory!(historical_graph_dirs, lane: evidence.lane.name)

    expected_full_exports =
      InstalledOtp.export_inventory!(full_graph_dirs, lane: evidence.lane.name)

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

    active_edges =
      Enum.filter(full_edges, fn {{module, _, _}, _} ->
        MapSet.member?(historical_modules, module)
      end)

    active_exported =
      Enum.filter(full_exported, fn {module, _, _} ->
        MapSet.member?(historical_modules, module)
      end)

    active_reverse = reverse(active_edges)
    active_forward = forward(active_edges)
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

    assert_active_sets_preserved!(
      historical_reached,
      full_reached,
      historical_exported,
      full_exported,
      historical_edges,
      full_edges,
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
        xref_graph.historical_exports,
        historical_edges,
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
          not MapSet.member?(historical_modules, inspection.module_atom),
          do: inspection

    pending_mfas = MapSet.difference(full_reached, historical_reached)

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
      exported: MapSet.new(active_exported),
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
      active_expansion_failures: active_expansion_failures,
      receipt_lines: receipt_lines,
      lane: evidence.lane,
      lock_sha256: evidence.lock_sha256
    }
  end

  defp assert_active_sets_preserved!(
         historical_reached,
         full_reached,
         historical_exported,
         full_exported,
         historical_edges,
         full_edges,
         lane
       ) do
    preserved =
      MapSet.subset?(historical_reached, full_reached) and
        MapSet.subset?(historical_exported, full_exported) and
        MapSet.subset?(MapSet.new(historical_edges), MapSet.new(full_edges))

    unless preserved,
      do: raise("installed OTP expansion removed historical active coverage for #{lane}")
  end

  defp assert_no_new_active_failures!(
         full_reached,
         historical_reached,
         historical_modules,
         tier,
         names,
         lane
       ) do
    failures =
      full_reached
      |> MapSet.difference(historical_reached)
      |> Enum.filter(fn {module, _function, _arity} = mfa ->
        MapSet.member?(historical_modules, module) and
          disposition(mfa, tier, names, @exclusions) == nil
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
         historical_exports,
         historical_edges,
         module_app
       ) do
    apps =
      historical_ingested
      |> Enum.map(& &1.app)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(&%{"kind" => "active_app", "app" => &1})

    modules =
      historical_ingested
      |> Enum.uniq_by(&{&1.app, &1.module})
      |> Enum.map(
        &%{"kind" => "active_module", "app" => &1.app, "module" => Atom.to_string(&1.module_atom)}
      )
      |> Enum.sort_by(&{&1["app"], &1["module"]})

    exports = mfa_records("active_export", historical_exports, module_app)

    edges =
      historical_edges
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
  alias Fablebook.Test.{BeamWalker, InstalledOtp, SweepEvidence}

  @moduletag :inventory_support
  @marker "FABLEBOOK_OTP_INVENTORY_V2 "
  @probe_app_atoms %{"probe" => :probe, "probe_one" => :probe_one, "probe_two" => :probe_two}

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
    source_text = "-module(probe).\n-export([run/0]).\nrun() -> ok.\n"
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
