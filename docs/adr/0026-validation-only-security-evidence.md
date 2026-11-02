# 0026. Stage delivery evidence without weakening security gates

**Status:** Accepted, 2026-11-01 · **Cites:** INT-20261101-01 · **Clarifies:** ADR 0021 for the validation-only sequence described here

## Context

The standard GSD ship gate requires `SECURITY.md` to report `threats_open: 0` before publishing a branch or PR. Some delivery threats can only be verified after a PR run or after merge. In Phase 01.1.1.3.1.3, exact-head CI provenance and merge identity are recorded as high threats whose mitigations require those later observations. Blocking all publication prevents the phase from reaching the evidence it requires.

The owner approved a phase-scoped validation-only path. It does not reduce the project's security threshold or close a threat by assertion.

## Decision

For Phase 01.1.1.3.1.3 only, a draft validation PR may be published while the only open high items are `T-01.1.1.3.1.3-03` and `T-01.1.1.3.1.3-04` and the reviewed change has no unresolved high implementation finding.

1. The PR remains draft while exact-head CI runs. Any added high finding, unrelated code scope, failed check, or identity mismatch stops delivery.
2. Merge requires green `core`, `floor`, `dialyzer`, `security`, and `ci-gate` checks on the same PR head, plus exact core/floor aggregate markers matched to the reviewed source, owner, receipts, and jobs. `T-01.1.1.3.1.3-03` closes only after those checks and markers are verified.
3. `T-01.1.1.3.1.3-04` remains open until after merge. The merge is allowed only after all pre-merge conditions above pass; phase completion remains blocked until PR head, CI run, merge SHA, and main ancestry are independently verified.
4. The security report keeps the real `threats_open` count. It remains `2` before CI evidence, `1` after T-03 closes, and `0` only after T-04 is verified.
5. The ordinary `$gsd-ship` behavior and all other phases remain unchanged: unresolved high threats block ordinary shipping.

## Alternatives considered

- **Lower `security_block_on` or disable security enforcement.** Rejected; this would weaken unrelated security gates.
- **Mark T-03 or T-04 mitigated before collecting its required evidence.** Rejected; this would make the report claim something not yet verified.
- **Keep the pre-PR publication block for this phase's evidence-only items.** Rejected; it prevents collecting the PR-run and merge evidence the approved phase outcome requires.

## Reversal trigger

Replace this phase-specific procedure when GSD provides a native, stage-aware gate that permits evidence collection while continuing to block merge and phase completion until the corresponding checks pass.
