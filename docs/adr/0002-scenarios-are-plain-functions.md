# 0002. Scenarios are plain functions; slots are never strings

**Status:** Accepted · **Cites:** INT-20261028-01, INT-20261028-04

## Context
phoenix_storybook stores slots as HEEx strings (`slots: ["<:x>…</:x>"]`). That causes issues #206, #128, #48, #477 and #536, and it is the root of the eval CVE. The owner's methodology requires every scenario to depict a real situation, with persona and JTBD.

## Decision
- **Arity 0 means data.** `def empty, do: %{attrs: %{…}, slots: %{inner_block: "Retry"}}`. Data scenarios drive controls.
- **Arity 1 means a template.** `def composed(assigns), do: ~H"…"`, for compositions. Controls only overlay overrides.
- **Slots:**
  - A string is always escaped text.
  - A rich slot is a captured function returning `~H`.
  - Named slots are lists of maps.
  - `Fablebook.Render.Slots` is the only code that builds the LiveView slot shape.
- **Metadata:** `@scenario desc:, persona:, job:, twin:, state:, group:, tags:`.
  - `desc` (the situation) is required.
  - `tier:` is set on the story.
  - Citations are canon string ids (`persona: "on-call"`). Their *shape* is checked at compile time; their *existence* is checked at catalog build and in generated tests (no canon `@external_resource`, so editing canon never recompiles stories).
  - Persona and job citations are required on Area and Screen scenarios. The rule is a warning until the canon has its first persona and an error after that (ADR 0024). It is waivable per scenario. There is no Book-wide off switch.
- **One story per component.** Every story has exactly one subject, and every component has at most one story. A composition worth showing is first extracted into its own presentational component, which pushes adopters toward clean components (INT-20261028-06). Pages are the only entries without a subject.
- **Twins are citations, not inputs.** A scenario always renders the same twin's data, so renditions stay deterministic. "Sample data" filters by twin. `state:` takes one or more state classes.
- **Subject kinds:**
  - `:component` (function component). Required for Area and Screen.
  - `:live_component` (Primitive to Area; hosted in the canvas LiveView; controls must be declared because LiveComponents have no attr metadata).
  - `:live_view` (`live_render` with `session:` from the scenario). Allowed **only with a Waiver** (ADR 0024).
  - Screens are presentational: the LiveView keeps mount, params, events and data loading, and its `render/1` calls the screen component with assigns. Fablebook renders that same component with twin data. Streams passed as attrs are materialized by the canvas. Pages (Markdown or HEEx) are not subjects.
- **Containers and placement:** an optional story-level `container/1` (a HEEx function taking `inner_block`) plus a Book-level default container; `placement: :centered | :padded | :fullscreen`.
- **Globals** are a closed set (theme, design direction, color scheme, locale, text direction, viewport, device frame, motion), all in the URL; see `docs/research/UX-DESIGN.md` § URL parameters.

## Rejected
- A `scenario do … end` DSL: hides the functions and adds macro surface.
- Making every scenario a template: removes controls.

## Reversal trigger
None expected. Revisit only if LiveView changes its slot representation incompatibly.
