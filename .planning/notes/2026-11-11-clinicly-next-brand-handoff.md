---
date: "2026-11-11 21:36"
promoted: false
---

# Clinicly next; Chatly and Logistify handoff lessons

For the next Fablebook session preparing or consuming fictional adopter brand books. Capture authorized by [INT-20261111-12](../intent/sources/2026-11-11-12-save-demo-brand-takeaways.md). This preserves the recommendation sent to the owner for abracabrand; it is not an owner identity selection, approved implementation plan or completed integration.

## Next brand and handoff boundary

Recommend **Clinicly**, then Finanza, then Shopadelic. [The showcase brief](../../docs/research/TWINS.md) already puts Clinicly with Logistify and Chatly in the initial design-canon showcase. Clinicly adds Arabic RTL, denied access, accessible forms, calendars and appointment time zones; the other two add money/charts and imagery/white-label coverage later. No sixth brand is needed for the current matrix.

The owner carries the reply between sessions. abracabrand does not open or modify Fablebook. Its proposed spike 019 produces a fictional brand book, records and illustrations: no API spend, publishing or GitHub repository. It reuses the Chatly pipeline, two strong directions and one owner identity selection. The pasted command belongs in abracabrand, not this repository. The owner has not reported running it or returned a Clinicly folder.

The books belong to future **Design canon and adopter Books (`design-canon`), local Phase 4**, under the reset roadmap. Preserve the active milestone boundary and all product safety stops in [STATE.md](../STATE.md). This capture starts no phase, changes no gate and accepts no visual baseline.

## Clinicly coverage brief to retain

- **Appointments:** empty day, one, many, overlaps, long names, missing optional details, loading, unavailable, stale data, date changes, explicit time zones and crossing midnight.
- **Book an appointment:** clinician → date → slot → review → confirmation; no/one/many slots, field errors, slot lost before submission, submitting, submission failure with input retained, repeated/skipped local time around a daylight-saving change.
- **Patients:** empty/one/many, no search results, duplicate names with distinct invented identifiers, long names, missing avatar, loading, unavailable and denied access.
- **Patient details and visit notes:** no/one/many visits, missing optional information, long notes, read-only access, unsaved draft, saving, failed save with draft retained, saved confirmation. Denied screens disclose no patient details.
- **Reminders:** none/one/many, Scheduled/Sent/Not sent, missing contact method, loading, failure and Try again. Reminder text omits visit-note content.
- **Shared coverage:** light/dark, phone/desktop, English LTR/Arabic RTL examples, visible focus and logical reading/focus order, keyboard slot selection, accessible field errors and save announcements, 200% text and narrow reflow, reduced motion, offline/reconnecting. Use meaningful combinations rather than a full artificial cross-product.
- **Status families:** appointment Scheduled/Completed/Canceled/Missed; reminder Scheduled/Sent/Not sent. Keep both distinct from the brand accent, with words, icons and light/dark values. Clinical severity and billing are outside this brief. Recommend light as default, with a complete dark scheme and independent scheme/direction examples.

Product vocabulary: **Patient, Clinician, Clinic, Appointment, Slot, Visit, Visit note, Reminder**. Appointment means the scheduled booking; Visit means the encounter that occurred. Avoid client/customer/member for Patient, interchangeable provider/practitioner/doctor for Clinician, session/reservation/visit for Appointment, window for Slot, chart/report/consultation note for Visit note, and alert/notification for Reminder. Actions: **Book appointment, Reschedule, Cancel appointment, Save note, Try again**. Calm plain copy, without blame, clinical promises or jokes about failures.

Keep an English brand book with Arabic usage plates, not a localized book. Show Arabic joining, combining marks, punctuation, Arabic-Indic and Western digits, and mixed-direction dates/times, Latin names and `APT-0042`. Specify icon mirroring. Preserve shaping in font subsets; ship licenses, exact sample glyph inventory, full font and fallback guidance. Disclose lack of native-reader review rather than implying it happened.

## Records and Fablebook proof needs

Retain Chatly's plain JSON, README and stable IDs. Clinicly needs people/roles, clinics, slots, appointments, visits, visit notes, reminders, personas/jobs, cases and ordered flows. All content is invented. Never reuse or renumber IDs; resolve every reference. Include offsets plus named time zones, duration, fixed sample today and formatting rules; distinguish missing values from empty strings.

Put changing state in each case/step: selected slot, appointment status, note draft/save result, reminder status and access role. Preserve one appointment's identity through rescheduling and failures. Cases specify actor, screen, record IDs, language/direction, color scheme, exact viewport and simulations. Flow steps specify case references, exact action labels and outcomes. Every illustration references its case and rendering settings. Request a runnable validator for references, order and displayed text.

