defmodule Fablebook.Contract.TierSweepTest do
  use ExUnit.Case, async: false

  alias Fablebook.Credo.BannedCalls
  alias Fablebook.Test.SweepEvidence
  @compile {:no_warn_undefined, :xref}

  Code.ensure_loaded?(BannedCalls) ||
    Code.require_file(Path.expand("../../credo/checks/banned_calls.ex", __DIR__))

  @otp_apps ~w(
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
    {:yecc, :epp_guard},
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
    {{:file, [:consult]}, :pure_data, ["kernel/src/file.erl:2314", "kernel/src/file.erl:2304"]},
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
    {{:kernel, [:init]}, :callback}
  ]

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
    Mix.ensure_application!(:tools)
    otp_lib = :code.lib_dir() |> to_string()
    otp_dirs = otp_app_dirs(otp_lib)
    elixir_dirs = for app <- @elixir_apps, do: app_dir(app)
    roots = dependency_roots()
    closure = dependency_closure(roots)
    dep_dirs = for app <- closure, do: Path.join([Mix.Project.build_path(), "lib", app, "ebin"])
    dirs = Enum.uniq(otp_dirs ++ elixir_dirs ++ dep_dirs)
    missing_apps = missing_apps(otp_lib, elixir_dirs, dep_dirs)

    {:ok, _} = :xref.start(:tier_sweep, xref_mode: :functions)

    :ok = :xref.set_default(:tier_sweep, warnings: false, verbose: false, builtins: true)

    for dir <- dirs, do: :xref.add_directory(:tier_sweep, String.to_charlist(dir))
    {:ok, xref_edges} = :xref.q(:tier_sweep, ~c"E")
    {:ok, exported} = :xref.q(:tier_sweep, ~c"X")
    :xref.stop(:tier_sweep)
    {form_edges, no_debug} = form_edges(dirs)
    edges = form_edges ++ for({caller, {m, f, _}} <- xref_edges, do: {caller, {m, f}})
    reverse = reverse(edges)
    forward = forward(edges)

    %{
      dirs: dirs,
      edges: edges,
      exported: MapSet.new(exported),
      reverse: reverse,
      forward: forward,
      no_debug: no_debug,
      missing_apps: missing_apps,
      roots: roots,
      closure: closure,
      out_of_scope: out_of_scope()
    }
  end

  defp otp_app_dirs(otp_lib) do
    otp_lib
    |> File.ls!()
    |> Enum.filter(fn dir ->
      Enum.any?(@otp_apps, &String.starts_with?(dir, "#{&1}-")) and
        File.dir?(Path.join([otp_lib, dir, "ebin"]))
    end)
    |> Enum.map(&Path.join([otp_lib, &1, "ebin"]))
  end

  defp missing_apps(otp_lib, elixir_dirs, dep_dirs) do
    otp_apps = Enum.map(@otp_apps, &Atom.to_string/1)
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

  defp out_of_scope do
    all = :code.lib_dir() |> to_string() |> File.ls!()
    scoped = Enum.map(@otp_apps, &Atom.to_string/1)

    all
    |> Enum.filter(&File.dir?(Path.join([:code.lib_dir() |> to_string(), &1, "ebin"])))
    |> Enum.map(&String.replace(&1, ~r/-[0-9][0-9.]*$/, ""))
    |> Enum.uniq()
    |> Enum.reject(&(&1 in scoped))
    |> Enum.sort()
  end

  defp form_edges(dirs) do
    beams =
      for dir <- dirs, file <- File.ls!(dir), String.ends_with?(file, ".beam"), do: {dir, file}

    Enum.reduce(beams, {[], []}, fn {dir, file}, acc -> collect_beam_edges(dir, file, acc) end)
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

  defp undisposed(graph, tier, names) do
    graph
    |> dispositions(tier, names)
    |> Enum.filter(&(elem(&1, 1) == nil))
    |> Enum.map(&elem(&1, 0))
  end

  defp dispositions(graph, tier, names) do
    {reached, _parent} = reach(graph, tier, names)

    reached
    |> Enum.filter(&MapSet.member?(graph.exported, &1))
    |> Enum.reject(fn {m, f, _arity} ->
      m in [:erlang, :erl_eval, :erl_ddll] or f == :module_info
    end)
    |> Enum.map(fn mfa -> {mfa, disposition(mfa, tier, names)} end)
  end

  defp disposition({m, f, a}, tier, names) do
    if covered?({m, f, a}, tier, names), do: :tier, else: exclusion_reason(m, f)
  end

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

  defp exclusion_reason(m, f) do
    Enum.find_value(@exclusions, fn
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
end
