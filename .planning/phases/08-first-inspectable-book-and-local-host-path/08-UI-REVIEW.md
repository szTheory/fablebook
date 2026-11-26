# Phase 8 — UI Review

**Audited:** 2026-11-25
**Baseline:** Approved `08-UI-SPEC.md`
**Screenshots:** captured (desktop 1440×900, tablet 768×1024, mobile 375×812; additional 1280×900 and 320×900 captures)
**Interaction captures:** off (workflow.ui_interaction_capture is false)

Visual captures were made from `http://127.0.0.1:4003/admin/dev/fablebook` and remain local under `.planning/ui-reviews/08-20261125-185251-4003/`. Interaction findings below are code-derived; the optional interaction capture was off.

---

## Pillar Scores

| Pillar | Score | Key Finding |
|--------|-------|-------------|
| 1. Copywriting | 3/4 | The persistent illustrative notice differs from the exact contracted copy. |
| 2. Visuals | 3/4 | Clear Canvas focal point; on narrow screens, the record details begin below the first viewport. |
| 3. Color | 2/4 | The Canvas boundary is only 1.45:1 against white, below the contract's 3:1 non-text boundary requirement. |
| 4. Typography | 2/4 | Catalog chrome uses an undeclared 12px size and 500 weight. |
| 5. Spacing | 2/4 | The stylesheet uses 2px, 6px, and 10px spacing plus fluid `4vw` padding. |
| 6. Experience Design | 2/4 | The required footer landmark is absent; some navigation targets and focus offset miss the contract. |

**Overall: 14/24**

---

## Top 3 Priority Fixes

1. **Meet the non-text boundary contrast rule** — the shell-to-Canvas frame is difficult to distinguish for low-vision users — darken the Canvas boundary to at least 3:1 and reconcile the `Hairline` role with the contract.
2. **Complete the navigation accessibility contract** — screen-reader users lack the required footer landmark and smaller navigation targets are harder to operate — add a semantic footer, raise link targets to 44px, and set the focus offset to 4px.
3. **Bring catalog type and spacing onto the declared scales** — visual rhythm and hierarchy drift across breakpoints — remove the 12px/500 catalog styles and off-scale 2px/6px/10px/14px and fluid spacing values.

---

## Detailed Findings

### Pillar 1: Copywriting (3/4)

- **WARNING:** [lib/fablebook/book_live.ex:482](../../../lib/fablebook/book_live.ex:482) renders “Illustrative records and actions. No live dispatch or external changes.” The contract requires “Illustrative records and actions · no live dispatch or external changes.” This persistent safety notice should match the approved copy exactly.
- Other copy follows the contract: “Books,” “Logistify operator console,” “Dispatcher recovery,” “Scenarios,” and “A failed shipment” are present. The unknown-screen message and “Return to Books” link are specific. The authored actions are static text prefixed with “Illustrative:” rather than operational controls.

### Pillar 2: Visuals (3/4)

- **Evidence:** The desktop captures show a clear hierarchy: Fablebook wordmark and tree at left, breadcrumb and Scenario title above the main Canvas, with the dark Scenario document as the focal content. The active Scenario has a Paper tint, full outline, and bookmark marker. The Canvas stays visually bounded by the white host frame.
- **WARNING:** In the 375×812 capture, the stacked sidebar and page heading push the Canvas record facts below the first viewport; only the Canvas heading and status are visible at the fold. At 320×900, the summary appears but the record facts remain below the fold. Tighten the narrow layout's vertical footprint while preserving the required links. Evidence: `.planning/ui-reviews/08-20261125-185251-4003/mobile.png` and `width320.png`.
- The 320/375 captures stack the sidebar above the Canvas, while 768/1280/1440 keep the sidebar beside it. No page-level horizontal overflow is visible at these widths.

### Pillar 3: Color (2/4)

