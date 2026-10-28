# Clearance scorecard: when Fablebook beats phoenix_storybook

1.0 ships, and the owner switches, only when **every** row passes. Each row names its proof. Status starts at `open`. (INT-20261028-04)

| # | Criterion | Proof | Status |
|---|---|---|---|
| C1 | **Story parity in the mailglass demo and accrue_admin**: every story they keep after pruning is migrated (via `mix fablebook.migrate.phoenix_storybook` plus hand fixes) | Migrated catalog in each repo; prune log | open |
| C2 | **Every phoenix_storybook footgun the owner hit is covered by a named test**: nesting under `/dev`, the serif font override, CSS via `@import`, unaddressable grouped scenarios, enumeration only in dev, no viewport control, its own LiveSocket and hook re-registration, recompiles on add/remove, string slots, playground eval (CVE-2026-8467), atom exhaustion, PubSub topic hijack, global telemetry handlers, CSP | `test/regressions/psb_*_test.exs`, one per footgun | open |
| C3 | **Fidelity receipt in the operator host app**: same CSS bytes, fonts (`document.fonts` and network), hooks and CSP as production | E2E fidelity spec green | open |
| C4 | **LLM bundle used for real**: at least 3 owner design iterations driven by Fablebook bundles in a dogfood repo | Linked PRs | open |
| C5 | **Design canon in use**: glossary, voice, personas/jobs and tokens authored in one dogfood repo, with lints green and ratchets only shrinking | CI run link | open |
| C6 | **Visual regression trustworthy**: determinism self-test (identical hashes across 3 captures), with no flake for 14 days | Nightly history | open |
| C7 | **Day-0 install**: clean-room `mix igniter.install fablebook` on a fresh `phx.new`, first render in under 5 minutes, no manual steps | Clean-room spec plus a timed run | open |
| C8 | **Dogfood stability**: at least 2 owner repos run Fablebook in CI for 14 days with no red caused by Fablebook | CI history | open |
| C9 | **Performance gates green** on the pinned lane (see `docs/research/QUALITY-PERF-SRE.md`) | CI run link | open |
| C10 | **Owner verdict**: the owner prefers Fablebook in daily use | Owner sign-off entry in `sources/` | open |
