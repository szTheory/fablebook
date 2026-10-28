# Fablebook

Fablebook is a workbench where every real state of a Phoenix LiveView UI, from a single control up to a whole screen, is shown, checked, and explained to people and to LLMs. It also holds the design-system knowledge (tokens, brand, voice, words, personas, jobs) that the UI is built from.

This file is the only source of vocabulary. Phoenix's own words (attr, slot, assigns, LiveView, LiveComponent, HEEx, function component, root layout) keep their Phoenix meaning. For implementation-level details (events, errors, modules), see `docs/domain/DOMAIN-MODEL.md`.

## Workbench

**Fablebook**:
The library and its workbench.

**Book**:
One adopter-defined catalog with its own settings, mounted at one path. An app may have several Books.
_Avoid_: backend, config

**Workbench**:
The part of the interface Fablebook owns, around the canvas: sidebar, toolbar, inspector, palette.
_Avoid_: manager, dashboard, explorer

**Canvas**:
The isolated document in which a scenario renders through the host app's own layout, styles and scripts.
_Avoid_: sandbox, preview (in code), iframe

**Host app**:
The adopter's Phoenix application that a Book renders inside. In Fablebook's own repo, a representative app used for testing.
_Avoid_: twin, demo app, example app

## Stories and scenarios

**Story**:
The catalog entry for exactly one component, its subject. It owns that component's scenarios. Every component has at most one story.
_Avoid_: fable, spec, story meaning a single state

**Subject**:
The component a story is about. Areas and Screens must have presentational function components as subjects. LiveComponents are allowed up to Area. A LiveView needs a waiver.
_Avoid_: target, component (when the story is meant)

**Page**:
A prose entry in the catalog, written in Markdown or HEEx, with no subject. A page may embed live scenarios.
_Avoid_: docs entry, MDX

**Scenario**:
One named, fixed, addressable state of a subject that depicts a real situation.
_Avoid_: variant, variation, example, case, state, knob combination

