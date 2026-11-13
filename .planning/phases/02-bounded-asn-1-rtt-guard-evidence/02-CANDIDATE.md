# Phase 2 Local Readiness Evidence

This file records local validation evidence only. The required full commands completed on both pinned lanes and failed. Local readiness is blocked pending diagnosis and resolution of those failures.

local_readiness: BLOCKED — both required full-suite commands failed.
local_tested_head: 4e6be83146db3a014986ae982d956d5a599c807b
core_command: bin/lane core test --warnings-as-errors --include prod_guard (runs `mix test --warnings-as-errors --include prod_guard` with the pinned core environment)
core_result: FAIL — Elixir 1.20.4 / OTP 29.1.2; 437/449 passed, 12 failed, 7 excluded; 1947.3 seconds. Failures: one planning contract diff-overlap assertion, three floor-specific source assertions under core, and eight 60-second timeouts in exhaustive tier-sweep / installed-OTP checks.
floor_command: bin/lane floor test --warnings-as-errors --include prod_guard (runs `mix test --warnings-as-errors --include prod_guard` with the pinned floor environment)
floor_result: FAIL — Elixir 1.18.5 / OTP 27.3.4.9; 456 tests, 3 failed, 6 excluded; 1572.4 seconds. Failures: one planning contract diff-overlap assertion, one 60-second timeout in intent citation scanning, and one 60-second timeout rewriting a large saved-settings receipt.
act_outcome: ATTEMPTED — `act --list -W .github/workflows/ci.yml` failed schema validation because this installed `act` rejects the workflow's hosted Actions `concurrency.queue` property at line 167; Docker daemon is available. No jobs ran.
review_disposition: CLOSED — `.planning/phases/02-bounded-asn-1-rtt-guard-evidence/02-REVIEW.md` reports no open high-severity finding; accepted review fixes are closed.
security_disposition: STATIC ONLY — review preserves the actual-library collision stop. No runtime behavior, dynamic-caller absence, native-internals safety, complete EX-107 row, aggregate closure, Walking Skeleton, or SEC-01 completion is established. Walking Skeleton remains blocked and SEC-01 remains Pending.
delivery_handoff: Local full-suite gate is red. Diagnose and resolve the test failures before treating readiness as passed. After all plan and summary commits, phase verification/ship must rerun required checks on the exact final candidate head, reconcile hosted core/floor receipts against that PR head, and record actual merge/main evidence. The final candidate head and hosted receipts are pending phase verification/ship.

## Local Run Details

- Both lane commands used the same source tree at `local_tested_head`; `bin/lane` selected each lane's pinned toolchain and isolated build/dependency paths.
- Core's planning contract failure reports that `test/planning/planning_state_test.exs` is changed in the same change set as `.planning/REQUIREMENTS.md` and twelve intent source files. The floor run reports the same diff-overlap failure.
- Core also ran the floor-owned RTT guard tests, which failed against core OTP source at the cited floor locations. The pinned floor command is the lane-correct run for those tests.
- The `act` attempt was supplementary only and did not run workflow jobs; it cannot substitute for hosted CI.
- This report is not final candidate-head, hosted CI, or merged-main evidence. No PR or hosted receipt is claimed.
- All observed failures are recorded above without changing unrelated planning files or widening this evidence scope.
