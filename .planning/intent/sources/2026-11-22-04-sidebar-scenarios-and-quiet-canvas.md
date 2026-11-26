---
id: INT-20261122-04
date: 2026-11-22
source: Direct owner feedback while reviewing the Phase 8 Book in the local browser
captured_by: Codex
context: Clarifies the visible Scenario taxonomy in the sidebar and removes raw provenance dumps from the Canvas while keeping source traceability in authored data. Also requests a live local review and a plain account of the milestone scope.
---

# Owner feedback: make Scenario taxonomy and Canvas content clear

> “weird what happned to the \"scenarios\" thing in the sidebar now there's no clear taxonomy... between the journey and the scenarios under it... a regression... [Image #1]”
>
> “u also re-added this slop \"Sources
> records/logistify/logistify-records.json — Dispatcher recovery flow — JSON Pointer /flows/1
> records/logistify/logistify-records.json — Bulk selection and listed IDs — JSON Pointer /cases/7
> records/logistify/logistify-records.json — Reassignment result — JSON Pointer /cases/8
> records/logistify/logistify-records.json — Bulk count — JSON Pointer /copy/console-bulk-count
> records/logistify/logistify-records.json — Reassign action — JSON Pointer /copy/console-bulk-reassign\" in http://127.0.0.1:4003/admin/dev/fablebook/book/operator?scenario=bulk_reassignment is this really the latest one do u need to restart or something? seems like we took a step backwards. what did we even do this milestone? what do u want me to look at exactly..”

## Reconciliation

- In the sidebar, show the fixed tree in this order: Books → Book → Journey → “Dispatcher recovery” → Scenarios → Scenario links. The visible “Scenarios” label names the children directly beneath it.
- Preserve exact source citations in the authored Scenario data, source manifest, and source checks. Do not render raw source paths or JSON Pointer lists in the Canvas.
- The page was served from a preserved checkout whose Book and stylesheet matched the active Phase 8 branch at review time. Restart the local host from the active candidate after the fix so the owner sees the current files.
- Keep public PRs free of screenshot files and image embeds, per INT-20261122-03. Use the local Phoenix Book for visual review.
- When presenting the review, explain the bounded v0.7 deliverable and name the two concrete UI details to inspect. The visual baseline remains undecided until the owner's end-of-milestone feedback.
