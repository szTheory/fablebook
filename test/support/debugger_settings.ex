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
  @monitor_group_modules [
    "dbg_wx_mon",
    "dbg_wx_mon_win",
    "dbg_wx_filedialog_win",
    "dbg_wx_win"
  ]
  @trace_group_modules [
    "dbg_wx_break",
    "dbg_wx_break_win",
    "dbg_wx_code",
    "dbg_wx_src_view",
    "dbg_wx_trace",
    "dbg_wx_trace_win",
    "dbg_wx_view",
    "dbg_wx_winman"
  ]
  @monitor_route_branch_ids [
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
  @remainder_source_branch_ids [
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
  @trace_route_branch_ids [
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
    :trace_resize_code_fixed_changeh_closure,
    :trace_resize_trace_fixed_changeh_closure,
    :trace_code_area_fixed_style_closure,
    :trace_source_view_fixed_style_closure,
    :trace_resize_fixed_closure_calls,
    :trace_output_fixed_callback_invocation,
    :trace_eval_entry_user_command,
    :trace_view_module_source_lookup,
    :trace_trace_module_source_lookup,
    :view_breakpoint_action_dispatch,
    :break_process_fixed_worker,
    :view_process_fixed_worker
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
  @callback_route_branch_ids @auto_attach_route_branch_ids ++
                               [
                                 :auto_attach_flag_init,
                                 :auto_attach_flag_break,
                                 :auto_attach_flag_exit,
                                 :auto_attach_flags_complete,
                                 :condition_setter_input,
                                 :condition_setter_function_checked,
                                 :condition_setter_broadcast,
                                 :condition_server_key_found,
                                 :condition_option_slot,
                                 :condition_options_broadcast,
                                 :condition_server_missing_break,
                                 :condition_message_received,
                                 :condition_process_dictionary_updated,
                                 :condition_break_p_called
                               ]
  @interpreter_route_branch_ids [
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
      ieval_sha256: "60362d2aa47470b70a9264c5a4f7c5e60e8362f844e3ec4171cc3733d2ff31d1",
      iload_sha256: "a2dd4ad09550a866e5cc16834c0f006a146a21c3abc983f72d8ed44dd1a4b250",
      debugged_sha256: "f0ea4b069cacf931380bf814eba15457a5e1823bdd49e38966b59e689e157bda",
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
      ieval_sha256: "393085c1fc6324687bc12b5184b5a501491f07c8f55dc293ee07774ea96d0b6a",
      iload_sha256: "530955c6525821e0382d53375ce5750cb4fd290ce4c323dd38521538452dae03",
      debugged_sha256: "6612e504e8180b783660fc6c5eb1f6a72b5bc3a1b75b27f0129e71c9cc8f00f2",
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

  @interpreter_branch_specs [
    {:interpreter_eval_reentry, {:dbg_ieval, :eval, 3}, :existing_meta_reentry, :ieval,
     %{core: {52, "re_entry, Debugged"}, floor: {50, "re_entry, Debugged"}}},
    {:interpreter_eval_spawn_meta, {:dbg_ieval, :eval, 3}, :new_meta_for_uninterpreted_process,
     :ieval, %{core: {55, "spawn(fun() ->"}, floor: {53, "spawn(fun() ->"}}},
    {:interpreter_meta_initial_eval, {:dbg_ieval, :meta, 5}, :initial_mfa_evaluated, :ieval,
     %{
       core: {240, "eval_mfa(Debugged,M,F,As,Ieval)"},
       floor: {238, "eval_mfa(Debugged,M,F,As,Ieval)"}
     }},
    {:interpreter_uninterpreted_top_apply, {:dbg_ieval, :do_eval_function, 6},
     :top_level_uninterpreted_mfa_returned_for_apply, :ieval,
     %{core: {477, "not_interpreted when Top"}, floor: {475, "not_interpreted when Top"}}},
    {:interpreter_uninterpreted_nested_apply, {:dbg_ieval, :do_eval_function, 6},
     :nested_uninterpreted_mfa_sent_to_debugged_process, :ieval,
     %{core: {479, "not_interpreted ->"}, floor: {477, "not_interpreted ->"}}},
    {:interpreter_external_function_lookup, {:dbg_ieval, :get_function, 4},
     :external_export_lookup_or_not_interpreted, :ieval,
     %{
       core: {554, "dbg_idb:lookup(DbRef, {Mod,Name,Arity,true})"},
       floor: {552, "dbg_idb:lookup(DbRef, {Mod,Name,Arity,true})"}
     }},
    {:interpreter_remote_call, {:dbg_ieval, :expr, 3}, :remote_module_function_dispatch, :ieval,
     %{
       core: {1064, "expr({call_remote,Line,M,F,As0,Lc}"},
       floor: {945, "expr({call_remote,Line,M,F,As0,Lc}"}
     }},
    {:interpreter_apply_fun, {:dbg_ieval, :expr, 3}, :apply_fun_value_dispatch, :ieval,
     %{
       core: {1146, "expr({apply_fun,Line,Fun0,As0,Lc}"},
       floor: {1027, "expr({apply_fun,Line,Fun0,As0,Lc}"}
     }},
    {:interpreter_apply_three, {:dbg_ieval, :expr, 3}, :apply_module_function_arguments, :ieval,
     %{core: {1167, "expr({apply,Line,As0,Lc}"}, floor: {1048, "expr({apply,Line,As0,Lc}"}}},
    {:interpreter_safe_bif_dispatch, {:dbg_ieval, :safe_bif, 5}, :safe_bif_module_function_apply,
     :ieval, %{core: {1692, "try apply(M, F, As) of"}, floor: {1252, "try apply(M, F, As) of"}}},
    {:interpreter_debugged_ready_apply, {:dbg_debugged, :msg_loop, 2}, :ready_dbg_apply_dispatch,
     :debugged, %{core: {53, "apply(M, F, A)"}, floor: {51, "apply(M, F, A)"}}},
    {:interpreter_debugged_command_dispatch, {:dbg_debugged, :msg_loop, 2},
     :meta_command_reply_dispatch, :debugged,
     %{
       core: {76, "{sys, Meta, {command,Command}}"},
       floor: {74, "{sys, Meta, {command,Command}}"}
     }},
    {:interpreter_debugged_reply_apply, {:dbg_debugged, :reply, 1}, :command_apply_dispatch,
     :debugged, %{core: {94, "reply({apply,M,F,As})"}, floor: {92, "reply({apply,M,F,As})"}}},
    {:interpreter_debugged_reply_eval, {:dbg_debugged, :reply, 1}, :command_expression_evaluation,
     :debugged, %{core: {96, "reply({eval,Expr,Bs})"}, floor: {94, "reply({eval,Expr,Bs})"}}},
    {:interpreter_loader_worker, {:dbg_iload, :load_mod, 4}, :linked_loader_worker, :iload,
     %{
       core: {52, "spawn_link(load_mod1(Mod, File, Binary, Db))"},
       floor: {47, "spawn_link(load_mod1(Mod, File, Binary, Db))"}
     }},
    {:interpreter_loader_envelope_decode, {:dbg_iload, :store_module, 4},
     :caller_envelope_term_decoded, :iload,
     %{core: {73, "binary_to_term(Binary)"}, floor: {68, "binary_to_term(Binary)"}}},
    {:interpreter_loader_abstract_decode, {:dbg_iload, :abstr, 1},
     :binary_abstract_code_decoded_or_term_passthrough, :iload,
     %{
       core: {145, "abstr(Bin) when is_binary(Bin) -> binary_to_term(Bin)"},
       floor: {128, "abstr(Bin) when is_binary(Bin) -> binary_to_term(Bin)"}
     }},
    {:interpreter_load_package, {:int, :load, 2}, :compiled_envelope_constructed_from_load_inputs,
     :int,
     %{
       core: {872, "load({Mod, Src, Beam, BeamBin, Exp, Abst}, Dist)"},
       floor: {868, "load({Mod, Src, Beam, BeamBin, Exp, Abst}, Dist)"}
     }},
    {:interpreter_server_loader_call, {:dbg_iserver, :handle_call, 3},
     :server_calls_interpreter_loader, :iserver,
     %{
       core: {231, "dbg_iload:load_mod(Mod, Src, Bin, ModDb)"},
       floor: {229, "dbg_iload:load_mod(Mod, Src, Bin, ModDb)"}
     }}
  ]

  @monitor_remainder_branch_specs [
    {:monitor_dialog_default_path, {:dbg_wx_filedialog_win, :init, 1},
     :current_directory_fallback_when_default_dir_absent, {:remainder, "dbg_wx_filedialog_win"},
     %{
       core: {93, "Path = proplists:get_value(defaultDir, Options0, DefPath)"},
       floor: {91, "Path = proplists:get_value(defaultDir, Options0, DefPath)"}
     }},
    {:monitor_dialog_filter_default, {:dbg_wx_filedialog_win, :init, 1},
     :fixed_file_type_filter_is_default, {:remainder, "dbg_wx_filedialog_win"},
     %{
       core: {95, "Filter = proplists:get_value(filter, Options0, fun file_type_and_icon/2)"},
       floor: {93, "Filter = proplists:get_value(filter, Options0, fun file_type_and_icon/2)"}
     }},
    {:monitor_dialog_sort_default, {:dbg_wx_filedialog_win, :init, 1}, :name_sort_is_default,
     {:remainder, "dbg_wx_filedialog_win"},
     %{
       core: {96, "SortCol = sort_col(proplists:get_value(sort, Options0, name))"},
       floor: {94, "SortCol = sort_col(proplists:get_value(sort, Options0, name))"}
     }},
    {:monitor_dialog_cancel, {:dbg_wx_filedialog_win, :handle_event, 2},
     :cancel_returns_without_selection, {:remainder, "dbg_wx_filedialog_win"},
     %{
       core: {216, "handle_event(#wx{id=Id=?wxID_CANCEL}"},
       floor: {214, "handle_event(#wx{id=Id=?wxID_CANCEL}"}
     }},
    {:monitor_dialog_selected, {:dbg_wx_filedialog_win, :handle_event, 2},
     :ok_returns_selected_path, {:remainder, "dbg_wx_filedialog_win"},
     %{
       core: {220, "handle_event(#wx{id=Id=?wxID_OK}"},
       floor: {218, "handle_event(#wx{id=Id=?wxID_OK}"}
     }},
    {:monitor_dialog_filter_dispatch, {:dbg_wx_filedialog_win, :get_file_info, 5},
     :filter_callback_receives_current_directory_and_entry_name,
     {:remainder, "dbg_wx_filedialog_win"},
     %{core: {511, "case Filter(Dir,Name) of"}, floor: {509, "case Filter(Dir,Name) of"}}},
    {:monitor_window_shortcut_atom, {:dbg_wx_mon_win, :handle_event, 2},
     :key_code_is_converted_to_shortcut_atom, {:remainder, "dbg_wx_mon_win"},
     %{
       core: {534, "{shortcut, list_to_atom([Key+($a-$A)])}"},
       floor: {530, "{shortcut, list_to_atom([Key+($a-$A)])}"}
     }},
    {:monitor_window_module_atom, {:dbg_wx_mon_win, :handle_event, 2},
     :displayed_module_name_becomes_atom, {:remainder, "dbg_wx_mon_win"},
     %{
       core: {557, "{module, list_to_atom(ModS), view};"},
       floor: {553, "{module, list_to_atom(ModS), view};"}
     }},
    {:monitor_window_reload_module_atom, {:dbg_wx_mon_win, :handle_event, 2},
     :displayed_module_name_is_loaded_for_reload, {:remainder, "dbg_wx_mon_win"},
     %{
       core: {565, "int:i(list_to_atom(ModS))"},
       floor: {561, "int:i(list_to_atom(ModS))"}
     }},
    {:monitor_window_checkbox_atoms, {:dbg_wx_mon_win, :handle_event, 2},
     :displayed_checkbox_labels_become_atoms, {:remainder, "dbg_wx_mon_win"},
     %{
       core: {577, "[list_to_atom(Name)|NamesAcc];"},
       floor: {573, "[list_to_atom(Name)|NamesAcc];"}
     }},
    {:monitor_window_strings_checkbox_atom, {:dbg_wx_mon_win, :handle_event, 2},
     :strings_checkbox_label_becomes_atom, {:remainder, "dbg_wx_mon_win"},
     %{
       core: {596, "[list_to_atom(Name)|NamesAcc];"},
       floor: {592, "[list_to_atom(Name)|NamesAcc];"}
     }},
    {:monitor_process_pid_parse, {:dbg_wx_mon_win, :clear_processes, 2},
     :displayed_process_identifier_is_parsed_for_cleanup, {:remainder, "dbg_wx_mon_win"},
     %{
       core: {411, "Pid = list_to_pid(wxListItem:getText(Item))"},
       floor: {407, "Pid = list_to_pid(wxListItem:getText(Item))"}
     }},
    {:monitor_backtrace_integer_scanner, {:dbg_wx_win, :verify, 2},
     :backtrace_integer_input_scanned_before_token_type_match, {:remainder, "dbg_wx_win"},
     %{
       core: {279, "case erl_scan:string(Str, 1, [text]) of"},
       floor: {277, "case erl_scan:string(Str, 1, [text]) of"}
     }},
    {:monitor_backtrace_integer_token_match, {:dbg_wx_win, :verify, 2},
     :backtrace_size_requires_one_integer_token_after_scanning, {:remainder, "dbg_wx_win"},
     %{
       core: {286, "{ok, [{Type, _Line, Value}], _EndLine} when Type/=term ->"},
       floor: {284, "{ok, [{Type, _Line, Value}], _EndLine} when Type/=term ->"}
     }},
    {:monitor_edit_variable_term_scanner, {:dbg_wx_win, :verify, 2},
     :edit_variable_term_input_scanned_before_term_parse, {:remainder, "dbg_wx_win"},
     %{
       core: {279, "case erl_scan:string(Str, 1, [text]) of"},
       floor: {277, "case erl_scan:string(Str, 1, [text]) of"}
     }},
    {:monitor_edit_variable_term_parser, {:dbg_wx_win, :verify, 2},
     :edit_variable_value_uses_extended_parse_term_without_expression_evaluation,
     {:remainder, "dbg_wx_win"},
     %{
       core: {281, "case erl_eval:extended_parse_term(Tokens++[{dot, erl_anno:new(1)}]) of"},
       floor: {279, "case erl_eval:extended_parse_term(Tokens++[{dot, erl_anno:new(1)}]) of"}
     }}
  ]

  @trace_remainder_branch_specs [
    {:trace_breakpoint_menu_dispatch, {:dbg_wx_trace, :gui_cmd, 2},
     :break_menu_action_routes_to_interpreter_break_control, {:remainder, "dbg_wx_trace"},
     %{
       core: {447, "gui_cmd({break, {Mod, Line}, What}, State) ->"},
       floor: {445, "gui_cmd({break, {Mod, Line}, What}, State) ->"}
     }},
    {:trace_edit_variable_term_entry, {:dbg_wx_trace, :gui_cmd, 2},
     :edit_variable_uses_term_entry, {:remainder, "dbg_wx_trace"},
     %{
       core: {524, "case dbg_wx_win:entry(Window, \"Edit variable\", Var, {term, Val}) of"},
       floor: {522, "case dbg_wx_win:entry(Window, \"Edit variable\", Var, {term, Val}) of"}
     }},
    {:trace_edit_variable_assignment, {:dbg_wx_trace, :gui_cmd, 2},
     :parsed_value_is_formatted_as_existing_variable_assignment, {:remainder, "dbg_wx_trace"},
     %{
       core: {530, "gui_cmd({user_command, lists:flatten(Cmd)}, State)"},
       floor: {528, "gui_cmd({user_command, lists:flatten(Cmd)}, State)"}
     }},
    {:trace_user_command_eval_dispatch, {:dbg_wx_trace, :gui_cmd, 2},
     :status_gated_command_reaches_debugger_meta_evaluator, {:remainder, "dbg_wx_trace"},
     %{
       core: {511, "int:meta(State#state.meta, eval, Arg);"},
       floor: {509, "int:meta(State#state.meta, eval, Arg);"}
     }},
    {:trace_backtrace_integer_entry, {:dbg_wx_trace, :gui_cmd, 2},
     :backtrace_size_caller_supplies_integer_type, {:remainder, "dbg_wx_trace"},
     %{
       core: {481, "case dbg_wx_win:entry(Win, \"Backtrace\",'Backtrace:', {integer, Val}) of"},
       floor: {479, "case dbg_wx_win:entry(Win, \"Backtrace\",'Backtrace:', {integer, Val}) of"}
     }},
    {:break_dialog_module_atom_live_edit, {:dbg_wx_break_win, :handle_event, 2},
     :edited_module_text_is_converted_to_atom, {:remainder, "dbg_wx_break_win"},
     %{
       core: {192, "{module, list_to_atom(Module)};"},
       floor: {188, "{module, list_to_atom(Module)};"}
     }},
    {:break_dialog_module_atom_function_submit, {:dbg_wx_break_win, :handle_event, 2},
     :function_break_selection_converts_module_text_to_atom, {:remainder, "dbg_wx_break_win"},
     %{
       core:
         {215, "Breaks = [[list_to_atom(Mod)|lists:nth(Index+1, Funcs)] || Index <- IndexL],"},
       floor:
         {211, "Breaks = [[list_to_atom(Mod)|lists:nth(Index+1, Funcs)] || Index <- IndexL],"}
     }},
    {:break_dialog_module_atom_line_submit, {:dbg_wx_break_win, :handle_event, 2},
     :line_break_submission_converts_module_text_to_atom, {:remainder, "dbg_wx_break_win"},
     %{
       core: {224, "{break, [[list_to_atom(Mod)|Data]], Triggered};"},
       floor: {220, "{break, [[list_to_atom(Mod)|Data]], Triggered};"}
     }},
    {:break_dialog_atom_input_types, {:dbg_wx_break_win, :create_win, 5},
     :line_uses_integer_field_and_conditional_break_adds_atom_fields,
     {:remainder, "dbg_wx_break_win"},
     %{
       core: {125, "Inputs = case Type of"},
       floor: {121, "Inputs = case Type of"}
     }},
    {:break_dialog_typed_input_wrapper, {:dbg_wx_break_win, :check_input, 1},
     :typed_dialog_input_wrapper_initializes_accumulator, {:remainder, "dbg_wx_break_win"},
     %{
       core: {231, "check_input(Entries, [])"},
       floor: {227, "check_input(Entries, [])"}
     }},
    {:break_dialog_typed_input_scanner, {:dbg_wx_break_win, :check_input, 2},
     :typed_dialog_text_is_scanned_before_type_match, {:remainder, "dbg_wx_break_win"},
     %{
       core: {234, "case erl_scan:string(Str) of"},
       floor: {230, "case erl_scan:string(Str) of"}
     }},
    {:break_dialog_conditional_callback_tuple, {:dbg_wx_break, :gui_cmd, 2},
     :conditional_callback_tuple_is_forwarded_to_prior_owner_setter, {:remainder, "dbg_wx_break"},
     %{
       core: {99, "int:test_at_break(Mod, Line, {CMod, CFunc}),"},
       floor: {97, "int:test_at_break(Mod, Line, {CMod, CFunc}),"}
     }},
    {:break_dialog_module_list_lookup, {:dbg_wx_break, :gui_cmd, 2},
     :module_text_route_looks_up_functions_without_membership_validation,
     {:remainder, "dbg_wx_break"},
     %{
       core: {88, "Funcs = int:functions(Mod),"},
       floor: {86, "Funcs = int:functions(Mod),"}
     }},
    {:trace_shortcut_atom, {:dbg_wx_trace_win, :handle_event, 2},
     :control_key_is_converted_to_shortcut_atom, {:remainder, "dbg_wx_trace_win"},
     %{
       core: {799, "{shortcut, list_to_atom([Key+($a-$A)])}"},
       floor: {795, "{shortcut, list_to_atom([Key+($a-$A)])}"}
     }},
    {:trace_resize_fixed_closure_calls, {:dbg_wx_trace_win, :handle_event, 2},
     :sash_resize_calls_a_fixed_local_change_closure, {:remainder, "dbg_wx_trace_win"},
     %{
       core: {729, "Change = fun(Szr, Width) ->"},
       floor: {725, "Change = fun(Szr, Width) ->"}
     }},
    {:trace_resize_code_fixed_changeh_closure, {:dbg_wx_trace_win, :handle_event, 2},
     :code_sash_uses_a_fixed_local_changeh_closure, {:remainder, "dbg_wx_trace_win"},
     %{
       core: {700, "ChangeH = fun(Item) ->"},
       floor: {696, "ChangeH = fun(Item) ->"}
     }},
    {:trace_resize_trace_fixed_changeh_closure, {:dbg_wx_trace_win, :handle_event, 2},
     :trace_sash_uses_a_fixed_local_changeh_closure, {:remainder, "dbg_wx_trace_win"},
     %{
       core: {762, "ChangeH = fun(Item) ->"},
       floor: {758, "ChangeH = fun(Item) ->"}
     }},
    {:trace_code_area_fixed_style_closure, {:dbg_wx_code, :code_area, 1},
     :code_area_applies_styles_through_a_fixed_local_closure, {:remainder, "dbg_wx_code"},
     %{
       core: {94, "SetStyle = fun({Style, Color}) ->"},
       floor: {92, "SetStyle = fun({Style, Color}) ->"}
     }},
    {:trace_source_view_fixed_style_closure, {:dbg_wx_src_view, :code_area, 2},
     :source_view_applies_styles_through_a_fixed_local_closure, {:remainder, "dbg_wx_src_view"},
     %{
       core: {55, "SetStyle = fun({Style, Color}) ->"},
       floor: {53, "SetStyle = fun({Style, Color}) ->"}
     }},
    {:trace_output_fixed_callback_invocation, {:dbg_wx_trace, :meta_cmd, 2},
     :trace_output_invokes_the_fixed_prior_owner_formatter_closure, {:remainder, "dbg_wx_trace"},
     %{
       core: {711, "dbg_wx_trace_win:trace_output(State#state.win, StrFun(P)),"},
       floor: {709, "dbg_wx_trace_win:trace_output(State#state.win, StrFun(P)),"}
     }},
    {:trace_eval_entry_user_command, {:dbg_wx_trace_win, :handle_event, 2},
     :typed_evaluator_text_is_returned_as_user_command, {:remainder, "dbg_wx_trace_win"},
     %{
       core: {920, "{user_command, Cmd}"},
       floor: {916, "{user_command, Cmd}"}
     }},
    {:trace_view_module_source_lookup, {:dbg_wx_view, :gui_load_module, 2},
     :module_view_reads_debugger_raw_contents_for_display, {:remainder, "dbg_wx_view"},
     %{
       core: {270, "case dbg_iserver:call({raw_contents, Mod, any}) of"},
       floor: {268, "case dbg_iserver:call({raw_contents, Mod, any}) of"}
     }},
    {:trace_trace_module_source_lookup, {:dbg_wx_trace, :gui_load_module, 3},
     :trace_window_reads_debugger_raw_contents_for_display, {:remainder, "dbg_wx_trace"},
     %{
       core: {827, "case dbg_iserver:call({raw_contents, Mod, any}) of"},
       floor: {825, "case dbg_iserver:call({raw_contents, Mod, any}) of"}
     }},
    {:view_breakpoint_action_dispatch, {:dbg_wx_view, :gui_cmd, 2},
     :module_view_breakpoint_action_routes_to_interpreter_control, {:remainder, "dbg_wx_view"},
     %{
       core: {195, "gui_cmd({break, {Mod, Line}, What}, State) ->"},
       floor: {193, "gui_cmd({break, {Mod, Line}, What}, State) ->"}
     }},
    {:break_process_fixed_worker, {:dbg_wx_break, :start, 5},
     :break_dialog_uses_fixed_local_linked_worker, {:remainder, "dbg_wx_break"},
     %{
       core: {53, "spawn_link(?MODULE, init, [Wx, Env, Pos, Type, Mod, Line])."},
       floor: {51, "spawn_link(?MODULE, init, [Wx, Env, Pos, Type, Mod, Line])."}
     }},
    {:view_process_fixed_worker, {:dbg_wx_view, :start, 2},
     :module_view_uses_fixed_local_linked_worker, {:remainder, "dbg_wx_view"},
     %{
       core: {50, "spawn_link(fun () -> init(GS, Env, Mod, Title) end)"},
       floor: {48, "spawn_link(fun () -> init(GS, Env, Mod, Title) end)"}
     }}
  ]

  @all_branch_specs @settings_branch_specs ++
                      @callback_branch_specs ++
                      @interpreter_branch_specs ++
                      @monitor_remainder_branch_specs ++
                      @trace_remainder_branch_specs

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
        ],
        interpreter_eval: [
          {:int, :eval, 3},
          {:dbg_debugged, :eval, 3},
          {:dbg_ieval, :eval, 3},
          :existing_meta_reentry_or_new_meta_worker,
          {:dbg_ieval, :meta, 5},
          {:dbg_ieval, :eval_mfa, 5},
          {:dbg_ieval, :do_eval_function, 6},
          {:dbg_ieval, :get_function, 4}
        ],
        interpreter_commands: [
          {:dbg_ieval, :debugged_cmd, 3},
          {:dbg_debugged, :msg_loop, 2},
          {:dbg_debugged, :handle_command, 1},
          {:dbg_debugged, :reply, 1},
          :dynamic_apply_or_expression_evaluation
        ],
        interpreter_load: [
          {:int, :load, 2},
          {:dbg_iserver, :handle_call, 3},
          {:dbg_iload, :load_mod, 4},
          {:dbg_iload, :store_module, 4},
          {:dbg_iload, :abstr, 1}
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

  def assert_function_dispositions!(graph, evidence, records, group)
      when group in [:callbacks, :interpreter, :monitor, :trace] do
    inventory = assert_remainder_inventory!(graph, evidence, records)
    {module_names, required_branches} = disposition_group!(group)
    lane = evidence.lane.name

    group_inventory_modules =
      Enum.filter(inventory.modules, &(&1.module in module_names))

    actual_module_names = Enum.map(group_inventory_modules, & &1.module) |> Enum.sort()

    require_ownership!(
      actual_module_names == Enum.sort(module_names),
      "lane #{lane} owner=#{@remainder_owner} group=#{group} caller-chain=adopted module assignment missing=#{inspect(Enum.sort(module_names -- actual_module_names))} extra=#{inspect(Enum.sort(actual_module_names -- module_names))} remedy=restore the exact assigned module set"
    )

    if group == :trace do
      assigned_groups = [:callbacks, :interpreter, :monitor, :trace]

      expected_assignment_union =
        assigned_groups
        |> Enum.flat_map(fn assigned_group -> elem(disposition_group!(assigned_group), 0) end)
        |> MapSet.new()

      actual_assignment_union = MapSet.new(inventory.module_names)

      require_ownership!(
        expected_assignment_union == actual_assignment_union,
        "lane #{lane} owner=#{@remainder_owner} caller-chain=Plans02/03 module groups versus fresh exact assigned universe missing=#{inspect(MapSet.to_list(MapSet.difference(actual_assignment_union, expected_assignment_union)))} extra=#{inspect(MapSet.to_list(MapSet.difference(expected_assignment_union, actual_assignment_union)))} remedy=cover every current assigned module exactly once"
      )
    end

    graph_adjacency =
      graph.full_edges
      |> Enum.flat_map(fn
        {{_caller_module, _caller_function, _caller_arity} = caller,
         {_callee_module, _callee_function, _callee_arity} = callee} ->
          [{format_mfa(caller), format_mfa(callee)}]

        _unresolved_export_edge ->
          []
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    root_links =
      inventory.ownership_observations
      |> Enum.filter(&(get_in(&1, ["identity", "kind"]) == "root"))

    reachable_by_root =
      Map.new(root_links, fn link ->
        root_mfa = identity_mfa!(link, lane)
        {root_mfa, reachable_mfas(root_mfa, graph_adjacency)}
      end)

    dispositions =
      Enum.map(group_inventory_modules, fn inventory_module ->
        module_name = inventory_module.module

        module_atom =
          graph.inspected
          |> Enum.find(&(Atom.to_string(&1.module_atom) == inventory_module.module))
          |> Map.fetch!(:module_atom)

        source = inventory_module.source
        source_row = inventory_module.source_assignment
        forms = parse_source_forms!(source.path, lane, module_name)
        function_forms = Enum.filter(forms, &match?({:function, _, _, _, _}, &1))

        source_functions =
          Enum.map(function_forms, fn {:function, _anno, function, arity, _clauses} ->
            format_mfa({module_name, Atom.to_string(function), arity})
          end)
          |> Enum.sort()

        require_ownership!(
          source_functions == inventory_module.functions,
          "lane #{lane} app debugger module #{module_name} owner=#{@remainder_owner} source_path=#{source.path} parsed_function_count=#{length(source_functions)} caller-chain=exact installed source versus independent BEAM functions missing=#{inspect(inventory_module.functions -- source_functions)} extra=#{inspect(source_functions -- inventory_module.functions)} parsed=#{inspect(source_functions)} remedy=restore every private and zero-hit MFA from this lane"
        )

        export_forms =
          Enum.filter(forms, &match?({:attribute, _, :export, _}, &1))

        source_exports =
          Enum.flat_map(export_forms, fn {:attribute, _anno, :export, exports} ->
            Enum.map(exports, fn {function, arity} ->
              format_mfa({module_name, Atom.to_string(function), arity})
            end)
          end)
          |> Enum.sort()

        require_ownership!(
          source_exports == inventory_module.exports,
          "lane #{lane} app debugger module #{module_name} owner=#{@remainder_owner} caller-chain=exact installed source versus independent BEAM exports missing=#{inspect(inventory_module.exports -- source_exports)} extra=#{inspect(source_exports -- inventory_module.exports)} remedy=restore every export declaration from this lane"
        )

        source_text = File.read!(source.path)
        source_lines = String.split(source_text, "\n")

        function_dispositions =
          Enum.map(function_forms, fn {:function, anno, function, arity, clauses} = form ->
            mfa = {module_atom, function, arity}
            mfa_name = format_mfa({module_name, Atom.to_string(function), arity})
            head_line = :erl_anno.line(anno)
            head_citation = source_citation!(source_row, source_lines, head_line, lane, mfa_name)

            clause_citations =
              Enum.map(clauses, fn {:clause, clause_anno, _args, _guards, _body} ->
                clause_line = :erl_anno.line(clause_anno)
                source_citation!(source_row, source_lines, clause_line, lane, mfa_name)
              end)
              |> Enum.uniq_by(& &1.line)

            sink_facts = source_call_facts(form, []) |> Enum.uniq()

            outgoing_edges =
              inventory_module.edges
              |> Enum.filter(&(elem(&1, 0) == mfa))
              |> Enum.map(&format_edge/1)
              |> Enum.sort()

            incoming_edges =
              graph.full_edges
              |> Enum.filter(fn
                {_caller, ^mfa} -> true
                _unresolved_export_edge -> false
              end)
              |> Enum.map(&format_edge/1)
              |> Enum.sort()

            relevant_chains =
              root_links
              |> Enum.filter(fn link ->
                root_mfa = identity_mfa!(link, lane)

                root_mfa == mfa_name or
                  (Map.has_key?(reachable_by_root, root_mfa) and
                     MapSet.member?(Map.fetch!(reachable_by_root, root_mfa), mfa_name))
              end)
              |> Enum.map(&chain_link_record/1)
              |> Enum.sort_by(&{&1.namespace, &1.canonical_chain_id || "", &1.identity})

            function_owner = disposition_owner(mfa, source_row)
            route_note = callback_route_note(mfa)
            zero_hit = mfa_name in inventory_module.zero_hit_functions

            %{
              mfa: mfa_name,
              exported: mfa_name in inventory_module.exports,
              source: %{
                path: source_row["source_path"],
                sha256: source_row["sha256"],
                head: head_citation,
                clauses: clause_citations
              },
              caller_inputs:
                Enum.map(clause_citations, &%{line: &1.line, source_head: &1.expected_text}),
              defaults_and_options:
                route_note.defaults_and_options ||
                  "Exact clause patterns above preserve accepted inputs, defaults and terminal branches.",
              caller_input_origin: route_note.caller_input_origin,
              branch_trace: outgoing_edges,
              incoming_edges: incoming_edges,
              branch_ids:
                records.source_branches
                |> Enum.filter(&(&1.mfa == mfa))
                |> Enum.map(& &1.id)
                |> Enum.sort(),
              sink_facts: sink_facts,
              sink_disposition:
                if(sink_facts == [],
                  do:
                    "No direct dynamic dispatch, evaluator, code-loader, atom-construction, or term-decoding sink occurs in this source form; transitively relevant callees are listed in branch_trace.",
                  else: callback_sink_disposition(mfa, sink_facts, route_note.guard_remedy)
                ),
              guard_remedy: route_note.guard_remedy,
              owner: function_owner.owner,
              origin_owner: function_owner.origin_owner,
              completion: function_owner.completion,
              canonical_observed_chains: relevant_chains,
              zero_hit: zero_hit,
              zero_hit_reason:
                if(zero_hit,
                  do:
                    zero_hit_source_reason(mfa_name, clause_citations, incoming_edges, sink_facts),
                  else: nil
                )
            }
          end)

        %{
          module: module_name,
          owner: inventory_module.owner,
          origin_owner: source_row["owner"],
          source: %{
            path: source_row["source_path"],
            sha256: source_row["sha256"],
            bytes: source_row["bytes"]
          },
          function_count: length(function_dispositions),
          export_count: length(source_exports),
          functions: source_functions,
          exports: source_exports,
          private_functions: inventory_module.private_functions,
          zero_hit_functions: inventory_module.zero_hit_functions,
          export_citations:
            Enum.map(export_forms, fn {:attribute, anno, :export, _exports} ->
              source_citation!(
                source_row,
                source_lines,
                :erl_anno.line(anno),
                lane,
                "#{module_name} exports"
              )
            end),
          dispositions: Enum.sort_by(function_dispositions, & &1.mfa)
        }
      end)
      |> Enum.sort_by(& &1.module)

    branch_map = Map.new(records.source_branches, &{&1.id, &1})
    branch_citations = records.branch_citations

    Enum.each(required_branches, fn branch_id ->
      branch = Map.get(branch_map, branch_id)
      citations = Map.get(branch_citations, branch_id, [])

      expected_owner =
        if is_nil(branch), do: nil, else: branch_owner(branch_source(branch_id), branch.mfa)

      require_ownership!(
        not is_nil(branch) and branch.owner == expected_owner and citations != [],
        "lane #{lane} MFA #{if(branch, do: format_mfa(branch.mfa), else: "unknown")} owner=#{if(branch, do: branch.owner, else: "missing")} caller-chain=#{if(branch, do: branch.trace, else: "source branch ledger")} branch=#{branch_id} remedy=restore the exact current-owner callback/control branch"
      )

      Enum.each(citations, fn citation ->
        if group == :interpreter or match?({:remainder, _module}, branch_source(branch_id)) do
          assert_adopted_source_citation!(evidence, lane, inventory, records, citation)
        else
          assert_citation!(evidence, lane, records, citation)
        end
      end)
    end)

    source_branches =
      Enum.map(required_branches, &Map.fetch!(branch_map, &1))
      |> Enum.sort_by(& &1.id)

    cond do
      group == :monitor -> :ok = assert_monitor_dispositions!(dispositions, lane)
      group == :trace -> :ok = assert_trace_dispositions!(dispositions, lane)
      true -> :ok
    end

    cross_owner =
      cond do
        group == :callbacks ->
          require_ownership!(
            function_owner!(dispositions, "dbg_icmd:break_p/4") == @owner,
            "lane #{lane} MFA dbg_icmd:break_p/4 owner=#{@owner} caller-chain=prior child source branch remedy=preserve the earlier callback-body and outcome owner"
          )

          require_ownership!(
            Enum.any?(source_branches, &(&1.id == :condition_break_p_called)),
            "lane #{lane} MFA dbg_icmd:cmd/4 owner=#{@remainder_owner} caller-chain=command -> conditional breakpoint remedy=retain only the current-owner dispatch into the prior-owner break_p/4 body"
          )

          [{{:dbg_icmd, :break_p, 4}, @owner, :pending}]

        group == :monitor ->
          selected_roots =
            Enum.map(@selected_root_mfas, fn {module, function, arity} = mfa ->
              name = format_mfa(mfa)
              disposition = find_function_disposition!(dispositions, name, lane)

              require_ownership!(
                disposition.owner == @owner and disposition.completion == :pending_cross_owner,
                "lane #{lane} MFA #{name} owner=#{disposition.owner} caller-chain=selected saved-settings root remedy=preserve prior-owner route responsibility and pending status"
              )

              %{
                mfa: name,
                owner: disposition.owner,
                completion: disposition.completion,
                changed_route:
                  Enum.any?(
                    inventory.changed_routes,
                    &changed_route_for?(&1, module, function, arity, lane)
                  )
              }
            end)

          selected_branches =
            Enum.filter(source_branches, &(&1.owner == @owner))
            |> Enum.map(&%{id: &1.id, mfa: format_mfa(&1.mfa), owner: &1.owner})

          require_ownership!(
            Enum.any?(selected_roots, &(&1.mfa == "dbg_wx_mon:start/2" and &1.changed_route)),
            "lane #{lane} MFA dbg_wx_mon:start/2 owner=#{@owner} caller-chain=changed selected root route remedy=preserve its pending changed-route observation"
          )

          require_ownership!(
            Enum.all?([:trace_windows_selected, :trace_windows_unselected], fn id ->
              Enum.any?(selected_branches, &(&1.id == id and &1.owner == @owner))
            end),
            "lane #{lane} MFA dbg_wx_mon:load_settings2/2 owner=#{@owner} caller-chain=selected trace-window branches remedy=preserve both prior-owner branch identities"
          )

          %{selected_roots: selected_roots, selected_branches: selected_branches}

        group == :trace ->
          prior_owner_branch = Map.fetch!(branch_map, :conditional_callback_clause)
          remainder_break_dispatch_branch = Map.fetch!(branch_map, :condition_break_p_called)

          current_callback_branch =
            Map.fetch!(branch_map, :break_dialog_conditional_callback_tuple)

          cross_owner_branch_ids = [:conditional_callback_clause, :condition_break_p_called]

          Enum.each(cross_owner_branch_ids, fn branch_id ->
            branch = Map.fetch!(branch_map, branch_id)
            citations = Map.get(branch_citations, branch_id, [])

            require_ownership!(
              citations != [],
              "lane #{lane} MFA #{format_mfa(branch.mfa)} owner=#{branch.owner} caller-chain=cross-owner conditional-break route branch=#{branch_id} remedy=retain exact source evidence for the prior callback body and current caller dispatch"
            )

            Enum.each(citations, fn citation ->
              assert_citation!(evidence, lane, records, citation)
            end)
          end)

          require_ownership!(
            prior_owner_branch.owner == @owner and
              prior_owner_branch.mfa == {:dbg_icmd, :break_p, 4} and
              remainder_break_dispatch_branch.owner == @remainder_owner and
              remainder_break_dispatch_branch.mfa == {:dbg_icmd, :cmd, 4} and
              current_callback_branch.owner == @remainder_owner and
              current_callback_branch.mfa == {:dbg_wx_break, :gui_cmd, 2},
            "lane #{lane} owner=#{@remainder_owner} caller-chain=break dialog -> int:test_at_break/3 -> dbg_icmd:cmd/4 -> prior-owner dbg_icmd:break_p/4 branch prior=#{prior_owner_branch.owner} dispatch=#{remainder_break_dispatch_branch.owner} callback=#{current_callback_branch.owner} remedy=keep the callback tuple and cmd/4 call route with this remainder while preserving break_p/4 body/outcomes with the earlier owner"
          )

          interpreter_roots = inventory.interpreter_root_observations

          interpreter_root_mfas =
            MapSet.new(Enum.map(interpreter_roots, &identity_mfa!(&1, lane)))

          expected_interpreter_roots =
            MapSet.new([
              "dbg_wx_interpret:filter_files/2",
              "dbg_wx_interpret:interpret_all/5",
              "dbg_wx_interpret:start/4"
            ])

          require_ownership!(
            interpreter_root_mfas == expected_interpreter_roots and
              Enum.all?(interpreter_roots, &(&1["owner"] == @remainder_owner)) and
              "dbg_wx_interpret" not in inventory.module_names,
            "lane #{lane} app debugger module dbg_wx_interpret owner=#{@remainder_owner} caller-chain=current observed roots=#{inspect(Enum.sort(MapSet.to_list(interpreter_root_mfas)))} remedy=disposition each currently assigned observed root without reopening the active module"
          )

          %{
            prior_owner_break_branch: %{
              id: prior_owner_branch.id,
              mfa: format_mfa(prior_owner_branch.mfa),
              owner: prior_owner_branch.owner
            },
            remainder_break_dispatch_branch: %{
              id: remainder_break_dispatch_branch.id,
              mfa: format_mfa(remainder_break_dispatch_branch.mfa),
              owner: remainder_break_dispatch_branch.owner
            },
            current_callback_branch: %{
              id: current_callback_branch.id,
              mfa: format_mfa(current_callback_branch.mfa),
              owner: current_callback_branch.owner
            },
            interpreter_roots:
              Enum.map(interpreter_roots, fn root ->
                %{mfa: identity_mfa!(root, lane), owner: root["owner"], chains: root["steps"]}
              end)
              |> Enum.sort_by(& &1.mfa)
          }

        true ->
          []
      end

    all_function_dispositions = Enum.flat_map(dispositions, & &1.dispositions)

    dynamic_facts =
      Enum.flat_map(all_function_dispositions, fn function ->
        Enum.filter(function.sink_facts, fn fact ->
          fact.kind in [
            :dynamic_remote_dispatch,
            :dynamic_spawn,
            :dynamic_apply,
            :dynamic_fun_call
          ]
        end)
        |> Enum.map(fn fact ->
          %{
            mfa: function.mfa,
            source: function.source,
            line: fact.line,
            expression: fact.expression,
            kind: fact.kind,
            owner: function.owner,
            guard_remedy: function.guard_remedy
          }
        end)
      end)

    resolved_dynamic =
      Enum.flat_map(dynamic_facts, fn fact ->
        case fixed_dynamic_route_status(fact, lane) do
          nil -> []
          status -> [Map.put(fact, :status, status)]
        end
      end)

    unresolved_dynamic =
      Enum.reject(dynamic_facts, &(not is_nil(fixed_dynamic_route_status(&1, lane))))
      |> Enum.map(&Map.put(&1, :status, :unresolved_static_target))

    require_ownership!(
      length(resolved_dynamic) + length(unresolved_dynamic) == length(dynamic_facts) and
        Enum.all?(unresolved_dynamic, &(&1.status == :unresolved_static_target)),
      "lane #{lane} group=#{group} owner=#{@remainder_owner} caller-chain=source AST remedy=classify every dynamic source capability as fixed/resolved or honestly unresolved"
    )

    %{
      status: :verified,
      lane: lane,
      group: group,
      module_names: Enum.sort(module_names),
      modules: dispositions,
      source_branches: source_branches,
      cross_owner: cross_owner,
      resolved_dynamic: resolved_dynamic,
      unresolved_dynamic: unresolved_dynamic,
      inventory: inventory
    }
  end

  defp fixed_dynamic_route_status(%{mfa: mfa, line: line, kind: kind}, lane) do
    routes =
      if lane == "core" do
        %{
          {"dbg_wx_code:code_area/1", 98} => :resolved_fixed_local_closure,
          {"dbg_wx_src_view:code_area/2", 59} => :resolved_fixed_local_closure,
          {"dbg_wx_trace:meta_cmd/2", 711} => :resolved_cross_owner_fixed_callback,
          {"dbg_wx_trace_win:handle_event/2", 706} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 734} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 735} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 736} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 767} => :resolved_fixed_local_closure,
          {"dbg_wx_break:start/5", 53} => :resolved_fixed_local_worker,
          {"dbg_wx_view:start/2", 50} => :resolved_fixed_local_worker
        }
      else
        %{
          {"dbg_wx_code:code_area/1", 96} => :resolved_fixed_local_closure,
          {"dbg_wx_src_view:code_area/2", 57} => :resolved_fixed_local_closure,
          {"dbg_wx_trace:meta_cmd/2", 709} => :resolved_cross_owner_fixed_callback,
          {"dbg_wx_trace_win:handle_event/2", 702} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 730} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 731} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 732} => :resolved_fixed_local_closure,
          {"dbg_wx_trace_win:handle_event/2", 763} => :resolved_fixed_local_closure,
          {"dbg_wx_break:start/5", 51} => :resolved_fixed_local_worker,
          {"dbg_wx_view:start/2", 48} => :resolved_fixed_local_worker
        }
      end

    case {kind, mfa, line} do
      {:dynamic_fun_call, _, _} -> Map.get(routes, {mfa, line})
      {:dynamic_spawn, _, _} -> Map.get(routes, {mfa, line})
      _ -> nil
    end
  end

  defp fixed_dynamic_route_status(_fact, _lane), do: nil

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
        (record.branch_citations
         |> Map.drop(
           @interpreter_route_branch_ids ++
             @remainder_source_branch_ids ++ @trace_route_branch_ids
         )
         |> Map.values()
         |> Enum.flat_map(&List.wrap/1)) ++
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
    loaded = load_delegation!()

    remainder_sources =
      loaded.records
      |> remainder_source_rows!(lane_name)
      |> Map.new(&{&1["module"], &1})

    Enum.into(@all_branch_specs, %{}, fn {id, _mfa, _predicate, source, lines} ->
      {line, expected_text} = Map.fetch!(lines, String.to_existing_atom(lane_name))

      citation =
        case source do
          {:remainder, module} ->
            source_row = Map.fetch!(remainder_sources, module)

            %{
              path: source_row["source_path"],
              line: line,
              sha256: source_row["sha256"],
              expected_text: expected_text
            }

          _ ->
            citation(lane_name, source, line, expected_text)
        end

      {id, [citation]}
    end)
  end

  defp branch_source(branch_id) do
    @all_branch_specs
    |> Enum.find(fn {id, _mfa, _predicate, _source, _lines} -> id == branch_id end)
    |> case do
      {_id, _mfa, _predicate, source, _lines} -> source
      nil -> nil
    end
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

  defp citation(lane_name, :ieval, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/dbg_ieval.erl",
      line: line,
      sha256: lane.ieval_sha256,
      expected_text: expected_text
    }
  end

  defp citation(lane_name, :iload, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/dbg_iload.erl",
      line: line,
      sha256: lane.iload_sha256,
      expected_text: expected_text
    }
  end

  defp citation(lane_name, :debugged, line, expected_text) do
    lane = Map.fetch!(@lane_data, lane_name)

    %{
      path: "debugger/src/dbg_debugged.erl",
      line: line,
      sha256: lane.debugged_sha256,
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

  defp branch_trace({:dbg_wx_mon_win, :handle_event, 2}),
    do:
      "wx event -> monitor window menu/list/checkbox route -> dbg_wx_mon command or displayed module/PID conversion"

  defp branch_trace({:dbg_wx_mon_win, :clear_processes, 2}),
    do:
      "monitor process rows -> clear_processes/2 -> parse displayed PID -> clear trace window state"

  defp branch_trace({:dbg_wx_filedialog_win, :init, 1}),
    do:
      "dbg_wx_filedialog_win:new/3 options -> init/1 -> cwd/defaultDir, fixed filter default and name sort"

  defp branch_trace({:dbg_wx_filedialog_win, :get_file_info, 5}),
    do: "directory listing -> get_file_info/5 -> filter callback -> file metadata rows or skip"

  defp branch_trace({:dbg_wx_filedialog_win, :handle_event, 2}),
    do:
      "file-dialog events -> cancel or selected path; navigation and typing only update displayed path"

  defp branch_trace({:dbg_wx_win, :verify, 2}),
    do:
      "Backtrace Size integer entry -> scanner -> one integer token; Edit Variable term entry -> scanner -> extended_parse_term"

  defp branch_trace({:dbg_wx_break, :start, 5}),
    do: "break menu -> dbg_wx_break:start/5 -> fixed linked local init/6 worker"

  defp branch_trace({:dbg_wx_break_win, :create_win, 5}),
    do:
      "break dialog type -> integer Line field, plus atom C-Module and C-Function fields for conditional breakpoints"

  defp branch_trace({:dbg_wx_break, :gui_cmd, 2}),
    do:
      "local break dialog module text -> int:functions/1 lookup without explicit membership check; break tuples -> int breakpoint controls or prior-owner condition setter"

  defp branch_trace({:dbg_wx_break_win, :handle_event, 2}),
    do:
      "break dialog text and selection events -> module atom conversions and typed input checks -> break command tuple"

  defp branch_trace({:dbg_wx_break_win, :check_input, 1}),
    do: "typed dialog input wrapper -> check_input/2 with empty accumulator"

  defp branch_trace({:dbg_wx_break_win, :check_input, 2}),
    do: "local wxTextCtrl text -> erl_scan:string/1 before configured token-type match or error"

  defp branch_trace({:dbg_wx_trace, :gui_cmd, 2}),
    do:
      "trace menu, Edit Variable, and user command events -> breakpoint controls or status-gated int:meta eval"

  defp branch_trace({:dbg_wx_trace, :meta_cmd, 2}),
    do:
      "interpreter trace event -> prior-owner fixed formatter closure -> attached-process route -> trace_output formatting"

  defp branch_trace({:dbg_wx_code, :code_area, 1}),
    do: "fixed syntax style list -> local SetStyle closure -> fixed wx styled-text setters"

  defp branch_trace({:dbg_wx_src_view, :code_area, 2}),
    do: "fixed syntax style list -> local SetStyle closure -> fixed wx styled-text setters"

  defp branch_trace({:dbg_wx_trace, :gui_load_module, 3}),
    do:
      "trace-window display -> dbg_iserver raw_contents query -> source display or no-code state"

  defp branch_trace({:dbg_wx_trace_win, :handle_event, 2}),
    do:
      "keyboard, menu, search, evaluator and binding events -> fixed shortcut, search, user-command or edit tuples"

  defp branch_trace({:dbg_wx_view, :start, 2}),
    do: "module-view request -> started-window check -> fixed linked local init/4 worker"

  defp branch_trace({:dbg_wx_view, :gui_cmd, 2}),
    do: "module-view breakpoint event -> int breakpoint control tuple"

  defp branch_trace({:dbg_wx_view, :gui_load_module, 2}),
    do: "module-view display -> dbg_iserver raw_contents query -> source display or no-code state"

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
    do:
      "dbg_iserver new_process -> auto_attach(init) -> running|break result; load request -> dbg_iload:load_mod/4"

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

  defp branch_trace({:dbg_ieval, :eval, 3}),
    do:
      "int:eval/3 -> dbg_debugged:eval/3 -> dbg_ieval:eval/3 -> existing Meta re_entry or spawned meta/5"

  defp branch_trace({:dbg_ieval, :meta, 5}),
    do:
      "dbg_ieval:eval/3 -> meta/5 -> dbg_iserver:new_process -> eval_mfa/5 -> interpreted result"

  defp branch_trace({:dbg_ieval, :do_eval_function, 6}),
    do:
      "eval_mfa/5 or eval_function/7 -> do_eval_function/6 -> interpreted clauses or not_interpreted apply route"

  defp branch_trace({:dbg_ieval, :get_function, 4}),
    do:
      "do_eval_function/6 -> get_function/4 -> interpreted database export lookup or not_interpreted fallback"

  defp branch_trace({:dbg_ieval, :expr, 3}),
    do: "eval_mfa/5 -> expr/3 remote-call, apply-fun, apply/3 and safe-BIF AST cases -> dispatch"

  defp branch_trace({:dbg_ieval, :safe_bif, 5}),
    do: "expr/3 safe_bif tag -> safe_bif/5 -> apply(M,F,As)"

  defp branch_trace({:dbg_ieval, :catch_clauses, 4}),
    do: "interpreted catch clauses exhausted -> erlang:Class(Reason) exception dispatch"

  defp branch_trace({:dbg_ieval, :do_exception, 5}),
    do: "exception/4,5 -> do_exception/5 -> erlang:Class(Reason) exception dispatch"

  defp branch_trace({:dbg_ieval, :meta_loop, 3}),
    do: "meta/5 -> meta_loop/3 receives debugged-process exception -> erlang:Class(Reason)"

  defp branch_trace({:dbg_debugged, :msg_loop, 2}),
    do:
      "error_handler -> dbg_debugged:eval/3 -> selected Meta messages -> ready dbg_apply or command reply"

  defp branch_trace({:dbg_debugged, :reply, 1}),
    do: "msg_loop/2 -> handle_command/1 -> reply/1 -> apply or erl_eval:expr/2"

  defp branch_trace({:dbg_iload, :load_mod, 4}),
    do: "int:load/2 -> dbg_iserver:handle_call(load) -> dbg_iload:load_mod/4 -> linked worker"

  defp branch_trace({:dbg_iload, :store_module, 4}),
    do:
      "int:load/2 envelope -> dbg_iserver load request -> store_module/4 -> binary term decoding"

  defp branch_trace({:dbg_iload, :abstr, 1}),
    do: "store_module/4 -> abstr/1 -> binary abstract-code decoding or already-decoded term"

  defp branch_trace({:int, :load, 2}),
    do:
      "caller-selected load tuple -> int:load/2 -> beam/source envelope -> dbg_iserver load request"

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

  defp zero_hit_source_reason(mfa, clauses, incoming_edges, sink_facts) do
    source_heads = Enum.map(clauses, &"#{&1.path}:#{&1.line} #{&1.expected_text}")

    case {incoming_edges, sink_facts} do
      {[], []} ->
        "This MFA has no static caller edge and no direct recognized sink. Its exact installed clause heads remain cited (#{Enum.join(source_heads, "; ")}); graph absence is not treated as a benign disposition."

      {[], facts} ->
        "This MFA has no static caller edge, but its exact source contains direct sink facts #{inspect(facts)}. Its installed clause heads remain cited (#{Enum.join(source_heads, "; ")}) and the route stays unresolved until a caller constraint is proved."

      {callers, facts} ->
        "This MFA is not reached by the selected assigned roots. Exact source callers are #{Enum.join(callers, "; ")}; direct sink facts are #{inspect(facts)}; cited clause heads are #{Enum.join(source_heads, "; ")}. It remains source-disposed rather than presumed benign."
    end
    |> then(fn reason -> "#{mfa}: #{reason}" end)
  end

  defp assert_citation!(evidence, lane, record, citation) do
    resolved =
      SweepEvidence.resolve!(evidence, "#{citation.path}:#{citation.line}")

    assert resolved.sha256 == citation.sha256,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{record.owner} caller-chain=source citation #{citation.path}:#{citation.line} remedy=restore exact lane SHA"

    assert resolved.text =~ citation.expected_text,
           "lane #{lane} MFA dbg_wx_settings:default_settings_dir/1 owner=#{record.owner} caller-chain=source citation #{citation.path}:#{citation.line} remedy=restore matching branch text"
  end

  defp assert_adopted_source_citation!(evidence, lane, inventory, record, citation) do
    module_name = Path.basename(citation.path, ".erl")
    inventory_module = Enum.find(inventory.modules, &(&1.module == module_name))

    require_ownership!(
      not is_nil(inventory_module),
      "lane #{lane} owner=#{record.owner} caller-chain=#{citation.path}:#{citation.line} remedy=resolve the citation to its adopted exact_source inventory row"
    )

    source_row = inventory_module.source_assignment

    require_ownership!(
      source_row["sha256"] == citation.sha256,
      "lane #{lane} app debugger module #{module_name} owner=#{record.owner} caller-chain=#{citation.path}:#{citation.line} remedy=use the adopted exact_source hash"
    )

    assert_remainder_source!(evidence, source_row, citation)
  end

  defp disposition_group!(:callbacks) do
    {["int", "i", "debugger", "dbg_iserver", "dbg_icmd"], @callback_route_branch_ids}
  end

  defp disposition_group!(:interpreter) do
    {["dbg_ieval", "dbg_iload", "dbg_debugged"], @interpreter_route_branch_ids}
  end

  defp disposition_group!(:monitor) do
    {@monitor_group_modules, @monitor_route_branch_ids}
  end

  defp disposition_group!(:trace) do
    {@trace_group_modules, @trace_route_branch_ids}
  end

  defp assert_trace_dispositions!(modules, lane) do
    required_sinks = [
      {"dbg_wx_break_win:handle_event/2", :atom_construction},
      {"dbg_wx_break_win:check_input/2", :token_scanner},
      {"dbg_wx_trace_win:handle_event/2", :atom_construction},
      {"dbg_wx_trace:meta_cmd/2", :dynamic_fun_call}
    ]

    Enum.each(required_sinks, fn {mfa, kind} ->
      disposition = find_function_disposition!(modules, mfa, lane)

      require_ownership!(
        Enum.any?(disposition.sink_facts, &(&1.kind == kind)) and
          is_binary(disposition.guard_remedy) and disposition.guard_remedy != "",
        "lane #{lane} MFA #{mfa} owner=#{disposition.owner} caller-chain=exact source sink #{kind} remedy=retain its narrow input and dispatch disposition"
      )
    end)

    source_functions =
      modules
      |> Enum.flat_map(& &1.dispositions)
      |> Map.new(&{&1.mfa, &1})

    break_atom_lines =
      source_functions["dbg_wx_break_win:handle_event/2"].sink_facts
      |> Enum.filter(&(&1.kind == :atom_construction))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    expected_break_atom_lines = if lane == "core", do: [192, 215, 224], else: [188, 211, 220]

    require_ownership!(
      break_atom_lines == expected_break_atom_lines,
      "lane #{lane} MFA dbg_wx_break_win:handle_event/2 owner=#{@remainder_owner} caller-chain=user module text -> list_to_atom/1 expected=#{inspect(expected_break_atom_lines)} actual=#{inspect(break_atom_lines)} remedy=map supported module names to existing atoms before any conversion"
    )

    shortcut_atom_lines =
      source_functions["dbg_wx_trace_win:handle_event/2"].sink_facts
      |> Enum.filter(&(&1.kind == :atom_construction))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    expected_shortcut_atom_lines = if lane == "core", do: [799], else: [795]

    require_ownership!(
      shortcut_atom_lines == expected_shortcut_atom_lines,
      "lane #{lane} MFA dbg_wx_trace_win:handle_event/2 owner=#{@remainder_owner} caller-chain=keyboard code -> list_to_atom/1 expected=#{inspect(expected_shortcut_atom_lines)} actual=#{inspect(shortcut_atom_lines)} remedy=map supported shortcut keys to fixed atoms"
    )

    expected_dynamic_fun_sites =
      if lane == "core" do
        [
          {"dbg_wx_code:code_area/1", 98},
          {"dbg_wx_src_view:code_area/2", 59},
          {"dbg_wx_trace:meta_cmd/2", 711},
          {"dbg_wx_trace_win:handle_event/2", 706},
          {"dbg_wx_trace_win:handle_event/2", 734},
          {"dbg_wx_trace_win:handle_event/2", 735},
          {"dbg_wx_trace_win:handle_event/2", 736},
          {"dbg_wx_trace_win:handle_event/2", 767}
        ]
      else
        [
          {"dbg_wx_code:code_area/1", 96},
          {"dbg_wx_src_view:code_area/2", 57},
          {"dbg_wx_trace:meta_cmd/2", 709},
          {"dbg_wx_trace_win:handle_event/2", 702},
          {"dbg_wx_trace_win:handle_event/2", 730},
          {"dbg_wx_trace_win:handle_event/2", 731},
          {"dbg_wx_trace_win:handle_event/2", 732},
          {"dbg_wx_trace_win:handle_event/2", 763}
        ]
      end

    actual_dynamic_fun_sites =
      source_functions
      |> Enum.flat_map(fn {mfa, disposition} ->
        disposition.sink_facts
        |> Enum.filter(&(&1.kind == :dynamic_fun_call))
        |> Enum.map(&{mfa, &1.line})
      end)
      |> Enum.sort()

    require_ownership!(
      actual_dynamic_fun_sites == Enum.sort(expected_dynamic_fun_sites),
      "lane #{lane} group=trace owner=#{@remainder_owner} caller-chain=exact function sinks expected=#{inspect(Enum.sort(expected_dynamic_fun_sites))} actual=#{inspect(actual_dynamic_fun_sites)} remedy=disposition every variable-fun call and reject unreviewed dynamic sites"
    )

    break_input = source_functions["dbg_wx_break_win:check_input/2"]
    break_wrapper = source_functions["dbg_wx_break_win:check_input/1"]
    break_inputs = source_functions["dbg_wx_break_win:create_win/5"]
    edit_route = source_functions["dbg_wx_trace:gui_cmd/2"]

    expected_break_scanner_line = if lane == "core", do: 234, else: 230

    require_ownership!(
      Enum.any?(
        break_input.sink_facts,
        &(&1.kind == :token_scanner and &1.line == expected_break_scanner_line)
      ) and
        String.contains?(break_input.guard_remedy, "tokenization") and
        String.contains?(break_input.guard_remedy, "existing-atom") and
        String.contains?(break_input.guard_remedy, "whitelist") and
        String.contains?(break_input.defaults_and_options, "before matching") and
        String.contains?(break_wrapper.caller_input_origin, "check_input/2") and
        String.contains?(break_wrapper.caller_input_origin, "empty accumulator") and
        String.contains?(break_inputs.defaults_and_options, "C-Module") and
        String.contains?(break_inputs.defaults_and_options, "C-Function") and
        String.contains?(break_inputs.defaults_and_options, "before matching") and
        String.contains?(edit_route.guard_remedy, "int:meta") and
        String.contains?(edit_route.caller_input_origin, "Edit Variable") and
        String.contains?(edit_route.guard_remedy, "term-only") and
        String.contains?(edit_route.guard_remedy, "scanner boundary"),
      "lane #{lane} MFA dbg_wx_break_win:check_input/1,2 and dbg_wx_trace:gui_cmd/2 owner=#{@remainder_owner} caller-chain=local typed fields -> private token scanner; Edit Variable caller -> monitor-owned verifier -> assignment -> status-gated int:meta eval remedy=keep scanner/parser sink ownership with monitor and preserve term-only constrained assignment"
    )

    resize_note = source_functions["dbg_wx_trace_win:handle_event/2"]
    expected_resize_lines = if lane == "core", do: [734, 735, 736], else: [730, 731, 732]

    actual_resize_lines =
      resize_note.sink_facts
      |> Enum.filter(&(&1.kind == :dynamic_fun_call))
      |> Enum.filter(&(&1.line in expected_resize_lines))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    require_ownership!(
      actual_resize_lines == expected_resize_lines and
        String.contains?(
          resize_note.caller_input_origin,
          "fixed local Change and ChangeH closures"
        ) and
        String.contains?(resize_note.guard_remedy, "resolved benign local capability"),
      "lane #{lane} MFA dbg_wx_trace_win:handle_event/2 owner=#{@remainder_owner} caller-chain=local fixed Change closure definition -> three eval-sizer calls lines=#{inspect(actual_resize_lines)} remedy=classify Change and ChangeH calls as resolved benign local closures, not caller-selected dispatch"
    )

    code_style_note = source_functions["dbg_wx_code:code_area/1"]
    source_style_note = source_functions["dbg_wx_src_view:code_area/2"]
    trace_output_note = source_functions["dbg_wx_trace:meta_cmd/2"]

    require_ownership!(
      String.contains?(code_style_note.guard_remedy, "resolved benign local capability") and
        String.contains?(source_style_note.guard_remedy, "resolved benign local capability") and
        String.contains?(trace_output_note.caller_input_origin, "dbg_ieval:trace/3") and
        String.contains?(trace_output_note.caller_input_origin, "dbg_icmd:tell_attached/1") and
        String.contains?(trace_output_note.guard_remedy, "resolved cross-owner fixed callback"),
      "lane #{lane} owner=#{@remainder_owner} caller-chain=local SetStyle closures or prior-owner dbg_ieval:trace/3 -> dbg_icmd:tell_attached/1 -> dbg_wx_trace:meta_cmd/2 StrFun(P) remedy=retain exact closure origin and classify only the cited fixed functions as resolved capabilities"
    )

    callback_route = source_functions["dbg_wx_break:gui_cmd/2"]

    require_ownership!(
      String.contains?(callback_route.caller_input_origin, "conditional callback tuple") and
        String.contains?(callback_route.guard_remedy, "prior-owner") and
        String.contains?(callback_route.guard_remedy, "arity") and
        String.contains?(callback_route.guard_remedy, "membership"),
      "lane #{lane} MFA dbg_wx_break:gui_cmd/2 owner=#{@remainder_owner} caller-chain=local wx module text -> int:functions/1 or conditional callback tuple -> prior-owner break_p/4 remedy=check interpreted-module membership before atom construction/lookup and preserve prior-owner callback outcomes"
    )

    :ok
  end

  defp assert_monitor_dispositions!(modules, lane) do
    required_sinks = [
      {"dbg_wx_mon_win:handle_event/2", :atom_construction},
      {"dbg_wx_mon_win:clear_processes/2", :pid_parser},
      {"dbg_wx_filedialog_win:get_file_info/5", :dynamic_fun_call},
      {"dbg_wx_win:verify/2", :token_scanner},
      {"dbg_wx_win:verify/2", :term_parser}
    ]

    Enum.each(required_sinks, fn {mfa, kind} ->
      disposition = find_function_disposition!(modules, mfa, lane)

      require_ownership!(
        Enum.any?(disposition.sink_facts, &(&1.kind == kind)) and
          is_binary(disposition.guard_remedy) and disposition.guard_remedy != "",
        "lane #{lane} MFA #{mfa} owner=#{disposition.owner} caller-chain=exact source sink #{kind} remedy=retain its narrow input and dispatch disposition"
      )
    end)

    filter_note =
      find_function_disposition!(modules, "dbg_wx_filedialog_win:get_file_info/5", lane)

    parser_note = find_function_disposition!(modules, "dbg_wx_win:verify/2", lane)
    expected_scanner_line = if lane == "core", do: 279, else: 277
    expected_parser_line = if lane == "core", do: 281, else: 279

    scanner_lines =
      parser_note.sink_facts
      |> Enum.filter(&(&1.kind == :token_scanner))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    parser_lines =
      parser_note.sink_facts
      |> Enum.filter(&(&1.kind == :term_parser))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    require_ownership!(
      String.contains?(filter_note.guard_remedy, "whitelist the filter callback") and
        String.contains?(parser_note.guard_remedy, "parse-only") and
        scanner_lines == [expected_scanner_line] and
        parser_lines == [expected_parser_line],
      "lane #{lane} MFA dbg_wx_win:verify/2 owner=#{parser_note.owner} caller-chain=monitor-owned shared entry verifier has scanner line=#{inspect(scanner_lines)} parser line=#{inspect(parser_lines)} remedy=preserve monitor ownership and parse-only term grammar while preventing scanner atom creation before parsing"
    )

    :ok
  end

  defp parse_source_forms!(path, lane, module) do
    source = File.read!(path)
    needs_wx_include = String.contains?(source, "-include_lib(\"wx/include/")

    wx_ebin = if needs_wx_include, do: exact_wx_ebin!(path, lane, module), else: nil
    wx_ebin_charlist = if wx_ebin, do: String.to_charlist(wx_ebin), else: nil
    wx_already_on_path = wx_ebin_charlist && wx_ebin_charlist in :code.get_path()

    if wx_ebin && not wx_already_on_path do
      require_ownership!(
        :code.add_patha(wx_ebin_charlist) == true,
        "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=exact wx include resolver remedy=add only the exact installed lane wx ebin path while parsing"
      )
    end

    try do
      case :epp.parse_file(String.to_charlist(path), []) do
        {:ok, forms} ->
          errors = Enum.filter(forms, &match?({:error, _}, &1))

          require_ownership!(
            errors == [],
            "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} source_path=#{path} caller-chain=EPP include or macro errors=#{inspect(errors)} remedy=resolve exact installed include files and reject partial source parses"
          )

          forms

        {:error, reason} ->
          ownership_fail!(
            "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=installed exact source parse=#{inspect(reason)} remedy=restore a parseable source file from the adopted lane"
          )
      end
    after
      if wx_ebin && not wx_already_on_path do
        :code.del_path(wx_ebin_charlist)
      end
    end
  end

  defp exact_wx_ebin!(source_path, lane, module) do
    lib_root = source_path |> Path.dirname() |> Path.dirname() |> Path.dirname()
    candidates = Path.wildcard(Path.join([lib_root, "wx-*", "ebin"])) |> Enum.filter(&File.dir?/1)

    require_ownership!(
      length(candidates) == 1,
      "lane #{lane} app debugger module #{module} owner=#{@remainder_owner} caller-chain=exact sibling wx installation candidates=#{inspect(candidates)} remedy=resolve the single wx app belonging to this installed OTP lane"
    )

    Path.expand(hd(candidates))
  end

  defp source_citation!(source_row, lines, line, lane, mfa) do
    source_line = Enum.at(lines, line - 1)

    require_ownership!(
      line > 0 and is_binary(source_line) and String.trim(source_line) != "",
      "lane #{lane} MFA #{mfa} owner=#{@remainder_owner} caller-chain=installed source line #{source_row["source_path"]}:#{inspect(line)} remedy=restore the exact source clause or export line"
    )

    %{
      path: source_row["source_path"],
      line: line,
      expected_text: String.trim(source_line),
      sha256: source_row["sha256"]
    }
  end

  defp source_call_facts({:call, anno, {:atom, _fun_anno, function}, args} = form, acc) do
    fact = source_local_call_fact(function, args, :erl_anno.line(anno), form)
    acc = if fact, do: [fact | acc], else: acc
    Enum.reduce(args, acc, &source_call_facts/2)
  end

  defp source_call_facts({:call, anno, {:var, _fun_anno, _function} = callee, args}, acc) do
    fact = %{
      line: :erl_anno.line(anno),
      kind: :dynamic_fun_call,
      arity: length(args),
      expression: inspect({:call, anno, callee, args}, limit: 12, printable_limit: 240)
    }

    [fact | Enum.reduce([callee | args], acc, &source_call_facts/2)]
  end

  defp source_call_facts(
         {:call, anno, {:remote, _remote_anno, module_expr, function_expr}, args} = form,
         acc
       ) do
    fact = source_remote_call_fact(module_expr, function_expr, args, :erl_anno.line(anno), form)
    acc = if fact, do: [fact | acc], else: acc

    Enum.reduce([module_expr, function_expr | args], acc, &source_call_facts/2)
  end

  defp source_call_facts(term, acc) when is_list(term),
    do: Enum.reduce(term, acc, &source_call_facts/2)

  defp source_call_facts(term, acc) when is_tuple(term),
    do: term |> Tuple.to_list() |> Enum.reduce(acc, &source_call_facts/2)

  defp source_call_facts(_term, acc), do: acc

  defp source_local_call_fact(function, args, line, form) do
    kind =
      case {function, length(args)} do
        {:apply, arity} when arity in [2, 3] -> :dynamic_apply
        {:spawn, 3} -> :dynamic_spawn
        {:spawn_link, 3} -> :dynamic_spawn
        {:list_to_atom, 1} -> :atom_construction
        {:list_to_pid, 1} -> :pid_parser
        {:binary_to_term, 1} -> :term_decoder
        {:binary_to_term, 2} -> :term_decoder
        _ -> nil
      end

    if kind do
      %{line: line, kind: kind, expression: inspect(form, limit: 12, printable_limit: 240)}
    end
  end

  defp source_remote_call_fact({:atom, _, module}, {:atom, _, function}, args, line, form) do
    kind =
      case {module, function} do
        {:erl_scan, :string} -> :token_scanner
        {:code, :load_binary} -> :code_loader
        {:code, :purge} -> :code_purge
        {:erts_debug, :breakpoint} -> :runtime_breakpoint_control
        {:erl_eval, :extended_parse_term} -> :term_parser
        {:erl_eval, _} -> :expression_parser_or_evaluator
        {:erlang, :list_to_atom} -> :atom_construction
        {:erlang, :list_to_pid} -> :pid_parser
        {:erlang, :apply} -> :dynamic_apply
        {:erlang, :trace} -> :process_trace_control
        _ -> nil
      end

    if kind do
      %{
        line: line,
        kind: kind,
        module: Atom.to_string(module),
        function: Atom.to_string(function),
        arity: length(args),
        expression: inspect(form, limit: 12, printable_limit: 240)
      }
    end
  end

  defp source_remote_call_fact(_module_expr, _function_expr, args, line, form) do
    %{
      line: line,
      kind: :dynamic_remote_dispatch,
      arity: length(args),
      expression: inspect(form, limit: 12, printable_limit: 240)
    }
  end

  defp reachable_mfas(root_mfa, adjacency) do
    do_reachable_mfas(:queue.in(root_mfa, :queue.new()), MapSet.new(), adjacency)
  end

  defp do_reachable_mfas(queue, visited, adjacency) do
    case :queue.out(queue) do
      {{:value, mfa}, rest} ->
        if MapSet.member?(visited, mfa) do
          do_reachable_mfas(rest, visited, adjacency)
        else
          next = Map.get(adjacency, mfa, [])
          queue = Enum.reduce(next, rest, &:queue.in/2)
          do_reachable_mfas(queue, MapSet.put(visited, mfa), adjacency)
        end

      {:empty, _queue} ->
        visited
    end
  end

  defp identity_mfa!(link, lane) do
    identity = link["identity"]

    require_ownership!(
      is_map(identity) and is_binary(identity["module"]) and is_binary(identity["function"]) and
        is_integer(identity["arity"]),
      "lane #{lane} owner=#{link["owner"]} caller-chain=canonical/observed root identity is incomplete remedy=restore the exact root MFA"
    )

    identity_text(identity)
  end

  defp chain_link_record(link) do
    %{
      namespace: link["namespace"],
      identity: identity_text(link["identity"]),
      owner: link["owner"],
      origin_owner: link["origin_owner"],
      canonical_chain_id: link["canonical_chain_id"],
      observed_chain_id: link["observed_chain_id"],
      completion: link["completion"],
      route_changed: get_in(link, ["evidence", "route_changed"]) == true
    }
  end

  defp identity_text(identity),
    do: "#{identity["module"]}:#{identity["function"]}/#{identity["arity"]}"

  defp disposition_owner({:dbg_wx_mon, function, 2}, source_row)
       when function in [:start, :load_settings, :load_settings2] do
    %{
      owner: @owner,
      origin_owner: source_row["owner"],
      completion: :pending_cross_owner
    }
  end

  defp disposition_owner({:dbg_icmd, :break_p, 4}, source_row) do
    %{
      owner: @owner,
      origin_owner: source_row["owner"],
      completion: :pending_cross_owner
    }
  end

  defp disposition_owner(_mfa, source_row) do
    %{
      owner: @remainder_owner,
      origin_owner: source_row["owner"],
      completion: :source_disposed_static
    }
  end

  defp callback_route_note({:int, :auto_attach, 2}) do
    %{
      caller_input_origin:
        "The public setter accepts false, an empty flag list, a two-element callback tuple, or a three-element callback tuple; Plan01's saved-settings loader is a separate earlier-owner caller.",
      defaults_and_options:
        "Two-element callback tuple supplies []; three-element tuple requires atom module/function and list args; accepted flags are init, break, and exit; an empty list disables the stored callback.",
      guard_remedy:
        "The setter validates callback atom/list shape and flags but not target export or arity. Keep this exact setter under the narrow static guard and validate a stored target before dynamic dispatch if callback attachment is permitted."
    }
  end

  defp callback_route_note({:dbg_iserver, :auto_attach, 3}) do
    %{
      caller_input_origin:
        "The function reads the callback tuple from server state and receives the current event plus process identity from init, break, or exit handling.",
      defaults_and_options:
        "false disables dispatch; already-attached PIDs and non-matching event flags are ignored; matching events pass [Pid | Args] to spawn/3.",
      guard_remedy:
        "The exact dynamic spawn target remains unresolved. A narrow follow-up must validate the stored module/function and the resulting argument arity at this dispatch point, or retain the caller's exact int:auto_attach/2 guard."
    }
  end

  defp callback_route_note({:int, :test_at_break, 3}) do
    %{
      caller_input_origin:
        "The caller chooses module, line, and a one-argument condition callback tuple; the setter forwards the tuple to dbg_iserver after check_function/1.",
      defaults_and_options:
        "Module and line are checked as atom and integer; check_function/1 only checks that callback module and function are atoms.",
      guard_remedy:
        "The selected callback target is later invoked dynamically by the prior-owner dbg_icmd:break_p/4 body. Preserve that body owner; if callback setting is allowed, validate target module/function and arity at this setter or guard the exact int:test_at_break/3 entry."
    }
  end

  defp callback_route_note({:debugger, :quick, 3}) do
    %{
      caller_input_origin:
        "The caller supplies module, function, and argument list directly to debugger:quick/3.",
      defaults_and_options:
        "No target restriction is present in this wrapper; it interprets the module, enables init auto-attach, then applies the supplied MFA.",
      guard_remedy:
        "Keep the exact debugger:quick/3 arbitrary-apply entry under a narrow static guard unless a separately reviewed caller policy constrains the target."
    }
  end

  defp callback_route_note({:int, :eval, 3}) do
    %{
      caller_input_origin:
        "The caller supplies the interpreted module, function, and arguments to the debugger process evaluator.",
      defaults_and_options:
        "This wrapper delegates directly to dbg_debugged:eval/3; it performs no local target validation.",
      guard_remedy:
        "Keep the exact int:eval/3 interpreter entry under the narrow static guard until its downstream dbg_debugged evaluator route has an approved constraint."
    }
  end

  defp callback_route_note({:int, :load, 2}) do
    %{
      caller_input_origin:
        "The caller supplies compiled module identity, source/beam paths, beam bytes, exports, and abstract code for interpreter loading.",
      defaults_and_options:
        "The implementation purges and loads the supplied binary, then extracts source metadata; exact lane clauses determine distribution and error handling.",
      guard_remedy:
        "Keep the exact int:load/2 code-loading entry guarded; any later relaxation needs a narrow allow-list for module identity, source origin, and the loaded beam rather than a debugger-module exemption."
    }
  end

  defp callback_route_note({:dbg_ieval, :eval, 3}) do
    %{
      caller_input_origin:
        "The error-handler route reaches int:eval/3, which delegates to dbg_debugged:eval/3; the module, function, and argument list remain caller-selected interpreter inputs. An existing Meta receives re_entry, while an uninterpreted process starts meta/5.",
      defaults_and_options:
        "There is no target default: the same MFA tuple enters the existing Meta or the spawned evaluator according to dbg_iserver:get_meta/1.",
      guard_remedy:
        "Retain the narrow int:eval/3 interpreter entry guard and the existing command-eval guard. Before relaxing either, constrain the target MFA and all downstream dynamic apply routes; do not exempt the debugger module family."
    }
  end

  defp callback_route_note({:dbg_ieval, :meta, 5}) do
    %{
      caller_input_origin:
        "meta/5 receives Int, Debugged, M, F, and As from dbg_ieval:eval/3's not_interpreted branch; it sends the initial eval_mfa/5 result to the debugged process and starts the Meta loop.",
      defaults_and_options:
        "The supplied module/function/arguments are retained, with a display-only rewrite for interpreted fun entry points; the Meta initializes status and per-process interpreter state before evaluation.",
      guard_remedy:
        "Keep the int:eval/3 entry under its exact static guard; constrain any change at the entry and when an uninterpreted target is returned for application."
    }
  end

  defp callback_route_note({:dbg_ieval, :do_eval_function, 6}) do
    %{
      caller_input_origin:
        "eval_mfa/5 and nested eval_function/7 pass module/function/arguments, or an interpreted fun and its arguments; get_function/4 distinguishes interpreted definitions from not_interpreted targets.",
      defaults_and_options:
        "Top-level not_interpreted calls are returned as dbg_apply; nested calls send an apply command to the debugged process. Interpreted clauses stay in fnk_clauses/4, and missing functions take the explicit undef path.",
      guard_remedy:
        "Keep the exact evaluator entry guarded and restrict not_interpreted targets at this dispatch boundary before returning dbg_apply or sending apply to the debugged process."
    }
  end

  defp callback_route_note({:dbg_ieval, :get_function, 4}) do
    %{
      caller_input_origin:
        "do_eval_function/6 supplies module, function, arguments and local/extern mode. The database stores interpreted clauses and export state; a missing module yields not_interpreted, while an interpreted module with no matching export yields undef.",
      defaults_and_options:
        "Local lookup uses match_object/2; external lookup requires the stored export flag true; cache hits preserve the recorded export bit.",
      guard_remedy:
        "Retain the current exact evaluator-entry guard. Before permitting external fallback, validate module, function, arity, and export status at the not_interpreted dispatch boundary."
    }
  end

  defp callback_route_note({:dbg_ieval, :expr, 3}) do
    %{
      caller_input_origin:
        "Expression forms originate in interpreted abstract code or the command expression supplied through dbg_icmd:eval/2. Remote-call, apply-fun, apply/3, safe-BIF, and operator clauses evaluate their embedded module/function/value inputs.",
      defaults_and_options:
        "The AST tags select distinct local, remote, fun, module/function, safe-BIF, and debugged-process dispatch paths; bad fun and invalid arity branches raise interpreter exceptions.",
      guard_remedy:
        "Retain the exact int:eval/3 and command-eval guards. Before relaxing them, apply a narrow MFA policy to remote/apply dispatch and an explicit safe-BIF allow-list at the safe_bif and guard_expr apply sites."
    }
  end

  defp callback_route_note({:dbg_ieval, :safe_bif, 5}) do
    %{
      caller_input_origin:
        "expr/3 supplies module, function, evaluated arguments, bindings and interpreter state from a safe_bif AST node; the helper dynamically applies that module/function tuple.",
      defaults_and_options:
        "Successful calls return the value with existing bindings; exceptions are captured and routed through the interpreter exception formatter.",
      guard_remedy:
        "Keep the exact evaluator entry guard and require the AST producer's safe-BIF classification to match a narrow allowed MFA set before apply/3; the helper itself does not revalidate the target."
    }
  end

  defp callback_route_note({:dbg_ieval, :catch_clauses, 4}) do
    %{
      caller_input_origin:
        "When all interpreted catch clauses fail to match, catch_clauses/4 receives Class and Reason from the exception produced by the interpreted path and calls erlang:Class(Reason) using a variable function name.",
      defaults_and_options:
        "Matching catch clauses take the ordinary interpreted sequence path; only the exhausted catch list reaches this dynamic exception dispatch.",
      guard_remedy:
        "Keep the exact interpreter-entry guard. If this helper is ever relaxed, constrain Class to the documented error, exit, or throw exception kinds before the dynamic erlang call."
    }
  end

  defp callback_route_note({:dbg_ieval, :do_exception, 5}) do
    %{
      caller_input_origin:
        "exception/4,5 and the catch/evaluator branches supply Class and Reason from an interpreted exception; do_exception/5 installs the deferred stack and exit-info state before calling erlang:Class(Reason).",
      defaults_and_options:
        "The caller selects whether the deferred stack includes arguments; both variants converge on the same dynamic exception-class call.",
      guard_remedy:
        "Keep the exact interpreter-entry guard. If this path is relaxed, constrain Class to error, exit, or throw before the variable erlang function call."
    }
  end

  defp callback_route_note({:dbg_ieval, :meta_loop, 3}) do
    %{
      caller_input_origin:
        "meta_loop/3 receives protocol messages whose sender field must match its Debugged pid; an exception tuple supplies Class, Reason, and stack data. When exit_info shows a re-entry, the loop calls erlang:Class(Reason).",
      defaults_and_options:
        "An exception outside interpreted re-entry passes through do_exception/5; an in-reentry exception takes the direct dynamic class call branch.",
      guard_remedy:
        "Keep the exact interpreter entry guard and constrain exception Class to error, exit, or throw before dispatch; the Meta pid match alone does not validate that function atom."
    }
  end

  defp callback_route_note({:dbg_ieval, :guard_expr, 2}) do
    %{
      caller_input_origin:
        "guard_expr/2 receives transformed guard AST from the interpreted expression evaluator; the general safe_bif guard clause applies its embedded module/function and evaluated arguments.",
      defaults_and_options:
        "The special erlang:not clause is separate; the general safe_bif clause returns its applied value to guard evaluation.",
      guard_remedy:
        "Keep the evaluator entry guard and preserve a narrow safe-BIF allow-list at the loader/compiler classification boundary and this apply site."
    }
  end

  defp callback_route_note({:dbg_debugged, :msg_loop, 2}) do
    %{
      caller_input_origin:
        "dbg_debugged:eval/3 monitors the Meta pid returned by dbg_ieval:eval/3 and msg_loop/2 matches protocol messages from that selected Meta; ready values may carry a dbg_apply tuple and command messages dispatch through handle_command/1.",
      defaults_and_options:
        "A ready value is returned directly unless it is dbg_apply; exception and DOWN replies terminate the loop, while receive and command messages recurse after acknowledgement/reply.",
      guard_remedy:
        "Retain the exact interpreter-entry guards. Before relaxing them, validate the target in dbg_apply values at this process bridge and keep command evaluation restricted to Meta-generated protocol messages."
    }
  end

  defp callback_route_note({:dbg_debugged, :handle_command, 1}) do
    %{
      caller_input_origin:
        "msg_loop/2 forwards the command field from a matching {sys, Meta, {command, Command}} protocol message.",
      defaults_and_options:
        "reply/1 exceptions are caught and converted to a structured exception reply with the debugged-process stacktrace tail removed.",
      guard_remedy:
        "Keep command construction on the exact interpreter route; do not treat this wrapper as a parser-only path because reply/1 applies commands and calls erl_eval:expr/2."
    }
  end

  defp callback_route_note({:dbg_debugged, :reply, 1}) do
    %{
      caller_input_origin:
        "handle_command/1 receives apply or eval commands from dbg_ieval's debugged_cmd protocol; the apply tuple names module/function/arguments and the eval tuple carries an expression plus bindings.",
      defaults_and_options:
        "The apply form calls erlang:apply/3; the eval form calls erl_eval:expr/2 with sorted bindings.",
      guard_remedy:
        "Retain exact interpreter-entry guards and require a narrow target policy before accepting apply commands; keep the eval form limited to the reviewed command path."
    }
  end

  defp callback_route_note({:dbg_iload, :load_mod, 4}) do
    %{
      caller_input_origin:
        "dbg_iserver:handle_call({load,...}) supplies module, source path, serialized envelope, and the module database after int:load/2 constructs the package.",
      defaults_and_options:
        "The loader starts a linked worker closure, waits for that worker's exit message, restores trap_exit, and returns its result synchronously.",
      guard_remedy:
        "Keep the exact int:load/2 caller path guarded and validate source/beam/module correspondence and package provenance before the serialized envelope reaches this loader."
    }
  end

  defp callback_route_note({:dbg_iload, :store_module, 4}) do
    %{
      caller_input_origin:
        "int:load/2 builds {interpreter_module, Exp, Abst, SrcBin, MD5} from caller-selected source/BEAM inputs, then dbg_iserver:handle_call/3 forwards the envelope to dbg_iload:load_mod/4.",
      defaults_and_options:
        "binary_to_term/1 decodes the envelope and abstr/1 decodes binary abstract code; the floor lane also rejects two older abstract-code tags before storing forms.",
      guard_remedy:
        "Retain the exact int:load/2 guard and validate caller provenance, module identity, source/beam pairing, envelope shape, and abstract-code version before either term decode; do not infer safety from the tuple tag."
    }
  end

  defp callback_route_note({:dbg_iload, :abstr, 1}) do
    %{
      caller_input_origin:
        "store_module/4 passes the abstract-code field from the int:load/2 package; this helper calls binary_to_term/1 for binary input and passes through an already-decoded term.",
      defaults_and_options:
        "Binary and term inputs take separate clauses; the floor lane's caller then handles legacy abstract-code tags as too_old_beam_file.",
      guard_remedy:
        "Keep the exact package-origin guard before this helper and validate abstract-code provenance and accepted version at the package boundary."
    }
  end

  defp callback_route_note({:dbg_iserver, :handle_call, 3}) do
    %{
      caller_input_origin:
        "The load request is sent by int:load/2 after it has prepared module, source path, and the interpreter envelope; handle_call/3 creates the module database and forwards those values to dbg_iload:load_mod/4.",
      defaults_and_options:
        "The server waits for the synchronous loader result before broadcasting that the module is interpreted.",
      guard_remedy:
        "Keep the exact int:load/2 source/beam policy at this caller route and preserve envelope validation at dbg_iload:store_module/4."
    }
  end

  defp callback_route_note({:i, :ipb, 1}) do
    %{
      caller_input_origin:
        "The shell helper accepts either an existing module atom or a caller-provided character list.",
      defaults_and_options:
        "Atom input passes through; list input is converted with list_to_atom/1 before breakpoint lookup.",
      guard_remedy:
        "Use existing-atom resolution for caller-provided module text, or keep the exact i:ipb/1 route constrained by the shell's approved input policy."
    }
  end

  defp callback_route_note({:i, :iv, 0}) do
    %{
      caller_input_origin:
        "The version atom is built from the installed debugger library directory, not from caller text.",
      defaults_and_options:
        "string:slice/2 and filename:basename/1 feed list_to_atom/1 from the installed app path.",
      guard_remedy:
        "The atom input is path-derived and fixed by the selected installed application; retain exact source provenance and do not treat this as the caller-controlled i:ipb/1 conversion."
    }
  end

  defp callback_route_note({:dbg_icmd, :eval, 2}) do
    %{
      caller_input_origin:
        "A command and interpreted module are supplied by the attached-process command path and are forwarded as an eval message.",
      defaults_and_options:
        "A two-element command tuple defaults stack-position to nostack; a three-element tuple preserves the supplied stack-position.",
      guard_remedy:
        "Keep the exact dbg_icmd:eval/2 expression-evaluation entry guarded; parsing alone is not execution, and the subsequent dbg_ieval path is handled in Plan02-02."
    }
  end

  defp callback_route_note({:dbg_icmd, :parse_cmd, 2}) do
    %{
      caller_input_origin:
        "The caller provides command text and a source line to erl_scan and the expression parser.",
      defaults_and_options:
        "This function returns parsed forms; it does not itself evaluate them.",
      guard_remedy:
        "Keep command parsing connected only to the already guarded eval path; do not claim parse_cmd/2 is a standalone execution sink."
    }
  end

  defp callback_route_note({:dbg_icmd, :break_p, 4}) do
    %{
      caller_input_origin:
        "The command path supplies module, line, and stack/binding state to the prior-owner condition-checking body.",
      defaults_and_options:
        "The active breakpoint, recursion suppression, condition result, callback exception, and action outcomes remain the earlier child's pending source obligation.",
      guard_remedy:
        "Do not claim or reassign this body. Keep 01.1.1.3.1.1 as owner until its exact callback-body and outcome evidence is completed."
    }
  end

  defp callback_route_note({:dbg_wx_mon, :start, 2}) do
    %{
      caller_input_origin:
        "The caller supplies monitor mode and either a selected settings path or the default sentinel; this root remains assigned to 01.1.1.3.1.1.",
      defaults_and_options:
        "Default startup and selected-file startup converge through init/3; the current route delta is retained as a pending changed-route observation.",
      guard_remedy:
        "Preserve the earlier child's exact start/2 route decision and pending guard obligation; this whole-module review does not complete or transfer the selected root."
    }
  end

  defp callback_route_note({:dbg_wx_mon, function, 2})
       when function in [:load_settings, :load_settings2] do
    %{
      caller_input_origin:
        "The selected root is part of the preceding saved-settings slice; its exact caller and canonical/observed chains are retained in this record.",
      defaults_and_options:
        "The selected load/replay branches remain owned by 01.1.1.3.1.1, including the cross-owner trace-window selections.",
      guard_remedy:
        "Keep this prior-owner body and branch obligation pending under 01.1.1.3.1.1; do not treat the broad module review as completion."
    }
  end

  defp callback_route_note({:dbg_wx_mon, :init, 3}) do
    %{
      caller_input_origin:
        "start/2 supplies mode and selected/default settings path; init/3 opens wx and catches the graphics-startup result before constructing the monitor.",
      defaults_and_options:
        "The exact startup branches distinguish graphics initialization error, successful wx startup, ignored exit:stop, and reported init2 exceptions.",
      guard_remedy:
        "Keep the startup error and stop cases explicit at init/3; do not convert setup failures into a successful monitor state."
    }
  end

  defp callback_route_note({:dbg_wx_mon, :init2, 4}) do
    %{
      caller_input_origin:
        "init/3 passes the selected/default settings path, mode and graphics state to init2/4.",
      defaults_and_options:
        "The default sentinel skips replay and enters loop/1; a non-default path calls the prior-owner load_settings/2 before entering the loop.",
      guard_remedy:
        "Preserve the default-versus-selected-path branch and keep selected replay responsibility with 01.1.1.3.1.1."
    }
  end

  defp callback_route_note({:dbg_wx_mon, :gui_cmd, 2}) do
    %{
      caller_input_origin:
        "The monitor event loop supplies the selected menu command and current monitor state.",
      defaults_and_options:
        "Load Settings cancel preserves the state; a selected path forwards to the prior-owner load_settings/2 root. Other menu commands retain their exact command clauses.",
      guard_remedy:
        "Keep the cancel and selected-path cases distinct, and preserve the earlier owner's selected-root body."
    }
  end

  defp callback_route_note({:dbg_wx_mon_win, :handle_event, 2}) do
    %{
      caller_input_origin:
        "wx events provide shortcut key codes, displayed module text, and checkbox labels; module/list values are converted into atoms before monitor commands are emitted.",
      defaults_and_options:
        "Shortcut, double-click, right-click, auto-attach and string checkbox branches have separate event shapes; checkbox labels are UI text, not an atom allow-list.",
      guard_remedy:
        "Replace list_to_atom on event and displayed module strings with fixed mappings or existing-atom/module-membership resolution; keep the exact event branches guarded until each conversion is constrained."
    }
  end

  defp callback_route_note({:dbg_wx_mon_win, :clear_processes, 2}) do
    %{
      caller_input_origin:
        "The monitor's process grid supplies a displayed PID string for rows marked exit; the function parses that text before clearing the matching trace window.",
      defaults_and_options:
        "Only exit rows take the PID conversion path; non-exit rows are ignored and missing rows terminate the recursive clear.",
      guard_remedy:
        "Use the PID already stored with the row, or validate that the displayed identifier is an exact PID produced by the monitor before list_to_pid/1."
    }
  end

  defp callback_route_note({:dbg_wx_filedialog_win, :new, 3}) do
    %{
      caller_input_origin:
        "The dialog caller supplies options including an optional filter callback; the current sole caller in dbg_wx_interpret passes its fixed local filter_files/2 callback.",
      defaults_and_options:
        "Dialog init defaults directory to file:get_cwd/0, filter to file_type_and_icon/2 and sort to name when options are absent.",
      guard_remedy:
        "Keep the exact caller callback identity at this boundary or accept only the fixed supported filter before relaxing the dialog's callback path."
    }
  end

  defp callback_route_note({:dbg_wx_filedialog_win, :init, 1}) do
    %{
      caller_input_origin:
        "new/3 passes caller options to init/1; defaultDir, filter and sort are read from that option list.",
      defaults_and_options:
        "The directory defaults to the current working directory, filter to the fixed file_type_and_icon/2 function, and sort to name.",
      guard_remedy:
        "Constrain option producers to the reviewed caller and preserve the fixed filter default; do not infer callback safety merely from the default."
    }
  end

  defp callback_route_note({:dbg_wx_filedialog_win, :get_file_info, 5}) do
    %{
      caller_input_origin:
        "Directory listing supplies file names and the stored Filter value; Filter(Dir,Name) is a dynamic function call whose current caller supplies a fixed local callback.",
      defaults_and_options:
        "Directory entries bypass the file filter, ordinary files accept {Type,Icon,Color}, and skip omits an entry.",
      guard_remedy:
        "Validate or whitelist the filter callback at new/3/init/1 and retain the exact current fixed callback identity before permitting any other filter."
    }
  end

  defp callback_route_note({:dbg_wx_filedialog_win, :handle_event, 2}) do
    %{
      caller_input_origin:
        "The user-facing dialog supplies navigation, typed names and the OK/cancel choice; OK returns the selected path while cancel returns without a path.",
      defaults_and_options:
        "Cancel and selected-path outcomes are explicit; navigation and completion events update displayed path state.",
      guard_remedy:
        "Treat the selected path as caller-controlled input at its consuming interpreter route; the file picker only proves selection and cancellation behavior."
    }
  end

  defp callback_route_note({:dbg_wx_win, :verify, 2}) do
    %{
      caller_input_origin:
        "The local debugger Backtrace Size menu supplies an integer-typed value, while the trace window's Edit Variable control supplies a term-typed value; the latter is formatted into Var= Term and forwarded to int:meta(..., eval, Arg) on break, wait_break, or wait_running statuses.",
      defaults_and_options:
        "Backtrace Size uses the non-term clause, which accepts one matching integer token; Edit Variable uses erl_scan:string/3 then erl_eval:extended_parse_term/1 and returns a parsed term or ignores syntax errors. verify/2 does not evaluate an arbitrary expression, but erl_scan interns ordinary and quoted atom tokens from local UI text before either type check or term parse.",
      guard_remedy:
        "Keep verify/2 parse-only and preserve the term-only grammar and parsed variable-assignment route. Put a tokenizer/parser boundary before term construction that cannot intern arbitrary UI text atoms, or explicitly reject/limit term editing; list_to_existing_atom/1 after erl_scan:string/3 is too late. Apply input-size and token-count limits only as defense-in-depth. This is a local debugger UI input boundary, not a claim of remote reachability."
    }
  end

  defp callback_route_note({:dbg_wx_trace, :gui_cmd, 2}) do
    %{
      caller_input_origin:
        "The Backtrace Size menu passes {integer,Val} to dbg_wx_win:entry/4. Edit Variable passes {term,Val}, then formats the parsed result as Var= Term. Separately, evaluator command text from the local trace window enters the general user_command route.",
      defaults_and_options:
        "The Edit Variable assignment and general typed evaluator command both reach int:meta(..., eval, Arg) only in break, wait_break, or wait_running states; other statuses display Commands not allowed.",
      guard_remedy:
        "Keep general command evaluation behind the existing debugger status gate and exact local interactive path into int:meta(..., eval, ...). Preserve the separate term-only Edit Variable grammar and the non-atom-creating scanner boundary described for dbg_wx_win:verify/2; the Backtrace Size path remains integer-token-only after scanning."
    }
  end

  defp callback_route_note({:dbg_wx_trace, :meta_cmd, 2}) do
    %{
      caller_input_origin:
        "The trace_output message carries StrFun from prior-owner dbg_ieval:trace/3, which constructs it as a fixed fun over What and Args; dbg_icmd:tell_attached/1 transports that message to the attached-process route, and meta_cmd/2 invokes the formatter with the current process pid.",
      defaults_and_options:
        "The dynamic call is a fixed cross-owner formatter closure with local debugger-owned input. It formats trace output for display and is not an externally supplied or caller-selected function target.",
      guard_remedy:
        "Preserve the prior interpreter owner for closure construction, cite the exact message route into this GUI call, and classify StrFun(P) as a resolved cross-owner fixed callback; do not treat it as arbitrary dynamic dispatch or a runtime safety proof."
    }
  end

  defp callback_route_note({:dbg_wx_code, :code_area, 1}) do
    %{
      caller_input_origin:
        "code_area/1 builds a fixed syntax-style list and local SetStyle closure over its editor and font handles.",
      defaults_and_options:
        "The closure is called only for entries in that fixed local style list and invokes fixed styled-text font/color setters.",
      guard_remedy:
        "Classify the SetStyle calls as a resolved benign local capability; do not widen them to caller-selected dynamic dispatch."
    }
  end

  defp callback_route_note({:dbg_wx_src_view, :code_area, 2}) do
    %{
      caller_input_origin:
        "code_area/1 builds a fixed syntax-style list and local SetStyle closure over its editor and font handles.",
      defaults_and_options:
        "The closure is called only for entries in that fixed local style list and invokes fixed styled-text font/color setters.",
      guard_remedy:
        "Classify the SetStyle calls as a resolved benign local capability; do not widen them to caller-selected dynamic dispatch."
    }
  end

  defp callback_route_note({:dbg_wx_break, :gui_cmd, 2}) do
    %{
      caller_input_origin:
        "The local break dialog supplies user-controlled module text, selected function/line data, action, and an optional conditional callback tuple; module selection reaches int:functions/1 without an explicit interpreted-module membership check.",
      defaults_and_options:
        "Line breaks add the breakpoint and action; conditional breaks also call int:test_at_break/3 with {CMod,CFunc}; function breaks call int:break_in/3. The called dbg_icmd:break_p/4 body and outcomes remain assigned to the prior owner.",
      guard_remedy:
        "Check local module text against the current interpreted-module membership before atom construction or int:functions/1 lookup, then resolve only to an existing atom. Keep the callback body and outcomes with prior-owner dbg_icmd:break_p/4; before relaxing the setter or exact entry guard, validate the callback module/function export and arity at the existing setting boundary."
    }
  end

  defp callback_route_note({:dbg_wx_break_win, :handle_event, 2}) do
    %{
      caller_input_origin:
        "The local debugger break dialog supplies module text from wxComboBox:getValue/1, function selections, typed fields, and OK/cancel events; user-controlled module text is converted with list_to_atom/1 on edit and submit routes.",
      defaults_and_options:
        "Cancel stops the dialog; function selection uses the displayed function list; other accepted values come from check_input/1 token-type matches before a break command tuple is returned.",
      guard_remedy:
        "Map displayed module names to existing atoms from the current supported module set before any conversion. Do not create atoms from editable text; preserve the selected function and typed-input constraints."
    }
  end

  defp callback_route_note({:dbg_wx_break_win, :create_win, 5}) do
    %{
      caller_input_origin:
        "The local debugger creates one editable Line field for line breaks; conditional breakpoints add editable C-Module and C-Function fields.",
      defaults_and_options:
        "create_win/5 configures Line as integer and C-Module/C-Function as atom tokens only for conditional breakpoints; check_input/1 delegates to check_input/2, which scans each wxTextCtrl value before matching its configured token type.",
      guard_remedy:
        "Preserve the line/conditional field distinction and term grammar, but tokenize wxTextCtrl text without interning atoms before type validation; resolve atom spellings only through an explicit existing module/callback allowlist. Do not claim remote reachability; input and token limits are defense-in-depth."
    }
  end

  defp callback_route_note({:dbg_wx_break_win, :check_input, 1}) do
    %{
      caller_input_origin:
        "check_input/1 initializes an empty accumulator and delegates the configured dialog fields to check_input/2.",
      defaults_and_options:
        "The wrapper adds no parsing or atom conversion of its own; the recursive check_input/2 branch handles each typed field.",
      guard_remedy:
        "Keep the wrapper connected only to the reviewed typed-field parser, and preserve its exact field accumulator behavior."
    }
  end

  defp callback_route_note({:dbg_wx_break_win, :check_input, 2}) do
    %{
      caller_input_origin:
        "check_input/2 reads user-controlled wxTextCtrl text in the local debugger UI and passes each field to erl_scan:string/1 before matching its configured token type.",
      defaults_and_options:
        "Only one token of each configured type is accepted; scanner errors or a mismatched token return error, but ordinary and quoted atom tokens can be interned before matching the configured type.",
      guard_remedy:
        "Replace atom-creating scanning at this local UI boundary with tokenization that retains atom spellings as text until a strict existing-atom/module/callback whitelist check succeeds. Preserve the current one-token type grammar; length and token-count caps are defense-in-depth."
    }
  end

  defp callback_route_note({:dbg_wx_trace_win, :handle_event, 2}) do
    %{
      caller_input_origin:
        "The trace-window keyboard handler turns a control key code into a one-character shortcut atom; sash resize clauses construct fixed local Change and ChangeH closures over their sizer geometry and call them at fixed child/sizer sites; other cases handle menu data, search text, evaluator command text, or binding selection.",
      defaults_and_options:
        "Invalid shortcut conversion is caught and ignored; Change and ChangeH capture no caller-supplied function and only resize local sizers; evaluator text is returned as a user_command for the trace controller, and binding activation returns the existing binding for Edit Variable.",
      guard_remedy:
        "Replace key-code list_to_atom/1 with an explicit mapping from supported shortcut key codes to fixed atoms; classify each Change and ChangeH call as a resolved benign local capability, not caller-selected dispatch; keep evaluator text on the existing status-gated debugger command route."
    }
  end

  defp callback_route_note({:dbg_wx_view, :gui_load_module, 2}) do
    %{
      caller_input_origin:
        "The module viewer receives its module atom from the existing debugger module/view route and requests raw_contents from dbg_iserver.",
      defaults_and_options:
        "A successful raw_contents reply is displayed as source; not_found switches to the no-code display. This is a read/display lookup, not source compilation or module loading.",
      guard_remedy:
        "Keep this route a fixed raw_contents read for the selected existing module; do not replace it with a code loader or infer safety for the upstream module-name conversion."
    }
  end

  defp callback_route_note({:dbg_wx_trace, :gui_load_module, 3}) do
    %{
      caller_input_origin:
        "The trace window's existing module state is used for a fixed raw_contents request to dbg_iserver.",
      defaults_and_options:
        "A successful reply is rendered in the source pane and not_found displays the no-code state; this route reads debugger database contents and does not load the selected source.",
      guard_remedy:
        "Retain the fixed raw_contents display lookup and keep module-name input constraints at the upstream caller boundary."
    }
  end

  defp callback_route_note(_mfa) do
    %{
      caller_input_origin:
        "See the exact source clause heads, current graph callers, and canonical/observed root links for this MFA.",
      defaults_and_options: nil,
      guard_remedy:
        "No function-specific guard conclusion is inferred from graph absence; retain exact source and direct-callee evidence for later tier review."
    }
  end

  defp callback_sink_disposition(mfa, sink_facts, guard_remedy) do
    %{
      source_static_only: true,
      operations: Enum.map(sink_facts, & &1.kind) |> Enum.uniq() |> Enum.sort(),
      caller_control: callback_route_note(mfa).caller_input_origin,
      narrow_remedy: guard_remedy,
      execution_performed: false
    }
  end

  defp function_owner!(modules, mfa_name) do
    modules
    |> Enum.flat_map(& &1.dispositions)
    |> Enum.find_value(fn disposition ->
      if disposition.mfa == mfa_name, do: disposition.owner
    end)
  end

  defp find_function_disposition!(modules, mfa_name, lane) do
    Enum.find_value(modules, fn module ->
      Enum.find(module.dispositions, &(&1.mfa == mfa_name))
    end)
    |> case do
      nil ->
        ownership_fail!(
          "lane #{lane} MFA #{mfa_name} owner=#{@owner} caller-chain=selected root source module remedy=retain its exact function disposition"
        )

      disposition ->
        disposition
    end
  end

  defp changed_route_for?(link, module, function, arity, lane) do
    identity = link["identity"] || %{}

    identity["lane"] == lane and identity["app"] == "debugger" and
      identity["module"] == Atom.to_string(module) and
      identity["function"] == Atom.to_string(function) and identity["arity"] == arity and
      get_in(link, ["evidence", "route_changed"]) == true
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
