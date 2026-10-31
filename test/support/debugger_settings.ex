defmodule Fablebook.Test.DebuggerSettings do
  @moduledoc false

  import ExUnit.Assertions

  @owner "01.1.1.3.1.1"
  @settings_module :dbg_wx_settings
  @monitor_module :dbg_wx_mon
  @settings_mfas [
    {:dbg_wx_settings, :load, 3},
    {:dbg_wx_settings, :save, 3},
    {:dbg_wx_settings, :open_win, 5},
    {:dbg_wx_settings, :default_settings_dir, 1}
  ]
  @settings_exports [
    {:dbg_wx_settings, :load, 3},
    {:dbg_wx_settings, :save, 3}
  ]
  @monitor_exports [
    {:dbg_wx_mon, :start, 2},
    {:dbg_wx_mon, :stop, 0}
  ]
  @root_functions [:start, :load_settings, :load_settings2]
  @lane_data %{
    "core" => %{
      settings_sha256: "0b92d64a6b071d7859ba23213b5e32110aa8ca3b68388c181a2be02f2f146f8e",
      monitor_sha256: "c47574e6f066df305154bbd893762011cf04ecb8315d8263cab415befbab22ff",
      settings_lines: %{load: 41, save: 45, open_win: 54, default_settings_dir: 79},
      monitor_lines: %{
        start: 76,
        init: 115,
        init2: 133,
        default_startup: 184,
        load_menu: 301,
        load_settings: 675,
        load_settings2: 688,
        legacy: 743,
        current: 746
      },
      roots: %{
        start: "0a3aab951f57b69472d39808a8492de656eb2dcbf938c0e222fc3afa803414a1",
        load_settings: "02bb31a0fed1a1e19ee13a06e2d89ce0c40caafdb7f1491002b76c61a1bba48e",
        load_settings2: "8b83a817595da370de0981ff0e9abbf78238a00bcb4f4a3ba0a88b8d8207c788"
      }
    },
    "floor" => %{
      settings_sha256: "1dc9b23f3056a060fdd505d42412550332db052bfdfdfc0005cf82662dcaff3b",
      monitor_sha256: "8beded69315466f8b941d4395e4047453667c31404226a8e53ab229b47a6a05e",
      settings_lines: %{load: 39, save: 43, open_win: 52, default_settings_dir: 77},
      monitor_lines: %{
        start: 72,
        init: 111,
        init2: 129,
        default_startup: 180,
        load_menu: 297,
        load_settings: 671,
        load_settings2: 684,
        legacy: 739,
        current: 742
      },
      roots: %{
        start: "8d94cc4ab32456f10a9accd2d6f7022b23fc623e2547ca9e222d3cdfd6f82ea5",
        load_settings: "c7a2fbb7f15e6afdcc3673a69dfd6c7f69bb0e3153fa3cfa5eae719029e1f798",
        load_settings2: "7714139d6e29ff9733a7158f1bf58304e701170ec8cf092684bd67c1a46725c6"
      }
    }
  }

  @function_descriptions %{
    {:dbg_wx_settings, :load, 3} => %{
      caller_input: [:window, :position, :selected_or_default_settings_path],
      defaults: %{dialog_message: "Load Settings Dialog", style: :wxFD_OPEN},
      option_paths: [:default_directory_and_filename, :selected_directory_and_filename],
      trace: [
        {:dbg_wx_settings, :load, 3},
        {:dbg_wx_settings, :open_win, 5},
        :wx_file_dialog,
        :selected_path_or_cancel
      ],
      verdict: :source_disposed_file_selection_and_cancellation
    },
    {:dbg_wx_settings, :save, 3} => %{
      caller_input: [:window, :position, :selected_or_default_settings_path],
      defaults: %{dialog_message: "Save Settings Dialog", style: :wxFD_SAVE},
      option_paths: [:default_directory_and_filename, :selected_directory_and_filename],
      trace: [
        {:dbg_wx_settings, :save, 3},
        {:dbg_wx_settings, :open_win, 5},
        :wx_file_dialog,
        :selected_path_or_cancel
      ],
      verdict: :source_disposed_file_selection_and_cancellation
    },
    {:dbg_wx_settings, :open_win, 5} => %{
      caller_input: [:window, :position, :settings_path, :message, :dialog_style],
      defaults: %{default_filename: "NoName.state", filter: "*.state"},
      option_paths: [:default_path, :selected_path, :dialog_selected, :dialog_cancel],
      trace: [
        {:dbg_wx_settings, :open_win, 5},
        {:dbg_wx_settings, :default_settings_dir, 1},
        :filename_dirname_and_basename,
        :wx_file_dialog_new_show_modal_get_path_destroy
      ],
      verdict: :source_disposed_all_dialog_returns
    },
    {:dbg_wx_settings, :default_settings_dir, 1} => %{
      caller_input: [:window],
      defaults: %{home_subdirectory: ".erlang_tools/debugger", xdg_subdirectory: "erlang/debugger"},
      option_paths: [
        :home_directory_exists,
        :xdg_directory_exists,
        :create_xdg_directory,
        :create_parent_then_xdg_directory,
        :create_error_cwd_fallback,
        :confirm_cancel_cwd_fallback
      ],
      trace: [
        {:dbg_wx_settings, :default_settings_dir, 1},
        :init_get_argument_home,
        :filelib_is_dir_home_and_xdg,
        :confirm_create_or_cancel,
        :make_dir_and_cwd_fallback
      ],
      verdict: :source_disposed_home_xdg_creation_and_cwd_branches
    }
  }

  @settings_branch_specs [
    {:default_path, {:dbg_wx_settings, :open_win, 5}, :default_path, :settings,
     %{core: {61, "SFile==default"}, floor: {59, "SFile==default"}}},
    {:selected_path, {:dbg_wx_settings, :open_win, 5}, :dirname_and_basename, :settings,
     %{core: {62, "filename:dirname(SFile)"}, floor: {60, "filename:dirname(SFile)"}}},
    {:settings_filter, {:dbg_wx_settings, :open_win, 5}, :state_file_filter, :settings,
     %{core: {68, "*.state"}, floor: {66, "*.state"}}},
    {:dialog_selected, {:dbg_wx_settings, :open_win, 5}, :selected_path_return, :settings,
     %{core: {71, "?wxID_OK"}, floor: {69, "?wxID_OK"}}},
    {:dialog_cancel, {:dbg_wx_settings, :open_win, 5}, :destroy_and_cancel, :settings,
     %{core: {74, "_ ->"}, floor: {72, "_ ->"}}},
    {:home_directory_exists, {:dbg_wx_settings, :default_settings_dir, 1}, :home_default_exists, :settings,
     %{core: {83, "filelib:is_dir(DefDir)"}, floor: {81, "filelib:is_dir(DefDir)"}}},
    {:home_directory_missing, {:dbg_wx_settings, :default_settings_dir, 1}, :home_default_missing, :settings,
     %{core: {85, "false ->"}, floor: {83, "false ->"}}},
    {:xdg_directory_exists, {:dbg_wx_settings, :default_settings_dir, 1}, :xdg_exists, :settings,
     %{core: {87, "filelib:is_dir(XDGDir)"}, floor: {85, "filelib:is_dir(XDGDir)"}}},
    {:xdg_directory_missing, {:dbg_wx_settings, :default_settings_dir, 1}, :xdg_missing_to_cwd_prompt, :settings,
     %{core: {89, "false ->"}, floor: {87, "false ->"}}},
    {:cwd_lookup, {:dbg_wx_settings, :default_settings_dir, 1}, :cwd_fallback_value, :settings,
     %{core: {90, "file:get_cwd()"}, floor: {88, "file:get_cwd()"}}},
    {:create_confirmed, {:dbg_wx_settings, :default_settings_dir, 1}, :confirm_ok, :settings,
     %{core: {96, "ok ->"}, floor: {94, "ok ->"}}},
    {:parent_directory_exists, {:dbg_wx_settings, :default_settings_dir, 1}, :parent_exists, :settings,
     %{core: {98, "filelib:is_dir(ToolsDir)"}, floor: {96, "filelib:is_dir(ToolsDir)"}}},
    {:target_directory_created, {:dbg_wx_settings, :default_settings_dir, 1}, :target_created, :settings,
     %{core: {100, "file:make_dir(XDGDir)"}, floor: {98, "file:make_dir(XDGDir)"}}},
    {:target_directory_create_error, {:dbg_wx_settings, :default_settings_dir, 1}, :target_create_error_to_cwd, :settings,
     %{core: {102, "_Error -> CWD"}, floor: {100, "_Error -> CWD"}}},
    {:parent_directory_created, {:dbg_wx_settings, :default_settings_dir, 1}, :parent_created, :settings,
     %{core: {105, "file:make_dir(ToolsDir)"}, floor: {103, "file:make_dir(ToolsDir)"}}},
    {:parent_then_target_created, {:dbg_wx_settings, :default_settings_dir, 1}, :parent_and_target_created, :settings,
     %{core: {107, "file:make_dir(XDGDir)"}, floor: {105, "file:make_dir(XDGDir)"}}},
    {:parent_then_target_error, {:dbg_wx_settings, :default_settings_dir, 1}, :target_error_to_cwd, :settings,
     %{core: {109, "_Error -> CWD"}, floor: {107, "_Error -> CWD"}}},
    {:parent_directory_create_error, {:dbg_wx_settings, :default_settings_dir, 1}, :parent_error_to_cwd, :settings,
     %{core: {111, "_Error -> CWD"}, floor: {109, "_Error -> CWD"}}},
    {:create_cancelled, {:dbg_wx_settings, :default_settings_dir, 1}, :confirm_cancel_to_cwd, :settings,
     %{core: {114, "cancel -> CWD"}, floor: {112, "cancel -> CWD"}}},
    {:monitor_start_unregistered, {:dbg_wx_mon, :start, 2}, :whereis_undefined, :monitor,
     %{core: {77, "case whereis(?MODULE) of"}, floor: {73, "case whereis(?MODULE) of"}}},
    {:monitor_start_spawned, {:dbg_wx_mon, :start, 2}, :spawn_private_init, :monitor,
     %{core: {80, "spawn(fun () -> init(CallingPid, Mode, SFile) end)"}, floor: {76, "spawn(fun () -> init(CallingPid, Mode, SFile) end)"}}},
    {:monitor_start_success, {:dbg_wx_mon, :start, 2}, :initialization_complete, :monitor,
     %{core: {82, "{initialization_complete, Pid}"}, floor: {78, "{initialization_complete, Pid}"}}},
    {:monitor_start_error, {:dbg_wx_mon, :start, 2}, :startup_error_message, :monitor,
     %{core: {84, "Error ->"}, floor: {80, "Error ->"}}},
    {:monitor_start_already_started, {:dbg_wx_mon, :start, 2}, :already_started_return, :monitor,
     %{core: {89, "{error, {already_started,Pid}}"}, floor: {85, "{error, {already_started,Pid}}"}}},
    {:startup_graphics_error, {:dbg_wx_mon, :init, 3}, :wx_init_exit_reports_error, :monitor,
     %{core: {120, "{'EXIT', Reason} ->"}, floor: {116, "{'EXIT', Reason} ->"}}},
    {:startup_graphics_ready, {:dbg_wx_mon, :init, 3}, :wx_init_value_enters_init2, :monitor,
     %{core: {122, "GS ->"}, floor: {118, "GS ->"}}},
    {:startup_init2_stop, {:dbg_wx_mon, :init, 3}, :stop_exit_is_ignored, :monitor,
     %{core: {126, "exit:stop -> stop;"}, floor: {122, "exit:stop -> stop;"}}},
    {:startup_init2_error, {:dbg_wx_mon, :init, 3}, :init2_exception_is_reported, :monitor,
     %{core: {127, "Error:Reason:Stacktrace ->"}, floor: {123, "Error:Reason:Stacktrace ->"}}},
    {:startup_default_no_replay, {:dbg_wx_mon, :init2, 4}, :default_skips_settings_replay, :monitor,
     %{core: {184, "SFile =:= default"}, floor: {180, "SFile =:= default"}}},
    {:startup_default_loop, {:dbg_wx_mon, :init2, 4}, :default_enters_loop_without_replay, :monitor,
     %{core: {185, "loop(State3)"}, floor: {181, "loop(State3)"}}},
    {:startup_selected_replay, {:dbg_wx_mon, :init2, 4}, :nondefault_loads_settings, :monitor,
     %{core: {187, "loop(load_settings(SFile, State3))"}, floor: {183, "loop(load_settings(SFile, State3))"}}},
    {:load_menu_cancel, {:dbg_wx_mon, :gui_cmd, 2}, :cancel_preserves_state, :monitor,
     %{core: {304, "cancel ->"}, floor: {300, "cancel ->"}}},
    {:load_menu_selected, {:dbg_wx_mon, :gui_cmd, 2}, :selected_file_replayed, :monitor,
     %{core: {305, "{ok, File} -> load_settings(File,State)"}, floor: {301, "{ok, File} -> load_settings(File,State)"}}},
    {:settings_read_success, {:dbg_wx_mon, :load_settings, 2}, :read_binary, :monitor,
     %{core: {677, "{ok, Binary} ->"}, floor: {673, "{ok, Binary} ->"}}},
    {:settings_read_error, {:dbg_wx_mon, :load_settings, 2}, :read_error_preserves_state, :monitor,
     %{core: {685, "{error, _Reason} -> State"}, floor: {681, "{error, _Reason} -> State"}}},
    {:settings_decode_match, {:dbg_wx_mon, :load_settings, 2}, :debugger_settings_envelope, :monitor,
     %{core: {679, "{debugger_settings, Settings}"}, floor: {675, "{debugger_settings, Settings}"}}},
    {:settings_decode_mismatch, {:dbg_wx_mon, :load_settings, 2}, :decode_error_preserves_state, :monitor,
     %{core: {683, "_Error -> State"}, floor: {679, "_Error -> State"}}},
    {:legacy_tuple_keep, {:dbg_wx_mon, :loaded, 1}, :legacy_implicit_strings_keep, :monitor,
     %{core: {745, "BackTrace,keep,Files,Breaks"}, floor: {741, "BackTrace,keep,Files,Breaks"}}},
    {:current_settings_keys, {:dbg_wx_mon, :loaded, 1}, :current_seven_keys, :monitor,
     %{core: {747, "Keys = [trace_win,auto_attach,stack_trace,back_trace,strings,files,"}, floor: {743, "Keys = [trace_win,auto_attach,stack_trace,back_trace,strings,files,"}}},
    {:missing_settings_key, {:dbg_wx_mon, :loaded, 1}, :missing_values_are_source_nil, :monitor,
     %{core: {749, "proplists:get_value(Key, Settings)"}, floor: {745, "proplists:get_value(Key, Settings)"}}},
    {:trace_windows_selected, {:dbg_wx_mon, :load_settings2, 2}, :selected_areas_true, :monitor,
     %{core: {694, "dbg_wx_mon_win:select(Area, true)"}, floor: {690, "dbg_wx_mon_win:select(Area, true)"}}},
    {:trace_windows_unselected, {:dbg_wx_mon, :load_settings2, 2}, :other_areas_false, :monitor,
     %{core: {696, "dbg_wx_mon_win:select(Area, false)"}, floor: {692, "dbg_wx_mon_win:select(Area, false)"}}},
    {:auto_attach_false, {:dbg_wx_mon, :load_settings2, 2}, :disable_auto_attach, :monitor,
     %{core: {700, "false -> int:auto_attach(false)"}, floor: {696, "false -> int:auto_attach(false)"}}},
    {:auto_attach_tuple, {:dbg_wx_mon, :load_settings2, 2}, :restore_flags_and_function, :monitor,
     %{core: {701, "{Flags, Function} -> int:auto_attach(Flags, Function)"}, floor: {697, "{Flags, Function} -> int:auto_attach(Flags, Function)"}}},
    {:strings_keep, {:dbg_wx_mon, :load_settings2, 2}, :keep_skips_update, :monitor,
     %{core: {707, "Strings =:= keep"}, floor: {703, "Strings =:= keep"}}},
    {:strings_show, {:dbg_wx_mon, :load_settings2, 2}, :show_selected_strings, :monitor,
     %{core: {709, "show_option(State#state.win, strings, Strings)"}, floor: {705, "show_option(State#state.win, strings, Strings)"}}},
    {:backtrace_show, {:dbg_wx_mon, :load_settings2, 2}, :show_backtrace_size, :monitor,
     %{core: {713, "show_option(State#state.win, back_trace, BackTrace)"}, floor: {709, "show_option(State#state.win, back_trace, BackTrace)"}}},
    {:local_files_empty, {:dbg_wx_mon, :load_settings2, 2}, :empty_local_list_no_iteration, :monitor,
     %{core: {716, "local -> lists:foreach"}, floor: {712, "local -> lists:foreach"}}},
    {:local_files_single, {:dbg_wx_mon, :load_settings2, 2}, :single_local_file, :monitor,
     %{core: {716, "int:i(File)"}, floor: {712, "int:i(File)"}}},
    {:local_files_multiple, {:dbg_wx_mon, :load_settings2, 2}, :multiple_local_files_in_order, :monitor,
     %{core: {716, "int:i(File)"}, floor: {712, "int:i(File)"}}},
    {:global_files_empty, {:dbg_wx_mon, :load_settings2, 2}, :empty_global_list_no_iteration, :monitor,
     %{core: {717, "global -> lists:foreach"}, floor: {713, "global -> lists:foreach"}}},
    {:global_files_single, {:dbg_wx_mon, :load_settings2, 2}, :single_global_file, :monitor,
     %{core: {717, "int:ni(File)"}, floor: {713, "int:ni(File)"}}},
    {:global_files_multiple, {:dbg_wx_mon, :load_settings2, 2}, :multiple_global_files_in_order, :monitor,
     %{core: {717, "int:ni(File)"}, floor: {713, "int:ni(File)"}}},
    {:break_status_inactive, {:dbg_wx_mon, :load_settings2, 2}, :inactive_break_disabled, :monitor,
     %{core: {724, "Status =:= inactive"}, floor: {720, "Status =:= inactive"}}},
    {:break_status_active, {:dbg_wx_mon, :load_settings2, 2}, :active_break_keeps_default, :monitor,
     %{core: {726, "true -> ignore"}, floor: {722, "true -> ignore"}}},
    {:break_action_enable, {:dbg_wx_mon, :load_settings2, 2}, :enable_action_keeps_default, :monitor,
     %{core: {731, "true -> ignore"}, floor: {727, "true -> ignore"}}},
    {:break_action_custom, {:dbg_wx_mon, :load_settings2, 2}, :custom_action_restored, :monitor,
     %{core: {730, "int:action_at_break(Mod,Line,Action)"}, floor: {726, "int:action_at_break(Mod,Line,Action)"}}},
    {:break_condition_tuple, {:dbg_wx_mon, :load_settings2, 2}, :condition_tuple_restored, :monitor,
     %{core: {734, "CFunction when is_tuple(CFunction)"}, floor: {730, "CFunction when is_tuple(CFunction)"}}},
    {:break_condition_null, {:dbg_wx_mon, :load_settings2, 2}, :null_condition_ignored, :monitor,
     %{core: {736, "null -> ignore"}, floor: {732, "null -> ignore"}}}
  ]

  def records(lane_name) when lane_name in ["core", "floor"] do
    lane = Map.fetch!(@lane_data, lane_name)
    functions = function_records(lane_name, lane)
    branches = branch_records(lane_name)

    %{
      lane: lane_name,
      owner: @owner,
      source_sha256: lane.settings_sha256,
      function_sources: Enum.map(functions, &%{mfa: &1.mfa, citation: &1.citations}),
      function_audit: functions,
      exports: @settings_exports,
      roots: root_records(lane_name, lane.roots),
      source_branches: branches,
      branch_citations: branch_citations(lane_name),
      trace: %{
        selected_path: [:caller, :dialog, :selected_path_or_cancel],
        saved_file: [:monitor_start, :private_init, :read_file, :decode, :restore],
        conditional_break: [:restore_tuple, :int_test_at_break]
      },
      defaults: %{settings_file: :caller_selected_or_default, strings: :legacy_keep, missing_keys: nil},
      option_paths: Enum.map(branches, & &1.id),
      verdict: :static_source_disposition_only,
      exclusion_matches: [],
      limitations: [
        :no_debugger_or_gui_execution,
        :no_serialized_term_decoding,
        :no_upstream_acceptance_claim,
        :monitor_broad_ownership_pending
      ]
    }
  end

  def records(lane_name), do: raise(ArgumentError, "unsupported debugger settings lane: #{inspect(lane_name)}")

  def assert_audit!(record, graph, tier, evidence, exclusions) do
    lane = evidence.lane.name
    lane_row = Map.get(@lane_data, lane)

    assert is_map(record), "lane #{lane} owner=#{@owner} caller-chain=dbg_wx_settings:load/3 remedy=restore the complete audit record"
    required_keys = [
      :lane,
      :owner,
      :source_sha256,
      :function_sources,
      :function_audit,
      :exports,
      :roots,
      :source_branches,
      :branch_citations,
      :trace,
      :defaults,
      :option_paths,
      :verdict,
      :exclusion_matches,
      :limitations
    ]

    missing_keys = Enum.reject(required_keys, &Map.has_key?(record, &1))
    assert missing_keys == [],
           "lane #{lane} owner=#{@owner} MFA dbg_wx_settings:default_settings_dir/1 caller-chain=load/3 -> open_win/5 remedy=restore required audit fields #{inspect(missing_keys)}"
    assert graph.lane.name == lane,
           "lane #{lane} owner=#{@owner} graph lane=#{graph.lane.name} caller-chain=source_roots! remedy=use matching lane evidence"
    assert record.lane == lane,
           "lane #{lane} owner=#{@owner} record lane=#{inspect(record.lane)} caller-chain=dbg_wx_settings:load/3 remedy=select the matching lane record"
    assert record.owner == @owner,
           "lane #{lane} owner=#{inspect(record.owner)} caller-chain=dbg_wx_settings:load/3 remedy=retain adopted plan ownership"
    assert record.source_sha256 == lane_row.settings_sha256,
           "lane #{lane} MFA dbg_wx_settings:load/3 owner=#{@owner} caller-chain=load/3 -> open_win/5 remedy=restore the exact settings source SHA"
    assert {:dbg_wx_mon, :start, 2} in tier,
           "lane #{lane} MFA dbg_wx_mon:start/2 owner=#{@owner} caller-chain=debugger:start/2 -> dbg_wx_mon:start/2 remedy=retain the exact monitor-front tier"

    function_sources = Map.get(record, :function_sources, [])
    function_audit = Map.get(record, :function_audit, [])
    source_mfas = Enum.map(function_sources, &Map.get(&1, :mfa))
    reviewed_mfas = Enum.map(function_audit, &Map.get(&1, :mfa))
    expected_mfas = MapSet.new(@settings_mfas)
    missing_source = MapSet.difference(expected_mfas, MapSet.new(source_mfas))
    missing_review = MapSet.difference(expected_mfas, MapSet.new(reviewed_mfas))

    assert MapSet.new(source_mfas) == expected_mfas and MapSet.new(reviewed_mfas) == expected_mfas,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{@owner} caller-chain=load/3 -> open_win/5 -> default_settings_dir/1 missing_source=#{inspect(MapSet.to_list(missing_source))} missing_review=#{inspect(MapSet.to_list(missing_review))} remedy=restore all four exact functions"

    inspection = Enum.find(graph.inspected, &(&1.module_atom == @settings_module))

    assert inspection != nil,
           "lane #{lane} MFA dbg_wx_settings:load/3 owner=#{@owner} caller-chain=installed debugger BEAM remedy=inspect the assigned settings module"

    assert {:ok, scan} = Fablebook.Test.BeamWalker.scan(inspection.path),
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{@owner} caller-chain=installed BEAM inventory remedy=restore debug-info function scan"

    actual_functions =
      scan.function_mfas
      |> Enum.reject(&(elem(&1, 1) == :module_info))
      |> MapSet.new()

    assert actual_functions == expected_mfas,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{@owner} caller-chain=BEAM function inventory remedy=update only from exact installed source review"

    assert MapSet.new(Map.get(record, :exports, [])) == MapSet.new(@settings_exports),
           "lane #{lane} MFA dbg_wx_settings:load/3 owner=#{@owner} caller-chain=module export declaration remedy=retain exact exports"

    actual_exports =
      graph.full_exported
      |> Enum.filter(&(elem(&1, 0) == @settings_module))
      |> MapSet.new()

    assert actual_exports == MapSet.new(@settings_exports),
           "lane #{lane} MFA dbg_wx_settings:load/3 owner=#{@owner} caller-chain=independent installed graph exports remedy=resolve export mismatch"

    assert Enum.all?(function_audit, &function_record_complete?/1),
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{@owner} caller-chain=source review remedy=restore caller input/defaults/options/trace/verdict/citations"

    root_records = Map.get(record, :roots, [])
    expected_roots = root_records |> Enum.map(&Map.get(&1, :mfa)) |> MapSet.new()
    expected_root_mfas = MapSet.new(Enum.map(@root_functions, &{@monitor_module, &1, 2}))

    assert expected_roots == expected_root_mfas and
             Enum.all?(root_records, &(&1.owner == @owner and &1.completion == :pending)),
           "lane #{lane} MFA dbg_wx_mon:load_settings2/2 owner=#{@owner} caller-chain=adopted root ledger remedy=restore all three pending canonical root records"

    monitor_exports =
      graph.full_exported
      |> Enum.filter(&(elem(&1, 0) == @monitor_module))
      |> MapSet.new()

    assert monitor_exports == MapSet.new(@monitor_exports),
           "lane #{lane} MFA dbg_wx_mon:init/3 owner=01.1.1.3.1.2 caller-chain=dbg_wx_mon:start/2 -> init/3 remedy=keep only start/2 and stop/0 exported"

    refute MapSet.member?(monitor_exports, {:dbg_wx_mon, :init, 3}),
           "lane #{lane} MFA dbg_wx_mon:init/3 owner=01.1.1.3.1.2 caller-chain=dbg_wx_mon:start/2 -> init/3 remedy=preserve its private status"

    candidate_mfas = graph_candidates(graph)
    assert MapSet.subset?(expected_roots, candidate_mfas),
           "lane #{lane} MFA dbg_wx_mon:load_settings2/2 owner=#{@owner} caller-chain=fresh graph candidates remedy=restore assigned roots or their exact graph identities"

    assert_root_ledger!(root_records, lane)

    expected_branch_ids = MapSet.new(branch_ids())
    actual_branch_ids = record |> Map.get(:branch_citations, %{}) |> Map.keys() |> MapSet.new()
    source_branch_ids = record |> Map.get(:source_branches, []) |> Enum.map(& &1.id) |> MapSet.new()

    assert actual_branch_ids == expected_branch_ids and source_branch_ids == expected_branch_ids,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{@owner} caller-chain=complete settings and replay branch map missing=#{inspect(MapSet.to_list(MapSet.difference(expected_branch_ids, actual_branch_ids)))} remedy=restore every exact default/error/cancel/replay branch"

    Enum.each(record.branch_citations, fn {branch_id, citations} ->
      assert citations != [],
             "lane #{lane} MFA #{branch_mfa(record, branch_id)} owner=#{@owner} caller-chain=#{branch_trace(record, branch_id)} remedy=add a resolvable source citation"
    end)

    citations =
      Enum.flat_map(record.function_sources, &List.wrap(&1.citation)) ++
        Enum.flat_map(record.function_audit, &List.wrap(&1.citations)) ++
        Enum.flat_map(Map.values(record.branch_citations), &List.wrap/1) ++
        Enum.flat_map(root_records, &List.wrap(&1.citations))

    Enum.each(citations, &assert_citation!(evidence, lane, record, &1))

    expected_roots
    |> MapSet.to_list()
    |> Enum.each(fn mfa ->
      assert MapSet.member?(graph.full_exported, mfa) or MapSet.member?(graph.full_reached, mfa),
             "lane #{lane} MFA #{format_mfa(mfa)} owner=#{@owner} caller-chain=adopted root identity remedy=retain it in the installed graph"
    end)

    assert Enum.all?(exclusions, &valid_exclusion?/1),
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{@owner} caller-chain=exclusion ledger remedy=preserve valid cited exclusion shapes"

    :ok
  end

  def branch_ids do
    Enum.map(@settings_branch_specs, &elem(&1, 0))
  end

  def exclusion_matches(universe, exclusions) do
    exclusions
    |> Enum.flat_map(fn exclusion ->
      matches = Enum.filter(universe, &matches_exclusion?(&1, exclusion))

      if matches == [] do
        []
      else
        matcher = elem(exclusion, 0)
        reason = elem(exclusion, 1)
        citations = if tuple_size(exclusion) > 2, do: elem(exclusion, 2), else: []

        [
          %{
            original_identity: exclusion,
            cited_triple: {matcher, reason, citations},
            matched_mfas: Enum.sort(matches)
          }
        ]
      end
    end)
  end

  def assert_exclusion_witnesses!(matches, graph, tier, names, exclusions) do
    active = %{reverse: graph.reverse, exported: graph.exported}

    Enum.each(matches, fn match ->
      actual = Enum.filter(match.universe, &matches_exclusion?(&1, match.original_identity))
      assert Enum.sort(actual) == Enum.sort(match.matched_mfas),
             "changed exclusion #{inspect(match.original_identity)} has incomplete matches"

      without_original = List.delete(exclusions, match.original_identity)
      newly_uncovered = undisposed(active, tier, names, without_original)

      assert Enum.any?(match.matched_mfas, &(&1 in newly_uncovered)),
             "retained exclusion #{inspect(match.original_identity)} has no individual active removal witness for #{inspect(match.matched_mfas)}"
    end)
  end

  defp function_records(lane_name, lane) do
    lines = lane.settings_lines

    Enum.map(@settings_mfas, fn mfa ->
      description = Map.fetch!(@function_descriptions, mfa)
      function = elem(mfa, 1)
      source_line = Map.fetch!(lines, function)
      expected_text = "#{function}("

      %{
        mfa: mfa,
        caller_input: description.caller_input,
        defaults: description.defaults,
        option_paths: description.option_paths,
        trace: description.trace,
        verdict: description.verdict,
        owner: @owner,
        lane: lane_name,
        citations: [citation(lane_name, :settings, source_line, expected_text)]
      }
    end)
  end

  defp root_records(lane_name, roots) do
    Enum.map(@root_functions, fn function ->
      %{
        mfa: {@monitor_module, function, 2},
        chain_id: Map.fetch!(roots, function),
        owner: @owner,
        completion: :pending,
        citations: [
          citation(
            lane_name,
            :monitor,
            Map.fetch!(Map.fetch!(@lane_data, lane_name).monitor_lines, function),
            "#{function}("
          )
        ]
      }
    end)
  end

  defp branch_records(_lane_name) do
    Enum.map(@settings_branch_specs, fn {id, mfa, predicate, source, _lines} ->
      %{id: id, mfa: mfa, owner: branch_owner(source, mfa), predicate: predicate, trace: branch_trace(mfa)}
    end)
  end

  defp branch_citations(lane_name) do
    Enum.into(@settings_branch_specs, %{}, fn {id, _mfa, _predicate, source, lines} ->
      {line, expected_text} = Map.fetch!(lines, String.to_atom(lane_name))
      {id, [citation(lane_name, source, line, expected_text)]}
    end)
  end

  defp citation(lane_name, :settings, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/dbg_wx_settings.erl",
      line: line,
      sha256: lane.settings_sha256,
      expected_text: expected_text
    }
  end

  defp citation(lane_name, :monitor, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/dbg_wx_mon.erl",
      line: line,
      sha256: lane.monitor_sha256,
      expected_text: expected_text
    }
  end

  defp branch_owner(:settings, _mfa), do: @owner
  defp branch_owner(:monitor, {:dbg_wx_mon, function, _arity}) when function in [:init, :init2, :gui_cmd],
    do: "01.1.1.3.1.2"

  defp branch_owner(:monitor, _mfa), do: @owner

  defp branch_trace({:dbg_wx_settings, :load, 3}), do: "dbg_wx_settings:load/3 -> open_win/5"
  defp branch_trace({:dbg_wx_settings, :save, 3}), do: "dbg_wx_settings:save/3 -> open_win/5"
  defp branch_trace({:dbg_wx_settings, :open_win, 5}), do: "dbg_wx_settings:load|save/3 -> open_win/5"
  defp branch_trace({:dbg_wx_settings, :default_settings_dir, 1}), do: "load|save/3 -> open_win/5 -> default_settings_dir/1"
  defp branch_trace({:dbg_wx_mon, :start, 2}), do: "debugger:start/2 -> dbg_wx_mon:start/2 -> init/3"
  defp branch_trace({:dbg_wx_mon, :init, 3}), do: "dbg_wx_mon:start/2 -> init/3 -> init2/4"
  defp branch_trace({:dbg_wx_mon, :init2, 4}), do: "dbg_wx_mon:start/2 -> init/3 -> init2/4"
  defp branch_trace({:dbg_wx_mon, :gui_cmd, 2}), do: "dbg_wx_mon:gui_cmd/2 -> settings dialog -> load_settings/2"
  defp branch_trace({:dbg_wx_mon, :load_settings, 2}), do: "dbg_wx_mon:load_settings/2 -> file:read_file/1 -> binary_to_term/1"
  defp branch_trace({:dbg_wx_mon, :load_settings2, 2}), do: "dbg_wx_mon:load_settings/2 -> load_settings2/2 -> replay options"
  defp branch_trace({:dbg_wx_mon, :loaded, 1}), do: "dbg_wx_mon:load_settings2/2 -> loaded/1"

  defp branch_trace(record, branch_id) do
    record.source_branches
    |> Enum.find(&(&1.id == branch_id))
    |> case do
      nil -> "unrecorded branch"
      branch -> branch.trace
    end
  end

  defp branch_mfa(record, branch_id) do
    record.source_branches
    |> Enum.find(&(&1.id == branch_id))
    |> case do
      nil -> "unrecorded"
      branch -> format_mfa(branch.mfa)
    end
  end

  defp function_record_complete?(record) do
    record.caller_input != nil and record.defaults != nil and record.option_paths != [] and
      record.trace != [] and record.verdict != nil and record.owner == @owner and
      record.citations != []
  end

  defp assert_citation!(evidence, lane, record, citation) do
    resolved = Fablebook.Test.SweepEvidence.resolve!(evidence, "#{citation.path}:#{citation.line}")

    assert resolved.sha256 == citation.sha256,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{record.owner} caller-chain=source citation #{citation.path}:#{citation.line} remedy=restore exact lane SHA"

    assert resolved.text =~ citation.expected_text,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{record.owner} caller-chain=source citation #{citation.path}:#{citation.line} remedy=restore matching branch text"
  end

  defp assert_root_ledger!(root_records, lane) do
    ledger =
      Path.join(
        File.cwd!(),
        ".planning/phases/01.1.1.3.1-debugger-remaining-settings-trace-breakpoint-and-monitor-rou/01.1.1.3.1-OWNERSHIP.jsonl.gz"
      )

    entries =
      ledger
      |> File.read!()
      |> :zlib.gunzip()
      |> String.split("\n", trim: true)
      |> Enum.map(&JSON.decode!/1)

    expected =
      root_records
      |> Enum.map(fn root ->
        {format_mfa(root.mfa), root.chain_id, root.owner, "pending"}
      end)
      |> MapSet.new()

    actual =
      entries
      |> Enum.filter(fn entry ->
        entry["t"] == "root" and entry["lane"] == lane and entry["module"] == "dbg_wx_mon" and
          entry["function"] in Enum.map(@root_functions, &Atom.to_string/1)
      end)
      |> Enum.map(fn entry ->
        {"#{entry["module"]}:#{entry["function"]}/#{entry["arity"]}", entry["chain_id"], entry["owner"], entry["completion"]}
      end)
      |> MapSet.new()

    assert actual == expected,
           "lane #{lane} MFA dbg_wx_mon:load_settings2/2 owner=#{@owner} caller-chain=effective OWNERSHIP.jsonl.gz remedy=restore exactly the three adopted pending roots"

    pending_module =
      Enum.find(entries, fn entry ->
        entry["t"] == "module" and entry["lane"] == lane and entry["module"] == "dbg_wx_mon"
      end)

    assert pending_module != nil and pending_module["owner"] == "01.1.1.3.1.2" and
             pending_module["pending"] == true and pending_module["completion"] == "pending",
           "lane #{lane} MFA dbg_wx_mon:init/3 owner=01.1.1.3.1.2 caller-chain=whole-module ownership remainder remedy=keep module scope pending"
  end

  defp graph_candidates(graph) do
    graph.full_edges
    |> Enum.flat_map(fn {caller, callee} -> [caller, callee] end)
    |> Kernel.++(MapSet.to_list(graph.full_reached))
    |> Kernel.++(MapSet.to_list(graph.full_exported))
    |> Enum.filter(&match?({_, _, _}, &1))
    |> MapSet.new()
  end

  defp valid_exclusion?(exclusion), do: is_tuple(exclusion) and tuple_size(exclusion) in [2, 3]

  defp matches_exclusion?({module, function, _arity} = mfa, exclusion) do
    matcher = elem(exclusion, 0)
    exact = match?({:mfa, ^mfa}, matcher)

    exact or
      case matcher do
        {^module, functions} when is_list(functions) -> function in functions
        {^module, matcher_function} -> matcher_function == function or matcher_function == :_
        {:prefix, prefix} -> String.starts_with?(inspect(module), prefix)
        {:fun_prefix, prefix} -> String.starts_with?(Atom.to_string(function), prefix)
        ^module -> true
        _ -> false
      end
  end

  defp matches_exclusion?(_mfa, _exclusion), do: false

  defp undisposed(graph, tier, names, exclusions) do
    reached = walk_callers(graph.reverse, Enum.map(tier, &matcher_mfa/1))

    reached
    |> Enum.filter(&MapSet.member?(graph.exported, &1))
    |> Enum.reject(fn {module, function, _arity} ->
      module in [:erlang, :erl_eval, :erl_ddll] or function == :module_info
    end)
    |> Enum.reject(fn mfa -> covered?(mfa, tier, names) or Enum.any?(exclusions, &matches_exclusion?(mfa, &1)) end)
  end

  defp walk_callers(reverse, roots) do
    Enum.reduce(roots, MapSet.new(), fn root, visited ->
      queue = :queue.in(root, :queue.new())
      walk_callers(queue, reverse, visited)
    end)
  end

  defp walk_callers(queue, reverse, visited) do
    case :queue.out(queue) do
      {:empty, _queue} -> visited
      {{:value, mfa}, rest} when is_map_key(reverse, mfa) ->
        if MapSet.member?(visited, mfa) do
          walk_callers(rest, reverse, visited)
        else
          callers = Map.get(reverse, mfa, MapSet.new())
          callers = if is_struct(callers, MapSet), do: MapSet.to_list(callers), else: callers
          walk_callers(Enum.reduce(callers, rest, &:queue.in/2), reverse, MapSet.put(visited, mfa))
        end

      {{:value, mfa}, rest} ->
        walk_callers(rest, reverse, MapSet.put(visited, mfa))
    end
  end

  defp matcher_mfa({:mfa, mfa}), do: mfa
  defp matcher_mfa(mfa), do: mfa

  defp covered?(mfa, tier, names) do
    {module, function, arity} = mfa
    Enum.any?(tier, fn
      {^module, :_, _} -> true
      {^module, ^function, :_} -> true
      {^module, ^function, ^arity} -> true
      _ -> false
    end) or function in names or module in names
  end

  defp format_mfa({module, function, arity}), do: "#{module}:#{function}/#{arity}"
end
