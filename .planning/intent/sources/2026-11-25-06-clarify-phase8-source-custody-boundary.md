---
id: INT-20261125-06
date: 2026-11-25
source: Direct owner response to the Phase 8 source-custody boundary question
captured_by: Codex
context: Clarifies whether the approved original-source check is required at Book authoring time or at every local host startup. This decision preserves the source-custody gate for creating content and the pinned-excerpt check in CI while allowing local browsing from the reviewed checkout without the ignored originals cache.
---

# Owner decision — source custody is an authoring and CI gate

> Authoring and CI only (Recommended): check original files before creating Book content, then validate the pinned excerpt in CI; local browsing works from the reviewed checkout.

For Phase 8, require the original-source custody preflight before authoring or changing Book content. Continue validating the checked-in pinned excerpt and citations in CI. Do not require the ignored raw source cache or repeat the original-source check for each local host startup; a reviewed checkout must remain browsable without the cache.

This preserves the original-source hash gate, exact-source provenance, pinned manifest verification, and the rule against creating Book content from missing or changed originals. It does not authorize changing source pins, fetching sources during host startup, weakening CI checks, or clearing any separate safety stop.
