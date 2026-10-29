---
schema_version: 1
open_count: 0
waived_count: 1
fixed_count: 1
total_count: 2
last_updated: 2026-10-29T02:27:33.004Z
---

# Broken Windows Ledger

> Cross-phase defect register. With `workflow.windows_enforce` enabled, `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 1 | stub | lib/fablebook/placeholder.ex | 14 | Fablebook.Placeholder answers 200 text/plain; intentional for 0.1.0 (D-07), replaced when the workbench ships | waived | Intentional 0.1.0 behavior per CONTEXT D-07 (name reservation, workbench unreleased); not a gap in this phase's goal | 2026-10-28T23:55:39.373Z | 2026-10-28T23:55:59.740Z |
| 2 | 1 | fixme | test/contract/prod_guard_test.exs | 23 | Flaky: prod phx.routes output can include the dep-compile banner '==> fablebook / Generated fablebook app', which matches ~r/fablebook/i (floor, PR #7 run 40805617266 attempt 1; attempt 2 passed). Fix the route-line filter or prevent the recompile, in a PR with no lib/ or .github/ changes | fixed |  | 2026-10-29T02:22:54.252Z | 2026-10-29T02:27:33.004Z |

````json
[
  {
    "id": 1,
    "kind": "stub",
    "phase": "1",
    "file": "lib/fablebook/placeholder.ex",
    "line": 14,
    "description": "Fablebook.Placeholder answers 200 text/plain; intentional for 0.1.0 (D-07), replaced when the workbench ships",
    "status": "waived",
    "reason": "Intentional 0.1.0 behavior per CONTEXT D-07 (name reservation, workbench unreleased); not a gap in this phase's goal",
    "recorded_at": "2026-10-28T23:55:39.373Z",
    "resolved_at": "2026-10-28T23:55:59.740Z",
    "milestone": null
  },
  {
    "id": 2,
    "kind": "fixme",
    "phase": "1",
    "file": "test/contract/prod_guard_test.exs",
    "line": 23,
    "description": "Flaky: prod phx.routes output can include the dep-compile banner '==> fablebook / Generated fablebook app', which matches ~r/fablebook/i (floor, PR #7 run 40805617266 attempt 1; attempt 2 passed). Fix the route-line filter or prevent the recompile, in a PR with no lib/ or .github/ changes",
    "status": "fixed",
    "reason": "",
    "recorded_at": "2026-10-29T02:22:54.252Z",
    "resolved_at": "2026-10-29T02:27:33.004Z",
    "milestone": null
  }
]
````
