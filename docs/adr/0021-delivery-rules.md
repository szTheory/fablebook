# 0021. Delivery rules for GSD: small phases, merged green PRs, gates never weakened

**Status:** Accepted · Amended 2026-10-28 (INT-20261028-18) · **Cites:** INT-20261028-04, INT-20261028-02, INT-20261028-03

## Context
The owner's retrospectives show the same failures repeatedly:
- **Oversized phases stall.** sigra 235.1 ran 449 commits; mailglass Phase 164 had 44 plans.
- **Proof ceremony ate whole milestones.**
- **Green locally is not green in CI.** sigra hid a 300-commit backlog that had never run in CI.
- **A rewritten guard hid a regression** (sigra v1.47).
- **Review loops past 3 passes** gave diminishing returns.
- **Long branches merged once** pushed CI and review to the very end.

## Decision
- **Phase size:** at most 5 plans per phase and about 3 working days. A phase that can't meet its gates **splits**.
- **Merging:** every phase ends in a **merged, green PR to main**. Push on day 1. Evidence is a link to a CI run, not prose.
- **No ceremony phases:** no ratification-only or "proof" phases, and no phase-numbered workflows or `verify.phaseN` tasks.
- **Review cap:** 2 review passes, then the owner decides.
- **Gates:** never weakened without an owner-signed DECISION that cites an INT id.
- **Contract tests:** never edited in the same PR as the implementation they guard. A test over the PR's diff enforces it:

  | Guard path changed (`M` or `D`) | Must not also change |
  |---|---|
  | `test/contract/**` | `lib/**` and `.github/**` |
  | `test/planning/**` | `.planning/intent/**` and `.planning/REQUIREMENTS.md` |

  Adding a guard file (`A`) is allowed, so test-first work and a phase's first PR pass. Recorded outputs (such as `test/snapshots/`) are not enforced until goldens land; then a change to one carries a `Recorded-Output-Change:` commit trailer.
- **Reading order:** every milestone and phase discussion reads `.planning/intent/NORTH-STAR.md` and `CLEARANCE.md` first.
- **GSD config:** granularity **`fine`** (8–12 phases; the seed proposes 12), vertical-MVP mode, plan-check and verifier on. Run `--auto` for new-project, then **one interactive review** of REQUIREMENTS and ROADMAP before phase 1, checking that ADR constraints and INT/ADR citations survived the rewrite.
- **Clearance is a soak, not a phase.** The last roadmap phase sets up dogfooding (host upgrades, migrations). The 14-day criteria in `CLEARANCE.md` (C6, C8) and the cross-repo ones (C1, C4, C5, C10) are checked by the milestone audit before 1.0 is tagged; the phase size cap does not apply to the soak window.

## Amendments (release pipeline sign-off, 2026-10-28)
- **Contract-test definition (D-21, Q15):** the guard-path table above defines the rule, enforced over the D-19 diff seam; `A` is allowed; recorded outputs wait for goldens and then use a `Recorded-Output-Change:` trailer. (INT-20261028-18)
