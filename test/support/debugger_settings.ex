defmodule Fablebook.Test.DebuggerSettings do
  @moduledoc false

  import ExUnit.Assertions

  alias Fablebook.Credo.BannedCalls
  alias Fablebook.Test.{BeamWalker, InstalledOtp, SweepEvidence}

  @compile {:no_warn_undefined, Fablebook.Credo.BannedCalls}

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
  @auto_attach_route_branch_ids [
    :auto_attach_empty_flags,
    :auto_attach_two_tuple,
    :auto_attach_valid_tuple,
    :auto_attach_safe_cast,
    :auto_attach_false_store,
    :auto_attach_false_broadcast,
    :auto_attach_tuple_store,
    :auto_attach_init_event,
    :auto_attach_init_result_break,
    :auto_attach_init_result_running,
    :auto_attach_break_event,
    :auto_attach_exit_event,
    :auto_attach_process_unattached,
    :auto_attach_already_attached_ignore,
    :auto_attach_false_ignore,
    :auto_attach_event_membership,
    :auto_attach_event_match_spawn,
    :auto_attach_event_nonmatch_ignore
  ]
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
      auto_attach_trace: %{
        input_origin: :caller_supplied_auto_attach_flags_and_function_tuple,
        accepted_forms: [
          :empty_flags_disable,
          {:flags, {:module, :function}, :implicit_empty_args},
          {:flags, {:module, :function, :args}, :validated_args}
        ],
        stored_value: {:flags, {:module, :function, :args}},
        event_gate: %{mfa: {:dbg_iserver, :auto_attach, 3}, events: [:init, :break, :exit]},
        gate_predicate: :lists_member_event_in_flags,
        dispatch: %{
          mfa: {:dbg_iserver, :auto_attach, 3},
          expression: "spawn(Mod, Func, [Pid | Args])",
          target: :unresolved_dynamic_module_function
        },
        ignored_branches: [:false_setting, :already_attached_process, :event_not_in_flags],
        owner: @remainder_owner,
        citation_ids: @auto_attach_route_branch_ids
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

  def assert_auto_attach_trace!(record, graph, tier, evidence) do
    lane = evidence.lane.name
    trace = Map.get(record, :auto_attach_trace)

    assert is_map(trace),
           "lane #{lane} owner=#{@remainder_owner} MFA int:auto_attach/2 caller-chain=setter -> stored state -> event gate -> spawn remedy=restore the complete auto-attach trace"

    required_trace_fields = [
      :input_origin,
      :accepted_forms,
      :stored_value,
      :event_gate,
      :gate_predicate,
      :dispatch,
      :ignored_branches,
      :owner,
      :citation_ids
    ]

    missing_trace_fields = Enum.reject(required_trace_fields, &Map.has_key?(trace, &1))

    assert missing_trace_fields == [],
           "lane #{lane} owner=#{@remainder_owner} MFA int:auto_attach/2 caller-chain=setter -> stored state -> event gate -> spawn missing=#{inspect(missing_trace_fields)} remedy=restore stored tuple, gate, dispatch, ignored branches and owner"

    expected_trace = %{
      input_origin: :caller_supplied_auto_attach_flags_and_function_tuple,
      accepted_forms: [
        :empty_flags_disable,
        {:flags, {:module, :function}, :implicit_empty_args},
        {:flags, {:module, :function, :args}, :validated_args}
      ],
      stored_value: {:flags, {:module, :function, :args}},
      event_gate: %{mfa: {:dbg_iserver, :auto_attach, 3}, events: [:init, :break, :exit]},
      gate_predicate: :lists_member_event_in_flags,
      dispatch: %{
        mfa: {:dbg_iserver, :auto_attach, 3},
        expression: "spawn(Mod, Func, [Pid | Args])",
        target: :unresolved_dynamic_module_function
      },
      ignored_branches: [:false_setting, :already_attached_process, :event_not_in_flags],
      owner: @remainder_owner,
      citation_ids: @auto_attach_route_branch_ids
    }

    Enum.each(expected_trace, fn {field, expected} ->
      assert Map.get(trace, field) == expected,
             "lane #{lane} owner=#{@remainder_owner} MFA int:auto_attach/2 caller-chain=setter -> stored state -> event gate -> spawn field=#{field} actual=#{inspect(Map.get(trace, field))} remedy=restore source-backed route evidence"
    end)

    assert graph.lane.name == lane,
           "lane #{lane} owner=#{@remainder_owner} MFA int:auto_attach/2 caller-chain=installed graph remedy=use the matching exact lane"

    assert {:int, :auto_attach, 2} in tier,
           "lane #{lane} owner=#{@remainder_owner} MFA int:auto_attach/2 caller-chain=static guard tier remedy=retain the exact setter entry"

    owners = pending_owners()

    Enum.each(["int", "dbg_iserver"], fn module ->
      assert Map.get(owners, module) == @remainder_owner,
             "lane #{lane} module=#{module} owner=#{inspect(Map.get(owners, module))} caller-chain=adopted pending owner ledger remedy=restore current remainder ownership"
    end)

    assert trace.owner == Map.fetch!(owners, "int") and
             trace.owner == Map.fetch!(owners, "dbg_iserver"),
           "lane #{lane} owner=#{trace.owner} MFA int:auto_attach/2 caller-chain=adopted pending owner ledger remedy=bind the route to both current owners"

    source_branches = Map.get(record, :source_branches, [])
    source_branch_map = Map.new(source_branches, &{&1.id, &1})
    actual_branch_ids = MapSet.new(Map.keys(source_branch_map))
    required_branch_ids = MapSet.new(@auto_attach_route_branch_ids)
    missing_branch_ids = MapSet.difference(required_branch_ids, actual_branch_ids)

    assert MapSet.size(missing_branch_ids) == 0,
           "lane #{lane} owner=#{@remainder_owner} MFA int:auto_attach/2 caller-chain=setter -> server state -> event gate -> spawn missing source branches=#{inspect(MapSet.to_list(missing_branch_ids))} remedy=restore each route branch"

    branch_citations = Map.get(record, :branch_citations, %{})

    Enum.each(@auto_attach_route_branch_ids, fn branch_id ->
      branch = Map.fetch!(source_branch_map, branch_id)
      source_module = elem(branch.mfa, 0)
      citations = Map.get(branch_citations, branch_id, [])

      assert branch.owner == @remainder_owner and
               source_module in [:int, :dbg_iserver],
             "lane #{lane} MFA #{format_mfa(branch.mfa)} owner=#{branch.owner} caller-chain=#{branch.trace} remedy=retain the adopted remainder owner for setter, storage, gate and dispatch"

      assert citations != [],
             "lane #{lane} MFA #{format_mfa(branch.mfa)} owner=#{@remainder_owner} caller-chain=#{branch.trace} remedy=restore its exact source citation"

      Enum.each(citations, &assert_citation!(evidence, lane, record, &1))
    end)

    assert MapSet.member?(graph.full_exported, {:int, :auto_attach, 2}),
           "lane #{lane} owner=#{@remainder_owner} MFA int:auto_attach/2 caller-chain=installed full graph remedy=retain the setter in the exact-lane exported universe"

    for {module, required_mfas} <- [
          {:int, [{:int, :auto_attach, 2}]},
          {:dbg_iserver,
           [
             {:dbg_iserver, :handle_cast, 2},
             {:dbg_iserver, :handle_call, 3},
             {:dbg_iserver, :auto_attach, 3}
           ]}
        ] do
      inspection = Enum.find(graph.inspected, &(&1.module_atom == module))

      assert inspection != nil,
             "lane #{lane} owner=#{@remainder_owner} module=#{module} caller-chain=installed debugger BEAM remedy=retain source and BEAM evidence for the assigned module"

      assert {:ok, scan} = BeamWalker.scan(inspection.path),
             "lane #{lane} owner=#{@remainder_owner} module=#{module} caller-chain=debug-info BEAM scan remedy=restore exact-lane function evidence"

      actual_functions = MapSet.new(scan.function_mfas)
      missing_functions = Enum.reject(required_mfas, &MapSet.member?(actual_functions, &1))

      assert missing_functions == [],
             "lane #{lane} owner=#{@remainder_owner} module=#{module} missing BEAM functions=#{inspect(missing_functions)} caller-chain=setter -> stored state -> event gate -> spawn remedy=restore exact installed functions"
    end

    :ok
  end

  def assert_receipt!(graph, evidence, records, receipt_lines) when is_list(receipt_lines) do
    lane = graph.lane.name

    require_ownership!(
      evidence.lane.name == lane,
      "lane #{lane} owner=#{@owner} source evidence lane=#{evidence.lane.name} caller-chain=receipt validator remedy=use matching lane source evidence"
    )

    current_receipt = InstalledOtp.verify_receipt_lines!(graph.receipt_lines)
    supplied_receipt = InstalledOtp.verify_receipt_lines!(receipt_lines)

    require_ownership!(
      supplied_receipt.lane == lane and supplied_receipt.sha256 == current_receipt.sha256,
      "lane #{lane} owner=#{@owner} supplied receipt differs from the current installed graph; caller-chain=graph receipt_lines remedy=use the complete current-lane receipt"
    )

    ownership =
      assert_ownership!(Map.put(graph, :receipt_lines, receipt_lines), evidence, records)

    require_ownership!(
      ownership.status == :verified and ownership.receipt_sha256 == supplied_receipt.sha256 and
        ownership.selected_module == @settings_module and
        ownership.remainder_module_count > 0,
      "lane #{lane} owner=#{@owner} current selected/remainder evidence does not match the validated receipt; caller-chain=assert_ownership!/3 remedy=restore selected settings evidence and the complete pending remainder"
    )

    ownership
  end

  def assert_receipt!(_graph, _evidence, _records, _receipt_lines) do
    ownership_fail!("current installed receipt must be a complete list of tagged lines")
  end

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
      not Enum.any?(records, &(&1["t"] == "delegation")),
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

  def required_source_modules do
    %{metadata: metadata, records: records} = load_delegation!()
    validate_delegation_rows!(records, metadata)

    core_sources = remainder_source_rows!(records, "core")
    floor_sources = remainder_source_rows!(records, "floor")

    require_ownership!(
      MapSet.new(core_sources, & &1["module"]) == MapSet.new(floor_sources, & &1["module"]),
      "lane core/floor app debugger owner=#{@remainder_owner} caller-chain=adopted exact_source assignments differ by lane remedy=preserve the same current module assignment universe"
    )

    Enum.map(core_sources, & &1["module"])
  end

  def assert_remainder_source!(evidence, source_row, citation) do
    lane = evidence.lane.name
    module = Map.get(source_row, "module")
    relative = Map.get(source_row, "source_path")

    require_ownership!(
      Map.get(source_row, "t") == "exact_source" and
        Map.get(source_row, "lane") == lane and Map.get(source_row, "app") == "debugger" and
        Map.get(source_row, "owner") == @remainder_owner and
        Map.get(source_row, "origin_owner") == @historical_owner and
        is_binary(module) and is_integer(Map.get(source_row, "bytes")) and
        source_row["bytes"] > 0 and valid_sha256?(Map.get(source_row, "sha256")),
      "lane #{lane} app debugger module #{inspect(module)} owner=#{@remainder_owner} caller-chain=adopted exact_source row remedy=restore exact lane/app/path/bytes/hash provenance"
    )

    expected_path = "debugger/src/#{module}.erl"

    require_ownership!(
      relative == expected_path and safe_relative_source_path?(relative),
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{inspect(relative)} caller-chain=installed source path remedy=use its contained debugger/src module path"
    )

    valid_citation? =
      citation == :module or
        (is_map(citation) and is_integer(Map.get(citation, :line)) and citation.line > 0 and
           is_binary(Map.get(citation, :expected_text)) and citation.expected_text != "")

    require_ownership!(
      valid_citation?,
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=source citation remedy=provide a positive line and expected text"
    )

    debugger_root = Map.get(evidence.installed, "debugger")

    require_ownership!(
      is_binary(debugger_root) and debugger_root != "",
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=SweepEvidence installed debugger root remedy=use the current exact lane root"
    )

    installed_path = Path.join(debugger_root, String.replace_prefix(relative, "debugger/", ""))

    case File.lstat(installed_path) do
      {:ok, %{type: :regular}} ->
        :ok

      {:ok, stat} ->
        ownership_fail!(
          "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{relative} caller-chain=installed source type=#{stat.type} remedy=require a regular installed source file"
        )

      {:error, reason} ->
        ownership_fail!(
          "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{relative} caller-chain=installed source read=#{reason} remedy=restore the current lane source"
        )
    end

    canonical_root = realpath!(debugger_root, lane, "debugger source root")
    canonical_path = realpath!(installed_path, lane, relative)

    require_ownership!(
      String.starts_with?(canonical_path, canonical_root <> "/"),
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{relative} caller-chain=installed realpath containment remedy=keep the resolved source below the installed debugger root"
    )

    bytes = File.read!(canonical_path)

    require_ownership!(
      byte_size(bytes) == source_row["bytes"] and sha256(bytes) == source_row["sha256"],
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{relative} caller-chain=installed exact_source digest remedy=restore the adopted byte count and SHA-256"
    )

    lines = String.split(bytes, "\n", trim: false)
    citation = resolve_citation!(citation, module, lines, lane, relative)

    require_ownership!(
      citation.line <= length(lines),
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{relative}:#{citation.line} caller-chain=installed source citation remedy=use an existing line"
    )

    text = Enum.at(lines, citation.line - 1)

    require_ownership!(
      String.contains?(text, citation.expected_text),
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{relative}:#{citation.line} caller-chain=installed source citation remedy=restore expected source text"
    )

    %{
      path: canonical_path,
      line: citation.line,
      text: text,
      bytes: byte_size(bytes),
      sha256: source_row["sha256"],
      origin: :installed
    }
  end

  def assert_remainder_inventory!(graph, evidence, records) do
    lane = evidence.lane.name
    loaded = load_delegation!()
    delegation_records = Map.get(records, :delegation_records, loaded.records)

    validate_delegation_rows!(
      delegation_records,
      Map.get(records, :delegation_metadata, loaded.metadata)
    )

    source_rows = remainder_source_rows!(delegation_records, lane)

    require_ownership!(
      graph.lane.name == lane,
      "lane #{lane} app debugger owner=#{@remainder_owner} caller-chain=installed graph remedy=use matching exact lane evidence"
    )

    ownership = assert_ownership!(graph, evidence, records)

    module_rows =
      Enum.filter(
        delegation_records,
        &(&1["t"] == "module" and &1["lane"] == lane and &1["app"] == "debugger" and
            &1["owner"] == @remainder_owner)
      )

    module_names = module_rows |> Enum.map(& &1["module"]) |> MapSet.new()

    inspections =
      graph.inspected
      |> Enum.filter(&(&1.app == "debugger" and &1.module in MapSet.to_list(module_names)))
      |> Map.new(&{&1.module, &1})

    inspection_names = MapSet.new(Map.keys(inspections))

    missing_inspections =
      module_names |> MapSet.difference(inspection_names) |> MapSet.to_list() |> Enum.sort()

    extra_inspections =
      inspection_names |> MapSet.difference(module_names) |> MapSet.to_list() |> Enum.sort()

    require_ownership!(
      inspection_names == module_names,
      "lane #{lane} app debugger owner=#{@remainder_owner} caller-chain=installed BEAM module set missing=#{inspect(missing_inspections)} extra=#{inspect(extra_inspections)} remedy=restore every adopted module inspection"
    )

    debugger_root = Map.fetch!(evidence.installed, "debugger")

    independent_exports =
      InstalledOtp.export_inventory!([Path.join(debugger_root, "ebin")],
        lane: lane,
        edges: graph.full_edges
      )
      |> MapSet.new()

    full_graph_edges = MapSet.new(graph.full_edges)

    module_inventory =
      module_names
      |> Enum.sort()
      |> Enum.map(fn module ->
        inspection = Map.fetch!(inspections, module)
        source_row = Enum.find(source_rows, &(&1["module"] == module))
        module_atom = inspection.module_atom

        case BeamWalker.scan(inspection.path) do
          {:ok, scan} ->
            require_ownership!(
              scan.module == module_atom,
              "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=independent BEAM scan actual=#{inspect(scan.module)} remedy=use the exact inspected module"
            )

            beam_functions = MapSet.new(scan.function_mfas)
            inspected_functions = MapSet.new(inspection.function_mfas)

            missing_inspected_functions =
              beam_functions
              |> MapSet.difference(inspected_functions)
              |> MapSet.to_list()
              |> Enum.sort()

            extra_inspected_functions =
              inspected_functions
              |> MapSet.difference(beam_functions)
              |> MapSet.to_list()
              |> Enum.sort()

            require_ownership!(
              beam_functions == inspected_functions and
                length(scan.function_mfas) == MapSet.size(beam_functions),
              "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=independent BEAM function universe missing=#{inspect(missing_inspected_functions)} extra=#{inspect(extra_inspected_functions)} remedy=restore every private and zero-hit function"
            )

            beam_edges = MapSet.new(scan.edges)
            missing_edges = MapSet.difference(beam_edges, full_graph_edges)

            require_ownership!(
              MapSet.size(missing_edges) == 0,
              "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=independent BEAM call edges missing=#{inspect(Enum.take(Enum.sort(MapSet.to_list(missing_edges)), 12))} remedy=restore full graph edges"
            )

            graph_exports =
              graph.full_exported
              |> Enum.filter(&(elem(&1, 0) == module_atom))
              |> MapSet.new()

            expected_exports =
              independent_exports
              |> Enum.filter(&(elem(&1, 0) == module_atom))
              |> MapSet.new()

            missing_graph_exports =
              expected_exports
              |> MapSet.difference(graph_exports)
              |> MapSet.to_list()
              |> Enum.sort()

            extra_graph_exports =
              graph_exports
              |> MapSet.difference(expected_exports)
              |> MapSet.to_list()
              |> Enum.sort()

            require_ownership!(
              graph_exports == expected_exports,
              "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=independent BEAM export universe missing=#{inspect(missing_graph_exports)} extra=#{inspect(extra_graph_exports)} remedy=restore every current graph export"
            )

            graph_candidates =
              graph.full_edges
              |> Enum.map(&elem(&1, 0))
              |> Kernel.++(MapSet.to_list(graph.full_reached))
              |> Kernel.++(MapSet.to_list(graph.full_exported))
              |> Enum.filter(&(elem(&1, 0) == module_atom))
              |> Enum.reject(fn {_mod, function, _arity} ->
                function in [:module_info, :behaviour_info]
              end)
              |> MapSet.new()

            omitted_graph_functions = MapSet.difference(graph_candidates, beam_functions)

            require_ownership!(
              MapSet.size(omitted_graph_functions) == 0,
              "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=full graph function refs missing from installed BEAM=#{inspect(Enum.sort(MapSet.to_list(omitted_graph_functions)))} remedy=restore exact-lane graph and BEAM parity"
            )

            resolved_source = assert_remainder_source!(evidence, source_row, :module)
            function_names = Enum.sort(Enum.map(beam_functions, &format_mfa/1))
            export_names = Enum.sort(Enum.map(expected_exports, &format_mfa/1))
            graph_functions = Enum.sort(Enum.map(graph_candidates, &format_mfa/1))
            zero_hit = MapSet.difference(beam_functions, graph_candidates)
            private_functions = MapSet.difference(beam_functions, expected_exports)

            %{
              module: module,
              owner: @remainder_owner,
              source_assignment: source_row,
              source: resolved_source,
              functions: function_names,
              function_count: MapSet.size(beam_functions),
              function_sha256: stable_set_sha256(function_names),
              exports: export_names,
              export_count: MapSet.size(expected_exports),
              export_sha256: stable_set_sha256(export_names),
              graph_functions: graph_functions,
              graph_function_sha256: stable_set_sha256(graph_functions),
              zero_hit_functions: Enum.sort(Enum.map(zero_hit, &format_mfa/1)),
              private_functions: Enum.sort(Enum.map(private_functions, &format_mfa/1)),
              edges: scan.edges,
              edge_count: MapSet.size(beam_edges),
              edge_sha256: stable_set_sha256(Enum.map(beam_edges, &format_edge/1))
            }

          {:error, reason} ->
            ownership_fail!(
              "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=independent installed BEAM scan error=#{inspect(reason)} remedy=restore debug info for the exact installed BEAM"
            )
        end
      end)

    all_root_rows =
      Enum.filter(
        delegation_records,
        &(&1["lane"] == lane and &1["app"] == "debugger" and
            &1["t"] in ["root", "observed_root"])
      )

    original_roots = Enum.filter(all_root_rows, &(&1["t"] == "root"))
    observed_roots = Enum.filter(all_root_rows, &(&1["t"] == "observed_root"))

    interpreter_root_observations =
      Enum.filter(ownership.observations, fn observation ->
        get_in(observation, ["identity", "module"]) == "dbg_wx_interpret" and
          get_in(observation, ["evidence", "new_pending_graph_identity"]) == true
      end)

    require_ownership!(
      interpreter_root_observations != [] and
        Enum.all?(interpreter_root_observations, &(&1["owner"] == @remainder_owner)),
      "lane #{lane} app debugger module dbg_wx_interpret owner=#{@remainder_owner} caller-chain=observed root namespace remedy=retain the existing interpreter roots while its module remains active"
    )

    overlap_rows =
      Enum.filter(
        delegation_records,
        &(&1["lane"] == lane and &1["t"] in ["overlap", "observed_overlap"])
      )

    source_branches =
      Enum.filter(
        delegation_records,
        &(&1["lane"] == lane and &1["t"] == "source_branch" and
            &1["module"] == "dbg_icmd" and &1["function"] == "break_p" and
            &1["arity"] == 4)
      )

    require_ownership!(
      length(source_branches) == 1 and hd(source_branches)["owner"] == @owner and
        hd(source_branches)["completion"] == "pending",
      "lane #{lane} app debugger MFA dbg_icmd:break_p/4 owner=#{@owner} caller-chain=adopted source branch remedy=preserve the pending cross-owner source obligation"
    )

    assigned_graph_modules =
      MapSet.union(
        module_names,
        MapSet.new(all_root_rows, & &1["module"])
      )

    assigned_edges =
      graph.full_edges
      |> Enum.filter(fn {caller, callee} ->
        MapSet.member?(assigned_graph_modules, Atom.to_string(elem(caller, 0))) or
          MapSet.member?(assigned_graph_modules, Atom.to_string(elem(callee, 0)))
      end)
      |> Enum.map(&format_edge/1)
      |> Enum.sort()

    assigned_reached =
      graph.full_reached
      |> Enum.filter(&MapSet.member?(assigned_graph_modules, Atom.to_string(elem(&1, 0))))
      |> Enum.map(&format_mfa/1)
      |> Enum.sort()

    assigned_exports =
      graph.full_exported
      |> Enum.filter(&MapSet.member?(assigned_graph_modules, Atom.to_string(elem(&1, 0))))
      |> Enum.map(&format_mfa/1)
      |> Enum.sort()

    full_edge_names = Enum.map(graph.full_edges, &format_edge/1) |> Enum.sort()
    full_reached_names = Enum.map(graph.full_reached, &format_mfa/1) |> Enum.sort()
    full_export_names = Enum.map(graph.full_exported, &format_mfa/1) |> Enum.sort()

    %{
      status: :verified,
      lane: lane,
      owner: @remainder_owner,
      modules: module_inventory,
      module_names: Enum.sort(MapSet.to_list(module_names)),
      original_roots: original_roots,
      observed_roots: observed_roots,
      interpreter_root_observations: interpreter_root_observations,
      ownership_observations: ownership.observations,
      changed_routes:
        Enum.filter(ownership.observations, &get_in(&1, ["evidence", "route_changed"])),
      new_owned_observations:
        Enum.filter(
          ownership.observations,
          &get_in(&1, ["evidence", "new_pending_graph_identity"])
        ),
      overlaps: overlap_rows,
      overlap_occurrence_count:
        Enum.sum(Enum.map(overlap_rows, &length(&1["occurrences"] || []))),
      selected_roots: ownership.selected_roots,
      source_branches: source_branches,
      graph: %{
        full_edge_count: length(graph.full_edges),
        full_edges_sha256: stable_set_sha256(full_edge_names),
        full_reached_count: length(full_reached_names),
        full_reached_sha256: stable_set_sha256(full_reached_names),
        full_export_count: length(full_export_names),
        full_exports_sha256: stable_set_sha256(full_export_names),
        assigned_edge_count: length(assigned_edges),
        assigned_edges_sha256: stable_set_sha256(assigned_edges),
        assigned_reached_count: length(assigned_reached),
        assigned_reached_sha256: stable_set_sha256(assigned_reached),
        assigned_export_count: length(assigned_exports),
        assigned_exports_sha256: stable_set_sha256(assigned_exports),
        assigned_edges: assigned_edges,
        assigned_reached: assigned_reached,
        assigned_exports: assigned_exports
      }
    }
  end

  def assert_ownership!(graph, evidence, records) do
    loaded = load_delegation!()
    delegation_metadata = Map.get(records, :delegation_metadata, loaded.metadata)
    delegation_records = Map.get(records, :delegation_records, loaded.records)
    lane = evidence.lane.name

    validate_complete_delegation!(delegation_records, loaded.records)
    validate_delegation_rows!(delegation_records, delegation_metadata)

    receipt =
      assert_ownership_preconditions!(graph, evidence, records, loaded, delegation_metadata, lane)

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

    assert_module_namespace_ownership!(module_sets, actual_module_ids, lane)

    original_roots = Map.fetch!(root_sets, "original")
    observed_roots = Map.fetch!(root_sets, "observed")

    assert_root_namespace_pair!(original_roots, observed_roots, lane)

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

    selected_root_ids = assert_selected_root_ids!(original_roots, records.roots, lane)
    remainder_module_ids = assert_live_module_projection!(graph, receipt, module_sets, lane)

    root_observations =
      Enum.flat_map(root_sets, fn {namespace, root_set} ->
        Enum.map(root_set.rows, fn row ->
          mfa = {row["module"], row["function"], row["arity"]}
          actual = Map.fetch!(receipt.pending_by_mfa, mfa)
          canonical_tokens = Enum.map(row["steps"], & &1["token"])
          observed_tokens = actual["caller_chain"]

          canonical_chain_id = canonical_root_chain_id(namespace, row)

          observed_chain_id = observed_root_chain_id(row, canonical_tokens, observed_tokens)

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

  defp assert_ownership_preconditions!(
         graph,
         evidence,
         records,
         loaded,
         delegation_metadata,
         lane
       ) do
    require_ownership!(
      delegation_metadata == loaded.metadata,
      "effective delegation metadata differs from the pinned adopted authority"
    )

    require_ownership!(
      graph.lane.name == lane,
      "lane #{lane} owner=#{@owner} graph lane=#{graph.lane.name} caller-chain=installed Xref graph remedy=use matching lane evidence"
    )

    tier = BannedCalls.banned_mfas()
    :ok = assert_audit!(records, graph, tier, evidence, [])
    assert_graph_receipt!(graph)
  end

  defp assert_module_namespace_ownership!(module_sets, actual_module_ids, lane) do
    for namespace <- ["original", "observed"] do
      module_set = Map.fetch!(module_sets, namespace)

      require_ownership!(
        module_set.identities == actual_module_ids,
        "lane #{lane} namespace=#{namespace} app=debugger owner=#{@remainder_owner} identity=module set differs from inspected BEAMs; missing=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(actual_module_ids, module_set.identities))))}; extra=#{inspect(Enum.sort(MapSet.to_list(MapSet.difference(module_set.identities, actual_module_ids))))}; caller-chain=installed debugger BEAM inventory remedy=route every added or missing module through its named owner"
      )

      Enum.each(module_set.owners, fn {{app, module}, owner} ->
        require_ownership!(
          owner == expected_module_owner(app, module),
          "lane #{lane} namespace=#{namespace} MFA #{module} owner=#{owner} caller-chain=adopted module task remedy=assign selected settings module to #{@owner} and every broad remainder module to #{@remainder_owner}"
        )
      end)
    end
  end

  defp expected_module_owner("debugger", "dbg_wx_settings"), do: @owner
  defp expected_module_owner(_app, _module), do: @remainder_owner

  defp assert_root_namespace_pair!(original_roots, observed_roots, lane) do
    require_ownership!(
      original_roots.identities == observed_roots.identities,
      "lane #{lane} owner=#{@remainder_owner} original and observed root identity sets differ; caller-chain=adopted receipt union remedy=preserve both complete root namespaces"
    )
  end

  defp assert_selected_root_ids!(original_roots, audit_roots, lane) do
    selected_root_ids =
      original_roots.rows
      |> Enum.filter(&(&1["owner"] == @owner))
      |> Enum.map(&{&1["app"], &1["module"], &1["function"], &1["arity"]})
      |> MapSet.new()

    audit_root_ids =
      MapSet.new(
        audit_roots,
        &{"debugger", Atom.to_string(elem(&1.mfa, 0)), Atom.to_string(elem(&1.mfa, 1)),
         elem(&1.mfa, 2)}
      )

    require_ownership!(
      selected_root_ids == audit_root_ids and MapSet.size(selected_root_ids) == 3,
      "lane #{lane} owner=#{@owner} selected canonical root set differs from the three source-reviewed monitor roots; caller-chain=dbg_wx_mon start/load_settings/load_settings2 remedy=retain the exact adopted root set"
    )

    selected_root_ids
  end

  defp assert_live_module_projection!(graph, receipt, module_sets, lane) do
    remainder_module_ids =
      Map.fetch!(module_sets, "original").rows
      |> Enum.filter(&(&1["owner"] == @remainder_owner))
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

    remainder_module_ids
  end

  defp observed_root_chain_id(row, canonical_tokens, observed_tokens) do
    if canonical_tokens == observed_tokens,
      do: row["chain_id"],
      else: observed_chain_id!(row, observed_tokens)
  end

  defp canonical_root_chain_id("observed", row), do: get_in(row, ["historical", "chain_id"])
  defp canonical_root_chain_id(_namespace, row), do: row["chain_id"]

  def ownership_controls!(graph, evidence, records) do
    %{metadata: metadata, records: authority} = load_delegation!()

    base =
      records
      |> Map.put(:delegation_metadata, metadata)
      |> Map.put(:delegation_records, authority)

    :verified = assert_ownership!(graph, evidence, records).status
    lane = evidence.lane.name

    controls =
      missing_module_controls(graph, base, lane) ++
        missing_root_controls(graph, base, authority, lane) ++
        changed_owner_controls(graph, base, authority, lane) ++
        settings_source_controls(graph, base) ++ graph_projection_controls(graph, base)

    run_ownership_controls!(controls, evidence)
  end

  defp missing_module_controls(graph, base, lane) do
    selected_module? = &(&1["module"] == "dbg_wx_settings")
    remainder_module? = &(&1["module"] == "dbg_wx_mon")

    [
      {"missing-selected-module-original",
       fn -> {graph, drop_delegation_rows(base, "module", lane, selected_module?)} end,
       "omitted"},
      {"missing-selected-module-observed",
       fn -> {graph, drop_delegation_rows(base, "observed_module", lane, selected_module?)} end,
       "omitted"},
      {"missing-remainder-module-original",
       fn -> {graph, drop_delegation_rows(base, "module", lane, remainder_module?)} end,
       "omitted"},
      {"missing-remainder-module-observed",
       fn -> {graph, drop_delegation_rows(base, "observed_module", lane, remainder_module?)} end,
       "omitted"}
    ]
  end

  defp missing_root_controls(graph, base, authority, lane) do
    selected_root? =
      &(&1["module"] == "dbg_wx_mon" and &1["function"] == "start" and &1["arity"] == 2)

    remainder_root? = &(&1["owner"] == @remainder_owner)

    [
      {"missing-selected-root-original",
       fn -> {graph, drop_delegation_rows(base, "root", lane, selected_root?)} end, "omitted"},
      {"missing-selected-root-observed",
       fn -> {graph, drop_delegation_rows(base, "observed_root", lane, selected_root?)} end,
       "omitted"},
      {"missing-remainder-root-original",
       fn -> {graph, drop_delegation_rows(base, "root", lane, remainder_root?)} end, "omitted"},
      {"missing-remainder-root-observed",
       fn -> {graph, drop_delegation_rows(base, "observed_root", lane, remainder_root?)} end,
       "omitted"},
      {"duplicate-canonical-root",
       fn ->
         selected = find_delegation_row(authority, "root", lane, selected_root?)
         {graph, append_delegation_row(base, "root", selected)}
       end, "duplicate"}
    ]
  end

  defp changed_owner_controls(graph, base, authority, lane) do
    selected_module? = &(&1["module"] == "dbg_wx_settings")

    selected_root? =
      &(&1["module"] == "dbg_wx_mon" and &1["function"] == "start" and &1["arity"] == 2)

    [
      {"wrong-selected-owner",
       fn ->
         changed =
           edit_delegation_rows(
             base,
             "module",
             lane,
             selected_module?,
             &Map.put(&1, "owner", @remainder_owner)
           )

         {graph, changed}
       end, "owner"},
      {"changed-canonical-chain",
       fn ->
         changed =
           edit_delegation_rows(
             base,
             "root",
             lane,
             selected_root?,
             &Map.put(&1, "chain_id", String.duplicate("0", 64))
           )

         {graph, changed}
       end, "chain"},
      {"changed-current-reference",
       fn ->
         changed =
           edit_delegation_rows(
             base,
             "root",
             lane,
             selected_root?,
             &Map.put(&1, "references", ["tampered-owner"])
           )

         {graph, changed}
       end, "references"},
      {"missing-overlap-occurrence",
       fn ->
         overlap = Enum.find(authority, &(&1["t"] == "overlap" and &1["lane"] == lane))

         changed =
           Map.update!(base, :delegation_records, fn rows ->
             Enum.map(rows, &drop_overlap_occurrence(&1, lane, overlap))
           end)

         {graph, changed}
       end, "overlap"},
      {"missing-source-branch",
       fn -> {graph, drop_delegation_rows(base, "source_branch", lane, fn _ -> true end)} end,
       "source_branch"}
    ]
  end

  defp settings_source_controls(graph, base) do
    [
      {"empty-settings-audit",
       fn ->
         {graph, Map.merge(base, %{function_sources: [], function_audit: [], exports: []})}
       end, "all four exact functions"},
      {"changed-settings-source-digest",
       fn -> {graph, Map.put(base, :source_sha256, String.duplicate("0", 64))} end,
       "exact settings source SHA"},
      {"escaping-settings-citation",
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
       end, "source"}
    ]
  end

  defp graph_projection_controls(graph, base) do
    [
      {"graph-new-settings-export",
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
       end, "independent installed graph exports"},
      {"graph-new-debugger-root",
       fn ->
         new_root = {:dbg_wx_mon, :unreviewed_saved_settings_root, 0}

         changed_graph = %{
           graph
           | full_reached: MapSet.put(graph.full_reached, new_root),
             pending_mfas: MapSet.put(graph.pending_mfas, new_root)
         }

         {changed_graph, base}
       end, "graph/receipt sets differ"},
      {"graph-omitted-debugger-beam",
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
       end, "inspected/receipt BEAM sets differ"},
      {"graph-omitted-debugger-export",
       fn ->
         omitted_export = {:dbg_wx_settings, :load, 3}
         {%{graph | full_exported: MapSet.delete(graph.full_exported, omitted_export)}, base}
       end, "independent installed graph exports"},
      {"graph-omitted-active-baseline",
       fn ->
         {%{graph | active_modules: MapSet.delete(graph.active_modules, :dbg_idb)}, base}
       end, "active debugger module graph/receipt sets differ"}
    ]
  end

  defp run_ownership_controls!(controls, evidence) do
    Enum.map(controls, fn {name, mutate, expected} ->
      rejected =
        try do
          {alternate_graph, alternate_records} = mutate.()
          assert_ownership!(alternate_graph, evidence, alternate_records)
          false
        rescue
          error in ExUnit.AssertionError ->
            String.contains?(Exception.message(error), expected)

          error in SweepEvidence.Error ->
            String.contains?(Exception.message(error), expected)
        end

      require_ownership!(
        rejected,
        "ownership negative control #{name} was accepted or returned the wrong diagnostic category"
      )

      "#{name}:rejected"
    end)
  end

  defp drop_delegation_rows(base, kind, lane, predicate) do
    Map.update!(base, :delegation_records, fn rows ->
      Enum.reject(rows, &(&1["t"] == kind and &1["lane"] == lane and predicate.(&1)))
    end)
  end

  defp edit_delegation_rows(base, kind, lane, predicate, update) do
    Map.update!(base, :delegation_records, fn rows ->
      Enum.map(rows, &edit_delegation_row(&1, kind, lane, predicate, update))
    end)
  end

  defp append_delegation_row(base, kind, item) do
    Map.update!(base, :delegation_records, &(&1 ++ [Map.put(item, "t", kind)]))
  end

  defp find_delegation_row(rows, kind, lane, predicate) do
    Enum.find(rows, &(&1["t"] == kind and &1["lane"] == lane and predicate.(&1)))
  end

  defp drop_overlap_occurrence(item, lane, overlap) do
    if item["t"] == "overlap" and item["lane"] == lane and item["token"] == overlap["token"],
      do: Map.update!(item, "occurrences", &Enum.drop(&1, 1)),
      else: item
  end

  defp edit_delegation_row(item, kind, lane, predicate, update) do
    if item["t"] == kind and item["lane"] == lane and predicate.(item),
      do: update.(item),
      else: item
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
    validate_delegation_rows_shape!(rows)
    Enum.each(rows, &validate_delegation_row!/1)
    validate_delegation_counts!(rows, metadata)
    validate_overlap_projection!(rows)
    :ok
  end

  defp validate_delegation_rows_shape!(rows) do
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
  end

  defp validate_delegation_row!(%{"t" => kind} = row)
       when kind in ["module", "observed_module"] do
    expected = if row["module"] == "dbg_wx_settings", do: @owner, else: @remainder_owner

    require_ownership!(
      row["app"] == "debugger" and row["owner"] == expected and
        row["origin_owner"] == @historical_owner and row["pending"] == true and
        row["completion"] == "pending",
      "lane #{row["lane"]} module #{row["module"]} owner=#{row["owner"]} caller-chain=adopted module task remedy=restore the effective current owner and pending status"
    )

    if kind == "observed_module", do: validate_observed_module_identity!(row)
  end

  defp validate_delegation_row!(%{"t" => kind} = row)
       when kind in ["root", "observed_root"] do
    expected = if selected_root_row?(row), do: @owner, else: @remainder_owner

    require_ownership!(
      is_binary(row["app"]) and row["owner"] == expected and
        row["origin_owner"] == @historical_owner and row["completion"] == "pending" and
        valid_sha256?(row["chain_id"]),
      "lane #{row["lane"]} MFA #{format_root_text(row)} owner=#{row["owner"]} chain=#{inspect(row["chain_id"])} caller-chain=adopted root remedy=preserve canonical chain and current child owner"
    )

    validate_root_projection!(row)
    if kind == "observed_root", do: validate_observed_root_identity!(row)
  end

  defp validate_delegation_row!(%{"t" => kind} = row)
       when kind in ["overlap", "observed_overlap"] do
    require_ownership!(
      row["origin_owner"] == nil or row["origin_owner"] == @historical_owner,
      "overlap #{row["token"]} changed historical provenance"
    )
  end

  defp validate_delegation_row!(%{"t" => "exact_source"} = row) do
    expected = if row["module"] == "dbg_wx_settings", do: @owner, else: @remainder_owner

    require_ownership!(
      row["owner"] == expected and row["origin_owner"] == @historical_owner and
        valid_sha256?(row["sha256"]),
      "lane #{row["lane"]} source #{row["module"]} has a changed owner or source fingerprint"
    )
  end

  defp validate_delegation_row!(%{"t" => "source_branch"} = row) do
    lane = row["lane"]
    source_sha = Map.fetch!(@lane_data, lane).icmd_sha256
    source_lines = if lane == "core", do: [88, 126], else: [86, 124]

    expected = %{
      "app" => "debugger",
      "module" => "dbg_icmd",
      "function" => "break_p",
      "arity" => 4,
      "owner" => @owner,
      "origin_owner" => @historical_owner,
      "completion" => "pending",
      "state" => "source-discovered-unresolved-callback-branch",
      "source_sha256" => source_sha,
      "source_path" => "debugger/src/dbg_icmd.erl",
      "source_lines" => source_lines,
      "canonical_receipt_root_present" => false,
      "shared_broad_roots_remain_with" => @remainder_owner
    }

    require_ownership!(
      Enum.all?(expected, fn {key, value} -> row[key] == value end),
      "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{row["owner"]} caller-chain=source-discovered callback branch remedy=preserve the selected pending source branch and broad remainder owner"
    )
  end

  defp validate_delegation_row!(row),
    do: ownership_fail!("effective delegation has unknown typed identity #{inspect(row)}")

  defp validate_observed_module_identity!(row) do
    identity = row["identity"] || %{}

    require_ownership!(
      row["namespace"] == "observed" and identity["kind"] == "module" and
        identity["lane"] == row["lane"] and identity["app"] == row["app"] and
        identity["module"] == row["module"] and valid_sha256?(row["identity_sha256"]),
      "observed module #{row["module"]} has a malformed typed identity"
    )
  end

  defp selected_root_row?(row) do
    row["app"] == "debugger" and
      Enum.any?(@selected_root_mfas, fn {module, function, arity} ->
        row["module"] == Atom.to_string(module) and row["function"] == Atom.to_string(function) and
          row["arity"] == arity
      end)
  end

  defp validate_observed_root_identity!(row) do
    identity = row["identity"] || %{}
    historical_chain_id = get_in(row, ["historical", "chain_id"])

    expected = %{
      "namespace" => "observed",
      "identity_kind" => "root",
      "identity_lane" => row["lane"],
      "identity_app" => row["app"],
      "identity_module" => row["module"],
      "identity_function" => row["function"],
      "identity_arity" => row["arity"]
    }

    matches_identity =
      Enum.all?(expected, fn
        {"namespace", value} -> row["namespace"] == value
        {"identity_kind", value} -> identity["kind"] == value
        {"identity_lane", value} -> identity["lane"] == value
        {"identity_app", value} -> identity["app"] == value
        {"identity_module", value} -> identity["module"] == value
        {"identity_function", value} -> identity["function"] == value
        {"identity_arity", value} -> identity["arity"] == value
      end)

    require_ownership!(
      matches_identity and valid_sha256?(row["identity_sha256"]) and
        valid_sha256?(historical_chain_id),
      "observed MFA #{format_root_text(row)} changed its canonical chain or typed identity"
    )
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
        category = delegation_difference_category(actual_row, expected_row)

        ownership_fail!(
          "effective delegation changed #{category} for typed identity #{inspect(identity)}"
        )
      end
    end)

    :ok
  end

  defp delegation_difference_category(actual, expected) do
    cond do
      actual["owner"] != expected["owner"] -> "owner"
      actual["chain_id"] != expected["chain_id"] -> "canonical chain"
      actual["references"] != expected["references"] -> "current references"
      actual["occurrences"] != expected["occurrences"] -> "overlap occurrence"
      actual["origin_record_sha256"] != expected["origin_record_sha256"] -> "origin fingerprint"
      actual["steps"] != expected["steps"] -> "caller-chain steps"
      true -> "historical fields"
    end
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
          |> Enum.map(&project_delegated_owner(&1, step["token"]))
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

  defp project_delegated_owner(@historical_owner, token), do: owner_for_step!(token)
  defp project_delegated_owner(owner, _token), do: owner

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
        original != [] and current == expected and row["owners"] == owners,
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

  defp resolve_citation!(:module, module, lines, lane, relative) do
    expected_text = "-module(#{module}"
    index = Enum.find_index(lines, &String.contains?(&1, expected_text))

    require_ownership!(
      index != nil,
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source=#{relative} caller-chain=module declaration remedy=restore the exact adopted source"
    )

    %{line: index + 1, expected_text: expected_text}
  end

  defp resolve_citation!(citation, _module, _lines, _lane, _relative), do: citation

  defp remainder_source_rows!(rows, lane) do
    module_ids =
      rows
      |> Enum.filter(
        &(&1["t"] == "module" and &1["lane"] == lane and &1["app"] == "debugger" and
            &1["owner"] == @remainder_owner)
      )
      |> Enum.map(& &1["module"])
      |> MapSet.new()

    observed_module_ids =
      rows
      |> Enum.filter(
        &(&1["t"] == "observed_module" and &1["lane"] == lane and
            &1["app"] == "debugger" and &1["owner"] == @remainder_owner)
      )
      |> Enum.map(& &1["module"])
      |> MapSet.new()

    source_rows =
      rows
      |> Enum.filter(
        &(&1["t"] == "exact_source" and &1["lane"] == lane and
            &1["app"] == "debugger" and &1["owner"] == @remainder_owner)
      )
      |> Enum.sort_by(& &1["module"])

    source_module_ids = MapSet.new(source_rows, & &1["module"])

    require_ownership!(
      MapSet.size(module_ids) > 0 and observed_module_ids == module_ids and
        source_module_ids == module_ids and length(source_rows) == MapSet.size(source_module_ids),
      "lane #{lane} app debugger owner=#{@remainder_owner} caller-chain=adopted module/exact_source assignments differ; modules=#{inspect(Enum.sort(MapSet.to_list(module_ids)))} observed=#{inspect(Enum.sort(MapSet.to_list(observed_module_ids)))} sources=#{inspect(Enum.sort(MapSet.to_list(source_module_ids)))} remedy=restore one exact source row for each assigned module"
    )

    Enum.each(source_rows, fn row ->
      module = row["module"]
      expected_path = "debugger/src/#{module}.erl"

      require_ownership!(
        row["origin_owner"] == @historical_owner and row["source_path"] == expected_path and
          safe_relative_source_path?(row["source_path"]) and
          is_integer(row["bytes"]) and row["bytes"] > 0 and valid_sha256?(row["sha256"]),
        "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=adopted exact_source row path/bytes/hash is invalid; remedy=restore the immutable exact-source assignment"
      )
    end)

    source_rows
  end

  defp safe_relative_source_path?(path) when is_binary(path) do
    parts = Path.split(path)

    Enum.take(parts, 2) == ["debugger", "src"] and
      Enum.all?(parts, &(&1 not in ["", ".", "..", "/"])) and
      Path.extname(path) == ".erl" and not String.contains?(path, "\\")
  end

  defp safe_relative_source_path?(_path), do: false

  defp realpath!(path, lane, description), do: realpath!(path, lane, description, 0)

  defp realpath!(_path, lane, description, depth) when depth > 40 do
    ownership_fail!(
      "lane #{lane} source=#{description} caller-chain=installed realpath resolver exceeded symbolic-link limit=#{depth} remedy=use a stable contained filesystem path"
    )
  end

  defp realpath!(path, lane, description, depth) do
    path
    |> Path.expand()
    |> Path.split()
    |> Enum.reject(&(&1 == "/"))
    |> realpath_components!("/", lane, description, depth)
  end

  defp realpath_components!([], resolved, _lane, _description, _depth), do: Path.expand(resolved)

  defp realpath_components!([component | rest], resolved, lane, description, depth) do
    candidate = Path.join(resolved, component)

    case File.lstat(candidate) do
      {:ok, %{type: :symlink}} ->
        target =
          case :file.read_link_all(String.to_charlist(candidate)) do
            {:ok, link} ->
              to_string(link)

            {:error, reason} ->
              ownership_fail!(
                "lane #{lane} source=#{description} caller-chain=installed realpath symlink read=#{reason} remedy=restore a readable contained path"
              )
          end

        target = Path.expand(target, Path.dirname(candidate))
        next = if rest == [], do: target, else: Path.join(target, Enum.join(rest, "/"))
        realpath!(next, lane, description, depth + 1)

      {:ok, _stat} ->
        realpath_components!(rest, candidate, lane, description, depth)

      {:error, reason} ->
        ownership_fail!(
          "lane #{lane} source=#{description} caller-chain=installed realpath component=#{candidate} read=#{reason} remedy=restore the current exact-lane path"
        )
    end
  end

  defp stable_set_sha256(values) when is_list(values) do
    values |> Enum.sort() |> Enum.join("\n") |> sha256()
  end

  defp format_edge({caller, {module, function}}),
    do: "#{format_mfa(caller)} -> #{module}:#{function}"

  defp format_edge({caller, callee}), do: "#{format_mfa(caller)} -> #{format_mfa(callee)}"

  defp typed_delegation_identity!(%{"t" => "exact_source", "lane" => lane, "module" => module}),
    do: {"exact_source", lane, module}

  defp typed_delegation_identity!(%{
         "t" => kind,
         "lane" => lane,
         "app" => app,
         "module" => module
       })
       when kind in ["module", "observed_module"],
       do: {kind, lane, app, module}

  defp typed_delegation_identity!(%{
         "t" => kind,
         "lane" => lane,
         "app" => app,
         "module" => module,
         "function" => function,
         "arity" => arity
       })
       when kind in ["root", "observed_root"],
       do: {kind, lane, app, module, function, arity}

  defp typed_delegation_identity!(%{"t" => kind, "lane" => lane, "token" => token})
       when kind in ["overlap", "observed_overlap"],
       do: {kind, lane, token}

  defp typed_delegation_identity!(%{
         "t" => "source_branch",
         "lane" => lane,
         "module" => module,
         "function" => function,
         "arity" => arity
       }),
       do: {"source_branch", lane, module, function, arity}

  defp typed_delegation_identity!(row),
    do: ownership_fail!("effective delegation has unknown typed identity #{inspect(row)}")

  defp assert_graph_receipt!(graph) do
    verified = InstalledOtp.verify_receipt_lines!(graph.receipt_lines)
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
        |> Enum.flat_map(&owner_reference_for_token/1)
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

  defp owner_reference_for_token(token) do
    case Regex.run(~r/^(.+)\.([^\.\/]+)\/([0-9]+)$/, token) do
      [_, token_module, token_function, token_arity] ->
        [owner_for_step!("#{token_module}.#{token_function}/#{token_arity}")]

      _ ->
        []
    end
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
      :auto_attach_trace,
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

    assert {:ok, scan} = BeamWalker.scan(inspection.path),
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

    :ok = assert_auto_attach_trace!(record, graph, tier, evidence)

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
    |> Enum.flat_map(&exclusion_match_rows(&1, universe))
  end

  defp exclusion_match_rows(exclusion, universe) do
    matches = Enum.filter(universe, &matches_exclusion?(&1, exclusion))
    citations = if tuple_size(exclusion) > 2, do: elem(exclusion, 2), else: []

    if matches == [] do
      []
    else
      [
        %{
          original_identity: exclusion,
          cited_triple: {elem(exclusion, 0), elem(exclusion, 1), citations},
          matched_mfas: Enum.sort(matches),
          universe: Enum.sort(universe)
        }
      ]
    end
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
      {line, expected_text} = Map.fetch!(lines, String.to_existing_atom(lane_name))
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
      SweepEvidence.resolve!(evidence, "#{citation.path}:#{citation.line}")

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
    source_lines = Map.fetch!(%{"core" => [88, 126], "floor" => [86, 124]}, lane)

    assert length(rows) == 1,
           "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{@owner} caller-chain=effective source-branch ledger remedy=retain one adopted callback source branch"

    [row] = rows

    assert source_branch_row_valid?(row, lane_row.icmd_sha256, source_lines),
           "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{@owner} caller-chain=effective source-branch ledger remedy=retain the adopted source obligation without promoting it to a canonical root"
  end

  defp source_branch_row_valid?(row, source_sha, source_lines) do
    expected = %{
      "owner" => @owner,
      "completion" => "pending",
      "state" => "source-discovered-unresolved-callback-branch",
      "caller" => "dbg_icmd.cmd/4",
      "sensitive_expression" => "try CM:CN(Bs) of",
      "source_path" => "debugger/src/dbg_icmd.erl",
      "source_sha256" => source_sha,
      "source_lines" => source_lines,
      "canonical_receipt_root_present" => false,
      "shared_broad_roots_remain_with" => @remainder_owner
    }

    Enum.all?(expected, fn {key, value} -> row[key] == value end)
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
    |> Enum.reject(fn {module, function, _arity} = mfa ->
      module in [:erlang, :erl_eval, :erl_ddll] or function == :module_info or
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
        walk_caller_step(mfa, rest, reverse, visited)

      {{:value, mfa}, rest} ->
        walk_callers(rest, reverse, MapSet.put(visited, mfa))
    end
  end

  defp walk_caller_step(mfa, rest, reverse, visited) do
    if MapSet.member?(visited, mfa) do
      walk_callers(rest, reverse, visited)
    else
      callers = reverse |> Map.fetch!(mfa) |> caller_list()

      walk_callers(
        Enum.reduce(callers, rest, &:queue.in/2),
        reverse,
        MapSet.put(visited, mfa)
      )
    end
  end

  defp caller_list(callers) when is_struct(callers, MapSet), do: MapSet.to_list(callers)
  defp caller_list(callers), do: callers

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
