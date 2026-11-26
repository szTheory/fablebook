---
phase: 08-first-inspectable-book-and-local-host-path
reviewed: 2026-11-22T22:20:20Z
source_report: 08-CANDIDATE-REVIEW-2026-11-22.md
findings:
  resolved: 2
  unresolved: 0
  new: 0
status: resolved
---

# Phase 8 Candidate Review Resolution

Focused read-only follow-up of WR-01 and WR-02 from the point-in-time report. The original report remains unchanged.

## WR-01 — CI drops source tooling self-tests: RESOLVED

The current core job restores both self-test commands at `.github/workflows/ci.yml:39-40`, before the pinned source fetch and verification at lines 41-42. Both are present in the current file, and the diff against the base shows them restored. The removed explicit `--check-original` invocation does not leave a coverage gap: `bin/verify_logistify_source`'s `check_pinned/0` calls `check_original(@brand_cache)` at line 135 and verifies the manifest against the cache afterward (lines 130-137).

## WR-02 — Citation test does not bind displayed values to cited data: RESOLVED

The current test decodes the pinned manifest and records, resolves every listed pointer, and compares the decoded manifest excerpt to the resolved source value at `hosts/operator/test/operator_host_test.exs:307-317`. It also checks each displayed text/pointer pair with `source_value_matches_display?/4` before checking that the text is rendered and that its pointer is among the Scenario citations (lines 319-327).

The helper checks concrete source relationships: the event timestamp formatting (lines 413-415), the completion claim against the flow's step count and result copy (lines 417-440), the absent shipment IDs against the bulk case's two listed IDs and twelve selected (lines 443-454), and the absent replacement driver against both the completion flow text and case fields (lines 456-468). Other text is matched against values recursively within the cited source value (lines 470-483).

The pinned `records/logistify/logistify-records.json` confirms those values: `/shipments/0` supplies the failure status, shipment ID, and route; `/drivers/0` supplies M. Keller; `/events/2` supplies `2026-11-10T14:20:00+01:00`; the cited copy pointers supply the exact failure and action labels; `/flows/1` reports twelve selected/reassigned; `/cases/7` lists only two IDs; and `/cases/8` plus completion step 5 do not identify a replacement driver. The encoded manifest excerpts for these pointers decode to the same source values as the test asserts.

## Final assessment

Both findings from the original report are resolved in the current candidate diff. No additional actionable issue was found within these two areas. No tests were run; this follow-up establishes the state of the CI declarations and the source-to-citation assertions by inspection only.

## Additional review — Canvas readiness retry: RESOLVED

The later readiness fix in `hosts/operator/priv/static/assets/app.js` was
reviewed after the original deep review. The parent registers its message
listener before checking for an already-loaded frame, validates same-origin
events and the current iframe source, and repeats the status request only while
the Canvas is incomplete. Ready and failure messages clear the retry timer;
the existing eight-second timeout bounds an unresponsive frame. The child
answers only same-origin requests from its parent for the currently mounted
screen. The failure and ready transitions were then confirmed in Chrome on the
actual Phoenix host. No new issue was found in this change.

The original 22:10 report remains a point-in-time record of its initial review;
this follow-up covers the later readiness code and real-browser result.
