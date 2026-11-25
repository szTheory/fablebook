---
id: INT-20261125-02
date: 2026-11-25
source: Direct owner feedback after the Phase 8 preview correction
captured_by: Codex
context: Requires durable safeguards so resumed OpenGSD UI work preserves previously reviewed behavior and does not repeat source/spec drift.
---

# Owner direction — prevent reviewed UI regressions

Date: 2026-11-25  
Source: direct owner feedback after the Phase 8 preview correction.

> “yeah this is looking better what happened? this is the second time i've looked at our progress after some opengsd work and noticed it regressed. let's apply lessons learned here so we never run into this issue again. but it's looking like we're on ther ight path again..”

The repeated regression is a process issue as well as a UI issue. On resumed or revised UI work, compare the latest owner-reviewed behavior with the active checkout, intent, UI-SPEC and plan before editing. Preserve successful interactions and visual selection cues as regression checks, update stale contracts before implementation, and confirm that the browser preview is served from the intended checkout. Keep captures local unless the owner asks to publish them. These safeguards prevent this specific source/spec drift from silently returning; they do not replace the owner's deferred visual-baseline decision.