Fablebook should eventually demonstrate a Clinicly Book, Foundations pages, controls through full Screens, and booking success/slot-loss/save-failure recovery. These are future acceptance inputs. Illustration checks and declared contrast-pair arithmetic do not verify an implemented product's accessibility or behavior.

## What was actually inspected

Sources are **untracked in the preserved primary checkout** at `docs/brand/chatly/` and `docs/brand/logistify/`; these folders are not present merely because this reviewed worktree contains the planning note. Preserve them without cleanup or copying into the current guard candidate. Read the book HTML, `BRAND.md`, `brand.json`, `tokens.json` and asset/records READMEs. This session inspected source text/data only, without rendering a browser or PDF.

Observed Chatly **0.3** and Logistify **1.0**. Neither was wired into a working Fablebook catalog. No runtime workaround or integration clash was established. A local one-off check found Chatly's record IDs unique and checked references resolving; all 27 case IDs and both flow IDs occur in the HTML. Every path listed in each brand's `brand.json` file table exists. Those checks establish neither illustration fidelity nor complete schema validation.

Chatly's file has 44 people, 10 conversations and 26 messages, plus the cases and flows. Stable IDs make the intended mapping inspectable; runtime reuse remains untested. **Keep this record shape. Logistify has no equivalent records file in the copied folder.**

Source SHA-256 at capture (recheck before integration):

| Primary-checkout source | SHA-256 |
| --- | --- |
| `docs/brand/chatly/BRAND.md` | `5d25263c5f79c4441d5705a691d7d8cd673ef8e18a5e8d68b93843f383b6c8f5` |
| `docs/brand/chatly/brand.json` | `3fddb671fc31c3a986db110b0100944a326c164dac3c8e2488f7ee456b077830` |
| `docs/brand/chatly/tokens.json` | `18bb2c4778a4ed0e033fc0b243a0c52350a2e51032fc67bd391dde4db536eec3` |
| `docs/brand/chatly/assets/records/chatly-records.json` | `1a243ab83ab0b781368e4d3506f5bbd8764900ac095f45b2cbe02590972c6236` |

Logistify's `BRAND.md` still matches the hash in [its existing intake](../references/logistify-brand-intake.md). Keep that intake's rights, sound, print, localization and review limits.

## Integration lessons and unresolved choices

1. Root `tokens.json` is a neutral subset requiring deliberate mapping. [ADR 0012](../../docs/adr/0012-canon-format.md) assumes older `brandbook/tokens/identity.json`, `inventory.json` and `rights/assets.json` paths; neither copied brand supplies those paths. Add an explicit mapping/inventory/rights handoff at integration rather than claiming compatibility or forcing the source books into the old layout.
2. Chatly chose **light-first Pear**, while the old showcase brief says dark-first violet/coral. Reconcile the stale starting direction against the supplied identity; do not silently recolor the delivered book. Fablebook's own catalog colors remain separate from adopter colors.
3. The original reply suggested source `cases` → Scenarios and `flows` → Journeys. Treat that as a provisional adapter idea, **not a settled schema or terminology decision**. The newer [Fablebook brand intake](../references/fablebook-brand-intake.md) records owner wording for case and leaves story/user-flow and canon naming unresolved. Preserve source IDs, distinguish circumstance records from rendered scenarios, and reconcile the owner direction before implementing a mapper. Do not revert to “situation” from stale vocabulary or rename contracts during this capture.
4. Qualify standalone HTML claims. Self-contained book HTML can embed its presentation; an asset index references sibling files. Document exactly which deliverables can stand alone.
5. The owner reports Chatly 0.3 fixed a focus-badge `.tn` collision with the hover panel. Preserve a regression check and scope/namespace book CSS; do not reserve short class names across the adopter's application. No browser confirmation of that fix was performed here.
6. Japanese in Chatly is usage data, not a localized product. Its M PLUS 2 subset covers exactly 108 sample characters; other Japanese text needs the shipped full font or system fallback. Apply the same explicit boundary to Arabic samples.
7. Fictional names are not cleared names; light owner reading is not deep product acceptance. Request explicit asset reuse terms and keep accessibility, native-language, device and browser claims bounded by actual evidence.

Next useful brand action: owner transfers the recommendation to abracabrand and later supplies the selected Clinicly source folder. Future Fablebook integration reads this note plus the existing intakes and reconciles vocabulary and source paths first. No further Fablebook action is needed solely to preserve this session.
