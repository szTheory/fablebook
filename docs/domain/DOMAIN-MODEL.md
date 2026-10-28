# Fablebook domain model: implementation vocabulary

The language itself lives in `GLOSSARY.md` at the repo root. This file maps that language onto code: telemetry, errors, modules, and a sketch of the story format. Every term used here must also be defined in `GLOSSARY.md`.

## 1. Domain events → telemetry

All events are `[:fablebook, domain, action, :start | :stop | :exception]` spans unless marked *(single)*.

- Metadata is restricted to ids, kinds, counts and enums.
- Attr values, assigns, params, rendered HTML, file paths and user data are **never** included.
- Fablebook never attaches handlers; it only emits.

| Domain event | Telemetry event | Metadata |
|---|---|---|
| CatalogBuilt | `[:fablebook, :catalog, :build, *]` | story_count, scenario_count, source (compile, reload) |
| ScenarioRendered / RenderFailed / RenderContained | `[:fablebook, :scenario, :render, *]` | story_id, scenario_id, purpose (canvas, test, bundle, export), render_mode (live, static), error_type |
| OverrideApplied / CastRejected | `[:fablebook, :control, :cast]` *(single)* | story_id, control, type, result (ok, invalid) |
| GlobalsChanged | `[:fablebook, :canvas, :globals]` *(single)* | changed keys |
| SubjectEventEmitted | `[:fablebook, :canvas, :event]` *(single)* | story_id, event_kind (push, info) |
| CanvasCrashContained | `[:fablebook, :canvas, :crash]` *(single)* | story_id, reason_kind (raise, throw, exit, timeout, heap) |
| CheckRunCompleted | `[:fablebook, :check, :run, *]` | rendition_count, finding_count, rule_ids_count |
| JourneyChecked / DeadEndFound | `[:fablebook, :journey, :check, *]` | journey_id, step_count, dead_end_count |
| FilmstripCaptured | `[:fablebook, :motion, :capture, *]` | rendition_count, frame_count, animation_count |
| WaiverApplied | `[:fablebook, :waiver, :apply]` *(single)* | rule_id, scope (story, scenario, canon) |
| ImageExported | `[:fablebook, :shot, :export, *]` | frame, count |
| CanonLoaded / CitationBroken | `[:fablebook, :canon, :load, *]` | entry_counts, broken_count |
| CoverageComputed / GapDetected | `[:fablebook, :coverage, :compute, *]` | gap_count, waiver_count |
| EvidenceIngested / EvidenceStale | `[:fablebook, :evidence, :ingest, *]` | rendition_count, stale_count |
| BundleBuilt | `[:fablebook, :bundle, :build, *]` | scope, detail, est_tokens, image_count, dropped_sections |
| ManifestWritten / ManifestDrift | `[:fablebook, :manifest, :write, *]` | story_count, drift (bool) |
| FindingRaised, BaselineAccepted, VerdictRecorded | not telemetry; recorded in files and git | — |
| ExportWritten (**v1.x**, not in the 1.0 catalogue) | `[:fablebook, :export, :write, *]` | count, needs_server_count |

The prod guard is a compile-time `CompileError`, not an event.

The catalogue of events lives in `Fablebook.Telemetry.events/0`. A test fails on any event that is emitted but not listed, and on any listed event that is never emitted.

---

## 2. Errors

`%Fablebook.Error{type: type, message: String.t(), details: map()}`. Match on `type`, never on the message.

The `type` set is closed:
`:story_not_found` · `:scenario_not_found` · `:invalid_scenario` · `:invalid_attrs` · `:render_failed` · `:render_timeout` · `:render_memory_exceeded` · `:cast_failed` · `:state_too_large` (URL state or control value over its cap) · `:invalid_canvas_token` (signed canvas topic) · `:path_rejected` (editor or `--out` path outside its root) · `:unsupported_subject` · `:canon_invalid` · `:broken_citation` · `:invalid_token_set` (DTCG) · `:evidence_missing` · `:evidence_stale` · `:budget_exceeded` · `:manifest_drift`

Mistakes in a declaration (a missing `desc`, a duplicate id, a malformed citation, a bad option) raise **`CompileError`** naming the file, line, offending value and a fix ("did you mean `:size`? declared attrs: …").

---

## 3. Bounded contexts → modules

| Context | Modules | Owns |
|---|---|---|
| Story | `Fablebook.Story`, `.Scenario`, `Fablebook.Book` | Declaration macros (≤20 injected lines), compile-time validation |
| Catalog | `Fablebook.Catalog`, `.Auto`, `.Coverage`, `.Id` | Discovery, ids/URLs, auto-stories, coverage matrix |
| LiveView adapter | `Fablebook.ComponentInfo` | The **only** code that touches `__components__/0` and the LiveView slot shape |
| Render | `Fablebook.Render`, `.Slots`, `.Contain` | The render seam `render(scenario, globals, purpose)`, containment |
| Controls | `Fablebook.Controls`, `.Cast`, `Fablebook.URLState` | Typed casting, presets, URL codec |
| Canon | `Fablebook.Canon`, `.Tokens`, `.Frontmatter`, `.Lint`, `.Contrast` | `design/` parsing, DTCG, lints, contrast, DESIGN.md generation |
| Workbench UI | `Fablebook.Router`, `Fablebook.UI.{WorkbenchLive, CanvasLive, Layouts, Assets}` | Mounting, chrome, canvas |
| Evidence | `Fablebook.Evidence`, `Fablebook.Probe` (JS in `priv/`) | Schema, ingest, staleness, fingerprints |
| Manifest / AI | `Fablebook.Manifest`, `Fablebook.Bundle` | `index.json`, `components.json`, bundles |
| Testing | `Fablebook.Testing`, `Fablebook.Test.Visual` | Generated scenario tests, `live_isolated` helpers, the visual-baseline guard |
| Export (v1.x) | `Fablebook.Export` | Static build |
| Shared | `Fablebook.Telemetry`, `Fablebook.Error` | Spans, event catalogue, closed error set |
| Mix tasks | `fablebook.install`, `.gen.story`, `.doctor`, `.manifest`, `.bundle`, `.tokens`, `.shot`, `.gen.screens`, `.skills.install`, `.migrate.phoenix_storybook` | Pure core + thin Mix shell each |

Everything not listed as public carries `@moduledoc false`. Target: ≤25 public modules at 1.0.

---

## 4. Sketch: what a story looks like

```elixir
defmodule MyAppWeb.Storybook.Deliveries.StatusBadge do
  use Fablebook.Story, subject: &MyAppWeb.Components.status_badge/1, tier: :primitive

  @scenario desc: "Delivered: the common case on the list page", persona: "ops-lead", job: "JOB-01", state: :happy
  def delivered, do: %{attrs: %{status: :delivered}}

  @scenario desc: "Retrying after a provider timeout, third attempt", persona: "on-call", job: "JOB-03", state: :error
  def retrying, do: %{attrs: %{status: :retrying, attempt: 3}}

  @scenario desc: "Long localized label in German, ops lead scanning the list", persona: "ops-lead", job: "JOB-01", twin: "acme-freight", state: :long
  def long_label(assigns), do: ~H"<.status_badge status={:bounced} label={Fixtures.long_label(:de)} />"
end
```
