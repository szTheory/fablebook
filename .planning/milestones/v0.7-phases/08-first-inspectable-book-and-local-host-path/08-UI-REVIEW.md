# Phase 8 — UI Review

**Audited:** 2026-11-25

**Baseline:** Approved `08-UI-SPEC.md`; records current UI conformance under the owner-accepted visual baseline (INT-20261125-04).

**Screenshots:** Captured at 1440×900, 768×1024, 375×812, and 320×900 from `http://127.0.0.1:4003/admin/dev/fablebook`; local and ignored under `.planning/ui-reviews/08-20261125/`.
**Interaction captures:** off (workflow.ui_interaction_capture is false)

Screenshots show the first paint only. Interaction observations below are code-derived; this audit did not repeat the 200% text-size or keyboard-focus checks recorded in `08-06-SUMMARY.md`.

---

## Pillar Scores

| Pillar | Score | Key Finding |
|--------|-------|-------------|
| 1. Copywriting | 4/4 | Contracted labels, unavailable-state copy, illustrative action labels, and Canvas notice are present. |
| 2. Visuals | 3/4 | Hierarchy and narrow stacking are clear; the 768px capture shows the Canvas notice cut at the iframe’s lower edge. |
| 3. Color | 4/4 | Neutral catalog surfaces and high-contrast essential boundaries; Logistify colors stay inside the Canvas. |
| 4. Typography | 4/4 | Catalog uses the four specified sizes and two weights. |
| 5. Spacing | 4/4 | Visible catalog spacing follows 4px increments and preserves the 44px navigation targets. |
| 6. Experience Design | 3/4 | States and landmarks are covered; the Journey breadcrumb link is smaller than the 44px target requirement. |

**Overall: 22/24**

---

## Top 3 Priority Fixes

1. **Let the Canvas frame expose its full content at 768px** — the persistent notice wraps below the 680px iframe viewport in the 768×1024 capture — size the host frame for the embedded document or provide a clear, usable scroll treatment.
2. **Give the Journey breadcrumb link a 44px target** — the interactive link currently receives only its text line height — use a flex target with `min-height: 44px` while retaining wrapping.
3. **Clarify the boundary token rule in the UI-SPEC** — `Hairline` is listed for the Canvas boundary, but its contrast against white is below the same spec’s 3:1 boundary requirement — document Ink as the accepted essential-boundary color so the current baseline remains unambiguous.

---

## Detailed Findings

### Pillar 1: Copywriting (4/4)

- **PASS:** Catalog labels and navigation use the approved terms “Books,” “Logistify operator console,” “Dispatcher recovery,” and “Scenarios.” The unavailable message and “Return to Books” recovery link are specific and match the contract ([`book_live.ex`](../../../lib/fablebook/book_live.ex:449)).
- **PASS:** Scenario actions are static text prefixed with “Illustrative:” and the persistent footer uses the exact approved copy, “Illustrative records and actions · no live dispatch or external changes.” ([`book_live.ex`](../../../lib/fablebook/book_live.ex:481), [`book_live.ex`](../../../lib/fablebook/book_live.ex:494)).
- **PASS:** The 320px and 375px captures show wrapped Scenario names without truncation. The notice remains readable content in the Canvas document, though at 768px its last wrapped line falls below the initial iframe view (visual/experience finding below).

### Pillar 2: Visuals (3/4)

- **PASS:** The desktop capture has a clear hierarchy: wordmark and Book tree at left, breadcrumb and screen title above a single Canvas focal point. The selected Scenario uses the Paper tint, full outline, and bookmark marker. The neutral host frame cleanly contains the darker Logistify preview.
- **PASS:** At 320px and 375px, the sidebar stacks above the Canvas and the first source-backed fact is visible within the initial viewport. At 768px and 1440px, the sidebar remains beside the Canvas. The captured pages show no visible horizontal clipping.
- **WARNING:** In the 768×1024 capture, the fixed-height iframe ends while the Canvas footer notice is wrapping; the final words are below the initial frame view. The outer host still has room below the frame. See [`tablet.png`](../../ui-reviews/08-20261125/tablet.png) and [`app.css`](../../../hosts/operator/priv/static/assets/app.css:412).

### Pillar 3: Color (4/4)

