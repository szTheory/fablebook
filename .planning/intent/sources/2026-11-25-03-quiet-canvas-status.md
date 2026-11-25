---
id: INT-20261125-03
date: 2026-11-25
source: Direct owner feedback during the Phase 8 live Scenario review
captured_by: Codex
context: Removes a redundant visible Canvas label and prevents transient readiness announcements from competing with the rendered screen while preserving accessible status updates and visible failure guidance.
---

# Owner correction — quiet Canvas status

Date: 2026-11-25
Source: direct owner feedback during the Phase 8 live Scenario review.

> “it is weird tho that it says Loading... like here: Loading screen: A failed shipment… also i dont think we need a label that says Canvas, that's self evident...”

Keep the screen's polite loading/readiness announcement available to assistive technology, but visually hide transient status lines so they do not compete with the Scenario already rendered in the Canvas. Keep actual failure guidance visible. Remove the redundant visible “Canvas” heading and give the section the accessible name “Scenario screen.”
