# Phase 01.1.1 starting material

These files came here from Phase 01.1 when CR-02 (01.1-VERIFICATION truth 7) moved to this phase (INT-20261029-03). They are input for `/gsd-plan-phase 01.1.1`, not a plan.

| File | What it is |
|------|------------|
| `test/contract/tier_sweep_test.exs` | The reachability sweep and its exclusions now live in this contract test; it supersedes both planning-directory sweep scripts. |

The candidate 80-entry tier, along with the `:int` and code-path-mutator reasoning, is in Plan 01.1-03 as of commit `a3dab47` (`git show a3dab47:.planning/phases/01.1-close-phase-1-guard-gaps/01.1-03-PLAN.md`, Task 3 and the context's "Verified facts for the CR-02 tier"). Plan 01.1-03 no longer carries it. `@mfa_tier` stays at 45 entries on main after Phase 01.1, and against those 45 entries the sweep printed `undisposed=152` on both lanes at planning time. A re-run after the move (Elixir 1.20.4 / OTP 29.1.1, 2026-10-29) printed `reached=603 covered=96 excluded=355 undisposed=152` and exited 1.

## Known starting gaps (01.1 plan checker iteration 2, and the 01.1 re-verification)

These are the checker's findings. Nobody has re-checked them against source yet, so each one is open until this phase confirms or refutes it.

1. **Exclusion reasons reported false.** Each function below carries a reason in the exclusions file that the checker says does not hold for caller-chosen input:
   - `Mix.Tasks.Format`: the `:dot_formatter` option of `formatter_for_file/2` and `run/1` with `--dot-formatter` (reason: `project_build`).
   - `Mix.Tasks.Help.run/1` with `"app:" <> name` (reason: `project_build`).
   - `Mix.Compilers.Erlang.ensure_application!/2` (reason: `project_build`).
   - `Mix.Tasks.Test.Coverage.start/2` (reason: `project_build`).
   - `Mix.Dep.in_dependency/3` (reason: `project_build`).
   - `ExUnit.Diff.compute/3` (reason: `own_clauses`).
   - `Mix.Local.append_paths/0` (reason: `fixed_app`).
2. **Runtime dependencies are not swept.** The sweep scans only OTP and Elixir applications. When the checker added the project's dependency `ebin` directories under `_build/dev/lib` (phoenix, phoenix_live_view, phoenix_html, phoenix_template, phoenix_pubsub, plug, plug_crypto, telemetry, nimble_options, mime, websock, websock_adapter) and ran against the 125-entry candidate tier, the sweep printed `undisposed=61`. Those rows include `Phoenix.LiveView.Engine.compile/2`, `Phoenix.Template.EExEngine.compile/2`, `Phoenix.LiveView.TagEngine.Compiler.compile/2`, `Phoenix.Router.Helpers.define/2`, `Mix.Phoenix.eval_from/3`, `Mix.Phoenix.copy_from/4` and `Mix.Tasks.Phx.Server.run/1` (with `-e` code).
3. **Whole-module literal over-catch (this phase's SC3).** The literal family that Plan 01.1-03 adds flags an atom that names a wholly banned module in any role. So `Regex.compile/1`, `:re.compile/2`, a local `compile/1` and `[epp: 1]` all hit `{:compile, :_, :_}` or `{:epp, :_, :_}`. Plan 01.1-03 documents this in the Credo explanation and pins it in the "(known strictness)" test. The owner chose the fix (INT-20261029-03: "the fix for over-catching any function named compile"), so SC3 requires the narrowing, not more documentation: call-name positions stop triggering the whole-module check, and any banned call the narrowing would drop gets an explicit tier entry first. The keyword and data-pair over-catches (`[epp: 1]`, `[compile: true]`, `[io: :read]`) are not function names; they stay documented and pinned unless this phase decides otherwise.
4. **APIs no sweep row names (this phase's SC4).** Against the 45-entry tier the sweep never lists `:erlang.load_nif/2`, `:erl_ddll.load/2`, `:epp_dodger.parse_file/1` or `:elixir.tokens_to_quoted/3`, yet 01.1-VERIFICATION truth 7 reproduced each of them passing the guard. SC4 makes every truth-7 API, the native loaders in full and the atom-creating parsers in full tier entries whether or not the sweep reaches them. The truth-7 list is `:qlc.string_to_handle`, `:merl.compile_and_load`, `:c.c`, `:make.files`, `:cover.compile_module`, `:erlang.load_nif`, `:erl_ddll.load`, `:epp_dodger.parse_file`, `:elixir_erl_compiler.noenv_forms`, `:elixir.tokens_to_quoted`, `IEx.Helpers.c` and `Mix.Tasks.Run.run`.

5. **Re-verification gaps from 01.1 (INT-20261029-04).** 01.1-VERIFICATION (2026-10-29T15:52:44Z) reproduced each of these on both lanes. The verifier's repro commands and probes are in its Behavioral Spot-Checks table.
   - **CR-04 (SC5):** `test/support/beam_walker.ex` `function_code/1` (lines 37-38) drops every `__info__` arity, but Elixir reserves only `__info__/1`. Fix: skip only `{:__info__, 1}` and add a beam-only fixture such as `info_arity_two.ex` to `@fixtures` and `@beam_only_fixtures`. The verifier tested this in a scratch copy: 79 passed, the `lib/` scan stayed clean, and all three probes hit.
   - **VR-01 and WR-11 (SC6):** a pair-tier call quoted in a `lib/` macro, or made in module-body code, passes both layers. In abstract code the quoted `{:., _, [m, f]}` is a cons list and an alias stays `{:__aliases__, _, [:Module]}`, so the pair family never sees an adjacent pair. The owner chose the fix: a source-level MFA-tier remote-call check in Credo, with alias expansion and the adjacent-literal rule. It also covers module bodies, so WR-11 is fixed rather than accepted. Fixtures: `macro_concat.ex`, `macro_script.ex`, a `__using__` injection, and module-body `@attr` cases.
   - **WR-12 (SC6):** the `mix.exs` scan misses `apply/3`, alias and newline-after-dot spellings (`banned_calls_test.exs:429-441`).
   - **Truth 6 (SC7):** `credo/checks/banned_calls.ex:16-19` says "anywhere in function code", and its misses list (lines 33-45) omits quoted and module-body calls. Rewrite it once, after SC3 to SC6 land, together with the tier-gap sentence SC4 removes. Then record the human wording check.

## Inbound threats

Phase 01.1 transferred or retired these threats to this phase per INT-20261029-03. None of them is closed until this phase closes it.

| Threat ID | From | Disposition in Phase 01.1 | What closes it here |
|-----------|------|---------------------------|---------------------|
| T-01.1-25 | Plan 01.1-03 (CR-02 share split out of T-01.1-27, whose reopened source is T-01.1-02, critical) | transfer | Eval, compile-and-load and native-load tier entries with negative fixtures (SC1, SC2, SC4) |
| T-01.1-28 | Plan 01.1-03 (high; was T-01.1-03 in 01.1-SECURITY) | transfer | `:qlc.string_to_handle`, `:epp_dodger` and `:elixir.tokens_to_quoted` tier entries with negative fixtures (SC1, SC2, SC4) |
| T-01.1-22 | Plan 01.1-03 as of `a3dab47` (high) | transfer (ID retired in 01.1) | The `:int` decision and the code-path mutator ban (SC2) |
| T-01.1-23 | Plan 01.1-03 as of `a3dab47` (medium) | transfer (ID retired in 01.1) | The committed sweep with true exclusion reasons, `undisposed=0` on both lanes (SC1) |
| T-01.1-27 | 01.1-SECURITY (critical) | reopened by CR-04 and VR-01, transfer per INT-20261029-04 | SC5 and SC6 fixtures hit on both lanes |
| T-01.1-15 | 01.1-SECURITY (high) | reopened by CR-04, transfer per INT-20261029-04 | SC5 fixture hits; the walker skips only `{:__info__, 1}` |

Plan 01.1-03 also pins three rows of its "(known strictness)" test as unlisted no-hit cases: `:qlc.string_to_handle/1` and `:epp_dodger.parse_file/1` (T-01.1-28), and `:erlang.load_nif/2` (T-01.1-25). Its Credo explanation names the same tier gap in one sentence. When this phase extends the tier, those rows must report hits and that sentence must go (SC4). The call-name rows change with SC3. Each of those edits rides in this phase's own contract-test-only PR (SC5, ADR 0021).