- **WARNING:** [hosts/operator/priv/static/assets/app.css:389](../../../hosts/operator/priv/static/assets/app.css:389) uses `#d9d6ce` for the Canvas boundary on white. Its contrast is approximately 1.45:1, below the same UI-SPEC's minimum 3:1 for non-text boundaries. The value matches the declared `Hairline` token, so the token and boundary rule need reconciliation; use a stronger neutral for this boundary.
- The shell otherwise uses a restrained neutral palette with no general accent. CSS has 10 unique hard-coded colors: five catalog/shell colors and five preview colors scoped under `.operator-preview` (lines 426–440). The Logistify dark treatment remains inside the Canvas and status is paired with the visible word “Failed.” `#5c5f66` is used for muted chrome labels but is not declared in the UI-SPEC palette.

### Pillar 4: Typography (2/4)

- **WARNING:** Catalog CSS uses five sizes (12px, 13px, 14px, 16px, and 22px) and three weights (400, 500, and 600), beyond the contract's four sizes (13/14/16/22px) and two weights (400/600). The 12px tree labels are at [app.css:182](../../../hosts/operator/priv/static/assets/app.css:182), and the 500-weight Journey link is at [app.css:186](../../../hosts/operator/priv/static/assets/app.css:186). The brand font is correctly declared and loaded from the local Fablebook asset at lines 10–15.
- Canvas-specific typography is separated in `.operator-preview`; the deviation is in catalog chrome, not the embedded document's source-styled content.

### Pillar 5: Spacing (2/4)

- **WARNING:** The catalog stylesheet departs from the declared 4px spacing increments: examples include 2px gaps at [app.css:174](../../../hosts/operator/priv/static/assets/app.css:174) and [app.css:214](../../../hosts/operator/priv/static/assets/app.css:214), 2px label margins at [app.css:180](../../../hosts/operator/priv/static/assets/app.css:180), and 6px/10px padding at [app.css:342](../../../hosts/operator/priv/static/assets/app.css:342).
- The main panel uses `clamp(20px, 4vw, 48px)` at [app.css:229](../../../hosts/operator/priv/static/assets/app.css:229), which produces intermediate gutters outside the fixed spacing scale. Use declared increments for the catalog layout.

### Pillar 6: Experience Design (2/4)

- **WARNING:** The UI-SPEC requires semantic `header`, labeled `nav`, `main`, and `footer` landmarks. Headers, navigation, and main regions are present, but no `<footer>` appears in `book_live.ex` or the host layout. The persistent Canvas notice at [book_live.ex:482](../../../lib/fablebook/book_live.ex:482) is a paragraph rather than a footer landmark.
- **WARNING:** Some navigation targets miss the contract's 44px minimum: the linked wordmark is 32px high at [app.css:117](../../../hosts/operator/priv/static/assets/app.css:117), and compact Scenario links are 40px high at [app.css:340](../../../hosts/operator/priv/static/assets/app.css:340). Focus outline offset is 3px, not the required 4px, at [app.css:47](../../../hosts/operator/priv/static/assets/app.css:47).
- Positive state coverage: the shell includes the defined empty and unavailable states at [book_live.ex:187](../../../lib/fablebook/book_live.ex:187) and [book_live.ex:443](../../../lib/fablebook/book_live.ex:443). The loading/readiness status is visually hidden and polite; the host makes genuine failure guidance visible. [app.js:82](../../../hosts/operator/priv/static/assets/app.js:82) handles frame loading, and lines 113–120 handle ready/failure messages. Static authored actions need no disabled or destructive-confirmation state.
- Interaction capture was off, so keyboard focus, the live state transitions, and 200% text zoom were not freshly captured in this pass. Navigation uses links and CSS visibly defines focus treatment; the target-size and outline-offset findings are source-derived.

---

## Files Audited

- `.planning/phases/08-first-inspectable-book-and-local-host-path/08-UI-SPEC.md`
- Phase 8 `08-CONTEXT.md`, Plans `08-01` through `08-05`, and Summaries `08-01`, `08-03`, `08-04`, `08-05`
- `lib/fablebook/book_live.ex`, `lib/fablebook/catalog.ex`, `lib/fablebook/story.ex`, `lib/fablebook/router.ex`
- `hosts/operator/lib/operator_host.ex`
- `hosts/operator/storybook/operator_book.ex`
- `hosts/operator/priv/static/assets/app.css`, `app.js`, and the local Fablebook logo/font assets
- `.planning/ui-reviews/.gitignore` and the five local screenshot captures listed above

