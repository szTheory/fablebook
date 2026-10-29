macro = "compile-time macro body; runs only while the caller is being compiled"

own_native =
  "loads its own NIF or OTP's own trace or scanner driver by a fixed name; no caller-chosen library"

callback =
  "process callback or loop; reached only through the module's front door, which the sweep judges separately"

expansion =
  "expansion inside a module being compiled: evaluates only that module's own definitions; AST from input needs a banned parser or atom creation"

own_clauses =
  "evaluates guards or patterns already compiled into the caller (error blame, assertion diff); takes no source"

compiler_pass =
  "compiler, analysis or parse-transform pass: returns forms, Core or a binary and loads nothing"

project_build =
  "Mix build step over the host project's own mix.exs, sources and lockfile; Mix.Task.run targets are computed (T-01.1-07)"

by_name =
  "loads a module by name from the code path; the code-path mutators are banned, so only beams already on the path load"

cover_server =
  "cover server API over modules already cover-compiled through a banned :cover compile function"

console = "boot, console or line-editing code of the running VM"
crypto_key = "reaches only beam_lib's lookup of the fixed .erlang.crypt key file"
epp_guard = "parses source with epp, whose -if conditions run as guard tests only; loads nothing"
boot_script = "writes c:erlangrc into a generated boot script as data; loads nothing"
dist_config = "evaluates the VM's own TLS distribution option file named on its command line"

iex_console =
  "IEx console internal, reached only inside a running IEx through the banned IEx front doors"

fixed_app =
  "puts only a named OTP application or Mix's own archive directory on the code path; loads no caller code"

