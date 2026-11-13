## Deferred Items

- Keep planning-test changes separate from planning documents and intent sources. This is resolved by prerequisite PR #87; its core/floor planning suites passed locally and its hosted CI is green. The Phase 2 PR is stacked on that branch and must retain the same boundary through final verification.
  status: resolved
- Floor-owned RTT source assertions ran under the core lane in the first full run. This is resolved by marking the floor guard module `:floor`; the final core suite excluded those checks and the floor suite passed them.
  status: resolved
- Several evidence and citation checks exceeded their default 60-second budget. Their assertions remain unchanged; the slow source/receipt/citation tests now have a 180-second per-test budget, and both full lanes pass. CN-004 passed at its existing default timeout in the uncontended run.
  status: resolved
- The installed `act` cannot parse the hosted workflow's `concurrency.queue` field, so local workflow jobs are unavailable. No workflow compatibility change is included; use hosted CI for the Phase 2 PR and main receipts.
  status: deferred
