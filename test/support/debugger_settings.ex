defmodule Fablebook.Test.DebuggerSettings do
  @moduledoc false

  import ExUnit.Assertions

  @owner "01.1.1.3.1.1"
  @historical_owner "01.1.1.3.1"
  @remainder_owner "01.1.1.3.1.2"
  @delegation_children [@owner, @remainder_owner]
  @delegation_schema "fablebook.debugger-settings-delegation.v1"
  @delegation_dir ".planning/phases/01.1.1.3.1-debugger-remaining-settings-trace-breakpoint-and-monitor-rou"
  @delegation_file "01.1.1.3.1-OWNERSHIP.jsonl.gz"
  @parent_ledger_dir ".planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil"
  @parent_ledger_file "01.1.1.3-OWNERSHIP.jsonl.gz"
  @partition_file "01.1.1.3.1-PARTITION.json.gz"
  @candidate_file "01.1.1.3.1-SOURCE-CANDIDATE.json"
  @source_decision_file "01.1.1.3.1-SOURCE-DECISION.md"
  @selected_root_mfas [
    {:dbg_wx_mon, :start, 2},
    {:dbg_wx_mon, :load_settings, 2},
    {:dbg_wx_mon, :load_settings2, 2}
  ]
  @debugger_seed_modules ["dbg_idb", "dbg_istk", "dbg_wx_interpret"]
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
      iserver_sha256: "3dde037e86dc9ba93d6bb8438f4fd38e062dfbf76aea6ef4d440c2162493728f",
      int_sha256: "14b667aa97d23b3ead643eae3bf2acabbc804919935f978a04846b353cac7a39",
      icmd_sha256: "5630b07823f0531d11b5415977c273b83a0176b18b985101c95afdc107d8431a",
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
      iserver_sha256: "04a9268e631c8a53fcb9a48821a44cddce07072016550eecaf43ef0734ec3a02",
      int_sha256: "913d32eaf82c21b9c9902e023f46dc88317ff729d66cc91078469d7c3b9b043c",
      icmd_sha256: "cd6d034c796c98ed3b3ce71048bef83aea8b25b612e227a02c2af6301a0d326e",
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
      defaults: %{
        home_subdirectory: ".erlang_tools/debugger",
        xdg_subdirectory: "erlang/debugger"
      },
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
    {:home_directory_exists, {:dbg_wx_settings, :default_settings_dir, 1}, :home_default_exists,
     :settings, %{core: {83, "filelib:is_dir(DefDir)"}, floor: {81, "filelib:is_dir(DefDir)"}}},
    {:home_directory_missing, {:dbg_wx_settings, :default_settings_dir, 1}, :home_default_missing,
     :settings, %{core: {85, "false ->"}, floor: {83, "false ->"}}},
    {:xdg_directory_exists, {:dbg_wx_settings, :default_settings_dir, 1}, :xdg_exists, :settings,
     %{core: {87, "filelib:is_dir(XDGDir)"}, floor: {85, "filelib:is_dir(XDGDir)"}}},
    {:xdg_directory_missing, {:dbg_wx_settings, :default_settings_dir, 1},
     :xdg_missing_to_cwd_prompt, :settings, %{core: {89, "false ->"}, floor: {87, "false ->"}}},
    {:cwd_lookup, {:dbg_wx_settings, :default_settings_dir, 1}, :cwd_fallback_value, :settings,
     %{core: {90, "file:get_cwd()"}, floor: {88, "file:get_cwd()"}}},
    {:create_confirmed, {:dbg_wx_settings, :default_settings_dir, 1}, :confirm_ok, :settings,
     %{core: {96, "ok ->"}, floor: {94, "ok ->"}}},
    {:parent_directory_exists, {:dbg_wx_settings, :default_settings_dir, 1}, :parent_exists,
     :settings,
     %{core: {98, "filelib:is_dir(ToolsDir)"}, floor: {96, "filelib:is_dir(ToolsDir)"}}},
    {:target_directory_created, {:dbg_wx_settings, :default_settings_dir, 1}, :target_created,
     :settings, %{core: {100, "file:make_dir(XDGDir)"}, floor: {98, "file:make_dir(XDGDir)"}}},
    {:target_directory_create_error, {:dbg_wx_settings, :default_settings_dir, 1},
     :target_create_error_to_cwd, :settings,
     %{core: {102, "_Error -> CWD"}, floor: {100, "_Error -> CWD"}}},
    {:parent_directory_created, {:dbg_wx_settings, :default_settings_dir, 1}, :parent_created,
     :settings,
     %{core: {105, "file:make_dir(ToolsDir)"}, floor: {103, "file:make_dir(ToolsDir)"}}},
    {:parent_then_target_created, {:dbg_wx_settings, :default_settings_dir, 1},
     :parent_and_target_created, :settings,
     %{core: {107, "file:make_dir(XDGDir)"}, floor: {105, "file:make_dir(XDGDir)"}}},
    {:parent_then_target_error, {:dbg_wx_settings, :default_settings_dir, 1},
     :target_error_to_cwd, :settings,
     %{core: {109, "_Error -> CWD"}, floor: {107, "_Error -> CWD"}}},
    {:parent_directory_create_error, {:dbg_wx_settings, :default_settings_dir, 1},
     :parent_error_to_cwd, :settings,
     %{core: {111, "_Error -> CWD"}, floor: {109, "_Error -> CWD"}}},
    {:create_cancelled, {:dbg_wx_settings, :default_settings_dir, 1}, :confirm_cancel_to_cwd,
     :settings, %{core: {114, "cancel -> CWD"}, floor: {112, "cancel -> CWD"}}},
    {:monitor_start_unregistered, {:dbg_wx_mon, :start, 2}, :whereis_undefined, :monitor,
     %{core: {77, "case whereis(?MODULE) of"}, floor: {73, "case whereis(?MODULE) of"}}},
    {:monitor_start_spawned, {:dbg_wx_mon, :start, 2}, :spawn_private_init, :monitor,
     %{
       core: {80, "spawn(fun () -> init(CallingPid, Mode, SFile) end)"},
       floor: {76, "spawn(fun () -> init(CallingPid, Mode, SFile) end)"}
     }},
    {:monitor_start_success, {:dbg_wx_mon, :start, 2}, :initialization_complete, :monitor,
     %{
       core: {82, "{initialization_complete, Pid}"},
       floor: {78, "{initialization_complete, Pid}"}
     }},
    {:monitor_start_error, {:dbg_wx_mon, :start, 2}, :startup_error_message, :monitor,
     %{core: {84, "Error ->"}, floor: {80, "Error ->"}}},
    {:monitor_start_already_started, {:dbg_wx_mon, :start, 2}, :already_started_return, :monitor,
     %{
       core: {89, "{error, {already_started,Pid}}"},
       floor: {85, "{error, {already_started,Pid}}"}
     }},
    {:startup_graphics_error, {:dbg_wx_mon, :init, 3}, :wx_init_exit_reports_error, :monitor,
     %{core: {120, "{'EXIT', Reason} ->"}, floor: {116, "{'EXIT', Reason} ->"}}},
    {:startup_graphics_ready, {:dbg_wx_mon, :init, 3}, :wx_init_value_enters_init2, :monitor,
     %{core: {122, "GS ->"}, floor: {118, "GS ->"}}},
    {:startup_init2_stop, {:dbg_wx_mon, :init, 3}, :stop_exit_is_ignored, :monitor,
     %{core: {126, "exit:stop -> stop;"}, floor: {122, "exit:stop -> stop;"}}},
    {:startup_init2_error, {:dbg_wx_mon, :init, 3}, :init2_exception_is_reported, :monitor,
     %{core: {127, "Error:Reason:Stacktrace ->"}, floor: {123, "Error:Reason:Stacktrace ->"}}},
    {:startup_default_no_replay, {:dbg_wx_mon, :init2, 4}, :default_skips_settings_replay,
     :monitor, %{core: {184, "SFile =:= default"}, floor: {180, "SFile =:= default"}}},
    {:startup_default_loop, {:dbg_wx_mon, :init2, 4}, :default_enters_loop_without_replay,
     :monitor, %{core: {185, "loop(State3)"}, floor: {181, "loop(State3)"}}},
    {:startup_selected_replay, {:dbg_wx_mon, :init2, 4}, :nondefault_loads_settings, :monitor,
     %{
       core: {187, "loop(load_settings(SFile, State3))"},
       floor: {183, "loop(load_settings(SFile, State3))"}
     }},
    {:load_menu_cancel, {:dbg_wx_mon, :gui_cmd, 2}, :cancel_preserves_state, :monitor,
     %{core: {304, "cancel ->"}, floor: {300, "cancel ->"}}},
    {:load_menu_selected, {:dbg_wx_mon, :gui_cmd, 2}, :selected_file_replayed, :monitor,
     %{
       core: {305, "{ok, File} -> load_settings(File,State)"},
       floor: {301, "{ok, File} -> load_settings(File,State)"}
     }},
    {:settings_read_success, {:dbg_wx_mon, :load_settings, 2}, :read_binary, :monitor,
     %{core: {677, "{ok, Binary} ->"}, floor: {673, "{ok, Binary} ->"}}},
    {:settings_read_error, {:dbg_wx_mon, :load_settings, 2}, :read_error_preserves_state,
     :monitor,
     %{core: {685, "{error, _Reason} -> State"}, floor: {681, "{error, _Reason} -> State"}}},
    {:settings_decode_match, {:dbg_wx_mon, :load_settings, 2}, :debugger_settings_envelope,
     :monitor,
     %{
       core: {679, "{debugger_settings, Settings}"},
       floor: {675, "{debugger_settings, Settings}"}
     }},
    {:settings_decode_mismatch, {:dbg_wx_mon, :load_settings, 2}, :decode_error_preserves_state,
     :monitor, %{core: {683, "_Error -> State"}, floor: {679, "_Error -> State"}}},
    {:legacy_tuple_keep, {:dbg_wx_mon, :loaded, 1}, :legacy_implicit_strings_keep, :monitor,
     %{core: {745, "BackTrace,keep,Files,Breaks"}, floor: {741, "BackTrace,keep,Files,Breaks"}}},
    {:current_settings_keys, {:dbg_wx_mon, :loaded, 1}, :current_seven_keys, :monitor,
     %{
       core: {747, "Keys = [trace_win,auto_attach,stack_trace,back_trace,strings,files,"},
       floor: {743, "Keys = [trace_win,auto_attach,stack_trace,back_trace,strings,files,"}
     }},
    {:missing_settings_key, {:dbg_wx_mon, :loaded, 1}, :missing_values_are_source_nil, :monitor,
     %{
       core: {749, "proplists:get_value(Key, Settings)"},
       floor: {745, "proplists:get_value(Key, Settings)"}
     }},
    {:trace_windows_selected, {:dbg_wx_mon, :load_settings2, 2}, :selected_areas_true, :monitor,
     %{
       core: {694, "dbg_wx_mon_win:select(Area, true)"},
       floor: {690, "dbg_wx_mon_win:select(Area, true)"}
     }},
    {:trace_windows_unselected, {:dbg_wx_mon, :load_settings2, 2}, :other_areas_false, :monitor,
     %{
       core: {696, "dbg_wx_mon_win:select(Area, false)"},
       floor: {692, "dbg_wx_mon_win:select(Area, false)"}
     }},
    {:auto_attach_false, {:dbg_wx_mon, :load_settings2, 2}, :disable_auto_attach, :monitor,
     %{
       core: {700, "false -> int:auto_attach(false)"},
       floor: {696, "false -> int:auto_attach(false)"}
     }},
    {:auto_attach_tuple, {:dbg_wx_mon, :load_settings2, 2}, :restore_flags_and_function, :monitor,
     %{
       core: {701, "{Flags, Function} -> int:auto_attach(Flags, Function)"},
       floor: {697, "{Flags, Function} -> int:auto_attach(Flags, Function)"}
     }},
    {:strings_keep, {:dbg_wx_mon, :load_settings2, 2}, :keep_skips_update, :monitor,
     %{core: {707, "Strings =:= keep"}, floor: {703, "Strings =:= keep"}}},
    {:strings_show, {:dbg_wx_mon, :load_settings2, 2}, :show_selected_strings, :monitor,
     %{
       core: {709, "show_option(State#state.win, strings, Strings)"},
       floor: {705, "show_option(State#state.win, strings, Strings)"}
     }},
    {:backtrace_show, {:dbg_wx_mon, :load_settings2, 2}, :show_backtrace_size, :monitor,
     %{
       core: {713, "show_option(State#state.win, back_trace, BackTrace)"},
       floor: {709, "show_option(State#state.win, back_trace, BackTrace)"}
     }},
    {:local_files_empty, {:dbg_wx_mon, :load_settings2, 2}, :empty_local_list_no_iteration,
     :monitor, %{core: {716, "local -> lists:foreach"}, floor: {712, "local -> lists:foreach"}}},
    {:local_files_single, {:dbg_wx_mon, :load_settings2, 2}, :single_local_file, :monitor,
     %{core: {716, "int:i(File)"}, floor: {712, "int:i(File)"}}},
    {:local_files_multiple, {:dbg_wx_mon, :load_settings2, 2}, :multiple_local_files_in_order,
     :monitor, %{core: {716, "int:i(File)"}, floor: {712, "int:i(File)"}}},
    {:global_files_empty, {:dbg_wx_mon, :load_settings2, 2}, :empty_global_list_no_iteration,
     :monitor,
     %{core: {717, "global -> lists:foreach"}, floor: {713, "global -> lists:foreach"}}},
    {:global_files_single, {:dbg_wx_mon, :load_settings2, 2}, :single_global_file, :monitor,
     %{core: {717, "int:ni(File)"}, floor: {713, "int:ni(File)"}}},
    {:global_files_multiple, {:dbg_wx_mon, :load_settings2, 2}, :multiple_global_files_in_order,
     :monitor, %{core: {717, "int:ni(File)"}, floor: {713, "int:ni(File)"}}},
    {:break_status_inactive, {:dbg_wx_mon, :load_settings2, 2}, :inactive_break_disabled,
     :monitor, %{core: {724, "Status =:= inactive"}, floor: {720, "Status =:= inactive"}}},
    {:break_status_active, {:dbg_wx_mon, :load_settings2, 2}, :active_break_keeps_default,
     :monitor, %{core: {726, "true -> ignore"}, floor: {722, "true -> ignore"}}},
    {:break_action_enable, {:dbg_wx_mon, :load_settings2, 2}, :enable_action_keeps_default,
     :monitor, %{core: {731, "true -> ignore"}, floor: {727, "true -> ignore"}}},
    {:break_action_custom, {:dbg_wx_mon, :load_settings2, 2}, :custom_action_restored, :monitor,
     %{
       core: {730, "int:action_at_break(Mod,Line,Action)"},
       floor: {726, "int:action_at_break(Mod,Line,Action)"}
     }},
    {:break_condition_tuple, {:dbg_wx_mon, :load_settings2, 2}, :condition_tuple_restored,
     :monitor,
     %{
       core: {734, "CFunction when is_tuple(CFunction)"},
       floor: {730, "CFunction when is_tuple(CFunction)"}
     }},
    {:break_condition_null, {:dbg_wx_mon, :load_settings2, 2}, :null_condition_ignored, :monitor,
     %{core: {736, "null -> ignore"}, floor: {732, "null -> ignore"}}}
  ]

  @callback_branch_specs [
    {:auto_attach_empty_flags, {:int, :auto_attach, 2}, :empty_flags_disables, :int,
     %{
       core: {391, "auto_attach([], _Function) ->"},
       floor: {387, "auto_attach([], _Function) ->"}
     }},
    {:auto_attach_false_store, {:dbg_iserver, :handle_cast, 2}, :false_setting_stored, :iserver,
     %{
       core: {357, "handle_cast({set_auto_attach, false}, State) ->"},
       floor: {355, "handle_cast({set_auto_attach, false}, State) ->"}
     }},
    {:auto_attach_false_broadcast, {:dbg_iserver, :handle_cast, 2}, :false_setting_broadcast,
     :iserver,
     %{
       core: {358, "send_all(subscriber, {auto_attach, false}, State)"},
       floor: {356, "send_all(subscriber, {auto_attach, false}, State)"}
     }},
    {:auto_attach_two_tuple, {:int, :auto_attach, 2}, :tuple_expands_empty_args, :int,
     %{
       core: {393, "auto_attach(Flags, {Mod, Func}) ->"},
       floor: {389, "auto_attach(Flags, {Mod, Func}) ->"}
     }},
    {:auto_attach_tuple_store, {:dbg_iserver, :handle_cast, 2}, :flags_and_function_stored,
     :iserver,
     %{
       core: {360, "handle_cast({set_auto_attach, Flags, Function}, State) ->"},
       floor: {358, "handle_cast({set_auto_attach, Flags, Function}, State) ->"}
     }},
    {:auto_attach_tuple_broadcast, {:dbg_iserver, :handle_cast, 2}, :flags_and_function_broadcast,
     :iserver,
     %{
       core: {361, "send_all(subscriber, {auto_attach, {Flags, Function}}, State)"},
       floor: {359, "send_all(subscriber, {auto_attach, {Flags, Function}}, State)"}
     }},
    {:auto_attach_valid_tuple, {:int, :auto_attach, 3}, :validated_flags_function_args, :int,
     %{
       core: {395, "auto_attach(Flags, {Mod, Func, Args})"},
       floor: {391, "auto_attach(Flags, {Mod, Func, Args})"}
     }},
    {:auto_attach_safe_cast, {:int, :auto_attach, 3}, :safe_cast_setting, :int,
     %{
       core: {397, "dbg_iserver:safe_cast({set_auto_attach, Flags, {Mod, Func, Args}})"},
       floor: {393, "dbg_iserver:safe_cast({set_auto_attach, Flags, {Mod, Func, Args}})"}
     }},
    {:auto_attach_flag_init, {:int, :check_flags, 1}, :init_flag_accepted, :int,
     %{core: {399, "check_flags([init|Flags])"}, floor: {395, "check_flags([init|Flags])"}}},
    {:auto_attach_flag_break, {:int, :check_flags, 1}, :break_flag_accepted, :int,
     %{core: {400, "check_flags([break|Flags])"}, floor: {396, "check_flags([break|Flags])"}}},
    {:auto_attach_flag_exit, {:int, :check_flags, 1}, :exit_flag_accepted, :int,
     %{core: {401, "check_flags([exit|Flags])"}, floor: {397, "check_flags([exit|Flags])"}}},
    {:auto_attach_flags_complete, {:int, :check_flags, 1}, :empty_flag_tail_is_valid, :int,
     %{core: {402, "check_flags([]) -> true"}, floor: {398, "check_flags([]) -> true"}}},
    {:auto_attach_init_event, {:dbg_iserver, :handle_call, 3}, :new_process_init_event, :iserver,
     %{
       core: {206, "auto_attach(init, State#state.auto, Pid)"},
       floor: {204, "auto_attach(init, State#state.auto, Pid)"}
     }},
    {:auto_attach_init_result_break, {:dbg_iserver, :handle_call, 3},
     :spawned_process_reports_break, :iserver,
     %{
       core: {207, "AttPid when is_pid(AttPid) -> break"},
       floor: {205, "AttPid when is_pid(AttPid) -> break"}
     }},
    {:auto_attach_init_result_running, {:dbg_iserver, :handle_call, 3},
     :ignored_process_reports_running, :iserver,
     %{core: {208, "ignore -> running"}, floor: {206, "ignore -> running"}}},
    {:auto_attach_break_event, {:dbg_iserver, :handle_cast, 2}, :break_event_gate, :iserver,
     %{
       core: {420, "_ = auto_attach(break, State#state.auto, Proc)"},
       floor: {418, "_ = auto_attach(break, State#state.auto, Proc)"}
     }},
    {:auto_attach_exit_event, {:dbg_iserver, :handle_info, 2}, :exit_event_gate, :iserver,
     %{
       core: {490, "_ = auto_attach(exit, State#state.auto, Pid)"},
       floor: {488, "_ = auto_attach(exit, State#state.auto, Pid)"}
     }},
    {:auto_attach_process_unattached, {:dbg_iserver, :auto_attach, 3},
     :unattached_process_recurses, :iserver,
     %{
       core: {540, "undefined -> auto_attach(Why, Auto, Pid)"},
       floor: {538, "undefined -> auto_attach(Why, Auto, Pid)"}
     }},
    {:auto_attach_already_attached_ignore, {:dbg_iserver, :auto_attach, 3},
     :already_attached_is_ignored, :iserver,
     %{
       core: {541, "_ when is_pid(Attpid) -> ignore"},
       floor: {539, "_ when is_pid(Attpid) -> ignore"}
     }},
    {:auto_attach_false_ignore, {:dbg_iserver, :auto_attach, 3}, :false_setting_disables_spawn,
     :iserver, %{core: {545, "false -> ignore"}, floor: {543, "false -> ignore"}}},
    {:auto_attach_event_membership, {:dbg_iserver, :auto_attach, 3}, :event_compared_to_flags,
     :iserver,
     %{
       core: {547, "case lists:member(Why, Flags) of"},
       floor: {545, "case lists:member(Why, Flags) of"}
     }},
    {:auto_attach_event_match_spawn, {:dbg_iserver, :auto_attach, 3},
     :matching_event_spawns_callback, :iserver,
     %{
       core: {549, "spawn(Mod, Func, [Pid | Args])"},
       floor: {547, "spawn(Mod, Func, [Pid | Args])"}
     }},
    {:auto_attach_event_nonmatch_ignore, {:dbg_iserver, :auto_attach, 3},
     :nonmatching_event_is_ignored, :iserver,
     %{core: {550, "false -> ignore"}, floor: {548, "false -> ignore"}}},
    {:condition_setter_input, {:int, :test_at_break, 3}, :module_line_input_validated, :int,
     %{
       core: {560, "test_at_break(Mod, Line, Function)"},
       floor: {556, "test_at_break(Mod, Line, Function)"}
     }},
    {:condition_setter_function_checked, {:int, :test_at_break, 3},
     :callback_checked_before_store, :int,
     %{core: {561, "check_function(Function)"}, floor: {557, "check_function(Function)"}}},
    {:condition_setter_broadcast, {:int, :test_at_break, 3}, :condition_sent_to_server, :int,
     %{
       core: {562, "dbg_iserver:safe_cast({break_option, {Mod, Line}, condition, Function})"},
       floor: {558, "dbg_iserver:safe_cast({break_option, {Mod, Line}, condition, Function})"}
     }},
    {:condition_server_key_found, {:dbg_iserver, :handle_cast, 2},
     :existing_break_options_updated, :iserver,
     %{
       core: {387, "case lists:keyfind(Point, 1, State#state.breaks) of"},
       floor: {385, "case lists:keyfind(Point, 1, State#state.breaks) of"}
     }},
    {:condition_option_slot, {:dbg_iserver, :handle_cast, 2}, :condition_uses_fourth_slot,
     :iserver, %{core: {392, "condition -> 4"}, floor: {390, "condition -> 4"}}},
    {:condition_options_broadcast, {:dbg_iserver, :handle_cast, 2}, :updated_break_broadcast,
     :iserver,
     %{
       core: {395, "send_all([subscriber, meta, attached],"},
       floor: {393, "send_all([subscriber, meta, attached],"}
     }},
    {:condition_server_missing_break, {:dbg_iserver, :handle_cast, 2}, :missing_break_is_ignored,
     :iserver, %{core: {400, "false ->"}, floor: {398, "false ->"}}},
    {:condition_message_received, {:dbg_icmd, :handle_int_msg, 4}, :break_options_message_stored,
     :icmd,
     %{
       core: {291, "handle_int_msg({break_options, Break}, _Status, _Bs, _Ieval) ->"},
       floor: {289, "handle_int_msg({break_options, Break}, _Status, _Bs, _Ieval) ->"}
     }},
    {:condition_process_dictionary_updated, {:dbg_icmd, :handle_int_msg, 4},
     :current_breakpoint_options_replaced, :icmd,
     %{
       core: {293, "put(breakpoints, lists:keyreplace(Point,1,get(breakpoints), Break))"},
       floor: {291, "put(breakpoints, lists:keyreplace(Point,1,get(breakpoints), Break))"}
     }},
    {:condition_break_p_called, {:dbg_icmd, :cmd, 4}, :running_expression_checks_breakpoint,
     :icmd,
     %{
       core: {66, "case break_p(M, Line, Le, Bs) of"},
       floor: {64, "case break_p(M, Line, Le, Bs) of"}
     }},
    {:conditional_callback_clause, {:dbg_icmd, :break_p, 4}, :dynamic_condition_is_source_only,
     :icmd, %{core: {97, "try CM:CN(Bs) of"}, floor: {95, "try CM:CN(Bs) of"}}},
    {:condition_breakpoint_active, {:dbg_icmd, :break_p, 4},
     :active_breakpoint_and_condition_loaded, :icmd,
     %{
       core: {90, "{value, {_Point, [active, Action, _, Cond]}} ->"},
       floor: {88, "{value, {_Point, [active, Action, _, Cond]}} ->"}
     }},
    {:condition_user_eval_suppressed, {:dbg_icmd, :break_p, 4},
     :recursive_user_evaluation_suppressed, :icmd,
     %{core: {92, "[{Line, Le}|_] -> false"}, floor: {90, "[{Line, Le}|_] -> false"}}},
    {:condition_null_true, {:dbg_icmd, :break_p, 4}, :null_condition_is_true, :icmd,
     %{core: {95, "null -> true"}, floor: {93, "null -> true"}}},
    {:condition_tuple_callback, {:dbg_icmd, :break_p, 4}, :module_function_called_with_bindings,
     :icmd, %{core: {97, "try CM:CN(Bs) of"}, floor: {95, "try CM:CN(Bs) of"}}},
    {:condition_callback_true, {:dbg_icmd, :break_p, 4}, :callback_true_result, :icmd,
     %{core: {98, "true -> true"}, floor: {96, "true -> true"}}},
    {:condition_callback_false, {:dbg_icmd, :break_p, 4}, :callback_false_result, :icmd,
     %{core: {99, "false -> false"}, floor: {97, "false -> false"}}},
    {:condition_callback_other_false, {:dbg_icmd, :break_p, 4}, :other_callback_result_false,
     :icmd, %{core: {100, "_Term -> false"}, floor: {98, "_Term -> false"}}},
    {:condition_callback_exception_false, {:dbg_icmd, :break_p, 4},
     :callback_exception_caught_false, :icmd,
     %{core: {102, "_C:_R -> false"}, floor: {100, "_C:_R -> false"}}},
    {:condition_true_actions, {:dbg_icmd, :break_p, 4}, :true_condition_enters_action_case, :icmd,
     %{core: {106, "Bool ->"}, floor: {104, "Bool ->"}}},
    {:condition_action_enable, {:dbg_icmd, :break_p, 4}, :enable_keeps_break_enabled, :icmd,
     %{core: {108, "enable -> ignore"}, floor: {106, "enable -> ignore"}}},
    {:condition_action_disable, {:dbg_icmd, :break_p, 4}, :disable_marks_break_inactive, :icmd,
     %{core: {109, "disable ->"}, floor: {107, "disable ->"}}},
    {:condition_action_delete, {:dbg_icmd, :break_p, 4}, :delete_removes_break, :icmd,
     %{core: {115, "delete ->"}, floor: {113, "delete ->"}}},
    {:condition_false_action_ignored, {:dbg_icmd, :break_p, 4},
     :false_condition_does_not_change_action, :icmd,
     %{core: {120, "true -> ignore"}, floor: {118, "true -> ignore"}}},
    {:condition_boolean_returned, {:dbg_icmd, :break_p, 4}, :condition_result_returned_to_command,
     :icmd, %{core: {122, "Bool"}, floor: {120, "Bool"}}},
    {:condition_inactive_or_missing_false, {:dbg_icmd, :break_p, 4},
     :inactive_or_missing_breakpoint_false, :icmd,
     %{core: {124, "_Other ->"}, floor: {122, "_Other ->"}}}
  ]

  @all_branch_specs @settings_branch_specs ++ @callback_branch_specs

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
        deferred_auto_attach: [
          {:int, :auto_attach, 2},
          {:dbg_iserver, :handle_cast, 2},
          {:dbg_iserver, :auto_attach, 3},
          :init_break_exit_event_gate,
          :spawn_callback_if_flag_matches
        ],
        conditional_break: [
          {:int, :test_at_break, 3},
          {:dbg_iserver, :handle_cast, 2},
          {:dbg_icmd, :handle_int_msg, 4},
          {:dbg_icmd, :cmd, 4},
          {:dbg_icmd, :break_p, 4},
          :source_only_dynamic_condition
        ]
      },
      defaults: %{
        settings_file: :caller_selected_or_default,
        strings: :legacy_keep,
        missing_keys: nil,
        auto_attach: false,
        empty_file_lists: :no_iteration,
        null_condition: :ignored_during_replay
      },
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

  def records(lane_name),
    do: raise(ArgumentError, "unsupported debugger settings lane: #{inspect(lane_name)}")

  def load_delegation! do
    root = File.cwd!()
    delegation_path = Path.join([root, @delegation_dir, @delegation_file])
    bytes = read_regular_file!(delegation_path, "effective delegation")

    decompressed =
      try do
        :zlib.gunzip(bytes)
      rescue
        error ->
          ownership_fail!("effective delegation gzip is malformed: #{Exception.message(error)}")
      end

    require_ownership!(byte_size(decompressed) > 0, "effective delegation is empty")

    require_ownership!(
      String.ends_with?(decompressed, "\n"),
      "effective delegation lacks its final newline"
    )

    lines = String.split(decompressed, "\n") |> List.delete_at(-1)

    require_ownership!(
      lines != [] and Enum.all?(lines, &(String.trim(&1) != "")),
      "effective delegation contains no records or a blank record"
    )

    rows =
      Enum.with_index(lines, 1)
      |> Enum.map(fn {line, line_number} ->
        decoded =
          try do
            JSON.decode!(line)
          rescue
            error ->
              ownership_fail!(
                "effective delegation JSON is malformed at line #{line_number}: #{Exception.message(error)}"
              )
          end

        require_ownership!(
          is_map(decoded),
          "effective delegation line #{line_number} is not an object"
        )

        decoded
      end)

    [metadata | records] = rows

    require_ownership!(
      metadata["t"] == "delegation",
      "effective delegation must start with exactly one metadata record"
    )

    require_ownership!(
      Enum.count(records, &(&1["t"] == "delegation")) == 0,
      "effective delegation contains duplicate or misplaced metadata"
    )

    validate_delegation_metadata!(metadata, root)
    validate_delegation_rows!(records, metadata)

    %{
      path: delegation_path,
      sha256: sha256(bytes),
      metadata: metadata,
      records: records
    }
  end

  def pending_owners do
    %{records: records} = load_delegation!()

    module_rows =
      Enum.filter(records, fn row ->
        row["t"] in ["module", "observed_module"] and row["app"] == "debugger" and
          row["owner"] == @remainder_owner and row["pending"] == true
      end)

    grouped = Enum.group_by(module_rows, & &1["module"])

    Enum.reduce(grouped, %{}, fn {module, rows}, owners ->
      module_owners = rows |> Enum.map(& &1["owner"]) |> Enum.uniq()
      lanes = rows |> Enum.map(& &1["lane"]) |> Enum.uniq() |> Enum.sort()

      require_ownership!(
        module_owners == [@remainder_owner] and lanes == ["core", "floor"],
        "debugger module #{module} has conflicting or incomplete current pending ownership; owner=#{inspect(module_owners)} lanes=#{inspect(lanes)}"
      )

      Map.put(owners, module, @remainder_owner)
    end)
  end

  def assert_ownership!(graph, evidence, records) do
    loaded = load_delegation!()
    delegation_metadata = Map.get(records, :delegation_metadata, loaded.metadata)
    delegation_records = Map.get(records, :delegation_records, loaded.records)
    lane = evidence.lane.name

    validate_complete_delegation!(delegation_records, loaded.records)
    validate_delegation_rows!(delegation_records, delegation_metadata)

    require_ownership!(
      delegation_metadata == loaded.metadata,
      "effective delegation metadata differs from the pinned adopted authority"
    )

    require_ownership!(
      graph.lane.name == lane,
      "lane #{lane} owner=#{@owner} graph lane=#{graph.lane.name} caller-chain=installed Xref graph remedy=use matching lane evidence"
    )

    tier = apply(Fablebook.Credo.BannedCalls, :banned_mfas, [])
    :ok = assert_audit!(records, graph, tier, evidence, [])
    receipt = assert_graph_receipt!(graph)

    lane_rows = Enum.filter(delegation_records, &(&1["lane"] == lane))

    module_namespaces = %{
      "original" => "module",
      "observed" => "observed_module"
    }

    root_namespaces = %{
      "original" => "root",
      "observed" => "observed_root"
    }

    module_sets =
      Map.new(module_namespaces, fn {namespace, kind} ->
        rows = Enum.filter(lane_rows, &(&1["t"] == kind and &1["app"] == "debugger"))
        identities = Enum.map(rows, &{&1["app"], &1["module"]})
        owners = Map.new(rows, &{{&1["app"], &1["module"]}, &1["owner"]})

        {namespace,
         %{
           rows: rows,
           identities: unique_identity_set!(identities, "#{namespace} module"),
           owners: owners
         }}
      end)

    root_sets =
      Map.new(root_namespaces, fn {namespace, kind} ->
        rows = Enum.filter(lane_rows, &(&1["t"] == kind))
        identities = Enum.map(rows, &{&1["app"], &1["module"], &1["function"], &1["arity"]})

        owners =
          Map.new(rows, &{{&1["app"], &1["module"], &1["function"], &1["arity"]}, &1["owner"]})

        {namespace,
         %{
           rows: rows,
           identities: unique_identity_set!(identities, "#{namespace} root"),
           owners: owners
         }}
      end)

    actual_module_ids =
      graph.inspected
      |> Enum.filter(&(&1.app == "debugger"))
      |> Enum.reject(&(Atom.to_string(&1.module_atom) in @debugger_seed_modules))
      |> Enum.map(&{&1.app, Atom.to_string(&1.module_atom)})
      |> MapSet.new()

    for namespace <- ["original", "observed"] do
      module_set = Map.fetch!(module_sets, namespace)

      require_ownership!(
        module_set.identities == actual_module_ids,
        "lane #{lane} namespace=#{namespace} app=debugger owner=#{@remainder_owner} identity=module set differs from inspected BEAMs; missing=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(actual_module_ids, module_set.identities))))}; extra=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(module_set.identities, actual_module_ids))))}; caller-chain=installed debugger BEAM inventory remedy=route every added or missing module through its named owner"
      )

      selected = MapSet.new([{"debugger", Atom.to_string(@settings_module)}])

      for {{app, module}, owner} <- module_set.owners do
        expected_owner =
          if MapSet.member?(selected, {app, module}), do: @owner, else: @remainder_owner

        require_ownership!(
          owner == expected_owner,
          "lane #{lane} namespace=#{namespace} MFA #{module} owner=#{owner} caller-chain=adopted module task remedy=assign selected settings module to #{@owner} and every broad remainder module to #{@remainder_owner}"
        )
      end
    end

    original_roots = Map.fetch!(root_sets, "original")
    observed_roots = Map.fetch!(root_sets, "observed")

    require_ownership!(
      original_roots.identities == observed_roots.identities,
      "lane #{lane} owner=#{@remainder_owner} original and observed root identity sets differ; caller-chain=adopted receipt union remedy=preserve both complete root namespaces"
    )

    assert_namespace_history_pair!(module_sets, :module, lane)
    assert_namespace_history_pair!(root_sets, :root, lane)

    actual_root_ids = MapSet.new(Map.keys(receipt.pending_by_identity))

    missing_root_ids = MapSet.difference(original_roots.identities, actual_root_ids)

    new_root_ids =
      actual_root_ids
      |> MapSet.difference(original_roots.identities)
      |> Enum.filter(fn {app, _module, _function, _arity} -> app == "debugger" end)
      |> MapSet.new()

    require_ownership!(
      MapSet.size(missing_root_ids) == 0,
      "lane #{lane} owner=#{@remainder_owner} delegated pending roots disappeared from the validated live receipt; missing=#{inspect(Enum.sort(MapSet.to_list(missing_root_ids)))} caller-chain=current pending_mfa receipt remedy=restore the pending identity or provide an approved completion record"
    )

    new_root_observations = observe_new_roots!(new_root_ids, receipt, module_sets, lane)

    selected_root_ids =
      original_roots.rows
      |> Enum.filter(&(&1["owner"] == @owner))
      |> Enum.map(&{&1["app"], &1["module"], &1["function"], &1["arity"]})
      |> MapSet.new()

    audit_root_ids =
      MapSet.new(
        records.roots,
        &{"debugger", Atom.to_string(elem(&1.mfa, 0)), Atom.to_string(elem(&1.mfa, 1)),
         elem(&1.mfa, 2)}
      )

    require_ownership!(
      selected_root_ids == audit_root_ids and MapSet.size(selected_root_ids) == 3,
      "lane #{lane} owner=#{@owner} selected canonical root set differs from the three source-reviewed monitor roots; caller-chain=dbg_wx_mon start/load_settings/load_settings2 remedy=retain the exact adopted root set"
    )

    remainder_module_ids =
      original_roots.rows
      |> then(fn _ ->
        Enum.filter(Map.fetch!(module_sets, "original").rows, &(&1["owner"] == @remainder_owner))
      end)
      |> Enum.map(&{&1["app"], &1["module"]})
      |> MapSet.new()

    actual_pending_module_ids =
      graph.pending_modules
      |> Enum.filter(&(&1.app == "debugger"))
      |> Enum.map(&{&1.app, Atom.to_string(&1.module_atom)})
      |> MapSet.new()

    require_ownership!(
      remainder_module_ids == actual_pending_module_ids,
      "lane #{lane} owner=#{@remainder_owner} remainder modules do not match actual pending debugger modules; missing=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(remainder_module_ids, actual_pending_module_ids))))}; extra=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(actual_pending_module_ids, remainder_module_ids))))}; caller-chain=pending module projection remedy=keep all broad debugger modules pending or reconcile the changed identity"
    )

    active_debugger_modules =
      graph.active_modules
      |> Enum.filter(&(Map.get(receipt.module_app, &1) == "debugger"))
      |> Enum.map(&Atom.to_string/1)
      |> MapSet.new()

    expected_active_modules =
      MapSet.new(@debugger_seed_modules ++ [Atom.to_string(@settings_module)])

    require_ownership!(
      active_debugger_modules == expected_active_modules and
        MapSet.size(
          MapSet.intersection(
            active_debugger_modules,
            MapSet.new(Enum.map(remainder_module_ids, &elem(&1, 1)))
          )
        ) == 0,
      "lane #{lane} owner=#{@owner} selected settings module is not the sole new active debugger member; actual=#{inspect(Enum.sort(MapSet.to_list(active_debugger_modules)))} expected seeds plus dbg_wx_settings; caller-chain=assert_audit! before active projection remedy=activate only source-proven dbg_wx_settings and retain the prior three-module seed"
    )

    root_observations =
      Enum.flat_map(root_sets, fn {namespace, root_set} ->
        Enum.map(root_set.rows, fn row ->
          mfa = {row["module"], row["function"], row["arity"]}
          actual = Map.fetch!(receipt.pending_by_mfa, mfa)
          canonical_tokens = Enum.map(row["steps"], & &1["token"])
          observed_tokens = actual["caller_chain"]

          canonical_chain_id =
            if namespace == "observed",
              do: get_in(row, ["historical", "chain_id"]),
              else: row["chain_id"]

          observed_chain_id =
            if canonical_tokens == observed_tokens,
              do: row["chain_id"],
              else: observed_chain_id!(row, observed_tokens)

          route_changed = canonical_tokens != observed_tokens
          observed_references = references_for_tokens(observed_tokens, row["owner"])

          %{
            "namespace" => namespace,
            "identity" =>
              row["identity"] ||
                %{
                  "kind" => "root",
                  "lane" => lane,
                  "app" => row["app"],
                  "module" => row["module"],
                  "function" => row["function"],
                  "arity" => row["arity"]
                },
            "origin_record_sha256" => row["origin_record_sha256"],
            "origin_owner" => row["origin_owner"],
            "owner" => row["owner"],
            "canonical_chain_id" => canonical_chain_id,
            "observed_chain_id" => observed_chain_id,
            "references" => observed_references,
            "origin_occurrences" =>
              root_origin_occurrences(delegation_records, lane, namespace, row["chain_id"]),
            "completion" =>
              if(row["owner"] == @owner and not route_changed,
                do: "selected_root_source_disposed",
                else: "pending"
              ),
            "evidence" => %{
              "receipt_sha256" => receipt.sha256,
              "caller_chain" => observed_tokens,
              "canonical_caller_chain" => canonical_tokens,
              "route_changed" => route_changed
            }
          }
        end)
      end)

    module_observations =
      Enum.flat_map(module_sets, fn {namespace, module_set} ->
        Enum.map(module_set.rows, fn row ->
          %{
            "namespace" => namespace,
            "identity" =>
              row["identity"] ||
                %{
                  "kind" => "module",
                  "lane" => lane,
                  "app" => row["app"],
                  "module" => row["module"]
                },
            "origin_record_sha256" => row["origin_record_sha256"],
            "origin_owner" => row["origin_owner"],
            "owner" => row["owner"],
            "canonical_chain_id" => nil,
            "observed_chain_id" => nil,
            "references" => [],
            "origin_occurrences" => [],
            "completion" =>
              if(row["module"] == Atom.to_string(@settings_module),
                do: "selected_settings_functions_exports_and_source_verified",
                else: "pending"
              ),
            "evidence" => %{
              "receipt_sha256" => receipt.sha256,
              "inspected_module" => row["module"]
            }
          }
        end)
      end)

    %{
      status: :verified,
      lane: lane,
      selected_module: @settings_module,
      selected_roots: Enum.sort(MapSet.to_list(selected_root_ids)),
      remainder_module_count: MapSet.size(remainder_module_ids),
      remainder_root_count:
        MapSet.size(MapSet.difference(original_roots.identities, selected_root_ids)),
      pending_observed_delta_count:
        Enum.count(module_observations ++ root_observations ++ new_root_observations, fn row ->
          row["completion"] == "pending" and
            (get_in(row, ["evidence", "route_changed"]) == true or
               get_in(row, ["evidence", "new_pending_graph_identity"]) == true)
        end),
      receipt_sha256: receipt.sha256,
      observations: module_observations ++ root_observations ++ new_root_observations
    }
  end

  def ownership_controls!(graph, evidence, records) do
    %{metadata: metadata, records: authority} = load_delegation!()

    base =
      records
      |> Map.put(:delegation_metadata, metadata)
      |> Map.put(:delegation_records, authority)

    :verified = assert_ownership!(graph, evidence, records).status
    lane = evidence.lane.name

    row = fn kind, predicate ->
      Enum.find(authority, &(&1["t"] == kind and &1["lane"] == lane and predicate.(&1)))
    end

    selected_module? = &(&1["module"] == "dbg_wx_settings")
    remainder_module? = &(&1["module"] == "dbg_wx_mon")

    selected_root? = fn item ->
      item["module"] == "dbg_wx_mon" and item["function"] == "start" and item["arity"] == 2
    end

    remainder_root? = &(&1["owner"] == @remainder_owner)

    drop_rows = fn kind, predicate ->
      Map.update!(base, :delegation_records, fn rows ->
        Enum.reject(rows, &(&1["t"] == kind and &1["lane"] == lane and predicate.(&1)))
      end)
    end

    edit_row = fn kind, predicate, update ->
      Map.update!(base, :delegation_records, fn rows ->
        Enum.map(rows, fn item ->
          if item["t"] == kind and item["lane"] == lane and predicate.(item),
            do: update.(item),
            else: item
        end)
      end)
    end

    add_row = fn kind, item ->
      Map.update!(base, :delegation_records, &(&1 ++ [Map.put(item, "t", kind)]))
    end

    controls = [
      {"missing-selected-module-original",
       fn -> {graph, drop_rows.("module", selected_module?)} end, "omitted"},
      {"missing-selected-module-observed",
       fn -> {graph, drop_rows.("observed_module", selected_module?)} end, "omitted"},
      {"missing-remainder-module-original",
       fn -> {graph, drop_rows.("module", remainder_module?)} end, "omitted"},
      {"missing-remainder-module-observed",
       fn -> {graph, drop_rows.("observed_module", remainder_module?)} end, "omitted"},
      {"missing-selected-root-original", fn -> {graph, drop_rows.("root", selected_root?)} end,
       "omitted"},
      {"missing-selected-root-observed",
       fn -> {graph, drop_rows.("observed_root", selected_root?)} end, "omitted"},
      {"missing-remainder-root-original", fn -> {graph, drop_rows.("root", remainder_root?)} end,
       "omitted"},
      {"missing-remainder-root-observed",
       fn -> {graph, drop_rows.("observed_root", remainder_root?)} end, "omitted"},
      {"duplicate-canonical-root",
       fn -> {graph, add_row.("root", row.("root", selected_root?))} end, "duplicate"},
      {"wrong-selected-owner",
       fn ->
         {graph, edit_row.("module", selected_module?, &Map.put(&1, "owner", @remainder_owner))}
       end, "owner"},
      {"changed-canonical-chain",
       fn ->
         {graph,
          edit_row.("root", selected_root?, &Map.put(&1, "chain_id", String.duplicate("0", 64)))}
       end, "chain"},
      {"changed-current-reference",
       fn ->
         {graph,
          edit_row.("root", selected_root?, &Map.put(&1, "references", ["tampered-owner"]))}
       end, "references"},
      {
        "missing-overlap-occurrence",
        fn ->
          [overlap] =
            Enum.filter(authority, &(&1["t"] == "overlap" and &1["lane"] == lane)) |> Enum.take(1)

          changed = fn rows ->
            Enum.map(rows, fn item ->
              if item["t"] == "overlap" and item["lane"] == lane and
                   item["token"] == overlap["token"],
                 do: Map.update!(item, "occurrences", &Enum.drop(&1, 1)),
                 else: item
            end)
          end

          {graph, Map.update!(base, :delegation_records, changed)}
        end,
        "overlap"
      },
      {"missing-source-branch", fn -> {graph, drop_rows.("source_branch", fn _ -> true end)} end,
       "source_branch"},
      {
        "empty-settings-audit",
        fn ->
          empty = Map.merge(base, %{function_sources: [], function_audit: [], exports: []})
          {graph, empty}
        end,
        "all four exact functions"
      },
      {"changed-settings-source-digest",
       fn -> {graph, Map.put(base, :source_sha256, String.duplicate("0", 64))} end,
       "exact settings source SHA"},
      {
        "escaping-settings-citation",
        fn ->
          escaped =
            Map.update!(base, :function_sources, fn [source | rest] ->
              [
                Map.update!(source, :citation, fn citations ->
                  [Map.put(hd(citations), :path, "../outside.erl") | tl(citations)]
                end)
                | rest
              ]
            end)

          {graph, escaped}
        end,
        "source"
      },
      {
        "graph-new-settings-export",
        fn ->
          new_export = {@settings_module, :unreviewed_saved_settings_entry, 0}
          changed_graph = %{graph | full_exported: MapSet.put(graph.full_exported, new_export)}
          changed_base = Map.update!(base, :exports, &(&1 ++ [new_export]))

          changed_base =
            Map.update!(
              changed_base,
              :function_sources,
              &(&1 ++ [%{mfa: new_export, citation: []}])
            )

          changed_base =
            Map.update!(changed_base, :function_audit, fn [first | rest] ->
              [Map.put(first, :mfa, new_export) | rest]
            end)

          {changed_graph, changed_base}
        end,
        "independent installed graph exports"
      },
      {
        "graph-new-debugger-root",
        fn ->
          new_root = {:dbg_wx_mon, :unreviewed_saved_settings_root, 0}

          changed_graph = %{
            graph
            | full_reached: MapSet.put(graph.full_reached, new_root),
              pending_mfas: MapSet.put(graph.pending_mfas, new_root)
          }

          {changed_graph, base}
        end,
        "graph/receipt sets differ"
      },
      {
        "graph-omitted-debugger-beam",
        fn ->
          changed_graph = %{
            graph
            | inspected:
                Enum.reject(
                  graph.inspected,
                  &(&1.app == "debugger" and &1.module_atom == :dbg_wx_mon)
                )
          }

          {changed_graph, base}
        end,
        "inspected/receipt BEAM sets differ"
      },
      {
        "graph-omitted-debugger-export",
        fn ->
          omitted_export = {:dbg_wx_settings, :load, 3}
          {%{graph | full_exported: MapSet.delete(graph.full_exported, omitted_export)}, base}
        end,
        "independent installed graph exports"
      },
      {
        "graph-omitted-active-baseline",
        fn ->
          {%{graph | active_modules: MapSet.delete(graph.active_modules, :dbg_idb)}, base}
        end,
        "active debugger module graph/receipt sets differ"
      }
    ]

    Enum.map(controls, fn {name, mutate, expected} ->
      rejected =
        try do
          {alternate_graph, alternate_records} = mutate.()
          assert_ownership!(alternate_graph, evidence, alternate_records)
          false
        rescue
          error in ExUnit.AssertionError ->
            String.contains?(Exception.message(error), expected)

          error in Fablebook.Test.SweepEvidence.Error ->
            String.contains?(Exception.message(error), expected)
        end

      require_ownership!(
        rejected,
        "ownership negative control #{name} was accepted or returned the wrong diagnostic category"
      )

      "#{name}:rejected"
    end)
  end

  defp validate_delegation_metadata!(metadata, root) do
    require_ownership!(
      metadata["schema"] == @delegation_schema,
      "effective delegation schema changed"
    )

    require_ownership!(metadata["status"] == "adopted", "effective delegation is not adopted")
    require_ownership!(metadata["parent"] == "01.1.1.3.1", "effective delegation parent changed")

    require_ownership!(
      metadata["children"] == @delegation_children,
      "effective delegation children changed"
    )

    require_ownership!(
      metadata["completion"] == "pending; structural delegation is not semantic evidence",
      "effective delegation claims semantic completion"
    )

    require_ownership!(
      metadata["original_receipt_union"] == "passed" and
        metadata["observed_receipt_union"] == "passed",
      "effective delegation lacks both receipt-union results"
    )

    parent_path = Path.join([root, @parent_ledger_dir, @parent_ledger_file])
    partition_path = Path.join([root, @delegation_dir, @partition_file])
    candidate_path = Path.join([root, @delegation_dir, @candidate_file])
    decision_path = Path.join([root, @delegation_dir, @source_decision_file])
    parent_bytes = read_regular_file!(parent_path, "historical parent ledger")
    partition_bytes = read_regular_file!(partition_path, "adopted partition proposal")
    candidate = JSON.decode!(read_regular_file!(candidate_path, "approved source candidate"))
    decision = read_regular_file!(decision_path, "approved source decision")

    require_ownership!(
      metadata["historical_authority"] == Path.relative_to(parent_path, root),
      "effective delegation historical authority path changed"
    )

    require_ownership!(
      metadata["historical_sha256"] == sha256(parent_bytes),
      "historical parent ledger fingerprint differs from adopted metadata"
    )

    require_ownership!(
      metadata["partition_sha256"] == sha256(partition_bytes),
      "adopted partition fingerprint differs from metadata"
    )

    require_ownership!(
      metadata["source_decision"] == Path.relative_to(decision_path, root),
      "effective delegation source decision path changed"
    )

    require_ownership!(
      metadata["source_candidate_sha256"] == candidate["candidate_sha256"],
      "approved source candidate fingerprint differs from delegation metadata"
    )

    require_ownership!(
      String.contains?(decision, "status: approved") and
        String.contains?(decision, metadata["source_candidate_sha256"]),
      "approved source decision no longer matches the delegated candidate"
    )
  end

  defp validate_delegation_rows!(rows, metadata) when is_list(rows) and is_map(metadata) do
    allowed = [
      "exact_source",
      "module",
      "root",
      "overlap",
      "observed_module",
      "observed_root",
      "observed_overlap",
      "source_branch"
    ]

    require_ownership!(rows != [], "effective delegation has no assignments")

    require_ownership!(
      Enum.all?(rows, &(is_map(&1) and &1["t"] in allowed)),
      "effective delegation contains a malformed or unknown record type"
    )

    typed = Enum.map(rows, &typed_delegation_identity!/1)

    require_ownership!(
      length(typed) == MapSet.size(MapSet.new(typed)),
      "effective delegation contains duplicate typed identities"
    )

    fingerprints =
      rows
      |> Enum.filter(
        &(&1["t"] in [
            "module",
            "root",
            "overlap",
            "observed_module",
            "observed_root",
            "observed_overlap"
          ])
      )
      |> Enum.map(& &1["origin_record_sha256"])

    require_ownership!(
      Enum.all?(fingerprints, &valid_sha256?/1),
      "effective delegation has a missing or malformed origin fingerprint"
    )

    require_ownership!(
      length(fingerprints) == MapSet.size(MapSet.new(fingerprints)),
      "effective delegation duplicates an original or observed origin fingerprint"
    )

    source_branches = Enum.filter(rows, &(&1["t"] == "source_branch"))

    require_ownership!(
      Enum.sort(Enum.map(source_branches, & &1["lane"])) == ["core", "floor"],
      "effective source-branch ledger must retain exactly one pending break_p/4 obligation per lane"
    )

    for row <- rows do
      case row["t"] do
        kind when kind in ["module", "observed_module"] ->
          expected = if row["module"] == "dbg_wx_settings", do: @owner, else: @remainder_owner

          require_ownership!(
            row["app"] == "debugger" and row["owner"] == expected and
              row["origin_owner"] == @historical_owner and row["pending"] == true and
              row["completion"] == "pending",
            "lane #{row["lane"]} module #{row["module"]} owner=#{row["owner"]} caller-chain=adopted module task remedy=restore the effective current owner and pending status"
          )

          if String.starts_with?(kind, "observed_") do
            identity = row["identity"] || %{}

            require_ownership!(
              row["namespace"] == "observed" and identity["kind"] == "module" and
                identity["lane"] == row["lane"] and identity["app"] == row["app"] and
                identity["module"] == row["module"] and valid_sha256?(row["identity_sha256"]),
              "observed module #{row["module"]} has a malformed typed identity"
            )
          end

        kind when kind in ["root", "observed_root"] ->
          mfa = {row["module"], row["function"], row["arity"]}

          selected_root? =
            row["app"] == "debugger" and
              mfa in Enum.map(
                @selected_root_mfas,
                &{Atom.to_string(elem(&1, 0)), Atom.to_string(elem(&1, 1)), elem(&1, 2)}
              )

          expected = if selected_root?, do: @owner, else: @remainder_owner

          require_ownership!(
            is_binary(row["app"]) and row["owner"] == expected and
              row["origin_owner"] == @historical_owner and row["completion"] == "pending" and
              valid_sha256?(row["chain_id"]),
            "lane #{row["lane"]} MFA #{format_root_text(row)} owner=#{row["owner"]} chain=#{inspect(row["chain_id"])} caller-chain=adopted root remedy=preserve canonical chain and current child owner"
          )

          validate_root_projection!(row)

          if String.starts_with?(kind, "observed_") do
            identity = row["identity"] || %{}
            historical_chain_id = get_in(row, ["historical", "chain_id"])

            require_ownership!(
              row["namespace"] == "observed" and identity["kind"] == "root" and
                identity["lane"] == row["lane"] and identity["app"] == row["app"] and
                identity["module"] == row["module"] and identity["function"] == row["function"] and
                identity["arity"] == row["arity"] and valid_sha256?(row["identity_sha256"]) and
                valid_sha256?(historical_chain_id),
              "observed MFA #{format_root_text(row)} changed its canonical chain or typed identity"
            )
          end

        kind when kind in ["overlap", "observed_overlap"] ->
          require_ownership!(
            row["origin_owner"] == nil or row["origin_owner"] == @historical_owner,
            "overlap #{row["token"]} changed historical provenance"
          )

        "exact_source" ->
          expected = if row["module"] == "dbg_wx_settings", do: @owner, else: @remainder_owner

          require_ownership!(
            row["owner"] == expected and row["origin_owner"] == @historical_owner and
              valid_sha256?(row["sha256"]),
            "lane #{row["lane"]} source #{row["module"]} has a changed owner or source fingerprint"
          )

        "source_branch" ->
          lane = row["lane"]
          source_sha = Map.fetch!(@lane_data, lane).icmd_sha256
          {first, last} = if lane == "core", do: {88, 126}, else: {86, 124}

          valid =
            row["app"] == "debugger" and row["module"] == "dbg_icmd" and
              row["function"] == "break_p" and row["arity"] == 4 and row["owner"] == @owner and
              row["origin_owner"] == @historical_owner and row["completion"] == "pending" and
              row["state"] == "source-discovered-unresolved-callback-branch" and
              row["source_sha256"] == source_sha and
              row["source_path"] == "debugger/src/dbg_icmd.erl" and
              row["source_lines"] == [first, last] and
              row["canonical_receipt_root_present"] == false and
              row["shared_broad_roots_remain_with"] == @remainder_owner

          require_ownership!(
            valid,
            "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{row["owner"]} caller-chain=source-discovered callback branch remedy=preserve the selected pending source branch and broad remainder owner"
          )
      end
    end

    validate_delegation_counts!(rows, metadata)
    validate_overlap_projection!(rows)
    :ok
  end

  defp validate_complete_delegation!(actual, expected) do
    actual_by_identity = Map.new(actual, &{typed_delegation_identity!(&1), &1})
    expected_by_identity = Map.new(expected, &{typed_delegation_identity!(&1), &1})
    actual_ids = MapSet.new(Map.keys(actual_by_identity))
    expected_ids = MapSet.new(Map.keys(expected_by_identity))
    missing = MapSet.difference(expected_ids, actual_ids) |> MapSet.to_list() |> Enum.sort()
    extra = MapSet.difference(actual_ids, expected_ids) |> MapSet.to_list() |> Enum.sort()

    require_ownership!(
      length(actual) == MapSet.size(actual_ids),
      "effective delegation contains duplicate typed identities"
    )

    require_ownership!(
      missing == [] and extra == [],
      "effective delegation omitted or added typed identities; missing=#{inspect(missing)} extra=#{inspect(extra)}"
    )

    Enum.each(expected_by_identity, fn {identity, expected_row} ->
      actual_row = Map.fetch!(actual_by_identity, identity)

      if actual_row != expected_row do
        category =
          cond do
            actual_row["owner"] != expected_row["owner"] ->
              "owner"

            actual_row["chain_id"] != expected_row["chain_id"] ->
              "canonical chain"

            actual_row["references"] != expected_row["references"] ->
              "current references"

            actual_row["occurrences"] != expected_row["occurrences"] ->
              "overlap occurrence"

            actual_row["origin_record_sha256"] != expected_row["origin_record_sha256"] ->
              "origin fingerprint"

            actual_row["steps"] != expected_row["steps"] ->
              "caller-chain steps"

            true ->
              "historical fields"
          end

        ownership_fail!(
          "effective delegation changed #{category} for typed identity #{inspect(identity)}"
        )
      end
    end)

    :ok
  end

  defp validate_root_projection!(row) do
    origin_steps = row["origin_steps"]
    current_steps = row["steps"]

    require_ownership!(
      is_list(origin_steps) and is_list(current_steps),
      "MFA #{format_root_text(row)} lost canonical or current caller-chain steps"
    )

    expected_steps =
      Enum.map(origin_steps, fn step ->
        expected_owners =
          step["owners"]
          |> Enum.map(fn owner ->
            if owner == @historical_owner do
              owner_for_step!(step["token"])
            else
              owner
            end
          end)
          |> Enum.uniq()
          |> Enum.sort()

        Map.put(step, "owners", expected_owners)
      end)

    expected_references =
      expected_steps
      |> Enum.flat_map(& &1["owners"])
      |> Enum.uniq()
      |> Enum.reject(&(&1 == row["owner"]))
      |> Enum.sort()

    require_ownership!(
      current_steps == expected_steps and row["references"] == expected_references and
        row["origin_references"] == Enum.sort(row["origin_references"] || []),
      "lane #{row["lane"]} MFA #{format_root_text(row)} owner=#{row["owner"]} canonical_chain_id=#{row["chain_id"]} caller-chain=effective delegated steps/references remedy=restore original tokens and explicit current-owner projection"
    )
  end

  defp validate_overlap_projection!(rows) do
    chain_owners =
      rows
      |> Enum.filter(&(&1["t"] in ["root", "observed_root"]))
      |> Enum.group_by(&{&1["lane"], &1["chain_id"]})
      |> Map.new(fn {key, values} ->
        owners = values |> Enum.map(& &1["owner"]) |> Enum.uniq()

        require_ownership!(
          length(owners) == 1,
          "canonical chain #{inspect(key)} has conflicting delegated owners #{inspect(owners)}"
        )

        {key, hd(owners)}
      end)

    Enum.each(Enum.filter(rows, &(&1["t"] in ["overlap", "observed_overlap"])), fn row ->
      original = row["origin_occurrences"] || []
      current = row["occurrences"] || []

      expected =
        Enum.map(original, fn
          [chain, origin_owner, position] ->
            [chain, Map.get(chain_owners, {row["lane"], chain}, origin_owner), position]

          other ->
            ownership_fail!(
              "overlap #{row["token"]} has malformed origin occurrence #{inspect(other)}"
            )
        end)

      owners = expected |> Enum.map(&Enum.at(&1, 1)) |> Enum.uniq() |> Enum.sort()

      require_ownership!(
        length(original) > 0 and current == expected and row["owners"] == owners,
        "lane #{row["lane"]} overlap #{row["token"]} lost a canonical chain occurrence or current owner; owner=#{inspect(row["owners"])} caller-chain=overlap occurrence projection remedy=restore every chain and position"
      )
    end)
  end

  defp validate_delegation_counts!(rows, metadata) do
    original = Enum.filter(rows, &(&1["t"] in ["module", "root"]))

    for lane <- ["core", "floor"], owner <- @delegation_children do
      modules =
        Enum.filter(
          original,
          &(&1["lane"] == lane and &1["owner"] == owner and &1["t"] == "module")
        )

      roots =
        Enum.filter(
          original,
          &(&1["lane"] == lane and &1["owner"] == owner and &1["t"] == "root")
        )

      expected = get_in(metadata, ["counts", lane, owner]) || %{}

      require_ownership!(
        length(modules) == expected["modules"] and length(roots) == expected["roots"] and
          Enum.count(modules, &(&1["zero_graph_hits"] == true)) == expected["zero_hit_modules"],
        "lane #{lane} owner=#{owner} effective delegation counts differ from adopted metadata; modules=#{length(modules)} roots=#{length(roots)} caller-chain=adopted partition counts remedy=restore missing or duplicated identities"
      )
    end
  end

  defp typed_delegation_identity!(row) do
    lane = row["lane"]
    kind = row["t"]

    case kind do
      "exact_source" -> {kind, lane, row["module"]}
      "module" -> {kind, lane, row["app"], row["module"]}
      "observed_module" -> {kind, lane, row["app"], row["module"]}
      "root" -> {kind, lane, row["app"], row["module"], row["function"], row["arity"]}
      "observed_root" -> {kind, lane, row["app"], row["module"], row["function"], row["arity"]}
      "overlap" -> {kind, lane, row["token"]}
      "observed_overlap" -> {kind, lane, row["token"]}
      "source_branch" -> {kind, lane, row["module"], row["function"], row["arity"]}
      _ -> ownership_fail!("effective delegation has unknown typed identity #{inspect(row)}")
    end
  end

  defp assert_graph_receipt!(graph) do
    verified = Fablebook.Test.InstalledOtp.verify_receipt_lines!(graph.receipt_lines)
    lane = graph.lane.name

    require_ownership!(
      verified.lane == lane,
      "lane #{lane} validated receipt has a different lane"
    )

    debugger_rows =
      graph.receipt_lines
      |> Enum.filter(&String.contains?(&1, "\"app\":\"debugger\""))
      |> Enum.map(fn line ->
        case String.split(line, "FABLEBOOK_OTP_INVENTORY_V2 ", parts: 2) do
          [_prefix, payload] -> JSON.decode!(payload)
          _ -> ownership_fail!("lane #{lane} receipt has an untagged debugger record")
        end
      end)

    module_app = Map.new(graph.ingested, &{&1.module_atom, &1.app})

    inspected =
      graph.inspected
      |> Enum.filter(&(&1.app == "debugger"))
      |> Enum.map(&{&1.app, Atom.to_string(&1.module_atom)})
      |> MapSet.new()

    receipt_modules =
      debugger_rows
      |> Enum.filter(&(&1["kind"] == "beam"))
      |> Enum.map(&{&1["app"], &1["module"]})
      |> MapSet.new()

    require_ownership!(
      inspected == receipt_modules,
      "lane #{lane} owner=#{@remainder_owner} debugger inspected/receipt BEAM sets differ"
    )

    compare_mfas = fn graph_set, kind, label ->
      graph_set =
        graph_set
        |> Enum.filter(fn {module, _function, _arity} ->
          Map.get(module_app, module) == "debugger"
        end)
        |> Enum.map(fn {module, function, arity} ->
          {Atom.to_string(module), Atom.to_string(function), arity}
        end)
        |> MapSet.new()

      receipt_set =
        debugger_rows
        |> Enum.filter(&(&1["kind"] == kind))
        |> Enum.map(&{&1["module"], &1["function"], &1["arity"]})
        |> MapSet.new()

      require_ownership!(
        graph_set == receipt_set,
        "lane #{lane} owner=#{@remainder_owner} debugger #{label} graph/receipt sets differ; missing=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(graph_set, receipt_set))))}; extra=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(receipt_set, graph_set))))}; remedy=restore the complete installed graph record"
      )
    end

    compare_mfas.(graph.full_exported, "export", "exports")
    compare_mfas.(graph.full_reached, "reached", "reached MFAs")
    compare_mfas.(graph.pending_mfas, "pending_mfa", "pending MFAs")
    compare_mfas.(graph.exported, "active_export", "active exports")

    graph_active_edges =
      graph.active_edges
      |> Enum.filter(fn {{module, _, _}, _} -> Map.get(module_app, module) == "debugger" end)
      |> Enum.map(fn {{module, function, arity}, {callee_module, callee_function}} ->
        {Atom.to_string(module), Atom.to_string(function), arity, Atom.to_string(callee_module),
         Atom.to_string(callee_function)}
      end)
      |> MapSet.new()

    receipt_active_edges =
      debugger_rows
      |> Enum.filter(&(&1["kind"] == "active_edge"))
      |> Enum.map(
        &{&1["module"], &1["function"], &1["arity"], &1["callee_module"], &1["callee_function"]}
      )
      |> MapSet.new()

    require_ownership!(
      graph_active_edges == receipt_active_edges,
      "lane #{lane} owner=#{@owner} debugger active edge graph/receipt sets differ"
    )

    graph_pending_modules =
      graph.pending_modules
      |> Enum.filter(&(&1.app == "debugger"))
      |> Enum.map(&{&1.app, Atom.to_string(&1.module_atom)})
      |> MapSet.new()

    receipt_pending_modules =
      debugger_rows
      |> Enum.filter(&(&1["kind"] == "pending_module"))
      |> Enum.map(&{&1["app"], &1["module"]})
      |> MapSet.new()

    require_ownership!(
      graph_pending_modules == receipt_pending_modules,
      "lane #{lane} owner=#{@remainder_owner} pending module graph/receipt sets differ"
    )

    graph_active_modules =
      graph.active_modules
      |> Enum.filter(&(Map.get(module_app, &1) == "debugger"))
      |> Enum.map(&{"debugger", Atom.to_string(&1)})
      |> MapSet.new()

    receipt_active_modules =
      debugger_rows
      |> Enum.filter(&(&1["kind"] == "active_module"))
      |> Enum.map(&{&1["app"], &1["module"]})
      |> MapSet.new()

    require_ownership!(
      graph_active_modules == receipt_active_modules,
      "lane #{lane} owner=#{@owner} active debugger module graph/receipt sets differ"
    )

    graph_boundaries =
      graph.boundary_records
      |> Enum.filter(&(&1["app"] == "debugger"))
      |> Enum.map(&{&1["module"], &1["function"], &1["arity"]})
      |> MapSet.new()

    receipt_boundaries =
      debugger_rows
      |> Enum.filter(&(&1["kind"] == "boundary"))
      |> Enum.map(&{&1["module"], &1["function"], &1["arity"]})
      |> MapSet.new()

    require_ownership!(
      graph_boundaries == receipt_boundaries,
      "lane #{lane} owner=#{@remainder_owner} debugger boundary graph/receipt sets differ"
    )

    all_rows =
      graph.receipt_lines
      |> Enum.map(fn line ->
        case String.split(line, "FABLEBOOK_OTP_INVENTORY_V2 ", parts: 2) do
          [_prefix, payload] -> JSON.decode!(payload)
          _ -> ownership_fail!("lane #{lane} receipt has an untagged record")
        end
      end)

    pending_rows = Enum.filter(debugger_rows, &(&1["kind"] == "pending_mfa"))
    all_pending_rows = Enum.filter(all_rows, &(&1["kind"] == "pending_mfa"))
    pending_by_mfa = Map.new(all_pending_rows, &{{&1["module"], &1["function"], &1["arity"]}, &1})

    require_ownership!(
      map_size(pending_by_mfa) == length(all_pending_rows),
      "lane #{lane} owner=#{@remainder_owner} validated receipt duplicates a pending MFA identity"
    )

    %{
      sha256: verified.sha256,
      module_app: module_app,
      debugger_pending_mfas: pending_rows,
      pending_by_mfa: pending_by_mfa,
      pending_by_identity:
        all_rows
        |> Enum.filter(&(&1["kind"] == "pending_mfa"))
        |> Map.new(&{{&1["app"], &1["module"], &1["function"], &1["arity"]}, &1})
    }
  end

  defp root_origin_occurrences(rows, lane, namespace, chain_id) do
    kind = if namespace == "observed", do: "observed_overlap", else: "overlap"

    rows
    |> Enum.filter(&(&1["lane"] == lane and &1["t"] == kind))
    |> Enum.flat_map(fn overlap ->
      overlap
      |> Map.get("origin_occurrences", [])
      |> Enum.filter(&(Enum.at(&1, 0) == chain_id))
      |> Enum.map(
        &%{
          "token" => overlap["token"],
          "position" => Enum.at(&1, 2),
          "canonical_chain_id" => chain_id
        }
      )
    end)
    |> Enum.sort_by(&{&1["token"], &1["position"]})
  end

  defp owner_for_step!(token) do
    case Regex.run(~r/^(.+)\.([^\.\/]+)\/([0-9]+)$/, token) do
      [_, module, function, arity] ->
        mfa = {module, function, String.to_integer(arity)}

        if module == Atom.to_string(@settings_module) or
             mfa in Enum.map(
               @selected_root_mfas,
               &{Atom.to_string(elem(&1, 0)), Atom.to_string(elem(&1, 1)), elem(&1, 2)}
             ) or mfa == {"dbg_icmd", "break_p", 4}, do: @owner, else: @remainder_owner

      _ ->
        ownership_fail!("adopted caller-chain token is not a typed MFA: #{inspect(token)}")
    end
  end

  defp observed_chain_id!(row, tokens) do
    payload =
      Enum.join(
        [
          row["lane"],
          row["app"],
          row["module"],
          row["function"],
          to_string(row["arity"]),
          row["chain_id"] | tokens
        ],
        "\n"
      )

    sha256(payload)
  end

  defp references_for_tokens(tokens, owner) do
    tokens
    |> Enum.map(fn token ->
      case Regex.run(~r/^(.+)\.([^\.\/]+)\/([0-9]+)$/, token) do
        [_, module, function, arity] ->
          owner_for_step!("#{module}.#{function}/#{arity}")

        _ ->
          ownership_fail!("unresolved current caller path #{inspect(token)} for owner=#{owner}")
      end
    end)
    |> Enum.uniq()
    |> Enum.reject(&(&1 == owner))
    |> Enum.sort()
  end

  defp unique_identity_set!(identities, label) do
    result = MapSet.new(identities)

    require_ownership!(
      length(identities) == MapSet.size(result),
      "effective delegation has duplicate #{label} identities"
    )

    result
  end

  defp assert_namespace_history_pair!(sets, kind, lane) do
    original = Map.fetch!(sets, "original")
    observed = Map.fetch!(sets, "observed")

    identity = fn row ->
      case kind do
        :module -> {row["app"], row["module"]}
        :root -> {row["app"], row["module"], row["function"], row["arity"]}
      end
    end

    original_by_id = Map.new(original.rows, &{identity.(&1), &1})

    Enum.each(observed.rows, fn row ->
      prior = Map.get(original_by_id, identity.(row))
      historical = row["historical"] || %{}

      require_ownership!(
        prior != nil and historical["owner"] == prior["origin_owner"] and
          historical["record_sha256"] == prior["record_sha256"] and
          (kind != :root or
             (historical["chain_id"] == prior["chain_id"] and
                historical["steps"] == prior["origin_steps"])),
        "lane #{lane} namespace=observed identity=#{inspect(identity.(row))} owner=#{row["owner"]} canonical_chain_id=#{inspect(get_in(row, ["historical", "chain_id"]))} caller-chain=immutable historical receipt remedy=restore the linked original record and chain"
      )
    end)
  end

  defp observe_new_roots!(identities, receipt, module_sets, lane) do
    module_owners =
      Map.fetch!(module_sets, "original").owners

    identities
    |> Enum.sort()
    |> Enum.map(fn {app, module, function, arity} = identity ->
      row = Map.fetch!(receipt.pending_by_identity, identity)

      module_owner =
        Map.get(
          module_owners,
          {app, module},
          if(app == "debugger" and module in @debugger_seed_modules, do: @remainder_owner)
        )

      require_ownership!(
        app == "debugger" and module_owner in @delegation_children,
        "lane #{lane} MFA #{module}:#{function}/#{arity} owner=unassigned caller-chain=#{inspect(row["caller_chain"])} remedy=assign the new graph root to an explicit debugger child before accepting it"
      )

      tokens = row["caller_chain"] || []

      references =
        tokens
        |> Enum.flat_map(fn token ->
          case Regex.run(~r/^(.+)\.([^\.\/]+)\/([0-9]+)$/, token) do
            [_, token_module, token_function, token_arity] ->
              [owner_for_step!("#{token_module}.#{token_function}/#{token_arity}")]

            _ ->
              []
          end
        end)
        |> Enum.uniq()
        |> Enum.reject(&(&1 == module_owner))
        |> Enum.sort()

      %{
        "namespace" => "observed",
        "identity" => %{
          "kind" => "root",
          "lane" => lane,
          "app" => app,
          "module" => module,
          "function" => function,
          "arity" => arity
        },
        "origin_record_sha256" => nil,
        "origin_owner" =>
          if(module_owner == @remainder_owner and not Map.has_key?(module_owners, {app, module}),
            do: "existing-active-baseline",
            else: @historical_owner
          ),
        "owner" => module_owner,
        "canonical_chain_id" => nil,
        "observed_chain_id" =>
          sha256(Enum.join([lane, app, module, function, to_string(arity) | tokens], "\n")),
        "references" => references,
        "origin_occurrences" => [],
        "completion" => "pending",
        "evidence" => %{
          "receipt_sha256" => receipt.sha256,
          "caller_chain" => tokens,
          "new_pending_graph_identity" => true
        }
      }
    end)
  end

  defp read_regular_file!(path, label) do
    case File.lstat(path) do
      {:ok, %File.Stat{type: :regular}} ->
        File.read!(path)

      {:ok, %File.Stat{type: type}} ->
        ownership_fail!("#{label} must be a regular file, got #{inspect(type)} at #{path}")

      {:error, reason} ->
        ownership_fail!("#{label} is unavailable at #{path}: #{inspect(reason)}")
    end
  end

  defp require_ownership!(condition, message) do
    unless condition, do: ownership_fail!(message)
    :ok
  end

  defp ownership_fail!(message), do: raise(ExUnit.AssertionError, message: message)
  defp valid_sha256?(value), do: is_binary(value) and Regex.match?(~r/^[a-f0-9]{64}$/, value)
  defp sha256(bytes), do: :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
  defp format_root_text(row), do: "#{row["module"]}:#{row["function"]}/#{row["arity"]}"

  def assert_audit!(record, graph, tier, evidence, exclusions) do
    lane = evidence.lane.name
    lane_row = Map.get(@lane_data, lane)

    assert is_map(record),
           "lane #{lane} owner=#{@owner} caller-chain=dbg_wx_settings:load/3 remedy=restore the complete audit record"

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

    graph_settings_exports =
      graph.full_exported
      |> Enum.filter(&(elem(&1, 0) == @settings_module))
      |> MapSet.new()

    assert graph_settings_exports == MapSet.new(@settings_exports),
           "lane #{lane} MFA dbg_wx_settings:load/3 owner=#{@owner} caller-chain=independent installed graph exports remedy=resolve any new or missing export against the exact settings BEAM"

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
    assert_source_branch_ledger!(lane)

    expected_branch_ids = MapSet.new(branch_ids())
    actual_branch_ids = record |> Map.get(:branch_citations, %{}) |> Map.keys() |> MapSet.new()

    source_branch_ids =
      record |> Map.get(:source_branches, []) |> Enum.map(& &1.id) |> MapSet.new()

    assert actual_branch_ids == expected_branch_ids and source_branch_ids == expected_branch_ids,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{@owner} caller-chain=complete settings and replay branch map missing=#{inspect(MapSet.to_list(MapSet.difference(expected_branch_ids, actual_branch_ids)))} remedy=restore every exact default/error/cancel/replay branch"

    expected_owners =
      Map.new(@all_branch_specs, fn {id, mfa, _predicate, source, _lines} ->
        {id, branch_owner(source, mfa)}
      end)

    actual_owners = Map.new(record.source_branches, &{&1.id, &1.owner})

    assert actual_owners == expected_owners,
           "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{@owner} caller-chain=source branch ownership remedy=retain break_p as an adopted source-branch obligation and shared modules with their remainder owner"

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
    Enum.map(@all_branch_specs, &elem(&1, 0))
  end

  def exclusion_matches(universe, exclusions) do
    universe = Enum.to_list(universe)

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
            matched_mfas: Enum.sort(matches),
            universe: Enum.sort(universe)
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

      matcher = elem(match.original_identity, 0)

      citations =
        if tuple_size(match.original_identity) > 2, do: elem(match.original_identity, 2), else: []

      assert match.cited_triple == {matcher, elem(match.original_identity, 1), citations},
             "changed exclusion #{inspect(match.original_identity)} lost its original cited identity"

      assert exact_mfa_matcher?(matcher) and length(match.matched_mfas) == 1,
             "changed exclusion #{inspect(match.original_identity)} is blanket or non-exact for the assigned family"

      assert citations != [],
             "changed exclusion #{inspect(match.original_identity)} has no exact source disposition"

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
    Enum.map(@all_branch_specs, fn {id, mfa, predicate, source, _lines} ->
      %{
        id: id,
        mfa: mfa,
        owner: branch_owner(source, mfa),
        predicate: predicate,
        trace: branch_trace(mfa)
      }
    end)
  end

  defp branch_citations(lane_name) do
    Enum.into(@all_branch_specs, %{}, fn {id, _mfa, _predicate, source, lines} ->
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

  defp citation(lane_name, :iserver, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/dbg_iserver.erl",
      line: line,
      sha256: lane.iserver_sha256,
      expected_text: expected_text
    }
  end

  defp citation(lane_name, :int, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/int.erl",
      line: line,
      sha256: lane.int_sha256,
      expected_text: expected_text
    }
  end

  defp citation(lane_name, :icmd, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/dbg_icmd.erl",
      line: line,
      sha256: lane.icmd_sha256,
      expected_text: expected_text
    }
  end

  defp branch_owner(:settings, _mfa), do: @owner

  defp branch_owner(:monitor, {:dbg_wx_mon, function, _arity})
       when function in [:init, :init2, :gui_cmd],
       do: "01.1.1.3.1.2"

  defp branch_owner(:monitor, _mfa), do: @owner
  defp branch_owner(:icmd, {:dbg_icmd, :break_p, 4}), do: @owner
  defp branch_owner(_source, _mfa), do: "01.1.1.3.1.2"

  defp branch_trace({:dbg_wx_settings, :load, 3}), do: "dbg_wx_settings:load/3 -> open_win/5"
  defp branch_trace({:dbg_wx_settings, :save, 3}), do: "dbg_wx_settings:save/3 -> open_win/5"

  defp branch_trace({:dbg_wx_settings, :open_win, 5}),
    do: "dbg_wx_settings:load|save/3 -> open_win/5"

  defp branch_trace({:dbg_wx_settings, :default_settings_dir, 1}),
    do: "load|save/3 -> open_win/5 -> default_settings_dir/1"

  defp branch_trace({:dbg_wx_mon, :start, 2}),
    do: "debugger:start/2 -> dbg_wx_mon:start/2 -> init/3"

  defp branch_trace({:dbg_wx_mon, :init, 3}), do: "dbg_wx_mon:start/2 -> init/3 -> init2/4"
  defp branch_trace({:dbg_wx_mon, :init2, 4}), do: "dbg_wx_mon:start/2 -> init/3 -> init2/4"

  defp branch_trace({:dbg_wx_mon, :gui_cmd, 2}),
    do: "dbg_wx_mon:gui_cmd/2 -> settings dialog -> load_settings/2"

  defp branch_trace({:dbg_wx_mon, :load_settings, 2}),
    do: "dbg_wx_mon:load_settings/2 -> file:read_file/1 -> binary_to_term/1"

  defp branch_trace({:dbg_wx_mon, :load_settings2, 2}),
    do: "dbg_wx_mon:load_settings/2 -> load_settings2/2 -> replay options"

  defp branch_trace({:dbg_wx_mon, :loaded, 1}), do: "dbg_wx_mon:load_settings2/2 -> loaded/1"

  defp branch_trace({:int, :auto_attach, 2}),
    do:
      "caller settings -> int:auto_attach/2 -> dbg_iserver:set_auto_attach -> deferred event gate"

  defp branch_trace({:int, :auto_attach, 3}),
    do: "caller settings -> validated flags/function -> dbg_iserver safe_cast"

  defp branch_trace({:int, :check_flags, 1}),
    do: "int:auto_attach/2 -> check_flags/1 -> allowed init|break|exit flags"

  defp branch_trace({:dbg_iserver, :handle_call, 3}),
    do: "dbg_iserver new_process -> auto_attach(init) -> running|break result"

  defp branch_trace({:dbg_iserver, :handle_cast, 2}),
    do:
      "int setting -> dbg_iserver set_auto_attach|break_option -> subscriber broadcast and state update"

  defp branch_trace({:dbg_iserver, :handle_info, 2}),
    do: "dbg_iserver exit notification -> auto_attach(exit) -> optional callback spawn"

  defp branch_trace({:dbg_iserver, :auto_attach, 3}),
    do: "init|break|exit event -> stored flags -> matching callback spawn or ignore"

  defp branch_trace({:int, :test_at_break, 3}),
    do: "int:test_at_break/3 -> dbg_iserver condition option store -> interpreter callback"

  defp branch_trace({:dbg_icmd, :handle_int_msg, 4}),
    do: "dbg_iserver break_options broadcast -> process-dictionary breakpoint update"

  defp branch_trace({:dbg_icmd, :cmd, 4}),
    do: "dbg_icmd:cmd/4 -> private break_p/4 -> break or continue"

  defp branch_trace({:dbg_icmd, :break_p, 4}),
    do: "dbg_icmd:cmd/4 -> adopted break_p/4 source obligation -> CM:CN(Bs)"

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
    resolved =
      Fablebook.Test.SweepEvidence.resolve!(evidence, "#{citation.path}:#{citation.line}")

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
        {"#{entry["module"]}:#{entry["function"]}/#{entry["arity"]}", entry["chain_id"],
         entry["owner"], entry["completion"]}
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

  defp assert_source_branch_ledger!(lane) do
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

    rows =
      Enum.filter(entries, fn entry ->
        entry["t"] == "source_branch" and entry["lane"] == lane and
          entry["module"] == "dbg_icmd" and entry["function"] == "break_p" and
          entry["arity"] == 4
      end)

    lane_row = Map.fetch!(@lane_data, lane)
    {first, last} = if lane == "core", do: {88, 126}, else: {86, 124}

    assert length(rows) == 1,
           "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{@owner} caller-chain=effective source-branch ledger remedy=retain one adopted callback source branch"

    [row] = rows

    assert row["owner"] == @owner and row["completion"] == "pending" and
             row["state"] == "source-discovered-unresolved-callback-branch" and
             row["caller"] == "dbg_icmd.cmd/4" and
             row["sensitive_expression"] == "try CM:CN(Bs) of" and
             row["source_path"] == "debugger/src/dbg_icmd.erl" and
             row["source_sha256"] == lane_row.icmd_sha256 and
             row["source_lines"] == [first, last] and
             row["canonical_receipt_root_present"] == false and
             row["shared_broad_roots_remain_with"] == "01.1.1.3.1.2",
           "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{@owner} caller-chain=effective source-branch ledger remedy=retain the adopted source obligation without promoting it to a canonical root"
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

  defp exact_mfa_matcher?({:mfa, {module, function, arity}}),
    do: is_atom(module) and is_atom(function) and is_integer(arity)

  defp exact_mfa_matcher?(_matcher), do: false

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
    |> Enum.reject(fn mfa ->
      covered?(mfa, tier, names) or Enum.any?(exclusions, &matches_exclusion?(mfa, &1))
    end)
  end

  defp walk_callers(reverse, roots) do
    Enum.reduce(roots, MapSet.new(), fn root, visited ->
      queue = :queue.in(root, :queue.new())
      walk_callers(queue, reverse, visited)
    end)
  end

  defp walk_callers(queue, reverse, visited) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        visited

      {{:value, mfa}, rest} when is_map_key(reverse, mfa) ->
        if MapSet.member?(visited, mfa) do
          walk_callers(rest, reverse, visited)
        else
          callers = Map.get(reverse, mfa, MapSet.new())
          callers = if is_struct(callers, MapSet), do: MapSet.to_list(callers), else: callers

          walk_callers(
            Enum.reduce(callers, rest, &:queue.in/2),
            reverse,
            MapSet.put(visited, mfa)
          )
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
