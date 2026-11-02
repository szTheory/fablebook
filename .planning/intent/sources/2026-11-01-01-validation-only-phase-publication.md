---
id: INT-20261101-01
date: 2026-11-01
source: Codex session, owner authorization
captured_by: Codex
context: Owner approval of a validation-only PR path for Phase 01.1.1.3.1.3 while preserving exact-head CI, merge, and phase-completion checks.
---

> Verbatim owner approval: “Yeah, that plan sounds good. I authorize you.”

**Resolution:** For Phase 01.1.1.3.1.3 only, allow a draft validation PR to collect the exact-head evidence that the phase plan requires. This is a scoped delivery procedure, not a security waiver:

- It is allowed only while the two remaining high items are the documented delivery-evidence obligations T-03 and T-04, and no unresolved high implementation finding exists.
- Keep `security_enforcement: true` and `security_block_on: high`. Keep `threats_open` accurate; the current value is `2` until the evidence actually closes those items.
- Require green `core`, `floor`, `dialyzer`, `security`, and `ci-gate` checks on the same PR head. Match core/floor aggregate markers to the phase source, owners, receipts, and job IDs before merging.
- T-03 closes only after the exact-head CI evidence is verified. T-04 remains open through merge and closes only after independently verifying the PR head, CI run, merge SHA, and main ancestry.
- Any additional high finding, changed code scope, failed check, or mismatched identity stops delivery. The PR stays draft until the exact-head CI evidence passes.
- This decision does not change the generic `$gsd-ship` gate or authorize other phases to publish with open high findings.
