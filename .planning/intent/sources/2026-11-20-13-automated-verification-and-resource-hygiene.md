---
id: INT-20261120-13
date: 2026-11-20
source: Direct owner message in the Fablebook planning conversation
captured_by: Codex
context: Reinforces automation-first verification, evidence-led CI efficiency, optional local act use, and safe cleanup/naming for any Docker resources.
---

# Owner direction: automate useful verification and clean up scoped resources

**Date:** 2026-11-20  
**Provenance:** Direct owner message in the Fablebook planning conversation.

> “goal is 0 human verificaiton/uat required. and remember this in our GSD .planning so that u do this by default going forward always whenever possible”
>
> “only if it's going to give you useful feedback. Don't put yourself into a corner. It's okay if you do throwaway verification. Everything doesn't have to be in the CI. Only CI if those requirements.”
>
> “whenever a CI run is happening or done evaluate low hanging fruit to make it more efficient in terms of speed/iteration time ... dont mess up its quality”
>
> “if and when u use docker ... clean up after urself ... names that make them easily identifiable with the project work”

Default to automating objective acceptance as early as useful, using deterministic checks and negative controls where they help. Prefer throwaway/local checks for one-time questions; put checks in recurring CI only when they protect behavior often enough to justify maintenance. Use `act` for relevant workflows when the current environment can run them, and retain hosted CI receipts. Reassess measured CI critical path and low-risk iteration improvements after runs without lowering coverage or quality gates. Preserve already documented no-retry limits when an `act` environment failure has not changed.

When Docker is useful, name and label resources with a Fablebook task/milestone identifier, record what the task created, and remove only resources attributable to that task. Never use a broad prune command that could remove unrelated owner resources. Hand off only irreducible judgment, unavailable authority, or a material owner decision.

This reinforces INT-20261029-08, INT-20261118-01, `.planning/VERIFICATION.md`, and `.planning/CI-PERFORMANCE.md`; it does not authorize weakening gates, visual-baseline policy, or delivery checks.
