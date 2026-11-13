---
phase: "2"
slug: "bounded-asn-1-rtt-guard-evidence"
status: draft
nyquist_compliant: true
wave_0_complete: true
created: "2026-11-12"
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | ExUnit on the pinned core and floor Elixir/OTP lanes |
| **Config file** | `mix.exs`, `test/test_helper.exs` |
| **Quick run command** | Run the lane-owned contract test plus `mix test test/contract/asn1_rtt_integration_test.exs --warnings-as-errors` on the affected lane. |
| **Full suite command** | `mix test --warnings-as-errors --include prod_guard` on both pinned lanes |
| **Estimated runtime** | Use the latest core and floor CI receipt timings; no tests were run during research. |

---

## Sampling Rate

- **After every task commit:** Run the focused ASN.1 RTT contract test on the lane(s) affected.
- **After every plan wave:** Run the focused test on core and floor; inspect static evidence without invoking audited OTP functions.
- **Before `$gsd-verify-work`:** Run the full suite on both pinned lanes and record the local tested head. After all plan and summary commits, phase verification/ship verifies the final PR head and reconciles required hosted receipts for that exact head.
- **Max feedback latency:** Use current pinned-lane CI timing; record task intervals and stop if the plan approaches its three-working-day bound.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | GRC-04/GRC-05 | — | Core `assert_defined/1` source and caller spans bind to the pinned identity, with an individual positive/negative control. | contract/static source | `mix test test/contract/asn1_rtt_core_guard_test.exs --warnings-as-errors` | ✅ present | ✅ green |
| 02-01-02 | 01 | 1 | GRC-05 | — | Core `code/0` and `dependencies/1` evidence and controls are complete; literal bytes use the full byte-only check. | contract/static source | `mix test test/contract/asn1_rtt_core_guard_test.exs --warnings-as-errors` | ✅ present | ✅ green |
| 02-02-01 | 02 | 1 | GRC-04/GRC-05 | — | Floor `assert_defined/1` source and caller spans bind to its distinct pinned identity. | contract/static source | `mix test test/contract/asn1_rtt_floor_guard_test.exs --warnings-as-errors` | ✅ present | ✅ green |
| 02-02-02 | 02 | 1 | GRC-05 | — | Floor `code/0` and `dependencies/1` evidence and controls are complete; literal bytes use the full byte-only check. | contract/static source | `mix test test/contract/asn1_rtt_floor_guard_test.exs --warnings-as-errors` | ✅ present | ✅ green |
| 02-03-01 | 03 | 2 | GRC-04 | — | Both 177-member lane sets, exact selected three, 174-member complement, and historical 13/164/161 partition remain exact and distinct. | contract/integration | `mix test test/contract/asn1_rtt_integration_test.exs --warnings-as-errors` | ✅ present | ✅ green |
| 02-03-02 | 03 | 2 | GRC-05 | — | All six function/lane control pairs reconcile without invocation or unsupported runtime claims; collisions stop with exact details. | contract/security | `mix test test/contract/asn1_rtt_integration_test.exs --warnings-as-errors` | ✅ present | ✅ green |
| 02-04-01 | 04 | 3 | GRC-05 | — | Independent high-severity review records bounded findings and preserves security/static-only limits before fixes. | review/security | `mix test test/contract/asn1_rtt_core_guard_test.exs --warnings-as-errors && mix test test/contract/asn1_rtt_floor_guard_test.exs --warnings-as-errors && mix test test/contract/asn1_rtt_integration_test.exs --warnings-as-errors` | ✅ present (`02-REVIEW.md`) | ✅ green |
| 02-04-02 | 04 | 3 | GRC-05 | — | Accepted fixes remain within the five approved output files and focused validation is green on affected lanes. | contract/retest | Run the same three contract commands on both lanes after the bounded correction pass. | ✅ present | ✅ green |
| 02-05-01 | 05 | 4 | GRC-05/GRC-06 | — | Full checks pass on both pinned lanes; the local act workflow is attempted when feasible and kept supplementary. | full suite/local CI | `mix test --warnings-as-errors --include prod_guard` on both pinned lanes | ✅ present (core/floor suites) | ✅ green |
| 02-05-02 | 05 | 4 | GRC-06 | — | Local report records the tested head, both lane results, review/security disposition, and hands final-head delivery to phase verification/ship. | report/handoff | `python3 -c 'import re; from pathlib import Path; p=Path(".planning/phases/02-bounded-asn-1-rtt-guard-evidence/02-CANDIDATE.md").read_text(); fields=("local_tested_head:","core_command:","core_result:","floor_command:","floor_result:","act_outcome:","review_disposition:","security_disposition:","delivery_handoff:"); assert all(re.search(rf"^{re.escape(f)}\s*\S",p,re.M) for f in fields); assert "final candidate head and hosted receipts are pending phase verification/ship" in p'` | ✅ present (`02-CANDIDATE.md`) | ✅ green |
*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] Confirm both pinned runtimes and the required local test toolchain are available; both pinned lanes completed their full suites.
- [x] Preserve five outputs: independent core and floor evidence/test pairs plus the integration-only contract file with inline evidence assertions.
- [x] Keep the complete `code/0` payload out of prompt context and preserve the existing bounded byte-only check.
- [x] Start Wave 1 core and floor plans concurrently; their exact output files are disjoint and neither reads the other lane's outputs.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Actual-library collision stop | GRC-05 | A reported collision needs source judgment and an owner decision; a passing static test cannot resolve its safety consequence. | If a new guard matches a real `lib/` function, stop and record the exact MFA, call site, input trace, and triggering guard. |
| Reviewed exact-head delivery and safety boundary | GRC-06 | Review and hosted receipt bookkeeping are repository delivery gates; static tests cannot establish review approval or CI provenance. | After all plan and summary commits, confirm approved review/security dispositions, rerun required checks on the final head if needed, and verify hosted green core/floor receipts against the same PR head. Keep runtime, dynamic-caller, native-internals, and SEC-01 claims explicitly open. |

---

## Validation Sign-Off

- [x] All tasks have a focused automated command or an explicit Wave 0 dependency.
- [x] Sampling continuity: no 3 consecutive tasks without automated verification.
- [x] Wave 0 covers any missing per-function/per-lane contract controls.
- [x] No watch-mode flags.
- [x] Feedback latency is based on current pinned-lane CI receipts.
- [x] `nyquist_compliant: true` set after validation confirmed the plan's verification coverage.

**Validation sign-off:** Automated coverage is green for all plan tasks on the pinned lanes. Final exact-head candidate/hosted receipt verification remains with phase verification and ship.