**Situation**:
The real-world circumstance a scenario depicts, stated in one line, e.g. "Empty: new account, nothing sent yet".
_Avoid_: description (as the concept's name)

**Group**:
Scenarios shown together in one grid for comparison. Each scenario keeps its own identity and address.
_Avoid_: variation group

**Unstoried**:
A component in a Book that has no story yet. It is shown using only the values its own declaration provides.
_Avoid_: orphan, auto-story

**Override**:
A temporary change to a scenario's attrs, made through a control. It is never saved.
_Avoid_: args, edit

**Control**:
An input in the inspector that changes one attr of the current scenario.
_Avoid_: knob

**Preset**:
A named, author-declared value that a control can choose for an attr too complex to type, such as a struct.
_Avoid_: fixture (for this meaning)

**Playground**:
The single-scenario view in which controls are active.
_Avoid_: sandbox

**Globals**:
The fixed set of settings for the environment a scenario renders in: theme, design direction (a candidate look), color scheme, locale, text direction, viewport, device frame, and motion (full, reduce, off).
_Avoid_: context, scope, environment

**Theme**:
A named visual skin a Book can render under, such as a brand theme or a white-label merchant's colors and logo. A twin may bring its own theme.
_Avoid_: token set, skin

**Direction**:
A candidate replacement for the canon's look and voice, explored before committing (greenfield or refresh). You can switch to it and compare it across the whole catalog. Choosing it makes it the canon; the alternatives are archived. Unlike a theme, it never ships.
_Avoid_: theme, variant, option

**Placement**:
How a scenario sits inside the canvas: centered, padded, or full-screen.
_Avoid_: layout

**Appearance**:
The workbench's own light/dark setting. It never affects the scenario. The scenario's look is set by its theme and color scheme.
_Avoid_: theme

**Mobile layout**:
How the workbench itself arranges when it runs on a phone-sized screen.
_Avoid_: review mode

**Isolate**:
The workbench view that hides everything except the canvas.
_Avoid_: focus mode, zen mode

**Container**:
Markup a story or Book wraps around every scenario it renders.
_Avoid_: decorator, layout

**Draft**:
A story or scenario still being shaped. Its token, visual and copy rules report warnings instead of errors, and it stays in the review queue until it becomes strict.
_Avoid_: wireframe, sketch, mockup

**Render mode**:
Whether a story renders as a live LiveView page or as a static page served by a controller with no socket, matching how it is served in production.
_Avoid_: dead/live (informal)

**Fixture**:
Adopter-owned example data, built without a database, and shared by scenarios, tests and demo seeds.
_Avoid_: factory, mock, seed

## Tiers

**Tier**:
How large a piece of UI a story's subject is, on a closed four-step ladder: Primitive, Pattern, Area, Screen. Each tier answers one question: is this control right, do these controls do their small job, does this part hold up with real data, can this persona finish the job.
_Avoid_: atom, molecule, organism, level

**Primitive**:
A single reusable control, such as a button, input or badge.
_Avoid_: atom, element

**Pattern**:
A few primitives working together for one small job, such as a form field with its error, a filter bar, or an empty state.
_Avoid_: molecule, group

**Area**:
A self-contained part of a screen that must hold up with real data, such as a list with its toolbar and pagination, a detail panel, or the Shell.
_Avoid_: widget, block, region

**Screen**:
A whole page, inside the Shell, on which a persona gets one or more jobs done.
_Avoid_: page (that is prose), view

**Shell**:
The Area that frames every screen: layout, navigation, header and flash area.
_Avoid_: chrome (that is the workbench), frame

**Section**:
A navigable part of the product, such as "Deliveries". It names a folder in the sidebar and is not a tier.
_Avoid_: surface, module

**Foundations**:
The catalog section that presents the canon: tokens, type, color, spacing, motion, imagery, voice, glossary, personas, jobs and twins. It is not a tier.
_Avoid_: base, theme

## Journeys and motion

**Journey**:
A job shown end to end as an ordered set of scenarios, usually spanning several screens, so the transitions between them get reviewed as well as the screens themselves.
_Avoid_: flow, user flow, path

**Step**:
One stop on a journey: a scenario plus the action the user takes to move on, e.g. "Rebook" on the failed-shipments list. Journeys are linear; an alternative path is a separate journey.
_Avoid_: stage, node

**Dead end**:
A step whose action no longer exists on its screen.

**Device frame**:
A generic outline of a phone, tablet, laptop or desktop drawn around a preview, with safe areas where relevant. Used for review and shareable images.
_Avoid_: mockup, device skin

**Motion tier**:
How often a user meets an animation (keyboard, frequent, occasional, rare). Under the **frequency gate**, the tier decides how much motion is acceptable: never for keyboard-triggered actions, and delight only when the animation is rare.
_Avoid_: animation level

**Filmstrip**:
Frames of a rendition's animations captured at fixed times, so motion can be reviewed, compared and diffed deterministically.
_Avoid_: video, recording, GIF

**Focus**:
The kind of feedback a bundle asks an LLM for. The list is closed: explore, critique, copy, a11y, layout, consistency, brand, compare, journey, motion.
_Avoid_: mode, prompt type

## Situations and coverage

**State class**:
A kind of situation from a closed list: happy, empty, one, many, boundary, loading, error, denied, stale, long, intl, huge. A scenario may belong to several.
_Avoid_: permutation, edge case

**Waiver**:
A declared exemption from one rule for one story, scenario or canon entry, with a written reason, e.g. that a state class doesn't apply or that a LiveView can't yet be extracted. It stays visible and is counted. There is no global waiver.
_Avoid_: exception, skip, ignore, override

**Coverage**:
Each story set against each state class, showing for every pair a scenario, a waiver or a gap.
_Avoid_: test coverage

**Gap**:
A story and state class with neither a scenario nor a waiver.

**Prune**:
To delete a scenario the app can never render, that duplicates another, or that depicts no real situation.
_Avoid_: cleanup

## Canon

**Canon**:
The adopter's version-controlled design knowledge: tokens, terms, voice, tone, microcopy rules, personas, jobs, twins and imagery rules. The workbench shows it as Foundations.
_Avoid_: docs, brand assets, design knowledge

**Brand canon**:
The canon shared by every product under one brand: voice, core terms, tokens and imagery rules.

**Product canon**:
One product's canon: its personas, jobs, product terms and tone. It inherits the brand canon. Overriding a brand rule requires a waiver.
_Avoid_: sub-brand canon

**Term**:
A user-facing word with its meaning, its label in each locale, the internal names it corresponds to, words to avoid, and retired wording.
_Avoid_: glossary item

**Retired wording**:
Phrases that must never again appear in the UI.
_Avoid_: deprecated term

**Voice**:
How the product sounds, everywhere.
_Avoid_: tone (when the constant is meant)

**Tone**:
How the voice shifts for a particular surface or user state.

**Microcopy rule**:
A mechanical, checkable copy convention, such as sentence case, or buttons starting with a verb.
_Avoid_: style guide

**Persona**:
A person who opens the UI to get a job done, e.g. "On-call engineer".
_Avoid_: user

**Job**:
A job to be done: "When…, I want…, so I can…". A screen may serve several jobs.
_Avoid_: task, user story

**Twin**:
A realistic, fictional organization the UI serves, often modeled on a real kind of product, e.g. a Japanese consumer chat app or a German freight-logistics firm. Its data fills scenarios so the design is tested against real-world variety. Each scenario picks the twin that makes its situation real. It appears in the UI as "Sample data". Twins nest: Fablebook's own twins are fictional adopter products, and each of those products' canon has its own twins (the organizations that product serves). Consumer products may have none.
_Avoid_: tenant, customer, persona, profile

**Proposal**:
A canon entry drafted by an agent or person but not yet confirmed. Rules treat it as advice, never as the rule. Only a person confirms it.
_Avoid_: draft (as a status), suggestion

**Citation**:
A scenario's stated link to the persona, job and twin it depicts.
_Avoid_: tag (tags only filter)

**Token set**:
The design tokens (color, type, spacing, radius, shadow, motion, layers) that make up the canon's single source of visual values.
_Avoid_: theme (theme is a global)

**Contrast pair**:
A declared pairing of foreground and background roles for a given use, checked in every color scheme.

## Checks and evidence

**Simulation**:
A forced environment condition used to stress a rendition: reduced motion, 200% text, text expansion, forced colors, a vision deficiency, keyboard only.
_Avoid_: emulation (in user-facing copy)

**Sweep**:
A run of checks across every rendition in the manifest, at each standard viewport and color scheme.
_Avoid_: crawl, scan

**Contact sheet**:
A single image tiling many renditions or filmstrip frames, so an LLM can review them within its image limits.
_Avoid_: collage, grid image

**Rendition**:
One scenario rendered under one set of globals at one viewport. It is the unit for reproducing anything.
_Avoid_: cell, snapshot

**Probe**:
The measuring that runs inside the canvas against a rendition.
_Avoid_: audit

**Check**:
One automated rule applied to a rendition or to the canon. Its outcome is pass, fail, unknown or not run.
_Avoid_: test, audit

**Evidence**:
What a probe recorded about a rendition, plus its screenshot. It goes stale when the rendition changes.
_Avoid_: report

**Finding**:
One problem a check found, with a stable fingerprint.
_Avoid_: error, violation

**Known findings**:
Findings already accepted as existing. The set may only shrink.
_Avoid_: baseline, allowlist

**Ratchet**:
The rule that known findings may only shrink and never grow.

**Verdict**:
An owner's judgment on one finding (fix, accept or reject). A rejected finding is not reported again.
_Avoid_: decision, triage note

**Baseline**:
A screenshot of a rendition that a person has accepted as correct. It is never accepted automatically.
_Avoid_: golden, snapshot

**Diff**:
A comparison of a new screenshot against its baseline.

**Golden**:
A committed, expected text output, such as a bundle or manifest.
_Avoid_: baseline

**Comparison**:
Renditions shown side by side that differ in exactly one respect: a global (light vs dark, locale, viewport), a theme (merchant A vs merchant B, direction A vs direction B), or a revision (this branch vs main).
_Avoid_: A/B test (that measures real users)

**Guardrail**:
A check applied to themes the adopter doesn't control, such as white-label merchant colors, so an unreadable choice surfaces as a finding.

**Review queue**:
Everything waiting for a person: proposals, stale or assumed canon, findings without a verdict, gaps, waivers due for review. The UI calls it "To review". It never interrupts.
_Avoid_: notifications, inbox, triage

## Catalog and context

**Catalog**:
Everything one Book contains: its stories, scenarios and pages.
_Avoid_: registry, index

**Manifest**:
The machine-readable description of a catalog and its component contracts.

**Contract**:
What a component declares about itself: its attrs, its slots and their documentation.
_Avoid_: schema, API

**Bundle**:
A context package for an LLM that covers a chosen part of the catalog: images, structure, measurements and the canon it cites, all within a token budget.
_Avoid_: export, dump

**Budget**:
The token limit a bundle must fit within. It decides what gets dropped.

**Static export**:
A server-free copy of a catalog (planned for v1.x).
_Avoid_: bundle, build

## Scope
Fablebook covers UI that the Elixir/Phoenix app renders. Native mobile screens are out of scope.

## Relationships
- A **Book** holds one **Catalog**, which contains **Stories** and **Pages**.
- A **Story** has exactly one **Subject**, a **Tier**, and one or more **Scenarios**.
- A **Scenario** depicts one **Situation**, belongs to one or more **State classes**, and **cites** one **Persona**, one or more **Jobs** and at most one **Twin**. Citing a persona and job is required for Areas and Screens and optional for Primitives and Patterns.
- **Coverage** sets **Stories** against **State classes**. Every **Gap** must be filled by a **Scenario** or a **Waiver**.
- A **Rendition** is a **Scenario** under specific **Globals**. **Probes** produce **Evidence**, **Checks** produce **Findings**, and **Verdicts** settle **Findings**.
- A **Bundle** draws on **Renditions**, **Evidence** and the **Canon** that its **Scenarios** cite.
- A **Persona** is a person; a **Twin** is an organization. A **Job** links them to **Screens**.

## Flagged ambiguities
- "Digital twin" meant two things. The CI apps are **Host apps**; the example organizations are **Twins**.
- "Decision" meant an ADR, a gate change, and a judgment on a finding. Judgments on findings are **Verdicts**.
- "Baseline" meant an accepted screenshot and a set of known findings. Only the screenshot is a **Baseline**.
- "Foundation" was a tier. It is now the **Foundations** section, which shows the **Canon**.
- "Direction" always means a candidate design look. Left-to-right versus right-to-left is **text direction**, labelled "LTR"/"RTL" in the toolbar.
- "Section" was a tier. It is now a product folder in the sidebar. The **Shell** is an **Area**.
