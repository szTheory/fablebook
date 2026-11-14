# Phase 03 tracer crosswalk

One EX-010 row is joined across the pinned core and floor inventories. This is a tracer only; source join and aggregate closure remain open.

```json
{
  "collector": "guard-aggregate-tracer/1",
  "generation": "f804533b8f8a2b01cce20a8169751143a006a6d615ff4b2c3aa5172c62153ad3",
  "input_sha256": "f804533b8f8a2b01cce20a8169751143a006a6d615ff4b2c3aa5172c62153ad3",
  "lane_records": {
    "core": {
      "path": ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json",
      "sha256": "daca10cb5ac5f8cc9e97e0611eab90545c59b8fcfd2d966fd48356a244c955e7"
    },
    "floor": {
      "path": ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json",
      "sha256": "be23f1f9695af09f2da080fe41b6ae012e69a65e95871e2c87fede2d9f3ef2fd"
    }
  },
  "rows": [
    {
      "core": {
        "evidence": {
          "delegate_edges": [
            {
              "callee": [
                "inets_trace",
                "enable",
                2
              ],
              "caller": [
                "inets",
                "enable_trace",
                2
              ],
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:503",
                  "inets_trace:enable(Level, Dest)"
                ]
              ]
            },
            {
              "callee": [
                "inets_trace",
                "enable",
                3
              ],
              "caller": [
                "inets",
                "enable_trace",
                3
              ],
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:505",
                  "inets_trace:enable(Level, Dest, Service)"
                ]
              ]
            }
          ],
          "exact_sources": [
            [
              "inets/src/inets_app/inets.erl",
              18519,
              "18d0c8091e7c9ce34fad897734c1b4105fd8c19d0912da28a32856664c760f00"
            ],
            [
              "inets/src/inets_app/inets_trace.erl",
              11112,
              "1f67a0bda05227eddd8ffb4909ec8a31465ef2d8582e0ff9ff5d2b72638c7599"
            ],
            [
              "runtime_tools/src/dbg.erl",
              105185,
              "d996e990b75251edb65d4930a1edf5c1914f6c18f77ac526313157612f95f5f2"
            ]
          ],
          "lane": "core",
          "matched_mfas": [
            [
              "inets",
              "enable_trace",
              2
            ],
            [
              "inets",
              "enable_trace",
              3
            ]
          ],
          "remainder_mfas": [],
          "reviews": [
            {
              "bytes": 18519,
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:503",
                  "inets_trace:enable(Level, Dest)"
                ],
                [
                  "inets/src/inets_app/inets.erl:505",
                  "inets_trace:enable(Level, Dest, Service)"
                ]
              ],
              "finding": "Read the complete exact core module; the selected exports forward arguments directly to inets_trace.",
              "reviewed_lines": {
                "__struct__": "Elixir.Range",
                "first": 1,
                "last": 566,
                "step": 1
              },
              "sha256": "18d0c8091e7c9ce34fad897734c1b4105fd8c19d0912da28a32856664c760f00",
              "source_path": "inets/src/inets_app/inets.erl"
            },
            {
              "bytes": 11112,
              "citations": [
                [
                  "inets/src/inets_app/inets_trace.erl:69",
                  "valid_trace_service(Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:78",
                  "file:open(File, [write])"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:86",
                  "dbg:trace_port(ip, Port)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:90",
                  "is_function(Fun)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:153",
                  "DetailLevel"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:174",
                  "dbg:tp(MFA, Pattern)"
                ]
              ],
              "finding": "Read the complete exact core module; validated services and explicit destination clauses reach fixed trace setup or a caller-supplied handler.",
              "reviewed_lines": {
                "__struct__": "Elixir.Range",
                "first": 1,
                "last": 355,
                "step": 1
              },
              "sha256": "1f67a0bda05227eddd8ffb4909ec8a31465ef2d8582e0ff9ff5d2b72638c7599",
              "source_path": "inets/src/inets_app/inets_trace.erl"
            },
            {
              "bytes": 105185,
              "citations": [
                [
                  "runtime_tools/src/dbg.erl:1069",
                  "tracer(process, {Handler,HandlerData})"
                ],
                [
                  "runtime_tools/src/dbg.erl:1324",
                  "trace_ip_drv"
                ],
                [
                  "runtime_tools/src/dbg.erl:1341",
                  "open_port({spawn, L}, [eof])"
                ],
                [
                  "runtime_tools/src/dbg.erl:2030",
                  "invoke_handler(Traces, Handler, Hdata)"
                ],
                [
                  "runtime_tools/src/dbg.erl:2041",
                  "Handler(Tr, Hdata)"
                ]
              ],
              "finding": "Read the complete exact core module; the selected path reaches the process callback or a fixed native trace-port generator. Other debugger entry points are outside this call path.",
              "reviewed_lines": {
                "__struct__": "Elixir.Range",
                "first": 1,
                "last": 3197,
                "step": 1
              },
              "sha256": "d996e990b75251edb65d4930a1edf5c1914f6c18f77ac526313157612f95f5f2",
              "source_path": "runtime_tools/src/dbg.erl"
            }
          ],
          "selected_function_evidence": [
            {
              "callback_boundary": "For {Fun, Data}, the caller-supplied function is retained as Handler and dbg invokes Handler(Trace, Data) in its tracer process for received events. Its implementation is caller code and is not recursively reviewed here.",
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:503",
                  "inets_trace:enable(Level, Dest)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:65",
                  "enable(Level, Dest)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:66",
                  "enable(Level, Dest, all)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:90",
                  "{Fun, _Data} = HandleSpec"
                ],
                [
                  "runtime_tools/src/dbg.erl:1069",
                  "tracer(process, {Handler,HandlerData})"
                ],
                [
                  "runtime_tools/src/dbg.erl:2041",
                  "Handler(Tr, Hdata)"
                ]
              ],
              "destination_dispatch": "A list destination opens the caller-selected output file; an integer selects the fixed IP trace port; io selects standard output; {Fun, Data} passes the caller function and data to the process tracer.",
              "disposition": "retained_callback_front_pending_integration",
              "finding": "The inspected path forwards values to fixed file, port, IO, service-validation, and callback operations. It does not derive a module name or evaluator input from Level, Dest, or Service. Callback semantics and dynamic callers remain outside this lane-local source conclusion.",
              "fixed_native_boundary": "The integer-port branch calls dbg:trace_port(ip, Port). That closure loads the fixed trace_ip_drv name from runtime_tools' private library directory and opens the resulting port; the native driver remains a fixed boundary.",
              "input_trace": "Level and Dest pass unchanged through inets_trace:enable/2 and select a destination branch. The two-argument API fixes Service to all.",
              "mfa": [
                "inets",
                "enable_trace",
                2
              ],
              "service_validation": "The two-argument form fixes Service to all. The three-argument delegate accepts only all, httpc, or httpd before dispatch."
            },
            {
              "callback_boundary": "A function destination reaches dbg:tracer(process, {Handler, HandlerData}); dbg later invokes the exact supplied Handler with each trace event and prior data. The callback body is outside OTP source authority.",
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:505",
                  "inets_trace:enable(Level, Dest, Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:68",
                  "enable(Level, Dest, Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:69",
                  "valid_trace_service(Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:85",
                  "is_integer(Port)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:90",
                  "is_function(Fun)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:94",
                  "dbg:tracer(Type, HandleSpec)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:153",
                  "Cond = [{ '=<', '$1', DetailLevel}]"
                ],
                [
                  "runtime_tools/src/dbg.erl:1324",
                  "Driver = \"trace_ip_drv\""
                ],
                [
                  "runtime_tools/src/dbg.erl:2041",
                  "Handler(Tr, Hdata)"
                ]
              ],
              "destination_dispatch": "The same fixed list, integer-port, io, and {Fun, Data} branches apply. File paths select file output; integer ports select the fixed IP trace port; function destinations select the caller callback.",
              "disposition": "retained_callback_front_pending_integration",
              "finding": "The selected path reaches fixed trace-pattern, service, output, and callback operations. The integer level is inserted as a comparison value in a generated match specification; it is not evaluated as source. No direct evaluator or atom-creation call is present in this path. Dynamic callers and callback implementation semantics remain unresolved.",
              "fixed_native_boundary": "The IP driver name is the fixed trace_ip_drv literal, loaded from runtime_tools' private library path before open_port. No caller-controlled driver or module name is constructed.",
              "input_trace": "Level, Dest, and Service pass unchanged from the exported wrapper. The delegate validates Service, then dispatches by destination and builds a fixed trace match specification from Level.",
              "mfa": [
                "inets",
                "enable_trace",
                3
              ],
              "service_validation": "valid_trace_service/1 accepts all, httpc, and httpd; other services return an invalid_service error before destination dispatch."
            }
          ]
        },
        "live_mfas": [
          [
            "inets",
            "enable_trace",
            2
          ],
          [
            "inets",
            "enable_trace",
            3
          ]
        ]
      },
      "delivery": {
        "ci_run": "https://github.com/szTheory/fablebook/actions/runs/43138409677",
        "merge_commit": "fb2e31be861acca65ef85399d0845901a3cc2b30",
        "milestone": "v0.2",
        "milestone_key": "guard-recovery",
        "phase": "1",
        "pr": 85,
        "reviewed_head": "a90ef1dfe7bad10ac3d303b82f8ba7b32c949745",
        "status": "merged"
      },
      "floor": {
        "evidence": {
          "delegate_edges": [
            {
              "callee": [
                "inets_trace",
                "enable",
                2
              ],
              "caller": [
                "inets",
                "enable_trace",
                2
              ],
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:499",
                  "inets_trace:enable(Level, Dest)"
                ]
              ]
            },
            {
              "callee": [
                "inets_trace",
                "enable",
                3
              ],
              "caller": [
                "inets",
                "enable_trace",
                3
              ],
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:501",
                  "inets_trace:enable(Level, Dest, Service)"
                ]
              ]
            }
          ],
          "exact_sources": [
            [
              "inets/src/inets_app/inets.erl",
              18409,
              "d8786fea1edde0d055e7198cdb279e9a1999daa070d4dc229f3ec66b75e8bd5e"
            ],
            [
              "inets/src/inets_app/inets_trace.erl",
              11073,
              "3e03ac1b03d2a01e7ddb1b1e29543e632aa3a63e16aa1f5a8c19ba935ae4dffd"
            ],
            [
              "runtime_tools/src/dbg.erl",
              112878,
              "808aa7980e020fc529e153fc907b606fd0e2ff5fb4ad0b74e548b5eafaea0dae"
            ]
          ],
          "lane": "floor",
          "matched_mfas": [
            [
              "inets",
              "enable_trace",
              2
            ],
            [
              "inets",
              "enable_trace",
              3
            ]
          ],
          "remainder_mfas": [],
          "reviews": [
            {
              "bytes": 18409,
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:499",
                  "inets_trace:enable(Level, Dest)"
                ],
                [
                  "inets/src/inets_app/inets.erl:501",
                  "inets_trace:enable(Level, Dest, Service)"
                ]
              ],
              "finding": "Read the complete exact floor module; both selected exports forward arguments directly to inets_trace.",
              "reviewed_lines": {
                "__struct__": "Elixir.Range",
                "first": 1,
                "last": 562,
                "step": 1
              },
              "sha256": "d8786fea1edde0d055e7198cdb279e9a1999daa070d4dc229f3ec66b75e8bd5e",
              "source_path": "inets/src/inets_app/inets.erl"
            },
            {
              "bytes": 11073,
              "citations": [
                [
                  "inets/src/inets_app/inets_trace.erl:67",
                  "case valid_trace_service(Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:76",
                  "file:open(File, [write])"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:84",
                  "dbg:trace_port(ip, Port)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:88",
                  "is_function(Fun)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:151",
                  "DetailLevel"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:172",
                  "dbg:tp(MFA, Pattern)"
                ]
              ],
              "finding": "Read the complete exact floor module; service validation precedes explicit destination routing to fixed tracing operations or a caller-supplied handler.",
              "reviewed_lines": {
                "__struct__": "Elixir.Range",
                "first": 1,
                "last": 353,
                "step": 1
              },
              "sha256": "3e03ac1b03d2a01e7ddb1b1e29543e632aa3a63e16aa1f5a8c19ba935ae4dffd",
              "source_path": "inets/src/inets_app/inets_trace.erl"
            },
            {
              "bytes": 112878,
              "citations": [
                [
                  "runtime_tools/src/dbg.erl:1287",
                  "tracer(process, {Handler,HandlerData})"
                ],
                [
                  "runtime_tools/src/dbg.erl:1542",
                  "trace_ip_drv"
                ],
                [
                  "runtime_tools/src/dbg.erl:1556",
                  "open_port({spawn, L}, [eof])"
                ],
                [
                  "runtime_tools/src/dbg.erl:2244",
                  "invoke_handler(Traces, Handler, Hdata)"
                ],
                [
                  "runtime_tools/src/dbg.erl:2255",
                  "Handler(Tr, Hdata)"
                ]
              ],
              "finding": "Read the complete exact floor module; the selected path reaches the caller-supplied process handler or fixed native trace-port generator.",
              "reviewed_lines": {
                "__struct__": "Elixir.Range",
                "first": 1,
                "last": 3392,
                "step": 1
              },
              "sha256": "808aa7980e020fc529e153fc907b606fd0e2ff5fb4ad0b74e548b5eafaea0dae",
              "source_path": "runtime_tools/src/dbg.erl"
            }
          ],
          "selected_function_evidence": [
            {
              "callback_boundary": "The supplied function is invoked for each event by dbg with its prior data. The callback implementation is caller code and is outside this review.",
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:499",
                  "inets_trace:enable(Level, Dest)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:63",
                  "enable(Level, Dest)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:64",
                  "enable(Level, Dest, all)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:88",
                  "{Fun, _Data} = HandleSpec"
                ],
                [
                  "runtime_tools/src/dbg.erl:1287",
                  "tracer(process, {Handler,HandlerData})"
                ],
                [
                  "runtime_tools/src/dbg.erl:2255",
                  "Handler(Tr, Hdata)"
                ]
              ],
              "destination_dispatch": "List destinations open a file; integer destinations select the fixed IP trace port; io selects standard output; {Fun, Data} passes the caller function and data to the process tracer.",
              "disposition": "retained_callback_front_pending_integration",
              "finding": "The reviewed floor path forwards inputs to fixed file, port, IO, service, and callback operations. It does not derive module names, evaluator input, or atoms from these arguments. Dynamic callers and callback semantics remain unresolved.",
              "fixed_native_boundary": "The integer-port case uses the fixed trace_ip_drv name in runtime_tools' private library path. Native driver internals are outside the source boundary.",
              "input_trace": "Level and Dest are forwarded unchanged; arity 2 supplies service all.",
              "mfa": [
                "inets",
                "enable_trace",
                2
              ],
              "service_validation": "Arity 2 fixes service to all. The arity 3 path accepts only all, httpc, and httpd before dispatch."
            },
            {
              "callback_boundary": "A function destination reaches dbg:tracer(process, {Handler, HandlerData}); dbg invokes that exact handler with each trace event and prior data. Its body is caller code.",
              "citations": [
                [
                  "inets/src/inets_app/inets.erl:501",
                  "inets_trace:enable(Level, Dest, Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:66",
                  "enable(Level, Dest, Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:67",
                  "valid_trace_service(Service)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:83",
                  "is_integer(Port)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:88",
                  "is_function(Fun)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:92",
                  "dbg:tracer(Type, HandleSpec)"
                ],
                [
                  "inets/src/inets_app/inets_trace.erl:151",
                  "Cond = [{ '=<', '$1', DetailLevel}]"
                ],
                [
                  "runtime_tools/src/dbg.erl:1542",
                  "Driver = \"trace_ip_drv\""
                ],
                [
                  "runtime_tools/src/dbg.erl:2255",
                  "Handler(Tr, Hdata)"
                ]
              ],
              "destination_dispatch": "The same fixed list, integer-port, io, and {Fun, Data} branches apply. File paths select file output; integer ports select the fixed IP trace port; function destinations select the caller callback.",
              "disposition": "retained_callback_front_pending_integration",
              "finding": "The floor source inserts an integer level only into a fixed comparison match specification and routes destinations to fixed operations. No direct evaluator or atom-creation call is reached in this path. Dynamic callers and callback implementation semantics remain unresolved.",
              "fixed_native_boundary": "The port branch loads the fixed trace_ip_drv literal from runtime_tools' private library path before opening the port; no caller-controlled driver name is constructed.",
              "input_trace": "Level, Dest, and Service reach the delegate unchanged; service validation precedes destination dispatch.",
              "mfa": [
                "inets",
                "enable_trace",
                3
              ],
              "service_validation": "valid_trace_service/1 accepts all, httpc, and httpd; all other services return invalid_service before destination handling."
            }
          ]
        },
        "live_mfas": [
          [
            "inets",
            "enable_trace",
            2
          ],
          [
            "inets",
            "enable_trace",
            3
          ]
        ]
      },
      "id": "EX-010",
      "identity": {
        "current_replacement_refs": [
          "source:EX:10"
        ],
        "id": "EX-010",
        "identity_class": "exclusion",
        "lane_matches": {
          "core": [
            "inets:enable_trace/2",
            "inets:enable_trace/3"
          ],
          "floor": [
            "inets:enable_trace/2",
            "inets:enable_trace/3"
          ]
        },
        "original_citations_raw": null,
        "original_entry_raw": "{{:inets, [:enable_trace]}, :own_native}",
        "original_matcher_raw": "{:inets, [:enable_trace]}",
        "original_reason_raw": ":own_native",
        "owner": "v0.2/1",
        "remaining_semantic_owner": "01.1.1.4",
        "semantic_status": "inets_trace_retained",
        "table": "EX"
      },
      "owner": "v0.2/1"
    }
  ],
  "schema": "fablebook.guard-aggregate-crosswalk/1",
  "scope": "one-row-tracer",
  "stops": {
    "aggregate_gate": "open",
    "candidate": null,
    "implementation_authorized": false,
    "scope_complete": false,
    "sec_01": "Pending",
    "walking_skeleton": "blocked"
  }
}
```
