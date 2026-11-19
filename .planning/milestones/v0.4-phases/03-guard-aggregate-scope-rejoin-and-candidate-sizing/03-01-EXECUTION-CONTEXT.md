# Plan 03-01 Compact Execution Context

This note is a compact, cited index of the canonical constraints needed by Plan 03-01. The cited project documents remain authoritative; consult a cited section if a decision cannot be resolved from this summary. It does not change phase scope, safety stops, or approval authority.

## Outcome and evidence contract

- Build a fresh, read-only core/floor inventory and join every original guard exclusion identity to its current owner, exact live MFA sets, source identities, and relevant caller/delegate paths. Keep gaps explicit; counts alone do not prove equality. Keep lane records authoritative and link a row-level crosswalk to those records and exact sources. Reuse existing helpers and add a narrowly scoped collector only for missing evidence. Prior inventories remain historical inputs. [PROJECT.md:42-51; ROADMAP.md:18-29; REQUIREMENTS.md:7-14; 03-RESEARCH.md:12-22]
- Preserve actual EX-010 and EX-107 delivery receipts and their distinct delivered/historical partitions. Never reinterpret a prior slice as aggregate closure. Candidate sizing comes after the complete join; recommend one bounded later increment only if exact remaining scope, source/caller evidence, context and effort all fit. Otherwise select no candidate and state the gap and bounded remedy. Any later implementation needs a separate owner decision. [ROADMAP.md:24-29; REQUIREMENTS.md:10-14; 03-RESEARCH.md:16-18,44-53]
- The active acceptance is GSR-01 through GSR-06: repeatable lane inventory and provenance; exact identity/member rejoin and complements; source/caller links or named gaps; receipt and partition preservation; measured current source/context/effort fit under inherited limits; and an inspectable owner decision without new dispositions or closure claims. [ROADMAP.md:22-29; REQUIREMENTS.md:7-27]
- Pattern baseline: `TierSweepTest` owns the private identity ledger, compiled matchers, and full graph; compose `InstalledOtp`'s current-export inventory and `SweepEvidence`'s source/digest helpers; use ASN.1 tests as a set-assertion analog. No existing helper performs the full aggregate join, so any collector remains narrow. [03-PATTERNS.md:7-14,206-234]

## Binding limits and stops

- Keep work static. Never invoke audited OTP APIs, callbacks, atom sinks, generated-code paths, runtime evaluation, or atoms from input. Stop at an actual-library collision; preserve the Macro caller-AST and explanation-wording checkpoints. [PROJECT.md:336,338; REQUIREMENTS.md:9,14,25-27; 03-RESEARCH.md:64-77]
- SEC-01 remains with `controls-bundle:1` and Pending; the guard aggregate gate stays open; Walking Skeleton stays blocked. No disposition change, implementation authority, or automatic follow-on phase. [PROJECT.md:44-51; REQUIREMENTS.md:14,18-20; PLANNING-GATES.json:5-20; 03-RESEARCH.md:16-18,53]
- Keep the 100,000-token plan ceiling, fixed 31,000-token reserve, 69,000-token working allocation, at most five exact-source body-read events per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan. Do not truncate required evidence or substitute a heuristic for a measured fit. [REQUIREMENTS.md:13; 03-01-PLAN.md:96-99]
- Do not add dependencies or a general-purpose audit framework. Keep any contract-test change separate from the production implementation it guards. Do not lower quality gates. [PROJECT.md:336,341,352-354; 03-RESEARCH.md:14,22]
- Keep git free of PII and absolute home paths; fixtures remain synthetic. [PROJECT.md:359]

The exact task event schedule and any measured context totals remain in `03-01-PLAN.md`, `03-01-READ-LEDGER.md`, and `03-01-RECOVERY.md`. This note does not certify context fit; the plan must record an exact count and numeric bounds before any source-body event begins.
