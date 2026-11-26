# Phase 8 implementation review resolution

The initial review is preserved in [08-04-05-IMPLEMENTATION-REVIEW.md](08-04-05-IMPLEMENTATION-REVIEW.md). This follow-up records what changed after that review and what remains open.

| Finding | Resolution | Evidence |
|---|---|---|
| CR-01 — contract test bundled with guarded implementation | **Open.** `test/contract/mount_literal_ast_test.exs` and `lib/fablebook/router.ex` are still modified in the same local candidate. ADR 0021 requires separate PRs. | Full core and floor lanes each report the ADR separation assertion as their only failure. Split into a test-only contract PR and a separate implementation PR before delivery. |
| CR-02 — CI omitted pinned-source verification | **Fixed.** Both lanes fetch the locked sources and run `bin/verify_logistify_source --check-pinned`; host tests check every displayed fact, action and citation against the manifest and records. | `--check-pinned` passed; host tests passed 11/11 in core and floor. |
| WR-01 — shared deterministic session secret | **Fixed.** Dev generates or accepts local secret material, prod requires an environment secret, and only test imports its deterministic test secret. | Core and floor production-boundary scripts passed after the config import correction. |
| WR-02 — same-origin HTTP error remained “loading” | **Fixed.** Canvas load handling detects a same-origin error document and the readiness timeout fails closed. | Browser failure-route check reached the prescribed failure message; real route returned to ready. |
| WR-03 — host lock drift from reviewed core pins | **Fixed.** Host core shared entries align with the root core pins; the root lockfiles remain unchanged. | Core/floor host tests and both production-boundary scripts passed. The current root pins now trigger the security audit gate described below. |
| Root dependency security | **New delivery blocker.** Core Hex audit reports two HIGH Phoenix advisories. Floor reports those two plus MEDIUM LiveView and Plug advisories. The phase plan explicitly says to leave root locks unchanged. | See local audit outputs recorded in [08-05-SUMMARY.md](08-05-SUMMARY.md) and the upstream Phoenix [1.8.17 release](https://github.com/phoenixframework/phoenix/releases/tag/v1.8.17). |

No review finding was suppressed. The initial review remains an immutable point-in-time record; this table is the current disposition.

## 2026-11-22 continuation status

| Finding | Current status | Evidence |
|---|---|---|
| CR-01 — contract test bundled with guarded implementation | **Resolved.** PR #105 delivered the mount contract test separately. The Phase 8 candidate changes `lib/fablebook/router.ex` without a diff to `test/contract/mount_literal_ast_test.exs`. | `git diff origin/main -- test/contract/mount_literal_ast_test.exs` is empty; PR #105 is merged with green exact-head CI. |
| CR-02 — CI omitted pinned-source verification | **Resolved.** Core and floor CI run `bin/verify_logistify_source --check-pinned`. The core job also restores both source-tool self-tests. | Fetcher self-test, verifier self-test, and `--check-pinned` passed locally after the CI change. |
| WR-01 — shared deterministic session secret | **Resolved.** Development signing material is local/generated, production requires its environment secret, and test alone uses its deterministic test secret. | `bin/verify_operator_host_prod` passed in core and floor builds. |
| WR-02 — same-origin HTTP error remained “loading” | **Partially resolved.** The earlier missing-document failure path is covered. A real browser later showed the normal Canvas readiness announcement could be missed when the iframe finished before the deferred host script attached its load listener. The parent now checks the completed expected document and requests its status. | Focused Node handshake simulation passed. Real-browser recheck remains outstanding because browser control became unavailable. |
| WR-03 — host lock drift from reviewed core pins | **Resolved.** The host lock was aligned with the approved core pins; floor checks use the pinned floor lane. | Host tests and production-boundary checks passed in core and floor. |
| Root Phoenix HIGH advisories | **Resolved for core.** PR #102 upgraded the authorized Phoenix pin. The existing floor LiveView and Plug MEDIUM advisories remain on their unchanged pins; no unrelated update was made. | Core full lane passed; floor dependency setup reported only the two known MEDIUM advisories. |
| Current-review WR-01 — source-tool self-tests missing from CI | **Fixed; review follow-up pending.** | Both commands were restored before the normal pinned-source checks; both self-tests passed locally. |
| Current-review WR-02 — displayed values not bound to cited source values | **Fixed; review follow-up pending.** | Host tests compare decoded manifest excerpts to their record pointers and verify displayed values against those pointers; host tests passed 12/12 in both lanes. |

The current code-review report and its resolution are separate from the original
implementation review. The [2026-11-22 resumption record](08-05-RESUMPTION-2026-11-22.md)
and [browser record](08-BROWSER.md) own the current delivery status. The live
visual-baseline decision, refreshed exact-head hosted CI, merge, and closeout
remain open.
