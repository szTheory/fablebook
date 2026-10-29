---
schema_version: 1
open_count: 0
waived_count: 1
fixed_count: 0
total_count: 1
last_updated: 2026-10-28T23:55:59.740Z
---

# Broken Windows Ledger

> Cross-phase defect register. With `workflow.windows_enforce` enabled, `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 1 | stub | lib/fablebook/placeholder.ex | 14 | Fablebook.Placeholder answers 200 text/plain; intentional for 0.1.0 (D-07), replaced when the workbench ships | waived | Intentional 0.1.0 behavior per CONTEXT D-07 (name reservation, workbench unreleased); not a gap in this phase's goal | 2026-10-28T23:55:39.373Z | 2026-10-28T23:55:59.740Z |

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
  }
]
````
