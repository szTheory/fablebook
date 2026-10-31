defmodule Fablebook.Contract.BannedCallsTest do
  use ExUnit.Case, async: false

  alias Credo.SourceFile
  alias Credo.Test.CheckRunner
  alias Fablebook.Credo.BannedCalls
  alias Fablebook.Test.BeamWalker

  Code.ensure_loaded?(BannedCalls) ||
    Code.require_file(Path.expand("../../credo/checks/banned_calls.ex", __DIR__))

  @atom_tier [
    :eval_string,
    :eval_quoted,
    :eval_quoted_with_env,
    :eval_file,
    :string_to_quoted,
    :string_to_quoted!,
    :string_to_quoted_with_comments,
    :string_to_quoted_with_comments!,
    :compile_string,
    :compile_quoted,
    :compile_file,
    :require_file,
    :binary_to_atom,
    :list_to_atom,
    :binary_to_existing_atom,
    :list_to_existing_atom,
    :to_atom,
    :to_existing_atom,
    :binary_to_term,
    :erl_eval,
    :erl_scan,
    :erl_parse,
    :yamerl,
    Jason,
    Floki,
    MDEx,
    YamlElixir,
    Telemetry.Metrics
  ]

  @caller_formatter_fronts [
    {Logger.Formatter, :new, 1},
    {Logger, :configure_backend, 2},
    {Logger, :default_formatter, 0},
    {Logger, :default_formatter, 1},
    {Logger.App, :start, 0},
    {Logger.App, :start, 2},
    {ExUnit.CaptureServer, :handle_call, 3},
    {ExUnit.CaptureServer, :log_capture_on, 3},
    {ExUnit.CaptureLog, :capture_log, 1},
    {ExUnit.CaptureLog, :capture_log, 2},
    {ExUnit.CaptureLog, :with_log, 1},
    {ExUnit.CaptureLog, :with_log, 2},
    {ExUnit, :configure, 1},
    {ExUnit, :start, 0},
    {ExUnit, :start, 1},
    {ExUnit, :run, 0},
    {ExUnit, :run, 1},
    {ExUnit, :async_run, 0},
    {ExUnit.Runner, :run, 2}
  ]

  @mfa_tier [
    {String, :to_atom, 1},
    {String, :to_existing_atom, 1},
    {List, :to_atom, 1},
    {List, :to_existing_atom, 1},
    {Module, :concat, 1},
    {Module, :concat, 2},
    {Module, :safe_concat, 1},
    {Module, :safe_concat, 2},
    {Module, :create, 3},
    {EEx, :_, :_},
    {Phoenix.LiveView.TagEngine, :compile, 2},
    {:compile, :_, :_},
    {:code, :load_binary, 3},
    {:erlang, :load_module, 2},
    {:erlang, :prepare_loading, 2},
    {:erlang, :call_on_load_function, 1},
    {:erlang, :finish_after_on_load, 2},
    {:erlang, :finish_loading, 1},
    {:init, :boot, 1},
    {:init, :run_on_load_handlers, 0},
    {:erl_prim_loader, :get_modules, 2},
    {:erl_prim_loader, :get_modules, 3},
    {Config.Provider, :boot, :_},
    {System, :restart, 0},
    {:eval_bits, :expr_grp, :_},
    {:eval_bits, :match_bits, :_},
    {:eval_bits, :bin_gen, :_},
    {:qlc, :cursor, :_},
    {:qlc, :e, :_},
    {:qlc, :eval, :_},
    {:qlc, :fold, :_},
    {:qlc, :next_answers, :_},
    {:code, :load_abs, :_},
    {:code, :atomic_load, 1},
    {:code, :prepare_loading, 1},
    {:code, :finish_loading, 1},
    {Kernel.ParallelCompiler, :_, :_},
    {Code, :load_file, :_},
    {:elixir, :quoted_to_erl, :_},
    {:elixir_compiler, :_, :_},
    {:elixir_module, :compile, :_},
    {:elixir_tokenizer, :_, :_},
    {:elixir_parser, :_, :_},
    {:file, :script, :_},
    {:file, :eval, :_},
    {:file, :path_script, :_},
    {:file, :path_eval, :_},
    {:ct_make, :all, 0},
    {:ct_make, :all, 1},
    {:ct_make, :files, 1},
    {:ct_make, :files, 2},
    {:file, :consult, 1},
    {:file, :path_consult, 2},
    {:elixir, :eval_forms, :_},
    {:io, :read, :_},
    {:io, :parse_erl_exprs, :_},
    {:io, :parse_erl_form, :_},
    {:io, :scan_erl_exprs, :_},
    {:io, :scan_erl_form, :_},
    {:io, :fread, :_},
    {:io_lib, :fread, :_},
    {:epp, :_, :_},
    {:xmerl_scan, :_, :_},
    {:elixir, :string_to_tokens, :_},
    {Code, :format_string!, :_},
    {Code, :format_file!, :_},
    {Code.Fragment, :container_cursor_to_quoted, :_},
    {Logger.Formatter, :compile, :_},
    {Logger.Formatter, :new, 1},
    {Logger, :configure_backend, 2},
    {Logger, :default_formatter, 0},
    {Logger, :default_formatter, 1},
    {Logger.App, :start, 0},
    {Logger.App, :start, 2},
    {ExUnit.CaptureServer, :handle_call, 3},
    {ExUnit.CaptureServer, :log_capture_on, 3},
    {ExUnit.CaptureLog, :capture_log, 1},
    {ExUnit.CaptureLog, :capture_log, 2},
    {ExUnit.CaptureLog, :with_log, 1},
    {ExUnit.CaptureLog, :with_log, 2},
    {ExUnit, :configure, 1},
    {ExUnit, :start, 0},
    {ExUnit, :start, 1},
    {ExUnit, :run, 0},
    {ExUnit, :run, 1},
    {ExUnit, :async_run, 0},
    {ExUnit.Runner, :run, 2},
    {EEx.Compiler, :compile, :_},
    {Phoenix.Template.ExsEngine, :compile, :_},
    {Phoenix.Template.EExEngine, :compile, :_},
    {Phoenix.LiveView.Engine, :compile, :_},
    {Phoenix.LiveView.HTMLEngine, :compile, :_},
    {Phoenix.LiveView.TagEngine.Compiler, :compile, :_},
    {:xref_compiler, :compile, :_},
    {Mix.Compilers.Elixir, :compile, :_},
    {Mix.Compilers.Erlang, :compile, :_},
    {Mix.Tasks.Deps.Compile, :compile, :_},
    {:erl_compile, :compile, :_},
    {:erl_compile_server, :compile, :_},
    {:leex, :compile, :_},
    {:yecc, :compile, :_},
    {:yecc, :file, 1},
    {:yecc, :file, 2},
    {:yecc, :yecc, 2},
    {:yecc, :yecc, 3},
    {:yecc, :yecc, 4},
    {Mix.Project, :compile, :_},
    {:elixir_erl, :compile, :_},
    {:cover, :compile, :_},
    {:merl, :_, :_},
    {:asn1ct, :_, :_},
    {:qlc, :string_to_handle, :_},
    {:c, :erlangrc, :_},
    {:shell, :start, :_},
    {:shell, :server, :_},
    {:shell, :local_func, :_},
    {:shell, :read_and_add_records, :_},
    {:shell_default, :_, :_},
    {:escript, :start, :_},
    {:ssl_dist_sup, :consult, :_},
    {Config, :__eval__!, :_},
    {Config, :__import__!, :_},
    {Config.Reader, :_, :_},
    {Mix.Config, :_, :_},
    {Kernel.CLI, :_, :_},
    {Record, :extract, :_},
    {Record, :extract_all, :_},
    {Record.Extractor, :_, :_},
    {IEx, :_, :_},
    {IEx.Evaluator, :_, :_},
    {IEx.Helpers, :_, :_},
    {IEx.Pry, :_, :_},
    {IEx.Server, :_, :_},
    {:iex, :_, :_},
    {Mix.CLI, :_, :_},
    {Mix.Tasks.Eval, :_, :_},
    {Mix.Tasks.Run, :_, :_},
    {Mix.Tasks.Loadconfig, :_, :_},
    {Mix.Tasks.Profile.Cprof, :_, :_},
    {Mix.Tasks.Profile.Eprof, :_, :_},
    {Mix.Tasks.Profile.Fprof, :_, :_},
    {Mix.Tasks.Profile.Tprof, :_, :_},
    {Mix.Generator, :copy_template, :_},
    {Mix.Rebar, :_, :_},
    {Mix.Dep.Lock, :_, :_},
    {:release_handler, :_, :_},
    {:release_handler_1, :_, :_},
    {:c, :c, :_},
    {:c, :l, :_},
    {:c, :lc, :_},
    {:c, :lc_batch, :_},
    {:c, :lm, :_},
    {:c, :nc, :_},
    {:c, :nl, :_},
    {:c, :y, :_},
    {:make, :all, :_},
    {:make, :all_or_nothing, :_},
    {:make, :files, :_},
    {:cover, :compile_module, :_},
    {:cover, :compile_beam, :_},
    {:cover, :compile_directory, :_},
    {:cover, :compile_beam_directory, :_},
    {:elixir_erl_compiler, :_, :_},
    {:elixir, :tokens_to_quoted, :_},
    {Kernel.ParallelRequire, :_, :_},
    {Mix, :install, :_},
    {Mix.Project, :in_project, :_},
    {Mix.Local.Installer, :_, :_},
    {Mix.Tasks.Archive.Install, :_, :_},
    {Mix.Tasks.Escript.Install, :_, :_},
    {Mix.Tasks.Test, :_, :_},
    {Mix.Compilers.Test, :_, :_},
    {:erlang, :load_nif, 2},
    {:erl_ddll, :_, :_},
    {:code, :add_path, :_},
    {:code, :add_patha, :_},
    {:code, :add_pathz, :_},
    {:code, :add_paths, :_},
    {:code, :add_pathsa, :_},
    {:code, :add_pathsz, :_},
    {:code, :set_path, :_},
    {:code, :replace_path, :_},
    {Code, :prepend_path, :_},
    {Code, :prepend_paths, :_},
    {Code, :append_path, :_},
    {Code, :append_paths, :_},
    {Mix, :ensure_application!, :_},
    {:epp_dodger, :_, :_},
    {Mix.Task, :run, :_},
    {:code, :del_path, :_},
    {:code, :del_paths, :_},
    {Code, :delete_path, :_},
    {Code, :delete_paths, :_},
    {:erl_prim_loader, :set_path, :_},
    {:erl_prim_loader, :set_primary_archive, :_},
    {:code_server, :_, :_},
    {:erts_internal, :prepare_loading, :_},
    {:init, :make_permanent, :_},
    {:init, :restart, :_},
    {:error_handler, :breakpoint, :_},
    {:int, :i, :_},
    {:int, :ni, :_},
    {:int, :eval, :_},
    {:int, :meta, :_},
    {:i, :ii, :_},
    {:i, :ini, :_},
    {:debugger, :quick, :_},
    {:debugger, :start, :_},
    {:dbg_icmd, :eval, :_},
    {:dbg_icmd, :cmd, :_},
    {:dbg_icmd, :handle_msg, :_},
    {:dbg_ieval, :eval, :_},
    {:dbg_ieval, :eval_expr, :_},
    {:dbg_iserver, :call, :_},
    {:dbg_iserver, :safe_call, :_},
    {:dbg_iserver, :handle_call, :_},
    {:dbg_iload, :load_mod, :_},
    {:dbg_wx_interpret, :start, 4},
    {:dbg_debugged, :eval, :_},
    {Mix.Tasks.Format, :formatter_for_file, :_},
    {Mix.Tasks.Help, :run, :_},
    {Mix.Compilers.Erlang, :ensure_application!, 2},
    {Mix.Tasks.Test.Coverage, :start, 2},
    {Mix.Dep, :in_dependency, 3},
    {ExUnit.Diff, :compute, 3},
    {Mix.Local, :append_paths, 0},
    {Mix.Local, :append_archives, 0},
    {Mix.Local, :remove_paths, 0},
    {Mix.Local, :remove_archives, 0},
    {Mix.Phoenix, :eval_from, 3},
    {Mix.Phoenix, :copy_from, 4},
    {Mix.Phoenix.Context, :new, :_},
    {Mix.Phoenix.Schema, :new, 4},
    {Mix.Tasks.Phx.Server, :run, 1},
    {Mix.Tasks.Phx.Routes, :run, :_},
    {Mix.Tasks.Phx.Gen.Context, :build, 1},
    {Mix.Tasks.Phx.Gen.Context, :build, 2},
    {Mix.Tasks.Phx.Gen.Context, :run, 1},
    {Mix.Tasks.Phx.Gen.Context, :copy_new_files, 3},
    {Mix.Tasks.Phx.Gen.Context, :ensure_context_file_exists, 3},
    {Mix.Tasks.Phx.Gen.Context, :ensure_test_file_exists, 3},
    {Mix.Tasks.Phx.Gen.Context, :ensure_test_fixtures_file_exists, 3},
    {Mix.Tasks.Phx.Gen.Embedded, :build, 1},
    {Mix.Tasks.Phx.Gen.Embedded, :run, 1},
    {Mix.Tasks.Phx.Gen.Embedded, :copy_new_files, 3},
    {Mix.Tasks.Phx.Gen.Live, :run, 1},
    {Mix.Tasks.Phx.Gen.Presence, :run, 1},
    {Mix.Tasks.Phx.Gen.Notifier, :build, 1},
    {Mix.Tasks.Phx.Gen.Notifier, :build, 2},
    {Mix.Tasks.Phx.Gen.Notifier, :run, 1},
    {Mix.Tasks.Phx.Gen.Schema, :build, 2},
    {Mix.Tasks.Phx.Gen.Schema, :build, 3},
    {Mix.Tasks.Phx.Gen.Schema, :copy_new_files, 3},
    {Mix.Tasks.Phx.Gen.Schema, :run, 1},
    {Mix.Tasks.Phx.Gen.Auth, :run, 1},
    {Mix.Tasks.Phx.Gen.Auth, :run, 2},
    {Mix.Tasks.Phx.Gen.Json, :run, 1},
    {Mix.Tasks.Phx.Gen.Json, :copy_new_files, 3},
    {Mix.Tasks.Phx.Gen.Html, :run, 1},
    {Mix.Tasks.Phx.Gen.Html, :copy_new_files, 3},
    {Mix.Tasks.Phx.Gen.Channel, :run, 1},
    {Mix.Tasks.Phx.Gen.Socket, :run, 1},
    {Mix.Tasks.Phx.Gen.Release, :run, 1},
    {Phoenix.LiveView.TagEngine.Parser, :tokenize, 2},
    {Phoenix.LiveView.TagEngine.Parser, :parse, :_},
    {Phoenix.LiveView.TagEngine.Parser, :parse!, :_},
    {Phoenix.LiveView.HTMLFormatter, :format, 2},
    {Phoenix.Router.Helpers, :define, 2},
    {ExUnit.AssertionError, :message, 1},
    {ExUnit.Formatter, :format_assertion_error, 1},
    {ExUnit.Formatter, :format_assertion_diff, 4},
    {ExUnit.Formatter, :format_test_failure, 5},
    {ExUnit.Formatter, :format_test_case_failure, 5},
    {ExUnit.Formatter, :format_test_all_failure, 5},
    {ExUnit.CLIFormatter, :handle_cast, 2},
    {Mix.Task, :rerun, 1},
    {Mix.Task, :rerun, 2},
    {Mix.Task, :run_in_apps, 2},
    {Mix.Task, :run_in_apps, 3},
    {Mix.Tasks.Format, :run, 1},
    {Mix.Tasks.Format, :formatter_opts_for_file, 1},
    {Mix.Tasks.Format, :formatter_opts_for_file, 2},
    {Mix.Dep, :in_dependency, 2},
    {Mix.Dep.Loader, :load, 3}
  ]

  @rewritten_calls %{
    {String, :to_atom, 1} => {:erlang, :binary_to_atom, 1},
    {String, :to_existing_atom, 1} => {:erlang, :binary_to_existing_atom, 1},
    {List, :to_atom, 1} => {:erlang, :list_to_atom, 1},
    {List, :to_existing_atom, 1} => {:erlang, :list_to_existing_atom, 1}
  }

  @allowlist []

  @ban_checks ~w(UnsafeToAtom MixEnv ForbiddenModule BannedCalls)

  @lib_modules [Fablebook, Fablebook.Router, Fablebook.Placeholder]

  @fixtures [
    {"alias.ex", {:atom, :eval_string}},
    {"import.ex", {:atom, :eval_string}},
    {"apply.ex", {:atom, :eval_string}},
    {"capture.ex", {:atom, :eval_string}},
    {"macro_quote.ex", {:atom, :eval_quoted}},
    {"interpolated_atom.ex", {:atom, :binary_to_atom}},
    {"dynamic_module.ex", {:mfa, {Module, :concat, 1}}},
    {"banned_dep.ex", {:atom, Jason}},
    {"apply_to_atom.ex", {:mfa, {String, :to_atom, 1}}},
    {"apply_list_existing_atom.ex", {:mfa, {List, :to_existing_atom, 1}}},
    {"function_capture_to_atom.ex", {:mfa, {String, :to_atom, 1}}},
    {"erlang_apply_to_atom.ex", {:mfa, {String, :to_atom, 1}}},
    {"default_arg_to_atom.ex", {:atom, :to_atom}},
    {"load_module.ex", {:mfa, {:erlang, :load_module, 2}}},
    {"internal_eval.ex", {:mfa, {:elixir_module, :compile, 6}}},
    {"parallel_compiler.ex", {:mfa, {Kernel.ParallelCompiler, :require, 1}}},
    {"file_script.ex", {:mfa, {:file, :script, 1}}},
    {"apply_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"computed_compile.ex", {:mfa, {:compile, :_, :_}}},
    {"apply_concat.ex", {:mfa, {Module, :concat, :_}}},
    {"task_async_concat.ex", {:mfa, {Module, :concat, :_}}},
    {"apply_args_to_atom.ex", {:mfa, {String, :to_atom, :_}}},
    {"capture_file_script.ex", {:mfa, {:file, :script, :_}}},
    {"spawn_file_script.ex", {:mfa, {:file, :script, :_}}},
    {"erpc_file_script.ex", {:mfa, {:file, :script, :_}}},
    {"rpc_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"rpc_remote_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"info_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"info_concat.ex", {:mfa, {Module, :concat, :_}}},
    {"info_capture_script.ex", {:mfa, {:file, :script, :_}}},
    {"info_arity_zero.ex", {:mfa, {:file, :script, :_}}},
    {"qlc_string.ex", {:mfa, {:qlc, :string_to_handle, 1}}},
    {"logger_formatter_compile.ex", {:mfa, {Logger.Formatter, :compile, 1}}},
    {"eex_compiler_compile.ex", {:mfa, {EEx.Compiler, :compile, 3}}},
    {"exs_engine_compile.ex", {:mfa, {Phoenix.Template.ExsEngine, :compile, 2}}},
    {"eex_engine_compile.ex", {:mfa, {Phoenix.Template.EExEngine, :compile, 2}}},
    {"liveview_engine_compile.ex", {:mfa, {Phoenix.LiveView.Engine, :compile, 2}}},
    {"html_engine_compile.ex", {:mfa, {Phoenix.LiveView.HTMLEngine, :compile, 2}}},
    {"tag_engine_compiler_compile.ex",
     {:mfa, {Phoenix.LiveView.TagEngine.Compiler, :compile, 2}}},
    {"xref_compiler_compile.ex", {:mfa, {:xref_compiler, :compile, 2}}},
    {"mix_compilers_elixir_compile.ex", {:mfa, {Mix.Compilers.Elixir, :compile, 7}}},
    {"mix_compilers_erlang_compile.ex", {:mfa, {Mix.Compilers.Erlang, :compile, 3}}},
    {"deps_compile_compile.ex", {:mfa, {Mix.Tasks.Deps.Compile, :compile, 1}}},
    {"erl_compile_compile.ex", {:mfa, {:erl_compile, :compile, 2}}},
    {"erl_compile_server_compile.ex", {:mfa, {:erl_compile_server, :compile, 1}}},
    {"leex_compile.ex", {:mfa, {:leex, :compile, 3}}},
    {"yecc_compile.ex", {:mfa, {:yecc, :compile, 3}}},
    {"mix_project_compile.ex", {:mfa, {Mix.Project, :compile, 1}}},
    {"elixir_erl_compile.ex", {:mfa, {:elixir_erl, :compile, 2}}},
    {"cover_compile.ex", {:mfa, {:cover, :compile, 1}}},
    {"merl_compile.ex", {:mfa, {:merl, :compile, 1}}},
    {"asn1ct_compile.ex", {:mfa, {:asn1ct, :compile, 1}}},
    {"merl_compile_and_load.ex", {:mfa, {:merl, :compile_and_load, 1}}},
    {"c_compile.ex", {:mfa, {:c, :c, 1}}},
    {"make_files.ex", {:mfa, {:make, :files, 1}}},
    {"cover_compile_module.ex", {:mfa, {:cover, :compile_module, 1}}},
    {"load_nif.ex", {:mfa, {:erlang, :load_nif, 2}}},
    {"erl_ddll_load.ex", {:mfa, {:erl_ddll, :load, 2}}},
    {"epp_dodger_parse_file.ex", {:mfa, {:epp_dodger, :parse_file, 1}}},
    {"elixir_erl_compiler.ex", {:mfa, {:elixir_erl_compiler, :noenv_forms, 3}}},
    {"tokens_to_quoted.ex", {:mfa, {:elixir, :tokens_to_quoted, 3}}},
    {"iex_helpers_c.ex", {:mfa, {IEx.Helpers, :c, 1}}},
    {"mix_run.ex", {:mfa, {Mix.Tasks.Run, :run, 1}}},
    {"format_dot_formatter.ex", {:mfa, {Mix.Tasks.Format, :formatter_for_file, 2}}},
    {"help_app.ex", {:mfa, {Mix.Tasks.Help, :run, 1}}},
    {"erlang_ensure_application.ex", {:mfa, {Mix.Compilers.Erlang, :ensure_application!, 2}}},
    {"coverage_start.ex", {:mfa, {Mix.Tasks.Test.Coverage, :start, 2}}},
    {"dep_in_dependency.ex", {:mfa, {Mix.Dep, :in_dependency, 3}}},
    {"diff_compute.ex", {:mfa, {ExUnit.Diff, :compute, 3}}},
    {"local_append_paths.ex", {:mfa, {Mix.Local, :append_paths, 0}}},
    {"dep_lock_read.ex", {:mfa, {Mix.Dep.Lock, :read, 1}}},
    {"phx_server_eval.ex", {:mfa, {Mix.Tasks.Phx.Server, :run, 1}}}
  ]

  @beam_only_fixtures ~w(
    dynamic_module.ex
    load_module.ex
    internal_eval.ex
    parallel_compiler.ex
    file_script.ex
    apply_load_module.ex
    computed_compile.ex
    apply_concat.ex
    task_async_concat.ex
    capture_file_script.ex
    spawn_file_script.ex
    erpc_file_script.ex
    rpc_load_module.ex
    rpc_remote_load_module.ex
    info_load_module.ex
    info_concat.ex
    info_capture_script.ex
    info_arity_zero.ex
    qlc_string.ex
    logger_formatter_compile.ex
    eex_compiler_compile.ex
    exs_engine_compile.ex
    eex_engine_compile.ex
    liveview_engine_compile.ex
    html_engine_compile.ex
    tag_engine_compiler_compile.ex
    xref_compiler_compile.ex
    mix_compilers_elixir_compile.ex
    mix_compilers_erlang_compile.ex
    deps_compile_compile.ex
    erl_compile_compile.ex
    erl_compile_server_compile.ex
    leex_compile.ex
    yecc_compile.ex
    mix_project_compile.ex
    elixir_erl_compile.ex
    cover_compile.ex
    merl_compile.ex
    asn1ct_compile.ex
    merl_compile_and_load.ex
    c_compile.ex
    make_files.ex
    cover_compile_module.ex
    load_nif.ex
    erl_ddll_load.ex
    epp_dodger_parse_file.ex
    elixir_erl_compiler.ex
    tokens_to_quoted.ex
    iex_helpers_c.ex
    mix_run.ex
    format_dot_formatter.ex
    help_app.ex
    erlang_ensure_application.ex
    coverage_start.ex
    dep_in_dependency.ex
    diff_compute.ex
    local_append_paths.ex
    dep_lock_read.ex
    phx_server_eval.ex
  )

  @source_only_fixtures ~w(
    macro_concat.ex
    macro_absolute_concat.ex
    macro_apply_load.ex
    macro_script.ex
    using_load_module.ex
    body_script.ex
    body_concat.ex
  )

  @fixture_dir Path.expand("../fixtures/guards", __DIR__)

  test "no lib/ module references a banned call, atom or dependency" do
    findings = Enum.flat_map(lib_modules(), &findings(:code.which(&1)))

    assert findings == [], "banned in lib/: #{inspect(findings)}"
  end

  test "the scan covers every lib/ module" do
    assert MapSet.subset?(MapSet.new(@lib_modules), MapSet.new(lib_modules()))
  end

  @tag :tmp_dir
  test "caller-file fronts are caught through uncalled direct, capture and apply bodies", %{
    tmp_dir: dir
  } do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    source = """
    defmodule Fablebook.GuardFixture.PathConsultShapes do
      def direct(dirs, path), do: :file.path_consult(dirs, path)
      def capture, do: &:file.path_consult/2
      def dynamic(args), do: apply(:file, :path_consult, args)
    end
    """

    path = Path.join(dir, "caller_file.ex")
    File.write!(path, source)
    [beam] = compile!([path], dir, true)
    assert {:ok, scan} = BeamWalker.scan(beam)
    assert {:mfa, {:file, :path_consult, 2}} in hits(scan)
    assert credo_issues(source, "caller_file.ex") != []
    assert credo_issues("quote do: :file.path_consult(dirs, path)", "quoted.ex") != []
    assert credo_issues("Regex.compile(pattern)", "regex.ex") == []

    consult_sources = [
      {"direct", "def direct(path), do: :file.consult(path)"},
      {"capture", "def capture, do: &:file.consult/1"},
      {"apply", "def dynamic(args), do: apply(:file, :consult, args)"}
    ]

    consult_paths =
      for {shape, body} <- consult_sources do
        source =
          "defmodule Fablebook.GuardFixture.Consult#{String.capitalize(shape)} do\n#{body}\nend\n"

        path = Path.join(dir, "caller_consult_#{shape}.ex")
        File.write!(path, source)
        assert credo_issues(source, "caller_consult_#{shape}.ex") != []
        path
      end

    for consult_beam <- compile!(consult_paths, dir, true) do
      assert {:ok, consult_scan} = BeamWalker.scan(consult_beam)

      assert Enum.any?(hits(consult_scan), fn
               {:mfa, {:file, :consult, arity}} when arity in [1, :_] -> true
               _ -> false
             end)
    end

    assert credo_issues("quote do: :file.consult(path)", "quoted_consult.ex") != []
  end

  @tag :tmp_dir
  test "every ct_make export is caught through uncalled direct, capture and apply bodies", %{
    tmp_dir: dir
  } do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    load_tier_apps()

    fronts = [
      {:all, 0, "", ""},
      {:all, 1, "options", "options"},
      {:files, 1, "files", "files"},
      {:files, 2, "files, options", "files, options"}
    ]

    for shape <- [:direct, :capture, :apply] do
      functions =
        Enum.map(fronts, fn {function, arity, args, apply_args} ->
          name = "#{shape}_#{function}_#{arity}"

          body =
            case shape do
              :direct -> ":ct_make.#{function}(#{args})"
              :capture -> "&:ct_make.#{function}/#{arity}"
              :apply -> "apply(:ct_make, :#{function}, [#{apply_args}])"
            end

          head = if shape == :capture, do: "def #{name}()", else: "def #{name}(#{args})"
          {function, arity, name, "#{head}, do: #{body}"}
        end)

      source =
        "defmodule Fablebook.GuardFixture.CtMake#{String.capitalize(to_string(shape))} do\n" <>
          Enum.map_join(functions, "\n", &elem(&1, 3)) <> "\nend\n"

      assert credo_issues(source, "ct_make_#{shape}.ex") != []

      for {function, arity, _name, line} <- functions do
        one_front =
          "defmodule Fablebook.GuardFixture.CtMakeSingle do\n#{line}\nend\n"

        assert credo_issues(one_front, "ct_make_#{shape}_#{function}_#{arity}.ex") != [],
               "Credo missed #{shape} ct_make.#{function}/#{arity}"
      end

      source_path = Path.join(dir, "ct_make_#{shape}.ex")
      File.write!(source_path, source)
      [beam] = compile!([source_path], dir, true)
      assert {:ok, scan} = BeamWalker.scan(beam)

      for {function, arity, _args, _apply_args} <- fronts do
        assert Enum.any?(hits(scan), fn
                 {:mfa, {:ct_make, ^function, found_arity}} when found_arity in [arity, :_] ->
                   true

                 _ ->
                   false
               end),
               "BEAM walker missed #{shape} ct_make.#{function}/#{arity}"
      end
    end
  end

  @tag :tmp_dir
  test "ct_make calls inside uninvoked macros remain source-only controls", %{tmp_dir: dir} do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    load_tier_apps()

    fronts = [
      {:all, 0, ""},
      {:all, 1, "options"},
      {:files, 1, "files"},
      {:files, 2, "files, options"}
    ]

    for {function, arity, args} <- fronts do
      source = """
      defmodule Fablebook.GuardFixture.CtMakeQuoted#{function}#{arity} do
        defmacro quoted, do: quote(do: :ct_make.#{function}(#{args}))
      end
      """

      assert credo_issues(source, "ct_make_quoted_#{function}_#{arity}.ex") != []

      source_path = Path.join(dir, "ct_make_quoted_#{function}_#{arity}.ex")
      File.write!(source_path, source)
      [beam] = compile!([source_path], dir, true)
      assert {:ok, scan} = BeamWalker.scan(beam)

      assert hits(scan) == [],
             "quoted ct_make code unexpectedly reached BEAM: #{inspect(hits(scan))}"
    end

    assert credo_issues("Regex.compile(pattern)", "ct_make_benign.ex") == []
  end

  @tag :tmp_dir
  test "Yecc file and legacy fronts are caught through uncalled direct, capture and apply bodies",
       %{tmp_dir: dir} do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    fronts = [
      {:file, 1, "grammar"},
      {:file, 2, "grammar, options"},
      {:yecc, 2, "grammar, parserfile"},
      {:yecc, 3, "grammar, parserfile, verbose"},
      {:yecc, 4, "grammar, parserfile, verbose, includefile"}
    ]

    functions =
      for {function, arity, args} <- fronts,
          shape <- [:direct, :capture, :apply] do
        name = "#{function}_#{arity}_#{shape}"

        body =
          case shape do
            :direct -> "def #{name}(#{args}), do: :yecc.#{function}(#{args})"
            :capture -> "def #{name}, do: &:yecc.#{function}/#{arity}"
            :apply -> "def #{name}(args), do: apply(:yecc, :#{function}, args)"
          end

        {function, arity, body}
      end

    source =
      "defmodule Fablebook.GuardFixture.YeccFrontShapes do\n" <>
        Enum.map_join(functions, "\n", &elem(&1, 2)) <>
        "\nend\n"

    path = Path.join(dir, "caller_yecc.ex")
    File.write!(path, source)
    [beam] = compile!([path], dir, true)
    assert {:ok, scan} = BeamWalker.scan(beam)

    for {function, arity, _shape} <- functions do
      assert Enum.any?(hits(scan), fn
               {:mfa, {:yecc, ^function, found_arity}}
               when found_arity == arity or found_arity == :_ ->
                 true

               _ ->
                 false
             end),
             "no BEAM hit for yecc.#{function}/#{arity}"
    end

    assert credo_issues(source, "caller_yecc.ex") != []

    for {function, arity, _args} <- fronts do
      call = "quote do: :yecc.#{function}(#{Enum.map_join(1..arity, ", ", fn n -> "a#{n}" end)})"
      assert credo_issues(call, "quoted_yecc_#{function}_#{arity}.ex") != []
    end
  end

  for {file, hit} <- @fixtures do
    @tag :tmp_dir
    @tag fixture: file, hit: hit
    test "the guard catches the #{Path.rootname(file)} bypass", %{tmp_dir: dir} = ctx do
      [beam] = compile!([Path.join(@fixture_dir, ctx.fixture)], dir, true)

      assert {:ok, scan} = BeamWalker.scan(beam)
      assert ctx.hit in hits(scan)
      assert {scan.module, ctx.hit} in findings(beam)
    end
  end

  @tag :tmp_dir
  test "the compiler-internal eval chain hits all three matchers", %{tmp_dir: dir} do
    [beam] = compile!([Path.join(@fixture_dir, "internal_eval.ex")], dir, true)
    assert {:ok, scan} = BeamWalker.scan(beam)

    for mfa <- [
          {:elixir_tokenizer, :tokenize, 4},
          {:elixir_parser, :parse, 1},
          {:elixir_module, :compile, 6}
        ] do
      assert {:mfa, mfa} in hits(scan)
    end
  end

  @tag :tmp_dir
  test "caller-controlled Logger formatter options are banned through direct, capture, and apply probes",
       %{tmp_dir: dir} do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    source = """
    defmodule Fablebook.GuardFixture.LoggerFormatterNew do
      def direct(options), do: Logger.Formatter.new(options)
      def capture, do: &Logger.Formatter.new/1
      def apply(options), do: apply(Logger.Formatter, :new, [options])
    end
    """

    assert credo_issues(source, "logger_formatter_new.ex") != []

    source_path = Path.join(dir, "logger_formatter_new.ex")
    File.write!(source_path, source)
    [beam] = compile!([source_path], dir, true)
    assert {:ok, scan} = BeamWalker.scan(beam)
    assert {:mfa, {Logger.Formatter, :new, 1}} in hits(scan)
  end

  @tag :tmp_dir
  test "Logger and ExUnit formatter wrappers are caught without being called", %{tmp_dir: dir} do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    for kind <- [:direct, :capture, :apply] do
      source = caller_formatter_probe_source(kind)
      assert credo_issues(source, "logger_formatter_#{kind}.ex") != []

      source_path = Path.join(dir, "logger_formatter_#{kind}.ex")
      File.write!(source_path, source)

      for beam <- compile!([source_path], dir, true) do
        assert {:ok, scan} = BeamWalker.scan(beam)

        for {module, function, arity} <- @caller_formatter_fronts do
          assert Enum.any?(hits(scan), fn
                   {:mfa, {^module, ^function, found_arity}} ->
                     found_arity in [arity, :_]

                   _ ->
                     false
                 end),
                 "#{kind} probe missed #{inspect({module, function, arity})}"
        end
      end
    end
  end

  @tag :tmp_dir
  test "a discarded Logger formatter quote is source-only", %{tmp_dir: dir} do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    source = """
    defmodule Fablebook.GuardFixture.LoggerFormatterQuote do
      def quoted(options), do: quote(do: Logger.Formatter.new(unquote(options)))
    end
    """

    assert credo_issues(source, "logger_formatter_quote.ex") != []

    source_path = Path.join(dir, "logger_formatter_quote.ex")
    File.write!(source_path, source)
    [beam] = compile!([source_path], dir, true)
    assert {:ok, scan} = BeamWalker.scan(beam)
    assert hits(scan) == []
  end

  test "every MFA matcher names an existing function" do
    load_tier_apps()

    for {mod, name, arity} = entry <- @mfa_tier do
      assert Code.ensure_loaded?(mod), "#{inspect(entry)} names a module that does not load"

      assert Enum.any?(mod.module_info(:exports), &mfa_match?({name, arity}, &1)),
             "#{inspect(entry)} matches no exported function"
    end
  end

  test "every guard fixture is listed" do
    on_disk =
      @fixture_dir |> Path.join("*.ex") |> Path.wildcard() |> MapSet.new(&Path.basename/1)

    listed = Enum.map(@fixtures, &elem(&1, 0)) ++ @source_only_fixtures
    assert on_disk == MapSet.new(listed)
  end

  @tag :tmp_dir
  test "source-only fixtures raise a Credo issue and pass the BEAM walker (pinned)", %{
    tmp_dir: dir
  } do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    for file <- @source_only_fixtures do
      path = Path.join(@fixture_dir, file)
      [beam] = compile!([path], dir, true)
      assert {:ok, scan} = BeamWalker.scan(beam)
      assert hits(scan) == []
      assert credo_issues(path) != [], "no Credo issue for #{Path.relative_to_cwd(path)}"
    end
  end

  test "beam-only fixtures carry an MFA hit" do
    hits = Map.new(@fixtures)

    for file <- @beam_only_fixtures do
      assert match?({:mfa, _}, hits[file]), "#{file} carries no MFA hit"
    end
  end

  @tag :tmp_dir
  test "a module without debug info fails the guard", %{tmp_dir: dir} do
    source = Path.join(dir, "stripped.ex")
    File.write!(source, "defmodule Fablebook.GuardFixture.Stripped, do: def(ok, do: :ok)\n")

    [beam] = compile!([source], dir, false)

    assert BeamWalker.scan(beam) == {:error, :no_debug_info}
    assert [{_, :no_debug_info}] = findings(beam)
  end

  @tag :tmp_dir
  test "the pair and whole-module checks match by adjacency and by name outside call-name positions (known strictness)",
       %{tmp_dir: dir} do
    expected = %{
      Fablebook.GuardFixture.StrictRegex => [],
      Fablebook.GuardFixture.StrictErlangRe => [],
      Fablebook.GuardFixture.StrictLocal => [],
      Fablebook.GuardFixture.StrictRegexCapture => [],
      Fablebook.GuardFixture.StrictCompileCapture => [
        {:mfa, {:compile, :_, :_}},
        {:mfa, {:compile, :file, :_}}
      ],
      Fablebook.GuardFixture.StrictVarModuleCompile => [],
      Fablebook.GuardFixture.StrictKeyword => [{:mfa, {:epp, :_, :_}}],
      Fablebook.GuardFixture.StrictKeywordPair => [{:mfa, {:io, :read, :_}}],
      Fablebook.GuardFixture.StrictCompileKey => [
        {:mfa, {:compile, true, :_}},
        {:mfa, {:compile, :_, :_}}
      ],
      Fablebook.GuardFixture.StrictBang => [],
      Fablebook.GuardFixture.StrictSigil => [],
      Fablebook.GuardFixture.StrictTuple => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictAttribute => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictMapKey => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictMfaTuple => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictVariable => [],
      Fablebook.GuardFixture.StrictHelper => [],
      Fablebook.GuardFixture.StrictList => [],
      Fablebook.GuardFixture.StrictMapFields => [],
      Fablebook.GuardFixture.StrictComputed => [],
      Fablebook.GuardFixture.StrictMixTask => [
        {:mfa, {Mix.Task, :run, 2}},
        {:mfa, {Mix.Task, :run, :_}}
      ],
      Fablebook.GuardFixture.StrictQlcString => [
        {:mfa, {:qlc, :string_to_handle, 1}},
        {:mfa, {:qlc, :string_to_handle, :_}}
      ],
      Fablebook.GuardFixture.StrictNativeLoad => [
        {:mfa, {:erlang, :load_nif, 2}},
        {:mfa, {:erlang, :load_nif, :_}}
      ],
      Fablebook.GuardFixture.StrictParser => [
        {:mfa, {:epp_dodger, :parse_file, 1}},
        {:mfa, {:epp_dodger, :parse_file, :_}},
        {:mfa, {:epp_dodger, :_, :_}}
      ],
      Fablebook.GuardFixture.StrictInt => [{:mfa, {:int, :i, :_}}],
      Fablebook.GuardFixture.StrictPathConsult => [
        {:mfa, {:file, :path_consult, 2}},
        {:mfa, {:file, :path_consult, :_}}
      ],
      Fablebook.GuardFixture.StrictConsult => [
        {:mfa, {:file, :consult, 1}},
        {:mfa, {:file, :consult, :_}}
      ],
      Fablebook.GuardFixture.StrictCtMake => [
        {:mfa, {:ct_make, :files, 2}},
        {:mfa, {:ct_make, :files, :_}}
      ],
      Fablebook.GuardFixture.StrictWriteThenLoad => []
    }

    source = Path.join(dir, "strict.ex")

    File.write!(source, ~S"""
    defmodule Fablebook.GuardFixture.StrictRegex do
      def run(source), do: Regex.compile(source)
    end

    defmodule Fablebook.GuardFixture.StrictErlangRe do
      def run(source), do: :re.compile(source, [])
    end

    defmodule Fablebook.GuardFixture.StrictLocal do
      def run(source), do: compile(source)
      defp compile(source), do: source
    end

    defmodule Fablebook.GuardFixture.StrictRegexCapture do
      def run, do: &Regex.compile/1
    end

    defmodule Fablebook.GuardFixture.StrictCompileCapture do
      def run, do: &:compile.file/1
    end

    defmodule Fablebook.GuardFixture.StrictVarModuleCompile do
      def run(m, s), do: m.compile(s)
    end

    defmodule Fablebook.GuardFixture.StrictKeyword do
      def run, do: [epp: 1]
    end

    defmodule Fablebook.GuardFixture.StrictKeywordPair do
      def run, do: [io: :read]
    end

    defmodule Fablebook.GuardFixture.StrictCompileKey do
      def run, do: [compile: true]
    end

    defmodule Fablebook.GuardFixture.StrictBang do
      def run(source), do: Regex.compile!(source)
    end

    defmodule Fablebook.GuardFixture.StrictSigil do
      def run(source), do: source =~ ~r/fo+/
    end

    defmodule Fablebook.GuardFixture.StrictTuple do
      def run(args) do
        {m, f} = target()
        apply(m, f, args)
      end

      defp target, do: {:erlang, :load_module}
    end

    defmodule Fablebook.GuardFixture.StrictAttribute do
      @target {:erlang, :load_module}

      def run(args) do
        {m, f} = @target
        apply(m, f, args)
      end
    end

    defmodule Fablebook.GuardFixture.StrictMapKey do
      def run(args) do
        [{m, f}] = Map.to_list(target())
        apply(m, f, args)
      end

      defp target, do: %{:erlang => :load_module}
    end

    defmodule Fablebook.GuardFixture.StrictMfaTuple do
      def run(args) do
        {m, f, a} = target(args)
        apply(m, f, a)
      end

      defp target(args), do: {:erlang, :load_module, args}
    end

    defmodule Fablebook.GuardFixture.StrictVariable do
      def run(args) do
        m = :erlang
        apply(m, :load_module, args)
      end
    end

    defmodule Fablebook.GuardFixture.StrictHelper do
      def run(args), do: apply(module(), :load_module, args)
      defp module, do: :erlang
    end

    defmodule Fablebook.GuardFixture.StrictList do
      def run(args) do
        [m, f] = target()
        apply(m, f, args)
      end

      defp target, do: [:erlang, :load_module]
    end

    defmodule Fablebook.GuardFixture.StrictMapFields do
      def run(args) do
        %{m: m, f: f} = target()
        apply(m, f, args)
      end

      defp target, do: %{m: :erlang, f: :load_module}
    end

    defmodule Fablebook.GuardFixture.StrictComputed do
      def run(m, f, args), do: apply(m, f, args)
    end

    defmodule Fablebook.GuardFixture.StrictMixTask do
      def run(code), do: Mix.Task.run("run", ["-e", code])
    end

    defmodule Fablebook.GuardFixture.StrictQlcString do
      def run(query), do: :qlc.string_to_handle(query)
    end

    defmodule Fablebook.GuardFixture.StrictNativeLoad do
      def run(path), do: :erlang.load_nif(path, 0)
    end

    defmodule Fablebook.GuardFixture.StrictParser do
      def run(path), do: :epp_dodger.parse_file(path)
    end

    defmodule Fablebook.GuardFixture.StrictInt do
      def run(args), do: apply(:int, :i, args)
    end

    defmodule Fablebook.GuardFixture.StrictPathConsult do
      def run(dirs, file), do: :file.path_consult(dirs, file)
    end

    defmodule Fablebook.GuardFixture.StrictConsult do
      def run(path), do: :file.consult(path)
    end

    defmodule Fablebook.GuardFixture.StrictCtMake do
      def run(files), do: :ct_make.files(files, [:load])
    end

    defmodule Fablebook.GuardFixture.StrictWriteThenLoad do
      def run(path, bin, mod) do
        File.write!(path, bin)
        Code.ensure_loaded?(mod)
      end
    end
    """)

    scans =
      for beam <- compile!([source], dir, true), into: %{} do
        assert {:ok, scan} = BeamWalker.scan(beam)
        {scan.module, Enum.sort(Enum.uniq(hits(scan)))}
      end

    assert Enum.sort(Map.keys(scans)) == Enum.sort(Map.keys(expected))

    for {module, hits} <- expected do
      assert scans[module] == Enum.sort(hits), "#{inspect(module)}: #{inspect(scans[module])}"
    end
  end

  @tag :tmp_dir
  test "every MFA-tier entry is caught by a generated probe", %{tmp_dir: dir} do
    load_tier_apps()
    assert Map.keys(@rewritten_calls) -- @mfa_tier == []

    entries = Enum.with_index(@mfa_tier)

    source =
      Enum.map_join(entries, "\n", fn {entry, index} ->
        generated_probe_module(entry, index)
      end)

    source_path = Path.join(dir, "guard_probes.ex")
    File.write!(source_path, source)

    scans =
      for beam <- compile!([source_path], dir, true), into: %{} do
        assert {:ok, scan} = BeamWalker.scan(beam)
        {Atom.to_string(scan.module), scan}
      end

    uncaught =
      for {entry, index} <- entries, reduce: [] do
        acc ->
          probe = Map.fetch!(scans, "Elixir.Fablebook.GuardProbe.P#{index}")
          expected_hits = generated_probe_hits(entry, probe)
          missing = Enum.reject(expected_hits, &(&1 in hits(probe)))

          if missing == [] do
            acc
          else
            [{entry, missing, probe.mfas} | acc]
          end
      end
      |> Enum.reverse()

    assert uncaught == [], "MFA-tier entries without a generated-probe hit: #{inspect(uncaught)}"
  end

  @tag :tmp_dir
  test "selected-file debugger front is caught by both guards without invocation", %{tmp_dir: dir} do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    source = """
    defmodule Fablebook.GuardFixture.DebuggerSelectedFile do
      def probe(server, window, options, state),
        do: :dbg_wx_interpret.start(server, window, options, state)
    end
    """

    source_path = Path.join(dir, "debugger_selected_file.ex")
    File.write!(source_path, source)
    [beam] = compile!([source_path], dir, true)

    assert {:ok, scan} = BeamWalker.scan(beam)
    mfa = {:dbg_wx_interpret, :start, 4}
    assert {:mfa, mfa} in hits(scan)

    refute {:mfa, mfa} in hits(scan, Enum.reject(@mfa_tier, &(&1 == mfa))),
           "the uncalled positive probe must depend on its individual MFA tier"

    assert credo_issues(source_path) != []
  end

  test "the Credo check bans the same names and flags the source-level fixtures" do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    assert BannedCalls.banned_names() == Enum.sort(@atom_tier)
    assert BannedCalls.banned_mfas() == Enum.sort(@mfa_tier)

    for path <- Path.wildcard(Path.join(@fixture_dir, "*.ex")),
        Path.basename(path) not in @beam_only_fixtures do
      assert credo_issues(path) != [], "no Credo issue for #{Path.relative_to_cwd(path)}"
    end

    for path <- Path.wildcard("lib/**/*.ex") do
      assert credo_issues(path) == [], "Credo issue in #{path}"
    end
  end

  test "no credo:disable in lib/ names a ban check" do
    hits =
      for path <- Path.wildcard("lib/**/*.ex"),
          {line, n} <- path |> File.read!() |> String.split("\n") |> Enum.with_index(1),
          line =~ "credo:disable",
          Enum.any?(@ban_checks, &(line =~ &1)),
          do: "#{path}:#{n}"

    assert hits == []
  end

  test "mix.exs names no banned call or module" do
    assert mix_exs_hits(File.read!("mix.exs")) == []
  end

  test "the Credo check scans mix.exs and source text samples" do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    assert credo_issues(File.read!("mix.exs"), "mix.exs") == []

    for text <- [
          "apply(:erlang, :load_module, [m, b])",
          "alias Module, as: M\nM.concat([x])",
          "Module.\nconcat([x])"
        ] do
      assert credo_issues(text, "mix.exs") != [], "no Credo issue for #{text}"
    end

    assert credo_issues("Regex.compile(s)", "mix.exs") == []
  end

  test "the source check matches by alias-expanded name and adjacency (known strictness)" do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    samples = [
      {"alias Module, as: M\nM.concat([x])", true},
      {"alias :file, as: F\nF.script(p)", true},
      {"require :file, as: F\nF.script(p)", true},
      {"Module.\nconcat([x])", true},
      {"x |> Module.concat()", true},
      {"Elixir.Module.concat(x)", true},
      {"alias String, as: Module\nElixir.Module.concat(x)", true},
      {"alias String, as: Module\napply(Elixir.Module, :concat, [x])", true},
      {"alias Module, as: Regex\nElixir.Regex.compile(s)", false},
      {"%{:erlang => :load_module}", true},
      {"{:erlang, :load_module, a}", true},
      {"import IEx.Helpers", true},
      {"apply(:compile, f, a)", true},
      {"[epp: 1]", true},
      {"[io: :read]", true},
      {"[compile: true]", true},
      {"[:erlang, :load_module]", true},
      {"Mix.Task.run(\"run\", [\"-e\", code])", true},
      {"Regex.compile(s)", false},
      {"&Regex.compile/1", false},
      {"m = Module\nm.concat(x)", false},
      {"m.compile(s)", false},
      {"defmodule StrictHelper do\n  def run(x), do: module().concat(x)\n  defp module, do: Module\nend",
       false},
      {"apply(m, f, a)", false},
      {"%{m: :erlang, f: :load_module}", false},
      {"defmodule StrictModuleAlias do\n  alias __MODULE__.Generated, as: M\n  def run(x), do: M.concat(x)\nend",
       false},
      {":file.path_consult(dirs, file)", true},
      {":ct_make.files(files, [:load])", true},
      {"File.write!(path, bin)\nCode.ensure_loaded?(mod)", false}
    ]

    for {source, flagged?} <- samples do
      assert credo_issues(source, "known_strictness.ex") != [] == flagged?, source
    end
  end

  test "the mix.exs scan matches bare and qualified calls" do
    assert mix_exs_hits("Code.eval_string(x)") == ["eval_string"]
    assert mix_exs_hits(":erlang.binary_to_atom(x, :utf8)") == ["binary_to_atom"]
    assert mix_exs_hits("Elixir.Telemetry.Metrics") == ["Telemetry.Metrics"]
    assert mix_exs_hits("String.to_atom(x)") == ["to_atom", "String.to_atom"]
    assert mix_exs_hits("eval_strings = 1") == []
    assert mix_exs_hits("my_eval_string(x)") == []
    assert mix_exs_hits(":file.eval(x)") == [":file.eval"]
    assert mix_exs_hits("Module.concat(x)") == ["Module.concat"]
    assert mix_exs_hits(":epp.parse_file(p)") == [":epp"]
    assert mix_exs_hits("compile --force") == []
  end

  defp mix_exs_hits(text) do
    atom_names =
      for atom <- @atom_tier, do: atom |> Atom.to_string() |> String.replace_prefix("Elixir.", "")

    mfa_names = @mfa_tier |> Enum.map(&mfa_name/1) |> Enum.uniq()

    for name <- atom_names ++ mfa_names,
        Regex.match?(~r/(?<!\w)#{Regex.escape(name)}(?![\w!?])/, text),
        do: name
  end

  defp load_tier_apps do
    Enum.each(
      [
        :xmerl,
        :syntax_tools,
        :tools,
        :parsetools,
        :iex,
        :mix,
        :asn1,
        :sasl,
        :ssl,
        :debugger,
        :common_test
      ],
      &Mix.ensure_application!/1
    )
  end

  defp mfa_name({module, :_, _}), do: inspect(module)
  defp mfa_name({module, function, _}), do: "#{inspect(module)}.#{function}"

  defp credo_issues(path), do: path |> File.read!() |> credo_issues(path)

  defp credo_issues(text, filename) do
    text
    |> SourceFile.parse(filename)
    |> CheckRunner.run_check(BannedCalls)
  end

  defp lib_modules do
    lib = Path.join(File.cwd!(), "lib") <> "/"

    for mod <- Application.spec(:fablebook, :modules),
        String.starts_with?(to_string(mod.module_info(:compile)[:source]), lib),
        do: mod
  end

  defp findings(beam) do
    case BeamWalker.scan(beam) do
      {:ok, scan} ->
        for hit <- hits(scan), {scan.module, hit} not in @allowlist, do: {scan.module, hit}

      {:error, reason} ->
        [{Path.basename(to_string(beam)), reason}]
    end
  end

  defp hits(%{atoms: atoms, mfas: mfas, pairs: pairs, literals: literals}, mfa_tier \\ @mfa_tier) do
    atom_hits = for atom <- @atom_tier, atom in atoms, do: {:atom, atom}
    mfa_hits = for mfa <- mfas, Enum.any?(mfa_tier, &mfa_match?(&1, mfa)), do: {:mfa, mfa}

    pair_hits =
      for {m, f} <- pairs,
          Enum.any?(mfa_tier, fn {pm, pf, _} -> pm == m and pf in [:_, f] end),
          do: {:mfa, {m, f, :_}}

    literal_hits = for m <- literals, {m, :_, :_} in mfa_tier, do: {:mfa, {m, :_, :_}}
    atom_hits ++ mfa_hits ++ pair_hits ++ literal_hits
  end

  defp mfa_match?(pattern, mfa) do
    pattern
    |> Tuple.to_list()
    |> Enum.zip(Tuple.to_list(mfa))
    |> Enum.all?(fn {expected, actual} -> expected == :_ or expected == actual end)
  end

  defp generated_probe_module({module, :_, :_}, index) do
    {function, arity} =
      module.module_info(:exports)
      |> Enum.reject(fn {name, _arity} ->
        name in [:module_info, :__info__] or String.starts_with?(Atom.to_string(name), "MACRO-")
      end)
      |> List.first()

    generated_probe_module(index, [{module, function, arity}])
  end

  defp generated_probe_module({module, function, :_}, index) do
    arities =
      module.module_info(:exports)
      |> Enum.reject(fn {name, _arity} ->
        name in [:module_info, :__info__] or String.starts_with?(Atom.to_string(name), "MACRO-")
      end)
      |> Enum.filter(fn {name, _arity} -> name == function end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort()

    generated_probe_module(index, Enum.map(arities, &{module, function, &1}))
  end

  defp generated_probe_module({module, function, arity}, index) do
    generated_probe_module(index, [{module, function, arity}])
  end

  defp generated_probe_module(index, calls) do
    functions =
      calls
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {{module, function, arity}, call_index} ->
        args_source = Enum.join(generated_probe_arguments(arity), ", ")
        module_source = inspect(module)
        function_source = inspect(Atom.to_string(function))

        "  def run_#{call_index}(#{args_source}), do: #{module_source}.#{function_source}(#{args_source})"
      end)

    "defmodule Fablebook.GuardProbe.P#{index} do\n#{functions}\nend\n"
  end

  defp caller_formatter_probe_source(kind) do
    functions =
      @caller_formatter_fronts
      |> Enum.with_index()
      |> Enum.map_join("\n", &caller_formatter_probe(kind, &1))

    module_kind = kind |> Atom.to_string() |> String.capitalize()
    "defmodule Fablebook.GuardProbe.LoggerFormatter.#{module_kind} do\n#{functions}\nend\n"
  end

  defp caller_formatter_probe(kind, {{module, function, arity}, index}) do
    args = Enum.map_join(1..max(arity, 1), ", ", &"arg#{&1}")
    args = if arity == 0, do: "", else: args
    module_source = inspect(module)
    function_source = Atom.to_string(function)

    body =
      caller_formatter_probe_body(kind, module_source, function, function_source, arity, args)

    head = if kind == :capture, do: "", else: "(#{args})"
    "  def probe_#{index}#{head}, do: #{body}"
  end

  defp caller_formatter_probe_body(:direct, module, _function, function_source, _arity, args),
    do: "#{module}.#{function_source}(#{args})"

  defp caller_formatter_probe_body(:capture, module, _function, function_source, arity, _args),
    do: "&#{module}.#{function_source}/#{arity}"

  defp caller_formatter_probe_body(:apply, module, function, _function_source, arity, args) do
    apply_args = if arity == 0, do: "[]", else: "[#{args}]"
    "apply(#{module}, #{inspect(function)}, #{apply_args})"
  end

  defp generated_probe_arguments(0), do: []

  defp generated_probe_arguments(arity),
    do: for(arg_index <- 1..arity, do: "arg#{arg_index}")

  defp generated_probe_hits(entry, scan) do
    case Enum.find(@rewritten_calls, fn {rewritten_entry, _emitted_mfa} ->
           rewritten_entry == entry
         end) do
      {_entry, emitted_mfa} ->
        assert emitted_mfa in scan.mfas, "#{inspect(entry)} did not emit #{inspect(emitted_mfa)}"
        rewritten_probe_hits(emitted_mfa)

      nil ->
        expected_probe_hits(entry)
    end
  end

  defp expected_probe_hits({module, :_, :_}), do: [{:mfa, {module, :_, :_}}]

  defp expected_probe_hits({module, function, :_}) do
    arities =
      module.module_info(:exports)
      |> Enum.reject(fn {name, _arity} ->
        name in [:module_info, :__info__] or String.starts_with?(Atom.to_string(name), "MACRO-")
      end)
      |> Enum.filter(fn {name, _arity} -> name == function end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort()

    Enum.map(arities, &{:mfa, {module, function, &1}})
  end

  defp expected_probe_hits({module, function, arity}),
    do: [{:mfa, {module, function, arity}}]

  defp rewritten_probe_hits({module, function, _arity}) do
    hits = for atom <- [module, function], atom in @atom_tier, do: {:atom, atom}

    assert hits != [], "rewritten MFA has no atom-tier hit: #{inspect({module, function})}"
    hits
  end

  defp compile!(files, dir, debug_info) do
    previous = Code.get_compiler_option(:debug_info)
    Code.put_compiler_option(:debug_info, debug_info)

    {result, _stderr} =
      try do
        ExUnit.CaptureIO.with_io(:stderr, fn ->
          Kernel.ParallelCompiler.compile_to_path(files, dir)
        end)
      after
        Code.put_compiler_option(:debug_info, previous)
      end

    assert {:ok, modules, _warnings} = result
    Enum.map(modules, &Path.join(dir, "#{&1}.beam"))
  end
end
