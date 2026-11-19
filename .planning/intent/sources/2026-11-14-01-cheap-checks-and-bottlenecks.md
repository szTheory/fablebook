---
id: INT-20261114-01
date: 2026-11-14
source: owner conversation during Phase 3 execution
captured_by: Codex
context: Iteration-speed guidance for bounded execution; no resource limit, safety gate, or credential-handling rule changes.
---

## Verbatim owner direction

> Okay, can't you just figure it out and use your own? Unlock us. if applicable in designs consider adding/running cheap consistency checks before the long test/process/suite... (always lessons learned find bottleneck low hanging fruit sanity check take a step back to keep things moving fast instead of banging our head against the wall)

## Captured execution implications

- Run cheap consistency checks before long tests or suites when they can catch malformed inputs or artifacts early. (INT-20261114-01)
- When repeated retries or gates stall progress, identify the narrow bottleneck and replan within the approved limits before repeating costly work. (INT-20261114-01)
