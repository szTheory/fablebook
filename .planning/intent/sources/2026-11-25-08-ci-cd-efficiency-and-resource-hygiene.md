---
id: INT-20261125-08
date: 2026-11-25
source: Direct owner follow-up in this Codex session
captured_by: Codex
context: Adds explicit early validation, pre-hosted local workflow reproduction, and scoped process/resource cleanup to the standing CI and release/CD efficiency policy in INT-20261120-13.
---

# Owner direction: fast CI/CD feedback and scoped cleanup

> “always whenever a CI run is happening or done evaluate low hanging fruit to make it more efficient in terms of speed/iteration time/github actions dont mess up its quality”
>
> “if applicable in designs consider adding/running cheap consistency checks before the long test/process/suite”
>
> “if u need to recreate CI stuff locally u can use github `act` to recreate locally and check as much as possible locally before waiting on long CI”
>
> “if/when u use docker ... always clean up after urself ... names that make them easily identifiable with the project work”
>
> “Whenever you're done with process/resources like using CPU/memory/disk/database connections ... you need to clean up that for yourself”

Before expensive suites, run the cheapest reliable checks for the changed scope. Before hosted CI, run as much of the exact affected workflow locally as the current machine and services permit. Use native pinned commands and `act` only where their runtime, architecture, services, and inputs match. Local results supplement required hosted receipts. Preserve every safety, quality, security, and coverage gate.

After each completed CI or release/CD run, inspect measured durations, critical path, repeated setup/work, retries, and evidence volume. Record a measured improvement or why none is safe. Add a repeated CI fast-fail check only when its cost on passing runs is justified by measured downstream work it can avoid. Keep existing no-retry stops until their recorded cause changes.

Name task-owned Docker resources with a distinctive project/task/purpose prefix, track what was created, and remove only those exact resources. When resource-intensive work ends, verify its owned processes have exited, close its database/network connections, and remove temporary artifacts. Do not broadly prune resources, terminate unrelated processes, or remove another owner's data.

This supplements [INT-20261120-13](2026-11-20-13-automated-verification-and-resource-hygiene.md) and `.planning/CI-PERFORMANCE.md`; it does not authorize reduced checks, a changed `act` retry limit, releases, or deployments.
