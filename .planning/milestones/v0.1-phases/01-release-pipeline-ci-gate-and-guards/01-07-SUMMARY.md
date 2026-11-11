# Plan 01-07 Summary: CI timing contract

## Outcome

Merged the contract-only PR [#50](https://github.com/szTheory/fablebook/pull/50) at `9a9a80446b2589dc900f20cce492e0661f820c5d`. Its only changed path is `test/contract/ci_health_test.exs`; `bin/ci_health`, `.github`, and `lib` were not part of the PR.

The tests establish that the exact historical producer bytes keep their staged behavior, while any changed producer must route timing-only overages to `ci-performance` and keep the 420-second p50 / 600-second p95 objectives visible as non-blocking feedback. The actual nightly release guard still permits performance-only reports and blocks genuine quality reports, including mixed inventories and API failures.

## Evidence

- [Timing contract receipt](01-07-TIMING-CONTRACT.json) binds paths, revisions, pinned-lane transcripts, mutation controls, privacy-scan scope, and CI evidence.
- [Hosted CI run 172](https://github.com/szTheory/fablebook/actions/runs/42237252814) passed core, floor, dialyzer, security, and `ci-gate`; `ci-health` and `nightly` were skipped as allowed for this PR.
- Exact core and floor contract tests and the core contract-rule / intent tests passed. The full local `mix ci` alias passed as well.
- Three mutation controls proved the digest exception, strict timing route, and release-blocker seam reject their respective regressions.

The initial hosted attempt found one Credo style issue in the new helper. It was changed to `Enum.map_join`; the updated commit passed the complete required hosted suite.

## Privacy scan scope

The whole-repository scan found inherited home-path strings already on `main`. Following the user's direction, the changed-file scan was used for this PR and passed; inherited paths were left untouched. The receipt records that scope decision.

## Next

The owner later approved a separate Plan 01-08 contract-compatibility PR because the staged test helper assumes the old producer line. This keeps the producer PR path-only while adding one contract PR before implementation. G-01-15 remains open until Plan 01-09 removes the staged digest exception, safely handles issue #37, and verifies the deployed report.

## Self-Check: PASSED

Both plan artifacts exist and the recorded merge commit is on fetched `main` in the isolated execution checkout. The final hosted run passed the required checks on the recorded PR head.
