# Interop opportunities with the owner's other libraries (eventual roadmap)

This document covers integration opportunities, not commitments. Nothing here is forced into 1.0. Its purpose is to keep the right seams open. (INT-20261028-10)

## Scope note (INT-20261028-11)
Fablebook covers UI that the Elixir/Phoenix app renders. The "external rendition" seam below is **not** a 1.0 commitment. Renderers are dispatched by subject kind internally only. Elixir-rendered emails (mailglass, chimeway) and PDFs (rendro) may become subject kinds later. Native screens (Crosswake) are out of scope beyond web-only shell-frame previews.

## Originally proposed seam: external renditions (superseded by INT-20261028-11 and ADR 0022; kept for history)
Several integrations need a **subject that is not a Phoenix component** and a **Rendition that is a pre-rendered artifact** (PNG, PDF, email HTML) with its source recorded, rather than a live iframe render. Crosswake native screens, mailglass emails, chimeway notifications and rendro documents all have this shape.

Decide the renderer seam now (ADR 0022's `render/3`) as:
- an open set of subject kinds, dispatched through a renderer behaviour;
- a Rendition that may be a pre-rendered artifact.

The second-most-valuable seam is **generator-emitted stories**: libraries that generate UI into the host (sigra, Crosswake) also emit Fablebook stories for it.

## Crosswake (`~/projects/crosswake`)
- **What it is.** A Phoenix library that decides, route by route, which runtime owns a screen when a Phoenix app ships as iOS or Android apps: `:live_view` (rendered in a WebView), `:offline_island`, or `:native_screen` (SwiftUI/UIKit/Kotlin in host-owned native shells). It writes a versioned JSON runtime manifest. It is not LiveView Native.
- **UI.** It ships no importable components (`ComponentTierGuard` bans `~H` and `attr` in `lib/`). Its generators copy UI templates into the host. Its tokens use DTCG 2025.10.
- **Path to native previews, cheapest first:**
  1. A web-only **shell-frame** preview (safe-area insets, a route-owner badge, offline and denied states) as a globals/frame option.
  2. Read the Crosswake manifest and tag each Screen story with its runtime owner, flagging `:native_screen` routes.
  3. Have Crosswake generators emit Fablebook stories next to the components they generate.
  4. Show native subjects as **external renditions** from SwiftUI previews, simulator snapshots, or Compose/Paparazzi images.
  5. A live simulator canvas. This is the most expensive option and probably not worth it.
- **Seams originally proposed (superseded by INT-20261028-11; only internal subject-kind dispatch remains):**
  - Subject kinds as an open tagged union.
  - Renditions that may be artifacts.
  - Viewport and frame globals with room for platform and safe area.
  - A DTCG resolver that accepts several token sources.

## Other libraries (highest value first)
| Library | Opportunity | Value | What Fablebook needs |
|---|---|---|---|
| mailglass | Mailables already define scenarios via `preview_props/0`; `/dev/mail` captures a width × theme × scenario matrix | high | An "email" subject kind (sandboxed HTML iframe, text part, client widths) mapped from preview props |
| abracabrand | Brand books become brand canon | high | Already planned (CANON-03, CANON-05, the twins) |
| Admin/operator UIs: accrue_admin, threadline, oban_powertools, scoria, lockspire, scrypath_ops, chimeway_admin, cairnloop, rindle, relyra, sigra | Mountable admin packages ship their own stories | high | Story discovery inside dependencies (deferred to v1.x), plus the dogfood fleet |
| chimeway | `preview_rendering/3` renders one notification channel without sending it | med-high | Notification subject; each channel is an external rendition |
| rendro | Deterministic pure-Elixir PDF layouts (invoices, statements, tickets) | med | Document subject; PDF → PNG renditions; rendro themes take DTCG tokens |
| sigra | Generated auth LiveViews (login, MFA, passkeys) | med | Generator-emitted stories with denied/error/locked scenarios |
| parapet | SLO and telemetry evidence | low-med | Possibly consumes Fablebook's check telemetry; not a story source |
| kiln | An LLM software factory | low-med | Consumes Fablebook bundles as agent input; needs a stable, versioned bundle format |
| keepling | A Mac/iPhone app | low | A later consumer of native renditions |

No plausible link: oarlock, gabbaboy, muhtari, glueyneo, playstead.
