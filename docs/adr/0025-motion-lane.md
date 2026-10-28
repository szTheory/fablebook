# 0025. Motion is a first-class lane: seekable, slowed, filmstripped, checked

**Status:** Accepted, 2026-10-28 · **Cites:** INT-20261028-12, INT-20261028-13 · **Detail:** `docs/research/MOTION-AND-UX-DIMENSIONS.md`

The owner calls great animation support "HUGEly important". Prior tools barely address motion: Chromatic pauses animations at their end, and Storybook has no mainstream motion addon. Motion is also exactly where reviewing one screen at a time leaves you blind. So Fablebook treats motion as its own lane.

## Workbench Motion panel
- Pause every canvas animation and scrub a timeline built from `document.getAnimations()`.
- Play at 0.1×, 0.25× or 0.5×. A time-dilation shim in the canvas stops LiveView's `time:` timers from cutting slowed animations short.
- Show a filmstrip of frames at 0, 50, 100, 150, 200 and 300 ms, plus the settled state.

## Reduced motion
- In the workbench, a `[data-motion=reduce]` custom variant switches it on. The installer adds the variant and the doctor checks that it's present.
- The browser runner uses real media emulation instead.

## CI motion lane
Seeked filmstrips are deterministic, so they get baselined and diffed. Ordinary visual diffs keep animations disabled.

## Checks
These are strict by default and can be waived (ADR 0024).
- **Tokens.** Durations and easings must come from the canon's motion tokens. Fablebook ships strong default curves that override Tailwind's weak default.
- **Bans:**
  - `transition: all`
  - animated layout properties
  - ease-in on enter
  - `scale(0)`
  - UI motion over 300 ms, unless the scenario is tagged marketing
  - hover motion outside `(hover:hover)`
  - any movement that survives reduced motion
- **LiveView lints:**
  - `JS` `time:` must equal the CSS duration.
  - `blocking: true` on decorative transitions.
  - `JS.show` without `display:` on a flex or grid element.
  - `stream_delete` without an exit animation.
- **Motion tier.** Scenarios declare `motion_tier: :keyboard | :frequent | :occasional | :rare`, which is linted against the frequency gate. Keyboard-initiated actions never animate.

## LLM bundles (`--focus motion`)
- `motion.json`: properties, keyframes, timing and easing for each animation, sampled every 16 ms.
- A filmstrip contact sheet.
- Reduced-motion frames.

The bundle never includes video: Claude can't read it, and sampling at 1 fps misses UI motion. Feel still needs a person watching at 0.25×, and the bundle says so.

## Considered options
- **Disable motion and review static frames only**, as Chromatic does. Rejected because it keeps the blind spot.
- **Video for review and diffs.** Rejected for diffs because it isn't deterministic, and for LLMs because they can't read it. Video remains an optional artifact for people.
