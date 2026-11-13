## Deferred Items

- Full core and floor suites fail the planning guard's changed-file boundary assertion: `test/planning/planning_state_test.exs` is reported alongside `.planning/REQUIREMENTS.md` and intent sources. Leave the existing planning/intent changes untouched; reconcile the contract-test scope before treating either full suite as green.
  status: open
- The core full-suite command runs floor-owned RTT source assertions under the core archive and gets three expected floor-source mismatches. The focused floor contract passes under `bin/lane floor`; establish a lane-correct full-suite test selection before claiming both lanes green.
  status: open
- Exhaustive installed-OTP receipt and membership checks exceed their 60-second ExUnit timeout in both full-suite runs. The floor citation scan also times out. Investigate runtime cost and choose a bounded verification approach before retrying the full gate.
  status: open
- Local `act` cannot parse the hosted CI workflow's `concurrency.queue` field, so no local jobs ran. Use hosted CI for the required receipts; any local compatibility adjustment needs a separate scoped decision.
  status: open
