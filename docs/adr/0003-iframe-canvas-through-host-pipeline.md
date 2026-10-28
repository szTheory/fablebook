# 0003. The canvas is always an iframe rendered through the host's pipeline and root layout

**Status:** Accepted · **Cites:** INT-20261028-01, INT-20261028-04

## Context
The biggest group of phoenix_storybook complaints comes from rendering inline in a shared DOM:
- fonts, preflight and Tailwind v4 layer conflicts: #494, #615, #652, #699, #419, #426, #289, #178, #17;
- hook re-registration: #284, #268, #287, #657;
- serif overrides.

Colocated hooks and colocated CSS (LiveView 1.1/1.2) work only when the host's `app.js` and `app.css` are loaded.

## Decision
- The router macro defines a **canvas** `live_session` with no `root_layout` override, so it inherits the host pipeline's root layout. That brings the host's `app.css`, `app.js`, colocated hooks, LiveSocket, CSRF, CSP and fonts.
- The workbench embeds the canvas in a same-origin iframe. Phoenix 1.8's default `frame-ancestors 'self'` already permits this.
- The grid ("All scenarios") renders a story's scenarios stacked in a single iframe and lazy-renders tiles. "One scenario" uses its own iframe.
- Fablebook injects no JS into the canvas except the opt-in probe.
- Options: `canvas_pipeline` and `canvas_root_layout` overrides, for hosts whose root layout carries analytics or other side effects.

## Rejected
- Inline rendering with a CSS prefix: this is the incumbent's original mistake.
- A separate endpoint (the LiveDebugger model): it loses the host's CSS and hooks, and with them fidelity.
- An inline opt-in mode in 1.0: YAGNI.

## Consequences
- When the host app breaks, the canvas breaks too. The canvas therefore shows a diagnostic: missing `window.liveSocket`, `frame-ancestors`, X-Frame-Options.
- Classes used only in stories never reach production CSS. Stories use the app's real classes, and Fablebook provides placement CSS through a nonce'd `<style>`.

## Reversal trigger
A grid of 40 scenarios exceeds the render budget in ADR 0015, even with stacked rendering and lazy loading.
