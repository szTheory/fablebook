# Motion, UX writing, skills, and the other UX dimensions

Research from 2026-10-28, prompted by the owner: "HUGEly important that we have amazing animations support out of the box" (INT-20261028-12).

## 1. Motion philosophy (Emil Kowalski, plus the installed skills)
Source: [emilkowalski/skill](https://github.com/emilkowalski/skill) (MIT). Install with `npx skills add emilkowalski/skill`. The skills installed locally are: emil-design-eng, animate, review-animations, improve-animations, find-animation-opportunities, animation-vocabulary, apple-design, break-ui and mobile-native. See also [emilkowal.ski/skill](https://emilkowal.ski/skill) and [You don't need animations](https://emilkowal.ski/ui/you-dont-need-animations).

### Gate 1: how often the user sees it
| Frequency | Example | Rule |
|---|---|---|
| 100+ times a day | Keyboard shortcuts, palette | Never animate |
| Tens of times a day | Hover, list navigation | Remove, or make it imperceptible |
| Occasional | Modal, drawer, toast | Standard animation |
| Rare or first time | — | The only place for delight |

Anything triggered from the keyboard is disqualified.

### Gate 2: purpose
Every animation needs a named purpose: feedback, spatial consistency, state indication, softening a jarring change, explanation, or delight (rare tier only). Never move data the user is reading.

### Easing
| Motion | Curve |
|---|---|
| Enter and exit | ease-out, `cubic-bezier(0.23,1,0.32,1)` |
| On-screen movement | ease-in-out, `cubic-bezier(0.77,0,0.175,1)` |
| Drawer | `cubic-bezier(0.32,0.72,0,1)` |
| Hover and color | `ease` |
| Constant motion | `linear` |

- **Never use ease-in for UI.**
- Built-in curves are too weak. Tailwind's default `cubic-bezier(0.4,0,0.2,1)` is one of them, so the canon must override `--ease-*`.

### Durations
| Element | Duration |
|---|---|
| Press | 100–160 ms |
| Tooltip | 125–200 ms (later tooltips appear instantly) |
| Dropdown | 150–250 ms |
| Modal or drawer | 200–500 ms |

- Keep UI motion under 300 ms.
- Stagger lists by 30–80 ms, and never block input while doing it.

### Springs and interruption
- Use springs for drag with momentum, elements that should feel alive, and interruptible gestures.
- Default spring: `{duration: 0.5, bounce: 0.2}`. Apple style: critically damped, response 0.3–0.4.
- A spring takes over the release velocity of the gesture that let go of it.
- CSS transitions retarget from the current value, but keyframes restart. Use transitions for toasts and toggles.

### Enter and exit
- Enter from `scale(0.9–0.97)` with opacity 0. Never `scale(0)`.
- Popovers scale from their trigger. Modals stay centered.
- Exit the way the element entered.
- Use asymmetric timing: slow where the user decides, fast where the system responds.
- Use `@starting-style` for enter animations.

### Reduced motion and what never to animate
- **Reduced motion means fewer, gentler animations, not none.** Keep opacity and color, drop movement. Gate hover motion behind `(hover:hover) and (pointer:fine)`.
- **Never animate:**
  - `transition: all`
  - width, height, margin, padding, top or left (accordion height is tolerated)
  - child transforms through a CSS variable on the parent
  - keyboard actions

### Review method
- Put changes in a Before/After/Why table.
- Fix in this order: delete, reduce, easing, origin, interruptibility, GPU, asymmetry.
- Play at 2–5× slower and step through frame by frame.

## 2. Motion in LiveView 1.2
Source: [JS docs](https://phoenix-live-view.hexdocs.pm/Phoenix.LiveView.JS.html).

### Primitives
- `JS.show`, `JS.hide`, `JS.toggle` and `JS.transition` take a `{transition, start, end}` class triple.
  - Options: `time:` (default 200), `blocking:` (default true), `display:`.
  - They emit the `phx:show-start` and `phx:show-end` events.
- `phx-mounted` runs enter animations. `phx-remove` runs exit animations, and LiveView waits for them before removing the element.
- **View Transitions.** [PR #4043](https://github.com/phoenixframework/phoenix_live_view/pull/4043) (shipped in 1.1.18+) added `dom.onDocumentPatch(start)` → `document.startViewTransition(() => start())`.
  - Prior art: [live_style](https://live-style.hexdocs.pm/advanced-features.html) and live_animate (early).
- **Tailwind v4:** `starting:`, `transition-discrete`, `motion-safe:` and `motion-reduce:`, plus theme variables `--ease-*` and `--animate-*`.

### Footguns (Fablebook should lint these mechanically)
1. **`time:` doesn't match the CSS duration.** LiveView removes the classes when its timer fires, so the animation snaps at 200 ms.
2. **`blocking: true` on decorative transitions** holds back server patches.
3. **Exits killed by patches.** `phx-remove` only fires on the element being removed, and `stream_delete` without `phx-remove` simply vanishes.
4. **Re-insertion replays enter animations** (stream reset, id change). Unverified; confirm before relying on it.
5. **`JS.show` defaults to `display:block`**, which breaks flex and grid layouts.
6. **Keyframes on toasts that patch often** restart every time.

## 3. Reviewing motion in a workbench (where Fablebook can lead)
Prior art is thin.
- Chromatic only pauses animations at their end state ([docs](https://www.chromatic.com/docs/animations/)).
- Storybook has no mainstream motion addon.
- The real models are the DevTools Animations panel, Framer's preview, and the Theatre.js and Lottie scrubbers.

### Techniques
1. **A seekable timeline.** In the same-origin iframe, `document.getAnimations()` covers CSS transitions and animations plus the Web Animations API (LiveView's transitions are CSS transitions). Pause and scrub `currentTime`, then read keyframes and timing. Catch new animations with `transitionrun` and `animationstart`.
   - It can't see animations driven by requestAnimationFrame, or LiveView's `time:` timers.
2. **Slow motion at 0.1×, 0.25× and 0.5×** using `playbackRate`. This needs a time-dilation shim on `setTimeout`, `performance.now` and requestAnimationFrame, or LiveView's timers cut the animation short.
3. **Reduced motion in the interactive workbench.** Page JavaScript can't toggle `prefers-reduced-motion` inside the iframe; only the browser runner can emulate it. The installer adds a Tailwind `@custom-variant motion-reduce` that also matches `[data-motion=reduce] &`, and the doctor checks it is present.
4. **Filmstrips: seeked frames at 0/50/100/150/200/300 ms plus the settled state.** These are deterministic, so they can be **baselined and diffed** in a motion lane. Ordinary visual diffs keep animations disabled.
5. **Video** (Playwright `recordVideo` or a CDP screencast) is for people only and is never diffed.

### Mechanical motion checks
**Over every element:**
- duration and easing come from the canon's motion tokens
- no `transition: all`
- no animated layout properties
- no ease-in on enter
- no `scale(0)` keyframe
- UI motion stays at or under 300 ms (unless the story is tagged as marketing)
- hover motion sits inside `(hover:hover)`
- nothing moves under reduced motion

**Phoenix-specific:**
- `time:` equals the computed duration
- `blocking: true` is flagged on decorative transitions
- `JS.show` without `display:` is flagged on flex or grid elements

**Scenario metadata:** a `motion_tier:` of `keyboard`, `frequent`, `occasional` or `rare`, linted against Gate 1.

**Springs:** encoded as CSS `linear()` easings so they stay seekable.

### Giving motion to an LLM
Claude doesn't accept video, and Gemini samples video at 1 fps, which misses a 200 ms transition. So the bundle carries three things:
- `motion.json`, with one entry per animation: target, trigger, properties, keyframes, duration, delay, easing, token match, and values sampled every 16 ms.
- A filmstrip contact sheet of 6–8 frames.
- Reduced-motion frames next to full-motion ones.

Models judge structure well: origin, starting scale, easing class, how properties sync. They can't judge feel, and the bundle says so plainly, sending feel to a person watching at 0.25×. This adds a new bundle focus: **`motion`**.

## 4. UX writing
Source: [content-designer/ux-writing-skill](https://github.com/content-designer/ux-writing-skill) v1.6.0, MIT, installed locally as `ux-writing`.
- Four standards: purposeful, concise, conversational, clear.
- Patterns for buttons, errors, empty states, forms and notifications, plus a voice chart.
- Benchmarks:

| Measure | Target |
|---|---|
| Button length | 2–4 words, 6 max |
| Title length | ≤ 40 characters |
| Error length | 12–18 words |
| Line length | 40–60 characters |
| Sentence length for comprehension | ≤ 8 words: 100%; ≤ 14 words: 90% |
| Reading grade | 7–8 for the public, 9–10 for professional tools |

- **Fablebook builds the mechanical part:**
  - button word count
  - sentence case
  - generic labels ("Click here", "Submit", "OK")
  - sentence length
  - reading grade per persona
  - placeholder-only labels
  - glossary and voice rules from the canon
- **It cross-references the judgement part.** Tone, blame and clarity go to the skill. The canon's `voice.md` can start from the skill's voice chart.

## 5. Skills strategy
### Prior art
- [usage_rules](https://usage-rules.hexdocs.pm/readme.html) is the Elixir-native channel. A package ships `usage-rules.md` and `usage-rules/skills/<name>/SKILL.md`, and the adopter runs `mix usage_rules.sync` to copy them into `.claude/skills` with a "managed-by" marker.
- Storybook's [AI setup](https://storybook.js.org/docs/ai/setup) is React/Vite-only and MCP-centric.
- `npx skills` requires Node, which adopters may not have (ADR 0018).

### Recommendation
1. **Ship a few small skills inside Fablebook:** `fablebook` (writing stories and scenarios), `fablebook-review` (using bundles), `fablebook-motion` and `fablebook-canon`.
2. **Install paths:** `usage_rules` sync, or `mix fablebook.skills.install`. The install is version-stamped and never overwrites files you've edited.
3. **Put rules into checks, not prose.** Each rule becomes a check with a stable id (e.g. `motion/ease-in-enter`). BUNDLE.md carries a short, attributed digest for each focus.
4. **Point to upstream skills, never install them.** BUNDLE.md names the relevant skill when it is installed (impeccable, ux-writing, review-animations, emil-design-eng). Otherwise it suggests installing it, marked optional. Third-party skills are never installed silently.

## 6. UI/UX dimension checklist
Coverage: **M** = mechanical check · **S** = supported through scenarios or simulation · **L** = LLM review with bundle evidence.

| Dimension | Coverage |
|---|---|
| Motion | M: tokens, LiveView lints, reduced-motion residue · S: filmstrips, slow motion, scrubbing · L: feel and purpose |
| Interaction states (hover, focus-visible, active, disabled, loading) | S: forced pseudo-states via CDP · M: each state differs visually, disabled semantics, `phx-click-loading` is styled · L: coherence |
| Forms and validation | S: pristine, invalid, server error, submitting · M: label association, `aria-invalid`/`describedby`, error text, autocomplete/inputmode, no placeholder-only labels, `used_input?` honored · L: timing and tone |
| Perceived performance and layout shift | M: layout-shift entries during a scripted load, skeleton matches final size, spinner only after ~300 ms · S: slow and optimistic scenarios |
| Data visualization | M: series contrast, legend or direct labels, an accessible table alternative, no color-only encoding · L: chart choice |
| Empty, error and recovery | S: required state classes · M: every error state offers an action · L: helpfulness |
| Toasts and notifications | M: live region and politeness, no focus theft, ≥5 s or pausable, dismissable, transitions rather than keyframes · S: stacking |
| Focus management | M: focus walk, trap and return on modals, focus not obscured (2.4.11), focus kept after a patch · L: order logic |
| Touch and gestures | M: 24 px floor and 44 px recommended, no hover-only affordances, single-pointer alternative to drag (2.5.7) · S: device frames |
| i18n | M: hardcoded-string Credo check, +35% text expansion overflow, RTL logical-property lint (`ms-`/`start`, not `ml-`/`left`) |
| Number, date and currency formats | M: ASCII-formatted values under a non-English locale, `<time datetime>` · S: time zones (Clinicly) |
| Print | S: print-media shot · M: no clipped content, no dark backgrounds |
| Dark patterns | M: pre-checked consent, confirmshaming via the glossary, cancel visibly weaker than confirm on destructive dialogs · L: the rest |
| Content density | M: line length 40–75ch, text density · L: persona fit |
| Information scent and navigation | M: unique link text, `aria-current`, heading outline, nav ARIA identity · L: label specificity |
| Sound and haptics | Not applicable on the web; out of scope |

**Highest leverage:** the motion lane (seekable, baselined filmstrips plus `motion.json`), forced pseudo-states, the LiveView JS-command lints, and the iframe reduced-motion variant. This is where Fablebook can beat both Storybook and Chromatic.