- **PASS:** Catalog chrome uses the intended neutral Paper, white, and Ink treatments. Essential shell boundaries use Ink (`#17181c`), which satisfies the contract’s stronger 3:1 non-text boundary requirement; preview colors are scoped inside `.operator-preview` ([`app.css`](../../../hosts/operator/priv/static/assets/app.css:386), [`app.css`](../../../hosts/operator/priv/static/assets/app.css:426)).
- **LOW:** The UI-SPEC table assigns Hairline (`#d9d6ce`) to the Canvas boundary, while its contrast rule requires at least 3:1 against white. The current Ink boundary resolves that conflict and matches the accepted baseline; clarify the token guidance for future implementation work.
- CSS contains eight distinct color literals: three neutral catalog colors and five Canvas preview colors. No general accent is used in the catalog.

### Pillar 4: Typography (4/4)

- **PASS:** Catalog declarations use only 13px, 14px, 16px, and 22px, with 400 and 600 weights ([`app.css`](../../../hosts/operator/priv/static/assets/app.css:60), [`app.css`](../../../hosts/operator/priv/static/assets/app.css:178), [`app.css`](../../../hosts/operator/priv/static/assets/app.css:267), [`app.css`](../../../hosts/operator/priv/static/assets/app.css:328)). The Canvas retains its separate embedded styling.
- Screenshots show clear distinction between the screen title, navigation labels, metadata, and body copy. Long labels wrap at the narrow captures.

### Pillar 5: Spacing (4/4)

- **PASS:** Catalog padding, gaps, and margins use 4px increments, including the mobile overrides; no catalog `2px`, `6px`, `10px`, or fluid `4vw` spacing remains. The mobile Canvas shell reduces to a 4px inset while retaining readable content ([`app.css`](../../../hosts/operator/priv/static/assets/app.css:133), [`app.css`](../../../hosts/operator/priv/static/assets/app.css:539)).
- The logo and navigation targets use 44px minimum heights. Internal `.operator-preview` spacing belongs to the separately styled Canvas and was not changed by Plan 08-06.

### Pillar 6: Experience Design (3/4)

- **PASS:** The catalog has labeled navigation, one screen heading, a named Canvas section, an accessible frame title, and a semantic footer outside the Scenario main landmark ([`book_live.ex`](../../../lib/fablebook/book_live.ex:127), [`book_live.ex`](../../../lib/fablebook/book_live.ex:167), [`book_live.ex`](../../../lib/fablebook/book_live.ex:494)). The polite Canvas status is visually hidden except when it reports a failure; empty and unavailable states have explanatory copy and a recovery path ([`book_live.ex`](../../../lib/fablebook/book_live.ex:187), [`book_live.ex`](../../../lib/fablebook/book_live.ex:445), [`app.js`](../../../hosts/operator/priv/static/assets/app.js:33)). Focus styling is 2px with a 4px offset ([`app.css`](../../../hosts/operator/priv/static/assets/app.css:47)).
- **WARNING:** The Journey link inside the Scenario breadcrumb has no target sizing rule, so its target is approximately one 14px text line rather than the specified 44px minimum ([`book_live.ex`](../../../lib/fablebook/book_live.ex:135), [`app.css`](../../../hosts/operator/priv/static/assets/app.css:308)). Sidebar and sibling-Scenario links do have the required height.
- **WARNING:** `#book-canvas` has a 680px minimum height but no content-based height rule. At 768px, the source-backed record content makes the embedded Canvas taller than that viewport; the notice’s second line is below the frame edge in the static capture ([`app.css`](../../../hosts/operator/priv/static/assets/app.css:412)). This is recoverable through iframe scrolling, but it makes the persistent caveat easy to miss on first view. This is inferred from CSS and the static capture; no interaction state was captured.
- No destructive controls are present, so confirmation and disabled-action states do not apply.

---

## Files Audited

- `.planning/phases/08-first-inspectable-book-and-local-host-path/08-01-PLAN.md` through `08-06-PLAN.md`
- `.planning/phases/08-first-inspectable-book-and-local-host-path/08-01-SUMMARY.md` through `08-06-SUMMARY.md`
- `.planning/phases/08-first-inspectable-book-and-local-host-path/08-CONTEXT.md`
- `.planning/phases/08-first-inspectable-book-and-local-host-path/08-UI-SPEC.md`
- Previous `.planning/phases/08-first-inspectable-book-and-local-host-path/08-UI-REVIEW.md`
- `lib/fablebook/book_live.ex`
- `hosts/operator/priv/static/assets/app.css`
- `hosts/operator/priv/static/assets/app.js` (status transition code)
- `hosts/operator/test/operator_host_test.exs` (assertion coverage reviewed; not executed)
- `.planning/ui-reviews/.gitignore`
- Captures: `.planning/ui-reviews/08-20261125/{desktop,tablet,mobile,narrow}.png` (all ignored)