[
  {{:fun_prefix, "MACRO-"}, macro},
  {:erl_tracer, own_native},
  {:prim_buffer, own_native},
  {:prim_file, own_native},
  {:prim_net, own_native},
  {:prim_socket, own_native},
  {:prim_tty, own_native},
  {:zlib, own_native},
  {{:dbg, [:trace_port]}, own_native},
  {{:inets, [:enable_trace]}, own_native},
  {:inets_trace, own_native},
  {:fprof, own_native},
  {:erl_compile_server, callback},
  {:peer, callback},
  {{IEx.Introspection, [:decompose]}, expansion},
  {{Kernel.Typespec, [:translate_typespecs_for_module]}, expansion},
  {{Kernel.Utils, [:defguard]}, expansion},
  {{Macro, [:expand, :expand_once, :expand_literal, :expand_literals]}, expansion},
  {{Macro.Env, [:expand_import]}, expansion},
  {{Module, [:add_doc, :compile_definition_attributes]}, expansion},
  {{Protocol, [:__derive__, :__impl__]}, expansion},
  {{Record, [:__access__]}, expansion},
  {{ExUnit.Assertions, [:__expand_pattern__, :__match__]}, expansion},
  {:elixir_bitstring, expansion},
  {:elixir_clauses, expansion},
  {:elixir_def, expansion},
  {:elixir_dispatch, expansion},
  {:elixir_expand, expansion},
  {:elixir_fn, expansion},
  {:elixir_map, expansion},
  {:elixir_overridable, expansion},
  {{:elixir_module, [:expand_callback]}, expansion},
  {{:elixir_erl, [:definition_to_anonymous]}, expansion},
  {Exception, own_clauses},
  {FunctionClauseError, own_clauses},
  {ExUnit.AssertionError, own_clauses},
  {ExUnit.CLIFormatter, own_clauses},
  {ExUnit.Diff, own_clauses},
  {ExUnit.Formatter, own_clauses},
  {{Protocol, [:consolidate]}, compiler_pass},
  {{:elixir_erl, [:compile, :consolidate, :debug_info]}, compiler_pass},
  {:erl_abstract_code, compiler_pass},
  {:beam_core_to_ssa, compiler_pass},
  {:beam_ssa_bsm, compiler_pass},
  {:beam_ssa_opt, compiler_pass},
  {:beam_ssa_pre_codegen, compiler_pass},
  {:v3_core, compiler_pass},
  {:erl_compile, compiler_pass},
  {:merl_transform, compiler_pass},
  {:ms_transform, compiler_pass},
  {{:qlc, [:parse_transform, :transform_from_evaluator]}, compiler_pass},
  {:qlc_pt, compiler_pass},
  {{:prefix, ":dialyzer"}, compiler_pass},
  {:typer, compiler_pass},
  {:typer_core, compiler_pass},
  {Mix.AppLoader, project_build},
  {Mix.Compilers.Elixir, project_build},
  {Mix.Compilers.Protocol, project_build},
  {Mix.Dep, project_build},
  {Mix.Dep.Converger, project_build},
  {Mix.Dep.Fetcher, project_build},
  {Mix.Dep.Loader, project_build},
  {Mix.Dep.Umbrella, project_build},
  {Mix.Hex, project_build},
  {{Mix.Project, [:compile, :deps_apps, :deps_paths, :deps_scms, :deps_tree]}, project_build},
  {Mix.Release, project_build},
  {Mix.Task, project_build},
  {Mix.Task.Compiler, project_build},
  {{:prefix, "Mix.Tasks.App."}, project_build},
  {{:prefix, "Mix.Tasks.Compile"}, project_build},
  {{:prefix, "Mix.Tasks.Deps"}, project_build},
  {Mix.Tasks.Archive.Build, project_build},
  {Mix.Tasks.Archive.Uninstall, project_build},
  {Mix.Tasks.Clean, project_build},
  {Mix.Tasks.Cmd, project_build},
  {Mix.Tasks.Do, project_build},
  {Mix.Tasks.Escript.Build, project_build},
  {Mix.Tasks.Escript.Uninstall, project_build},
  {Mix.Tasks.Format, project_build},
  {Mix.Tasks.Help, project_build},
  {Mix.Tasks.Loadpaths, project_build},
  {Mix.Tasks.Local.Hex, project_build},
  {Mix.Tasks.New, project_build},
  {Mix.Tasks.Release, project_build},
  {Mix.Tasks.Source, project_build},
  {Mix.Tasks.Test.Coverage, project_build},
  {Mix.Tasks.Xref, project_build},
  {{:code, [:ensure_loaded, :ensure_modules_loaded, :load_file]}, by_name},
  {:cover, cover_server},
  {{:elixir, [:start, :start_cli]}, console},
  {:erl_init, console},
  {:edlin_context, console},
  {:edlin_expand, console},
  {:group, console},
  {:standard_error, console},
  {:user_drv, console},
  {:beam_lib, crypto_key},
  {{:escript, [:extract, :parse_file]}, epp_guard},
  {:yecc, epp_guard},
  {:systools, boot_script},
  {:systools_make, boot_script},
  {{:ssl_dist_sup, [:start_link]}, dist_config},
  {:inet_tls_dist, dist_config},
  {:inet6_tls_dist, dist_config},
  {:inet_epmd_tls_socket, dist_config},
  {IEx.Autocomplete, iex_console},
  {IEx.CLI, iex_console},
  {IEx.Config, iex_console},
  {IEx.Info.Atom, iex_console},
  {IEx.Introspection, iex_console},
  {{Mix, [:start]}, callback},
  {:sasl, callback},
  {Mix.Compilers.Erlang, project_build},
  {{:prefix, "Mix.Tasks.Local."}, project_build},
  {{Mix.Local, [:find_matching_versions!, :find_matching_versions_from_signed_csv!, :decode_pk!]},
   project_build},
  {{Mix.Local, [:append_archives, :append_paths]}, fixed_app},
  {{Mix.Utils, [:read_path]}, fixed_app},
  {:asn1_db, compiler_pass},
  {{:prefix, ":asn1ct_"}, compiler_pass}
]
