# Phase 03 independent evidence review

## Metadata-only source and context schedule

Status: **source-body gate closed**. No implementation source or test body has
been emitted. The direct input-token count, independent schedule review, and
the fresh preflight immediately before that count are still required.

### Review scope and bounded inputs

Review GSR-01–06 and D-01–04 against the actual two lane records, sizing
decision, required report summary, collector, and tagged identity/caller
contracts. The records stay separate authorities. Lane arrays and the 13 MB
report are opaque inputs; use the compact keyed projection and the bounded
report section only. This task schedules five exact files: two code files and
three evidence files.

| Exact file | Bytes | SHA-256 | Bounded use |
|---|---:|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 | `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | Complete selected functions below; no other source reads |
| `test/contract/tier_sweep_test.exs` | 768,677 | `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | Complete selected tests below; no other source reads |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json` | 12,107,528 | `ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a` | Exact keyed projections only; no lane array emission |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json` | 11,828,076 | `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121` | Exact keyed projections only; no lane array emission |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-SIZING.json` | 17,357 | `7b3caeec99b0d8d1182386b095b27f4fa85f6056270cbe0989f7fe53baad0f16` | Complete bounded sizing record |

### Reproducible keyed lane projections

The two large lane files are selected only by the selectors and summary
algorithm below; full arrays remain un-emitted. Each projection starts from its
bound file and copies exactly these top-level fields unchanged:
`schema,generation,lane,identity,delivery,delivery_receipts,owner,candidate,implementation_authorized,aggregate_gate,walking_skeleton,sec_01,scope_complete,membership_join_complete,source_join_complete,target_source_coverage_complete,inventory_universe,selected_mfas,live_mfas,input_sha256,lock_sha256,membership_sha256`.
It also copies `target_source_records` unchanged. For each array at
`$.identity_rows`, `$.target_source_associations`, `$.target_source_gaps`, and
`$.required_evidence_gaps`, replace the full array with `{count, sha256,` plus
the relevant keyed distribution: `mapping_status_counts`, `status_counts`,
`status_counts`, or `reason_counts`. Missing or null direct field values in a
distribution map use the JSON key string `"null"`; other values use their
string form. `sha256` is SHA-256 of canonical UTF-8
JSON for the selected array, with recursive object-key sorting, compact
separators, preserved array order, and no trailing newline. Recursively apply
the same replacement to arrays inside `source_and_caller_evidence` and
`static_caller_evidence`; for their object arrays include `status_counts` and
`reason_counts` distributions. Copy non-array scalars and object keys
unchanged. Serialize the resulting projection with recursive key sorting,
compact separators, UTF-8, and no trailing newline, then SHA-256 it.

| Lane | Full record SHA-256 | Projection bytes | Projection SHA-256 | Identity rows | Source gaps | Required evidence gaps |
|---|---|---:|---|---:|---:|---:|
| core | `ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a` | 6,191 | `f26040b3b9319e0a77f0a2987a5fab060f1427732096d7b4ab09339aec5693cf` | 226 | 1,761 | 5,287 |
| floor | `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121` | 6,196 | `57fd78a919b9f5dae6c446682439764b29cba25c26de1a96ee4ddd3ef3b0aff8` | 226 | 1,716 | 5,152 |

### Complete source spans

Span hashes cover exact UTF-8 bytes including line endings. Function/test
boundaries are inclusive and include all clauses and the complete selected
test body. Token counts are intentionally pending the required direct count;
the cumulative span limit is 12,000 tokens.

| File | Complete function or test | Lines | Bytes | Span SHA-256 |
|---|---|---:|---:|---|
| collector | `build_lane!/1`, lane validation, aggregate validation, rendering and bundle validation | 16–318 | 12,093 | `852fd22e64027391ac7646525f60a578b09b3017087d0896cee5e58a4cdd768c` |
| collector | source attach/validation/crosswalk and static-caller attach/validation | 321–724 | 13,981 | `399193ae0c5a248fb638badb230fdb31b9fe2e78866f2de7d0685b1e39e5b38d` |
| collector | sizing validation/build plus static-caller rendering and parsing/source/delegate resolution | 727–1322 | 21,933 | `4ec3e18bd6401078bdebe5b05a523612666ad894e2dd9bfc0736767bda0595d5` |
| collector | required-value, safe canonicalization, sanitization and digest helpers | 1384–1427 | 1,674 | `c85ee3b26e4994de25e9b71c07d7f67c5da27bef6e294bfa64b775b33fa21ec0` |
| collector | target-source archive lookup and source-key indexing | 1494–1598 | 3,697 | `af9b973cd6f78f1d1ebbc5c701ffa83ab3119204d16e38467a21d2e638d0aa82` |
| contract | complete tagged original-identity, target-source acquisition, and caller-gap tests | 5600–6137 | 21,395 | `df46b58321f395edf05f32157032563a1506256b08aea0fd0cfafdb399671709` |

The complete contract span includes each test's preceding tags and ends before
the next test. It includes the target-source acquisition test identified in
independent review. All selected collector entry points, attach/validation
paths, source/caller crosswalk helpers, and archive/path/digest lookups are
included. The line/file digests above were computed over the exact inclusive
UTF-8 spans and checked against the current full-file digests. Total scheduled
span bytes: 74,773; direct token count is pending and must prove the 12,000-token
limit before body emission. File/task source cap: 2 of 5 exact source files.

One source path remains explicitly outside this bounded span schedule:
`test/contract/tier_sweep_test.exs`'s `aggregate_identity_rows!/4` construction
helper at line 5340 and its dependent helpers. The scheduled identity test and
compact projections expose the resulting complete 226-row identity digest and
both lane joins, but do not let the reviewer inspect how every identity row is
constructed. This is an owner-facing review gap, not a cleared check. Its
consequence is that source-level omission in row construction cannot be ruled
out by the independent body review. Remedy: separately authorize/replan a
bounded complete review of that helper and its dependencies, without changing
the ledger or accepting the row construction on counts alone.

### Compact context manifest

Required context is bounded to complete small policy documents and exact
sections/projections. Each complete input is selected as lines 1 through its
recorded line count. Bind every excerpt to the current file SHA-256, inclusive
line boundaries, byte count, and excerpt SHA-256 before counting. Context cap:
45,000 tokens. Include the current plan and replan, GSR requirements, Phase 3
goal/boundary, D-01–D-04 and inherited stops, current phase handoff, prior
findings and correction trace, current lane identity/membership/gap summaries,
candidate/fit/effort decision, and the concise report decision section. Never
emit full lane arrays or the full report body.

| Context source | Bounded selection |
|---|---|
| `.planning/intent/NORTH-STAR.md`, `.planning/intent/CLEARANCE.md`, `GLOSSARY.md`, `docs/adr/README.md`, `docs/adr/0004-no-eval-no-new-atoms.md`, `docs/adr/0014-testing-strategy.md`, `docs/adr/0018-dependency-budget.md`, `docs/adr/0021-delivery-rules.md`, `.planning/VERIFICATION.md` | Complete small policy documents; each bound by current digest |
| `AGENTS.md`, `CLAUDE.md` | Complete project instructions and workflow constraints, each bound by current digest |
| `.planning/REQUIREMENTS.md` | Lines 7–15 for GSR-01–06 and lines 22–28 for out-of-scope boundaries |
| `.planning/ROADMAP.md` | Phase 3 goal, success criteria, and boundaries |
| `.planning/STATE.md` | Current position, active handoff, Phase 3 decisions and stops |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md` | Complete phase boundary, D-01–D-04, and evidence/safety decisions |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-PLAN.md` | Complete plan, exact full-file binding below |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-SUMMARY.md` | Lines 65–119, exact file and excerpt binding below |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-KEYED-EVIDENCE.json` | Complete compact keyed projection, exact full-file binding below |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-PLAN.md`, `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-REPLAN.md` | Complete execution constraints, exact full-file bindings below |
| `.planning/milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-CONTEXT.md` | Lines 11–25 and 46–50 for the separate EX-107 partitions |
| `.planning/references/PHASE-DELIVERIES.json`, `.planning/references/PLANNING-GATES.json`, `.planning/references/PLANNING-LIFECYCLE.md`, `.planning/migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md`, `.planning/milestones/v0.2-CLOSEOUT.md`, `.planning/milestones/v0.3-CLOSEOUT.md` | Current receipts, gate ownership, lifecycle, carry-forward obligations, and prior-scope closeouts; exact digests below |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECONCILIATION.md` | Only the concise candidate sizing/owner decision section; file digest bound; report body stays closed |

| Bounded report excerpt | Exact binding |
|---|---|
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECONCILIATION.md` | Full file: 13,115,491 bytes, SHA-256 `3ee538cdce64372ffe9a6641894ba309f976572118bae3f3c73d90fdfd488c61`; selected lines 5–12: 528 bytes, SHA-256 `4522ccd14b59c0441f105f5aa0ac30e69f6b98b3cc6b6e0e6e77c7238d453cf3` |

Context hash bindings (complete files; lines; bytes; SHA-256):
`AGENTS.md` (1–40; 6,295;
`86f3c829e1853ff1ba66e54f7301da9d2706e4d3a6b9353fd5d118663936e1c7`),
`CLAUDE.md` (1–36; 3,743;
`7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2`),
`.planning/intent/NORTH-STAR.md` (1–34; 3,559;
`c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248`),
`.planning/intent/CLEARANCE.md` (1–16; 2,154;
`1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff`),
`GLOSSARY.md` (1–370; 15,891;
`e1f8dbee98abf437ee6851f103a93e119dff97a0416b93754a8dd41ae55e25c6`),
`docs/adr/README.md` (1–32; 2,597;
`8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5`),
`docs/adr/0004-no-eval-no-new-atoms.md` (1–24; 1,649;
`5d9232471b38fc7e038749bbc85145e6a608b70412c9d15c50b425e442c4fb23`),
`docs/adr/0014-testing-strategy.md` (1–29; 2,323;
`42c70f5792c98c3ea8a77eb9cc7aec8c94c7d1f8b6101306bb3d8fb76cea34e4`),
`docs/adr/0018-dependency-budget.md` (1–29; 3,066;
`3ca266284f17d26ee5f2044d00ffa4b7e8d60336fe6e1d3191aa393927ad46cf`),
`docs/adr/0021-delivery-rules.md` (1–34; 3,072;
`2074bc6920a6bc36cd4e295a5649a2b82036f37899cb3fa9d26fa69441582a56`),
and `.planning/VERIFICATION.md` (1–25; 5,352;
`0295edd62cb7b6351075b8ace1ddfa1203ab18fe175b757950cc1caa5b048e66`).
Also include `.planning/references/PHASE-DELIVERIES.json` (1–25; 779;
`16d5e37be6579c9ed78b3418ec31c2e541a916c1d5eddef3a7fb4e0531bce088`),
`.planning/references/PLANNING-GATES.json` (1–22; 503;
`ca2fc6d23ad474dad7d72688fee03a71dfff38e4d8e4d3237e1ecef0bec1271b`),
`.planning/references/PLANNING-LIFECYCLE.md` (1–53; 7,775;
`5e1e5a09d270d496b73f9d11f346a9bd95f0eb7dc79fe0101c5900eecef01255`),
`.planning/migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md` (1–25; 3,456;
`c3362c64769ba4d6a770defd65263a1b1d7c2781dc03d7aad50250dca0b2302f`),
`.planning/milestones/v0.2-CLOSEOUT.md` (1–169; 13,042;
`dfcd65c2aaa1eb1d789816354f5ed6757ad7e15a76932fd71bf8e291277a1c8f`),
and `.planning/milestones/v0.3-CLOSEOUT.md` (1–33; 3,319;
`b02325de36e48bb57d43418989d2bdc0dae6e10756e85242d4b1b17f643c5c4d`).
For `.planning/references/PHASE-DELIVERIES.json`, select only the exact v0.2
Phase 1 EX-010 and v0.3 Phase 2 EX-107 receipt objects. Their canonical compact
JSON projection digests are `ded2db3bd5032b952dd48e3669195da503df15cf07c7302966fa924a2da30433`
and `f564b5bc12a53ded99e7e50964bc4482bd5d36737fc5634275781d836434b822`.
Reproduce each projection by selecting exactly the matching object in the
top-level `phases` array (`milestone == "v0.2" && phase == "1"`, or
`milestone == "v0.3" && phase == "2"`), retaining exactly
`milestone,milestone_key,phase,status,pr,reviewed_head,merge_commit,ci_run`,
serializing as UTF-8 JSON with recursively sorted object keys, compact
separators, and no trailing newline, then SHA-256 hashing those bytes.
For EX-107, retain the separate 3/174 and 13/164/161 sets and historical
remainder digest from `.planning/milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-CONTEXT.md`
(lines 11–25: 1,984 bytes, SHA-256
`0007c18e442561b090e40b60779dfcf3eb2c64032436cd6108dcf10f3f00a296`; lines
46–50: 1,107 bytes, SHA-256
`4a18c59ce59dae4fcdf08fae01eac3412b743b3e9f95da4289a57a3f9da1abd7`). No
historical archive bodies are selected.
The selected exact sections follow. Excerpts are `.planning/REQUIREMENTS.md`
lines 7–15 (2,336 bytes, SHA-256
`e8ef98d2c649d46db23f7564c4a6c24e231d54c38a1fcdfebfc6fe264187d68b`),
and lines 22–28 (521 bytes, SHA-256
`8b16eb8344722d748f58db8f1bf2088ec8ce966bd1e59f0fdc3f31e5a1006e01`),
`.planning/ROADMAP.md` lines 16–33 (1,817 bytes, SHA-256
`8923814efd944830107a79ca4f769de06e2302f2358ad8176d6303d24f88d370`),
`.planning/STATE.md` lines 34–54 (2,320 bytes, SHA-256
`34bf08cae3cb1f95ea517d2319197ec524fe3ab5a2352bb74e3354cac4e06db0`),
`03-CONTEXT.md` lines 1–34 (3,518 bytes, SHA-256
`412f3ea65e9f6cdf8793438d967c15022ee8a7ac4249415992942baf4c7e1866`),
`03-03-SUMMARY.md` lines 65–119 (3,631 bytes, SHA-256
`233b4af297c5b38641385e34e4a95cca1b5bfa8364c981530036abd0c9bca50d`),
and `03-RECONCILIATION.md` lines 5–12 (528 bytes, SHA-256
`4522ccd14b59c0441f105f5aa0ac30e69f6b98b3cc6b6e0e6e77c7238d453cf3`).
The record projection input is the complete compact
`03-03-KEYED-EVIDENCE.json` (lines 1–216; 9,958 bytes, SHA-256
`5e8e6a92e870ab2ea7373017c93da70d50d5cb0fede817b8e1b586cfc0ae99c4`);
the three current machine record digests are listed above. `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-PLAN.md`
lines 1–143 (24,590 bytes, SHA-256
`5c71e01e7fbf93cdf7316911d8f138d5a7cbef24c4d7d40b5fa8f1878cbd006b`),
`.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-PLAN.md`
lines 1–147 (18,922 bytes, SHA-256
`a613a4ae0e480fc044d80e56e3b90bdc4dd418dc974ee538f46afe5cef697d33`), and
`.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-REPLAN.md`
lines 1–107 (6,508 bytes, SHA-256
`28f35ae2e5aa90d9e39a4359ee1f23f522069bc486567877e9ed31879aacccba`) are
complete exact inputs.
The large report digest is
`3ee538cdce64372ffe9a6641894ba309f976572118bae3f3c73d90fdfd488c61`; its
bounded section digest is separately listed above.

### Count gate protocol

No compatible local `o200k_base.encode_ordinary` tokenizer is installed. After
the independent schedule reviewer returns PASS, rerun
`bin/planning_health --stage execute --phase 3`, then call only the approved
count endpoint `POST /v1/responses/input_tokens` for `gpt-6-luna` using the
existing ignored `.env.local` credential. Do not print or persist the key. The
count must cover the exact serialized current context, schedule and review
receipt, all scheduled spans, ≤5,000 output tokens, 2,000 cushion, and the
fixed 31,000 reserve; record payload SHA-256, count result, method, and a
redacted harness description. Combined count must be ≤100,000 and charged
working source spans ≤12,000. Any schedule/context/receipt change invalidates
the count. No source body may be emitted before all three gates pass.

## Independent schedule review

**PASS — metadata only.** The independent reviewer verified the source/evidence
file identities, all scheduled span hashes/byte counts, reproducible lane
projection hashes and selectors, exact report and requirements excerpts, and
the receipt projection recipe. The reviewer read no source, test, or report
body. This PASS is bound to the schedule as it stood at SHA-256
`45470d8f278b34ee6f92bfd06025ce4d88781702d2123c31eb4e267b788e4952`. It does
not certify the 12,000-token span cap or the 100,000-token combined ceiling.
The unscheduled `aggregate_identity_rows!/4` construction path remains an
owner-facing gap with the consequence and remedy recorded above. Source-body
emission remains closed until the fresh preflight and direct count both pass.

## Direct count gate — FAILED; source-body gate remains closed

After metadata PASS and a fresh `bin/planning_health --stage execute --phase 3`
PASS (`route_phase: 03`), the approved count-only endpoint was called for
`gpt-6-luna`. No response was generated and no source body was emitted to the
model prompt. The source spans were transferred only to this count-only
endpoint. The exact serialized request SHA-256 values and responses are:

| Count input | Tokens | Request SHA-256 |
|---|---:|---|
| Hash-bound context and required keyed projections | 52,623 | `74e83fa3bb774d1f6d9b812476430f7d831948c643df9e1169d36c270cb043d5` |
| Scheduled complete source spans | 18,258 | `a9542b54155786af6bece789f50cc1125352a8e4ccba6e6d7f693fc78670e887` |
| Combined context, schedule/review receipt, and spans | 70,881 | `89387529e0db62eb883955d1d4254f34eeef02540f231d99b02a0d42d32373c7` |

The context exceeds its 45,000-token cap by 7,623; spans exceed 12,000 by
6,258. With the unchanged 5,000-token output allowance, 2,000-token cushion,
and 31,000-token reserve, the projection is 77,881 working tokens and 108,881
total, exceeding the 69,000 working envelope and 100,000 total ceiling by
8,881. These are direct endpoint counts, not byte-based estimates. The
responses bind to this pre-receipt schedule SHA-256:
`0abecabdf8cc68831e74deff5a4ad922f2c8f1cf69e5e1233343e98818b48299`.

**Plan-limited blocker:** Task 1 cannot emit source bodies or begin its review
under the current schedule. The metadata schedule review identified complete
collector/source-acquisition spans and tagged contracts needed to cover the
trust boundaries; trimming them to fit would leave those checks unreviewed.
The exact context also exceeds its cap. Preserve all findings and safety
stops. Remedy: replan the review into bounded, independently reviewable
increments with explicit carry-forward digests and owners, or obtain a new
owner-approved budget/sequence that preserves all required checks. Do not
continue to Task 2 or Task 3 under this plan without that replan. Any changed
schedule or context requires a new independent schedule review, fresh execute
preflight, and direct combined count before source emission.
