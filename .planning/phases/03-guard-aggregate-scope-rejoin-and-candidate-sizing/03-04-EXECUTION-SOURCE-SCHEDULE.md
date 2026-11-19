---
phase: 03
plan: 03-04
status: stale historical schedule; current body gate closed
---

# Plan 03-04 exact context and source schedule

> **Stale after INT-20261115-02 and the 03-04 source-search incident.** This
> schedule contains prior V20/V21-era caps and hashes. It does not authorize
> source emission under the current 110,000-token recovery envelope. Preserve
> it as historical evidence; prepare a new complete schedule bound to the
> current Plan, REPLAN, STATE, incident receipt, and SIZING hashes, then obtain
> independent review, execute preflight, and a fresh direct count.

This schedule supersedes no earlier receipt. Both failed direct counts and all
independent review outcomes remain preserved in `03-REVIEW.md`, `STATE.md`,
and the receipt sections below; their full narratives are not duplicated in
the active count context. No implementation or test body has been emitted.
The unchanged Task 1 source-span set was directly counted at 21,183 tokens
under the prior exact span payload in `03-REVIEW.md`; hashes below bind that
same set. Its new context/combined count remains gated on independent review
of this compact schedule.

## Envelopes and acquisition rule

| Component | Cap |
|---|---:|
| Complete hash-bound compact context and keyed evidence | 38,500 tokens |
| Task 03-04-01 exact complete spans | 22,000 tokens |
| Task 03-04-02 correction/reread spans | 800 tokens |
| Task 03-04-03 new source reads | 0 tokens |
| Output | 5,000 tokens |
| Cushion | 2,000 tokens |
| Fixed reserve | 31,000 tokens |
| Maximum working / total | 68,300 / 99,300 tokens |

Each task is capped at five exact files, counting rereads. The current
Task 1 source schedule contains two source files and three keyed evidence
files. Context excerpts and keyed projections are bound by full file digest,
selection, bytes, and excerpt/projection digest. Full lane arrays and the
13 MB report are never emitted. Task 2 uses no source body unless an accepted
finding proves a complete correction span is needed; every such span must
receive a new independently reviewed schedule and fresh direct count before
emission. Task 3 remains a zero-read task.

## Task 03-04-01 source spans

Span hashes below cover exact inclusive UTF-8 line ranges including line
endings. Per-span token breakdowns are not recorded; the unchanged full Task 1
span set has a direct count of 21,183 tokens bound by the existing receipt in
`03-REVIEW.md`. Lines and span hashes were computed metadata-only from the
current phase branch.

| Exact source file | Full bytes / SHA-256 | Complete function/test span | Lines | Span bytes | Span SHA-256 | Direct tokens |
|---|---|---|---:|---:|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | `build_lane!/1`, lane and aggregate validation, renderer, and bundle validation | 16–318 | 12,093 | `852fd22e64027391ac7646525f60a578b09b3017087d0896cee5e58a4cdd768c` | pending |
| same | same | source attach/validation/crosswalk and caller attach/validation | 321–724 | 13,981 | `399193ae0c5a248fb638badb230fdb31b9fe2e78866f2de7d0685b1e39e5b38d` | pending |
| same | same | sizing validation/build and caller projection/resolution helpers | 727–1322 | 21,933 | `4ec3e18bd6401078bdebe5b05a523612666ad894e2dd9bfc0736767bda0595d5` | pending |
| same | same | sanitization, canonical MFA/identity helpers, exact partition construction | 1384–1493 | 4,102 | `7c70fba6aa9b95e3bc063d4ac932d682a939cb08cd9eddd0a9ceafc281f7c0b5` | pending |
| same | same | exact target-source archive lookup and source-key indexing | 1494–1603 | 3,889 | `763014c570d2beb8217373f704ab8d764eb65c494b874a3a23718360ca9a2b3f` | pending |
| `test/contract/tier_sweep_test.exs` | 768,677 / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | complete input/acquisition and identity-reference contract, including its exact tag lines | 5094–5141 | 1,774 | `98f6b4f8819f2efaceb2b6b9b1ae2690d1387dcd2560970a7df1fcc4758a3156` | pending |
| same | same | `aggregate_identity_rows!/4` and complete dependent identity construction helpers, ending before the next test's tag lines | 5340–5541 | 6,986 | `2c1610cf7f437feca4aa92cf4b8ef119465a9c6bed912b35f5016e944b1473ff` | pending |
| same | same | complete two-lane original-identity crosswalk contract, including its exact tag lines | 5600–5788 | 8,663 | `fd97582989f6eb03e49c398035ad2cc55c2b7594e10df6e412fe583cf37cebda` | pending |
| same | same | complete target-source acquisition and explicit-gap contract, including its exact tag lines | 5789–5935 | 4,935 | `a82bca9e9dcdd78d2022af3da33c699f0cb380b9d0c81c41257c6e16e21c0b28` | pending |
| same | same | complete caller observation, resolution and explicit-gap contract, including its exact tag lines | 5936–6137 | 7,797 | `39d0c8cb47e88d1a42b4849e2afe0736439eb65aff2dbac41f0490ea5a94798c` | pending |

The identity-construction helper is included. All five test spans include
their own preceding `@tag` lines and exclude the following test's tags. The
caller-chain-index-only contract at lines 6138–6193 is not selected: caller
graph resolution is covered by the complete 5936–6137 contract and source
helpers at 1107–1322. Total selected Task 1 spans are 86,153 bytes across two
exact source files. If the direct count identifies an overage, no required
source, identity, caller, lane member, receipt, or control may be dropped to
force fit; keep the body gate closed and report the exact overage for a bounded
owner decision.

## Compact context manifest

The selected excerpts below are complete documents or complete bounded
sections. Their current full-file digests are bound before counting. The
context builder must verify every file digest and excerpt digest immediately
before constructing the count-only request. Any changed source or excerpt
invalidates this schedule review and count.

| Context source | Selected lines | Full file bytes / SHA-256 | Excerpt bytes / SHA-256 | Purpose |
|---|---:|---|---|---|
| `AGENTS.md` | 1–40 | 6,295 / `86f3c829e1853ff1ba66e54f7301da9d2706e4d3a6b9353fd5d118663936e1c7` | same | project execution and lifecycle constraints |
| `CLAUDE.md` | 1–36 | 3,743 / `7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2` | same | intent, architecture and safety rules |
| `.planning/intent/NORTH-STAR.md` | 1–34 | 3,559 / `c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248` | same | quality and static-only product boundaries |
| `.planning/intent/CLEARANCE.md` | 1–16 | 2,154 / `1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff` | same | inherited clearance ownership |
| `GLOSSARY.md` | 118–150; 261–354 | 15,891 / `e1f8dbee98abf437ee6851f103a93e119dff97a0416b93754a8dd41ae55e25c6` | 1,389 / `71de3c4a5253fe24c58d863d316935e67cd6093f97b3c8579323f654a169f883`; 3,248 / `df439721b4874967bb5fef7a454c6b9bacbd85f4e26fe053f672d0854460982a` | phase-relevant tier-sweep, checks/evidence, bundle/budget, and scope terms |
| `docs/adr/README.md` | 1–32 | 2,597 / `8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5` | same | locked-decision precedence |
| `docs/adr/0004-no-eval-no-new-atoms.md` | 1–24 | 1,649 / `5d9232471b38fc7e038749bbc85145e6a608b70412c9d15c50b425e442c4fb23` | same | no-eval/no-input-atoms boundary |
| `docs/adr/0014-testing-strategy.md` | 1–29 | 2,323 / `42c70f5792c98c3ea8a77eb9cc7aec8c94c7d1f8b6101306bb3d8fb76cea34e4` | same | evidence and test boundary |
| `docs/adr/0018-dependency-budget.md` | 1–29 | 3,066 / `3ca266284f17d26ee5f2044d00ffa4b7e8d60336fe6e1d3191aa393927ad46cf` | same | no new dependency |
| `docs/adr/0021-delivery-rules.md` | 1–34 | 3,072 / `2074bc6920a6bc36cd4e295a5649a2b82036f37899cb3fa9d26fa69441582a56` | same | review and delivery constraints |
| `.planning/VERIFICATION.md` | 1–25 | 5,352 / `0295edd62cb7b6351075b8ace1ddfa1203ab18fe175b757950cc1caa5b048e66` | same | automated evidence and owner-only judgment |
| `.planning/REQUIREMENTS.md` | 9–26 | 3,954 / `74ede0ad048f06d31bda9800946aa98b64e39e8b45e8625415e9d0c7c75c512e` | 2,978 / `5f7a40479b1729f80cca20c065ff85097b5c36e52db80f8fb2f32c22448128bf` | GSR-01–06 and explicit scope exclusions |
| `.planning/ROADMAP.md` | 16–23 | 2,986 / `b4d9ac03da1141b66b65d57540be1980e9ffe28d9f9e44b0de6cae3af11e681b` | 666 / `1fcd9c5340d4c77d37b5fe381081c1e9a97005f15b2ad9f7b88b9844acaac482` | Phase 3 goal and exit criteria |
| `.planning/STATE.md` | current summary/handoff at line 41 and lines 49–51 | 18,481 / `7cbde995192c7ec8c2ab2e2fe556a344793910d3b8255536c9f950a43fbef81e` | line 41: 636 / `bdfa9b1233bfd467b0941873ce3c8646f71053971cc5ceac9c4ae9695f4ca346`; lines 49–51: 1,213 / `51b12310d7914181e0b936c40dcc2f38280b94ee478222b07ddf6172a6f62acf` | current Task2 v3 recount status, active handoff, unchanged owner/safety stops; full current STATE remains hash-bound |
| `03-04-REPLAN.md` | final bounded recount summary, lines 227–242 | 17,147 / `3f0900b0dd8a0ae342434e8c4d915ba9116fb59100334435227d29d687de065f` | 1,011 / `975363882a3fec9e197887989d9466984e78508bc01066e4ea5c9cffc72de6be` | latest compact accounting and gating summary; prior history remains in the full file |
| `03-REVIEW.md` | current recount summary, lines 454–466 | 32,430 / `1cba2d2586ad338fe5887f395e68deecd0d877fa8fefa1a350cbabc0cc0206db` | 825 / `9dfcc8368146810c65524844b893ca8ad561ba36483d07f32927b529488d6306` | current accounting interpretation, latest finding/candidate, unchanged stops; full review history remains hash-bound |
| `03-CONTEXT.md` | 8–28 | 10,916 / `a2a66a691e9026d3e97821a82aafa14c63460137912813b27f7018677cbef22b` | 2,924 / `d7982df35142c233b2fb981afa6b615d33c7340d945fd80379d4f9e7e8048968` | phase scope, D-01–04, owner decision and stops |
| `03-04-PLAN.md` | 1–49; 62–85; 116–147 | 19,853 / `b9093150394e0e331aba12bbdd1195156c2071cbe43fc4dd6fda3cadb8476190` | 3,121 / `39565ad2f8fd01ae7d22798a7ff6e642ecbe8da6eb00b1731d2002e598cc032a`; 6,725 / `77065e7a0b1e3296784b79c7c0e53da8f4ba08870503f54381b78992c06d1768`; 2,284 / `85c63e2bcc9002674210a198311e72c394c6de05bf09bd8cfc4f7e5f2a519d19` | frontmatter/must-haves/objective; artifacts, current resource bounds and complete Task1; threat model, verification, success/output |
| `03-03-SUMMARY.md` | 73–132 | 7,699 / `4d36ea2d8cc41f0937628a9c5344024871e560c1374f3d94ba903ec5b25ab107` | 4,242 / `3103ef54aee7f43941aa57448f7a323057654c37a3cb2c4184137bb77bc9a8ee` | current no-candidate evidence, gaps, owner choice |
| v0.3 Phase 2 `02-CONTEXT.md` | 11–25; 46–50 | 14,424 / `d769dfd143534ba5272f88a140f261462a020dc348c305e399dde624af7b9c78` | 1,984 / `0007c18e442561b090e40b60779dfcf3eb2c64032436cd6108dcf10f3f00a296` + 1,107 / `4a18c59ce59dae4fcdf08fae01eac3412b743b3e9f95da4289a57a3f9da1abd7` | separate EX-107 3/174 and 13/164/161 partitions and stop |
| `.planning/references/PLANNING-GATES.json` | 1–22 | 503 / `ca2fc6d23ad474dad7d72688fee03a71dfff38e4d8e4d3237e1ecef0bec1271b` | same | current gate owners/stops |
| `.planning/references/PHASE-DELIVERIES.json` | keyed compact context projection only; see ledger below | 779 / `16d5e37be6579c9ed78b3418ec31c2e541a916c1d5eddef3a7fb4e0531bce088` | v0.2 Phase 1 EX-010: 282 / `ded2db3bd5032b952dd48e3669195da503df15cf07c7302966fa924a2da30433`; v0.3 Phase 2 EX-107: 282 / `f564b5bc12a53ded99e7e50964bc4482bd5d36737fc5634275781d836434b822` | registry is compact project context; selected objects cross-check lane receipt arrays |

### Concise hash-bound status and receipt context

The preceding count measured 41,326 context tokens against the new 38,500
cap, so the selected context must save at least 2,826 tokens. This schedule
replaces full plan/replan documents with the exact current complete sections
and replaces the repeated state/review failure narratives with the concise
hash-bound summaries below. The entire 21,183-token Task 1 span set remains
unchanged; no identity, caller, receipt, partition, owner, safety or gap data
is removed. The reduction target is not certified by byte counts; only the
fresh approved direct count can establish fit.

The active context uses the complete selected Plan 03-04 objective/must-haves,
resource bounds, Task 1 contract, threat model and verification sections listed
above. For the current replan, it uses only the current constraint/gate sections
and latest PASS excerpt; earlier planning reviews remain fully recorded in the
replan file but are not repeated in the count input.

Compact STATE summary, bound to the full digest and selected line hashes above:
v0.4 Phase 3 is on the named `gsd/phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing`
branch; Plans 03-01–03-03 are complete, Plan 03-04 remains blocked before
source review, and Plan 03-05 is unstarted. The prior measured 41,326 context /
21,183 span / 101,523 total failure remains recorded. Candidate stays null,
implementation unauthorized, aggregate open, Walking Skeleton blocked, SEC-01
Pending, and static-only, collision and Macro/wording stops remain unchanged.
The approved current replan is the 38,500 / 22,000 / 800 / 0 / 5,000 / 2,000
working envelope plus 31,000 reserve. The phase orchestrator acts next; the
owner acts only if fitting complete evidence requires a scope/envelope change.

Compact receipt summary, bound to `03-REVIEW.md` full digest and the two
failure-range hashes above. Original failed count: 52,623 context, 18,258
spans, 70,881 combined, 108,881 total; request hashes
`74e83fa3bb774d1f6d9b812476430f7d831948c643df9e1169d36c270cb043d5`,
`a9542b54155786af6bece789f50cc1125352a8e4ccba6e6d7f693fc78670e887`, and
`89387529e0db62eb883955d1d4254f34eeef02540f231d99b02a0d42d32373c7`. Historical
failed count: 41,326 context, 21,183 spans, 62,523 combined, 101,523 total;
request hashes `cacec5e27a7d257b7c90ffea23a2b93494caa31dc56b43b4cad495aa4596d97a`,
`f929d9da7f596952deb826b9c263feb3c7f72808f4204e523ac27727a742e9d9`, and
`be45b712257b6b549c7d741eb205a3ede9753a4d6366a558601e2e08318b6b28`. Neither
count emitted source/test bodies or ran tests. Metadata schedule review trail:
two earlier FAIL receipts remain appended; the corrected 2+3=5 ledger and
tag/projection bindings passed for pre-receipt schedule
`9e782bb95dd719a2dac600c524474d74d9b547420266b88048559fb80e29c4dd`; the
active receipt-bearing schedule digest is
`faabfdfce9a22b3f2d3af9641dc5f131ec6aa08fc7e74ff6cbff623a054d5479`. The new
approved replan digest is
`a19c7bfb34bd7e91f5f3b6d3ef3f18c33e706e2025689eb50e41b1d7253a5223`.
Full count and reviewer narratives remain unchanged in `03-REVIEW.md`,
`STATE.md`, `03-04-REPLAN.md` and the appended schedule receipts.

### Task 1 exact-file ledger

The five-file limit applies to exact source/evidence files used for semantic
review; compact planning context has its separate 38,500-token cap. The ledger
is exactly 2 source files plus 3 evidence files:

| File class | Count | Exact files | Use |
|---|---:|---|---|
| Source files | 2 | `test/support/guard_aggregate_reconciliation_evidence.ex`; `test/contract/tier_sweep_test.exs` | Complete scheduled source/test spans above |
| Machine evidence files | 3 | `03-CORE-AGGREGATE-EVIDENCE.json`; `03-FLOOR-AGGREGATE-EVIDENCE.json`; `03-SIZING.json` | Exact keyed projections described below; lane delivery and `delivery_receipts` objects remain copied unchanged |
| **Task 1 total** | **5 / 5** | **2 source + 3 machine evidence** | **Within cap** |

`.planning/references/PHASE-DELIVERIES.json` is not a fourth machine-evidence
input and is not used for source/caller evidence. It is a required compact
planning-context registry, charged only to the 38,500-token context cap. The
context payload includes only its canonical selected receipt objects, not the
full registry body: select the one object in `phases` matching
`milestone == "v0.2" && phase == "1"` and the one matching
`milestone == "v0.3" && phase == "2"`; retain exactly
`milestone,milestone_key,phase,status,pr,reviewed_head,merge_commit,ci_run`;
serialize each as UTF-8 JSON with recursively sorted keys, compact separators,
and no trailing newline. Their output sizes/digests are 282 bytes /
`ded2db3bd5032b952dd48e3669195da503df15cf07c7302966fa924a2da30433` and 282
bytes / `f564b5bc12a53ded99e7e50964bc4482bd5d36737fc5634275781d836434b822`.
Those exact receipt objects cross-check the unchanged `delivery` and
`delivery_receipts` carried by each of the three scheduled machine records;
the lane records remain the semantic evidence files. The prior receipt recipe
and digests are also bound by `03-REVIEW.md` lines 150–164. The full registry
digest above binds the selectors without adding its entire JSON body to the
context request.

The exact `03-SIZING.json` input is bound by full file identity and a
reproducible keyed projection. Full file: 19,092 bytes,
SHA-256 `3f98ec287f98276951ffdb8ce45e5792b4dc3019111b6401f31d631c17e2e7c8`.
Select exactly `$.candidate`, `$.candidate_fit`,
`$.caller_closure_complete`, `$.evidence_complete`, `$.forward_effort`,
`$.generation`, `$.global_gaps`, `$.implementation_authorized`,
`$.lane_records`, `$.measurements`, `$.owner_decision`, `$.schema`,
`$.source_join_complete`, and `$.actual_library_collision`; serialize as UTF-8
JSON with recursively sorted object keys, compact separators, and no trailing
newline. Projection: 14,744 bytes, SHA-256
`fc9da203c8490a16ee736d8d3f582ca12342e437b28f4d3e7a09305c34286a98`.
Each lane binding retains its full record digest, generation, per-lane
identity/membership/source/caller gap counts and reason digests.

For the two full lane records, reproduce exactly the projection recipe and
digests in `03-REVIEW.md` lines 26–50. The full files remain bound to core
12,107,528 bytes / SHA-256
`ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a` and floor
11,828,076 bytes / SHA-256
`47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121`; generation
is `09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b`.
Projection retains top-level `identity`, `delivery`, and
`delivery_receipts`; `target_source_records`; full-array count, canonical
digest and exact keyed status/reason distributions; and recursively summarized
source/caller/delegate evidence arrays, following the recipe. Bind exact
projection outputs to core 6,191 bytes / SHA-256
`f26040b3b9319e0a77f0a2987a5fab060f1427732096d7b4ab09339aec5693cf` and floor
6,196 bytes / SHA-256
`57fd78a919b9f5dae6c446682439764b29cba25c26de1a96ee4ddd3ef3b0aff8`. Preserve
the exact selector strings in the count input; emit no arrays.

The v0.3 Phase 2 context excerpt separately binds the 3/174 and 13/164/161
partitions. Retain lane `delivery_receipts` unchanged in each lane projection.
Cross-check each lane receipt against the exact selected registry object from
the compact context projection; do not substitute a combined count.

## Required replay and independent schedule review

The independent reviewer must receive this exact schedule digest plus the
plan/replan digests, confirm that acquisition, `aggregate_identity_rows!/4`,
source construction, two-lane crosswalk, target-source verification, caller
resolution/gaps, sizing, static-only proof, exact partitions and real delivery
receipts, all six GSR requirements, D-01–D-04, and every owner/safety stop are
covered, verify the exact tag-inclusive span boundaries, projection and
delivery-receipt recipes/digests, and verify the explicit 2+3=5 Task 1
file-ledger classification. The
reviewer must explicitly
decide whether any required coverage was omitted; no body can be emitted based
only on the earlier schedule PASS.

After that PASS, rerun `bin/planning_health --stage execute --phase 3`. Then
count the exact current context manifest/projections, this schedule and review
receipt summary, every selected complete span, output allowance, cushion,
Task 2 500-token cap, Task 3 zero-read cap, and reserve with the already approved
`POST /v1/responses/input_tokens` endpoint for `gpt-6-luna` and the existing
ignored `.env.local` credential. Record only the redacted harness, serialized
request SHA-256 and returned token count. Never print or persist the credential
or call another endpoint. No byte/4 substitution is permitted. A changed file,
excerpt, projection, plan, schedule, review receipt or count payload requires
re-review as applicable and a fresh count before any source body is emitted.

## Independent schedule review — FAIL

Reviewed metadata only on 2026-11-15. This review binds to the pre-receipt
schedule SHA-256 `c359ee45380ce73f02067fa1bb9d1d84563330935da90bb537ff4bf705fcaba6`,
plan SHA-256 `dc4d309ee57c78bc88df84f9a3157dfc902182fdb0cec4c82b56978d351e18fb`,
and replan SHA-256 `9028c1c5f36c9d24d2517d6b1dac06bcd387827a36e63e759c9729a8795e5e11`.
Full source-file and listed span byte/hash metadata matched. The five-file
source/evidence grouping and 38,000 + 21,000 + 1,000 + 0 + 5,000 + 2,000 =
67,000 working tokens, plus 31,000 reserve = 98,000, match the revised
envelope. The identity helper is included; the review did not inspect source,
test, or report bodies and did not certify token fit.

This schedule is not ready for a fresh count or source-body emission:

- Contract test spans omit the tests' own `@tag` lines and include tags for
  following tests: use 5094–5141 (not 5097–5144), 5600–5788 (not 5602–5790),
  and 5789–5935 (not 5791–5936). The caller test starts at its tag on line
  5936, not line 5937. The identity helper span 5340–5544 includes the next
  test's tags at 5542–5544 and must end before those tags.
- The schedule defers lane projection details to `03-REVIEW.md`, but the active
  context selects only lines 1–9 and 230–262, not the projection recipe. Bind
  the exact lane selectors, canonicalization rules, and output digests in the
  active schedule or include the exact recipe excerpt in the context.
- The active schedule does not give `03-SIZING.json`'s full file byte count and
  SHA-256 or a reproducible keyed-projection digest/selector. The exact delivery
  receipt projection selectors, retained fields, canonicalization, and output
  digests also are not present in the active context selection.

No source body was read. Keep the body gate closed until the exact boundaries
and evidence bindings are corrected and independently reviewed. The current
schedule already preserves all required spans and says not to drop required
coverage if the count exceeds its cap; any overage must remain an owner-facing
stop with its exact amount and remedy. After corrections, obtain another fresh
execute preflight and a direct count that includes the changed schedule and
this review receipt.

## Independent schedule review — FAIL

Reviewed metadata only on 2026-11-15. This receipt binds to the pre-receipt
schedule SHA-256
`4cd4ab57ceb6be8060daae92ca05f3808cb0edaa22eae8a66a971daa525aeb91`, plan
SHA-256 `dc4d309ee57c78bc88df84f9a3157dfc902182fdb0cec4c82b56978d351e18fb`,
and replan SHA-256
`9028c1c5f36c9d24d2517d6b1dac06bcd387827a36e63e759c9729a8795e5e11`.
The source and test full-file identities, all listed span byte counts and
hashes, tag-inclusive boundaries, compact-context excerpt bindings, SIZING
projection, lane projection recipes/digests, delivery-receipt selectors and
digests, and 38,000 + 21,000 + 1,000 + 0 + 5,000 + 2,000 = 67,000 working
tokens plus 31,000 reserve = 98,000 were verified from metadata. The complete
identity helper, acquisition, crosswalk, target-source and caller-resolution
spans are listed. No source, test or report body was opened; this does not
certify token fit.

The five-exact-file Task 1 cap is not auditable from the schedule as written.
It claims two source files plus three keyed evidence files, but separately
binds four distinct keyed evidence files: `03-SIZING.json`, the core lane
record, the floor lane record, and `.planning/references/PHASE-DELIVERIES.json`.
The schedule does not identify which file is excluded from the five-file
ledger or explain why its required keyed projection belongs only to compact
context rather than the scheduled evidence inputs. Resolve the accounting
explicitly without dropping required evidence, or preserve the excess file as
an owner-facing gap with its consequence and remedy under the plan's cap.
Keep source-body emission and the direct count blocked until this correction
receives a new independent metadata review.

## Independent schedule review — PASS

Reviewed metadata only on 2026-11-15. This receipt binds to the pre-receipt
schedule SHA-256
`9e782bb95dd719a2dac600c524474d74d9b547420266b88048559fb80e29c4dd`, plan
SHA-256 `dc4d309ee57c78bc88df84f9a3157dfc902182fdb0cec4c82b56978d351e18fb`,
and replan SHA-256
`9028c1c5f36c9d24d2517d6b1dac06bcd387827a36e63e759c9729a8795e5e11`.

The Task 1 ledger is explicit and within cap: two source files plus three
machine-evidence files (core, floor and sizing), 5/5 total. The delivery
registry is separately classified as required compact project context with
only the two canonical selected receipt objects. Their 282-byte projection
digests match the scheduled EX-010 and EX-107 digests; both lane records retain
the same `delivery` and `delivery_receipts` values, and their receipt arrays
contain both selected objects. The registry therefore does not add a fourth
machine-evidence file.

All ten listed source/test span byte counts and hashes and both full source
file identities match; the tag-inclusive boundaries and aggregate identity
helper are present. Compact-context full-file and excerpt bindings, the
SIZING projection, lane projection recipe/output digests, delivery selectors,
and the 38,000 + 21,000 + 1,000 + 0 + 5,000 + 2,000 = 67,000 working-token
envelope plus 31,000 reserve = 98,000 remain consistent. Required acquisition,
crosswalk, target-source and caller-resolution spans are included; no required
coverage is omitted from the metadata schedule. The previous FAIL receipts
remain preserved.

This PASS certifies schedule metadata and file-cap accounting only. No source,
test or report content was emitted or semantically reviewed, and token fit is
not certified. Rerun the execute preflight and obtain the required fresh
combined direct count with this receipt included before any source body is
emitted.

## Independent compact-context schedule review — PASS

Reviewed metadata and bounded planning excerpts only on 2026-11-15. This
receipt binds to pre-receipt schedule SHA-256
`a4245566ba2f0a2e16fa742ddfc705e1a0229965bc6596d57796fc5a6283c9a5`, current
Plan SHA-256 `b9093150394e0e331aba12bbdd1195156c2071cbe43fc4dd6fda3cadb8476190`,
current Replan SHA-256
`a19c7bfb34bd7e91f5f3b6d3ef3f18c33e706e2025689eb50e41b1d7253a5223`, STATE
SHA-256 `1f17b3af38d9de7546ab3bcac5af461493289dbadd16ce735e52812fa7c01ac7`, and
REVIEW SHA-256
`ce726d29db2636830334b8d797f86e41cab13a8d2fb828c0d75a20aaa42b6da0`.

The selected Plan excerpts (lines 1–49, 62–85, and 116–147) bind the
must-haves and objective, the complete Task 03-04-01 review/action/verification
contract and resource limits, and the threat model, verification, success and
output criteria. The selected Replan excerpts (lines 10–119 and 176–178) bind
the current trigger and preserved scope, 38,500/22,000/500/0/5,000/2,000 caps,
the source and count gates, credential boundary, unchanged safety/authority
stops, and the latest independent replan PASS. All 13 selected Plan, Replan,
STATE and REVIEW excerpt byte/hash pairs match their current full-file
identities. The compact STATE summary retains blocked status, candidate-null
and authority facts, owner handoff, and unchanged safety stops. REVIEW and
schedule receipts retain both historical failed count results and exact
request hashes; the full receipts remain available in their hash-bound source
documents and prior schedule receipts.

The 5/5 ledger remains two source files plus the core, floor and sizing machine
evidence files. PHASE-DELIVERIES remains compact context with only the exact
282-byte EX-010/EX-107 projections, cross-checked against both unchanged lane
receipt arrays. All ten scheduled source/test spans, including
`aggregate_identity_rows!/4`, retain their exact byte counts and hashes. The
21,183-token span count is historical direct-count evidence for this unchanged
span set; it does not certify the new context or combined count. The current
38,500 + 22,000 + 500 + 0 + 5,000 + 2,000 = 68,000 working envelope plus
31,000 reserve = 99,000 is internally consistent. The compact Task 1 context
contains the full Task 1 review criteria and gates; Task 2 and Task 3 remain
unstarted and require their task-specific instructions to be bound before
those tasks begin.

This PASS certifies excerpt completeness/binding and metadata consistency,
not token fit. No implementation, contract-test or large-report body was
emitted or semantically reviewed. Rerun execute preflight and obtain a fresh
combined direct count including this receipt before any source body is
emitted.

## Deterministic count request serialization

The redacted harness constructs context and span inputs in memory after
verifying every selected full-file digest, excerpt digest, projection digest,
and exact span boundary. It does not write request bodies or credentials to
disk. The context input is UTF-8 plain text with these sections, in order:

1. Every compact-context excerpt in the manifest table's row order, headed
   `## {path} [{selection}]`, followed by its selected bytes decoded as UTF-8.
   State, plan, replan, summary, and review fragments follow the order listed
   in their manifest rows.
2. `## Keyed evidence projections`, then the four projection names in
   lexicographic order (`delivery_receipts`, `lane_core`, `lane_floor`,
   `sizing`), each headed `### {name}` and followed by its canonical JSON.
3. The active schedule metadata selections: lines 40–102 (ten exact source
   spans and the compact-context manifest), lines 153–196 (the exact 5/5
   evidence ledger and delivery/sizing projection selectors), and lines
   215–218 (inherited phase partitions and lane-receipt cross-check). Include
   this serialization section and only the latest independent PASS receipt
   appended after it. The selected Plan/Replan/STATE/REVIEW context already
   carries the budget, task gates, current count receipt, lane recipe, and
   review procedure. The omitted schedule prose is duplicate wording; the full
   file remains bound by the independent receipt, and no evidence or control is
   removed.

Join adjacent excerpt, projection, and schedule sections with exactly two LF
bytes. Preserve selected file bytes, including existing line endings; add no
extra final newline. The span input contains the ten exact Task 1 spans in
schedule order, each preceded by
`--- {path} lines {start}-{end} ---\n`; join blocks with one LF byte and add no
extra final newline. The combined input is the context input, two LF bytes,
then the span input. For each direct count, POST compact, recursively
key-sorted UTF-8 JSON with `model` and `input`, using the input-token counting
endpoint only; hash the exact serialized request body. No generation request
is made.

## Independent count-serialization review — PASS

Reviewed metadata only on 2026-11-15. This receipt binds to the pre-receipt
schedule SHA-256
`ab6c58a2b8758b5f2bb42a13eb48b73cca41e3ba7cd7df64dc86439cc50b158d`, current
Plan SHA-256 `b9093150394e0e331aba12bbdd1195156c2071cbe43fc4dd6fda3cadb8476190`,
Replan SHA-256
`a19c7bfb34bd7e91f5f3b6d3ef3f18c33e706e2025689eb50e41b1d7253a5223`, STATE
SHA-256 `1f17b3af38d9de7546ab3bcac5af461493289dbadd16ce735e52812fa7c01ac7`,
REVIEW SHA-256
`ce726d29db2636830334b8d797f86e41cab13a8d2fb828c0d75a20aaa42b6da0`, and
count harness SHA-256
`c22bca53d4f1cd3adbf9ead987d74c1014175dbece0494601e8a6dfdb5b152d8`.

The harness binds the two `03-REVIEW.md` recipe excerpts and validates both
count-receipt excerpts by digest without adding the full receipt narratives to
the compact context. It verifies full core/floor lane and delivery-registry
identities, the keyed lane/sizing/receipt projection sizes and hashes, and the
EX-010/EX-107 receipt equality against both lane records. Its ten source-span
specifications and source full-file identities match the schedule. Context
excerpt order, projection-name sort order, schedule lines 1–244, the
serialization section, and appended PASS receipts match the written ordering;
span and JSON request framing preserve the stated UTF-8, delimiter, compact
separator and key-order rules. The harness checks the current
38,500/22,000/99,000 context/span/total caps and the 500-token Task 2, zero-read
Task 3, output, cushion and reserve allowances. The current full Plan, Replan,
STATE and REVIEW hashes and their selected excerpts match the schedule.

This is a metadata/serialization review only. The harness was not executed,
the count endpoint was not called, and no source, test or report body was
opened or emitted. This PASS does not certify token fit. Run the approved
direct count against the receipt-bearing schedule after a fresh execute
preflight before any source body is emitted.

## Independent current-context schedule review — PASS

Reviewed metadata and bounded context excerpts on 2026-11-15. This receipt
binds to pre-receipt schedule SHA-256
`83668d149221ce88dcd1b5b733a4bac9f058e56a921e5332b067b5ffe8d3541e`, Plan
SHA-256 `b9093150394e0e331aba12bbdd1195156c2071cbe43fc4dd6fda3cadb8476190`,
Replan SHA-256
`7bc58fd096f15ef75969087f8f8a050d5c5b57fdb1edf21d6e5bc67c8fa3af69`, STATE
SHA-256 `384d8e1736981e3ce0d1b812dc72d45088417bda61b64d8fe67d29ecf89b32fb`,
REVIEW SHA-256
`5608bc4ea9dbf6f258eeb46b672c44d576e6154b1dc27f33119405b4d79381a1`, and
count harness SHA-256
`7834ca50e92c21baf81ce97fe76fbb4f67467b35dfae5b705d8bcb4e8e4663a0`.
Fresh `bin/planning_health --stage execute --phase 3` passed with no errors.

The GLOSSARY excerpts at lines 118–150 and 261–354 retain the four tiers,
sweep/check/evidence/finding and ratchet terms, bundle/budget language, and
the explicit native-mobile scope boundary. The selected Replan excerpt binds
the latest 40,422 context / 21,172 span / 61,588 combined failure and all
three request hashes; current STATE excerpt bindings retain the blocked status,
owner handoff, candidate/authority facts and safety stops. All 31 context
excerpt bindings and keyed lane/sizing/EX-010/EX-107 receipt projections
reproduced from the harness; all ten source-span byte/hash bindings and both
source full-file identities matched. The 2-source + 3-machine-evidence ledger
is 5/5, with the delivery registry remaining compact context. Schedule
selections 40–102, 153–196 and 215–218, serializer section and latest-PASS
ordering match the harness. The 38,500/22,000/500/0/5,000/2,000 working
allowances plus 31,000 reserve remain 68,000 / 99,000; static-only, collision,
Macro, candidate-null, implementation-unauthorized, aggregate-open, Walking
Skeleton-blocked and SEC-01 Pending stops remain explicit.

No source, test or large-report content was emitted or semantically reviewed;
source/test identities were checked only as opaque byte/hash metadata. The
harness prefix was used to verify context bindings, projections and serialization
selection only; no count endpoint was called. This PASS certifies metadata
consistency, not token fit. Run a fresh direct combined count including this
receipt before any source body is emitted.

## Task 03-04-02 correction schedule draft — v1 (superseded after 759-token count)

Task 1 found a material fail-closed defect: source attachment can leave exact
source gaps empty while the sizing gate's `source_join_complete` fact remains
false. The proposed correction is to derive that fact only from the canonical
sorted source-gap list. Do not infer it from coverage enumeration. Add one
focused synthetic regression that exercises both an empty-source/no-live-MFA
association (complete join) and a missing-source association (incomplete
join), using the public lane and source-attachment interfaces. No code has
been read or emitted for Task 2; candidate code text must be supplied to the
count request and bound before any source edit.

| Path | Current full identity | Task 2 source selection | Current span identity | Purpose |
|---|---|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 bytes / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | lines 383–390, 297 bytes | `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` | Exact source-join decision tail in `attach_target_sources!/3`; full function lines 324–390 were already reviewed in Task 1. |
| `test/contract/tier_sweep_test.exs` | 768,677 bytes / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | v1 trial insertion after current line 5935 | v1 patch payload 2,402 bytes / `147d8ef69e1bee8115b3365f40e70c4467a5eb42aea6fe55f8c4bcd32d5d62bf`; 759 direct tokens, over cap | Historical v1 candidate only; superseded. |
The v1 candidate payload was `/private/tmp/fablebook_plan03_04_task2_candidate.patch`, 2,402 bytes, SHA-256 `147d8ef69e1bee8115b3365f40e70c4467a5eb42aea6fe55f8c4bcd32d5d62bf`. Its direct count was 759 tokens and exceeded the 500-token Task 2 cap. This receipt and its context amendment are historical; the v1 patch is not active.

Task 2 source-token limit is 500 including every correction and regression
span. The exact candidate payload is byte/hash-bound above, but its direct
token count is pending. The fresh count must include the exact candidate text and
correction selection, hash-bound compact context, this receipt-bearing
schedule, 5,000 output tokens, 2,000 cushion, and 31,000 fixed reserve. The
independent reviewer must review this exact draft before a fresh execute
preflight and direct count. If the exact candidate or combined request exceeds
any limit, do not emit source bodies; preserve the finding as an owner-facing
gap with its consequence and remedy.

## Task 03-04-02 correction schedule metadata review — PASS (v1 schedule, superseded)

Independent metadata-only review on 2026-11-15 bound the pre-receipt schedule
SHA-256 `1ceaff6de2f415d739ef6a1b9e4adc66c6130936bbad5e62bd1481308aacbbf6`,
SIZING full-file SHA-256
`7f12fa1ab132a6c8e450f6a3c7a51c730a0f9a2c715bb3eef648931c592b28ca`, and
selected SIZING projection (14,051 bytes, SHA-256
`7f567adceabf8c54259c7e786cab148d5161d45a174d0421d61e6cd80f362c8a`). It
reproduced the 297-byte support correction selection at lines 383–390, SHA-256
`598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912`, and
confirmed the 2,402-byte candidate payload identity SHA-256
`147d8ef69e1bee8115b3365f40e70c4467a5eb42aea6fe55f8c4bcd32d5d62bf` is
bound in the schedule. The reviewer did not inspect candidate/source/test
bodies. The correction derives completion from an empty canonical gap list,
and the planned test covers complete and incomplete joins. Token cap and
fixture executability remain unverified until fresh direct count and later
focused test; no Task 2 body may be emitted before the count gate passes.

## Task 2 exact context amendment — v1 (superseded)

The Task 2 compact context adds the complete Task 1 independent finding and
candidate-hash excerpt from `03-REVIEW.md` lines 329–368 (full file 26,210
bytes, SHA-256
`b5add47acbec31338fd7340b2b6c0cdcc5173e1043af87760e06bec2ffebf0e8`; selected
excerpt 2,644 bytes, SHA-256
`67e0c918453745a0dfb300124140f0e5ca278b38e08e7a5148c1a8c56ca630d3`). It
also includes the updated 03-SIZING full identity and keyed projection bound
above. The span request includes only support lines 383–390 and the exact
temporary candidate patch bytes/hash bound above. Retain the original compact
context manifest and do not load complete lane arrays or report bodies. The
schedule and this amendment are selected into the new count request after an
independent metadata PASS receipt is appended.

## Task 2 candidate v2 context amendment — superseded after 743-token count

The first candidate exceeded the Task 2 source-span cap at 759 tokens. Its
failure receipt is preserved in `03-REVIEW.md`; it is not the current
candidate. Candidate v2 is the exact proposed unified diff held temporarily
outside the workspace: 2,292 bytes, SHA-256
`2c3c51eb1a7ff53e268d38b81e660539ec93d1d6ef775e8389d40db267b86660`. The
current compact context uses the canonical STATE file (18,590 bytes, SHA-256
`16c01a2bc1596dce0e110d620c85a0d1992edc4620f7a2823544d0cd17f5b70c`), retaining
its selected excerpt bindings in the manifest above. It also uses REVIEW
(28,159 bytes, SHA-256
`06a2578931c578b7b72de441c87b6116e7bbfeb8b2f3a8a414eff4139540311d`) lines
329–399 (4,593 bytes, SHA-256
`0aafb11f272714690e0790da13cc4d048419f21f1f540362c6701d57516408c2`), which
bind the independent finding, failed count receipts and candidate v2 identity.
SIZING is 18,100 bytes, SHA-256
`5225c957e5f49c29ac54b23177e224f9c7f387f947a292f4061c90ab6a7328dc`; its
14,051-byte keyed projection is SHA-256
`4a3f0784d3917e82ab8d9e230ca3ed7fd8b017f804be76545d9f5e8b11468799`. Task 2
source spans are the 297-byte support selection at lines 383–390 and exact v2
candidate payload. Obtain a fresh independent metadata PASS, execute preflight,
then direct-count context, spans and combined request with 5,000 output, 2,000
cushion and 31,000 reserve before any source-body emission.

## Task 2 final metadata review — PASS (v1 schedule, superseded)

Independent metadata-only review on 2026-11-15 verified the corrected
schedule pre-receipt digest `441e655ec3085e75e64321926cb6fcf3eebf5c8dcf54456d1fe4bd1331665a38`.
The selected `03-REVIEW.md` full-file digest and lines 329–368 excerpt are
current at 26,210 bytes / `b5add47acbec31338fd7340b2b6c0cdcc5173e1043af87760e06bec2ffebf0e8`
and 2,644 bytes / `67e0c918453745a0dfb300124140f0e5ca278b38e08e7a5148c1a8c56ca630d3`.
The `03-SIZING.json` identity is 18,100 bytes / `7f12fa1ab132a6c8e450f6a3c7a51c730a0f9a2c715bb3eef648931c592b28ca`; its exact selected projection is 14,051 bytes / `7f567adceabf8c54259c7e786cab148d5161d45a174d0421d61e6cd80f362c8a`.
The support correction span remains lines 383–390, 297 bytes /
`598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912`. The
temporary candidate payload is bound as 2,402 bytes /
`147d8ef69e1bee8115b3365f40e70c4467a5eb42aea6fe55f8c4bcd32d5d62bf` and was
not inspected. Count instructions cover the exact candidate, updated review
excerpt, receipt-bearing schedule, five-file limit, 500-token cap, 5,000
output, 2,000 cushion, and 31,000 fixed reserve. The candidate remains
uncounted and un-emitted; run fresh execute preflight then direct count before
any source-body change.

## Task 2 candidate v2 exact schedule — superseded after 743-token combined count

This v2 candidate supersedes every v1 trial row and receipt above. Keep the
same narrow change: source-join completion derives only from the canonical
empty source-gap list. Keep the same falsifiable behavior: one gap-free
no-live-MFA/not-applicable identity sets `source_join_complete` true, while a
nonempty source-gap case leaves it false. The fixture must stay within the
existing collector and remain static-only.

| File | Current identity | Exact Task 2 selection | Candidate binding |
|---|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 bytes / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | lines 383–390, 297 bytes / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` | Changed decision only; no source body emitted. |
| `test/contract/tier_sweep_test.exs` | 768,677 bytes / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | one complete focused test insertion after current line 5935 | Exact temp-only v2 candidate 2,292 bytes / `2c3c51eb1a7ff53e268d38b81e660539ec93d1d6ef775e8389d40db267b86660`; direct token count pending. |

The two source files plus core record, floor record and sizing record are the
five-file Task 2 ceiling. Count the complete support decision and exact v2
candidate patch together against the strict 500-token source/reread cap. Count
the compact context bound above, this exact schedule, 5,000 output tokens,
2,000 cushion and fixed 31,000 reserve. Obtain a fresh independent metadata
PASS and execute preflight after this schedule is final; run the approved
count-only requests and emit no source body unless every cap passes.

## Task 2 candidate v2 metadata review — PASS (superseded) (superseded)

Independent metadata-only review on 2026-11-15 bound the pre-receipt schedule
SHA-256 `199e83efde531c9d398732f26df7fbc655bdc64fbbfe6a4430af0abdc95881ea`.
It verified that all v1 rows and receipts are historical/superseded, and v2
is the sole active candidate. Current input bindings were reproduced: STATE
18,590 bytes / `16c01a2bc1596dce0e110d620c85a0d1992edc4620f7a2823544d0cd17f5b70c`; REVIEW
28,159 bytes / `06a2578931c578b7b72de441c87b6116e7bbfeb8b2f3a8a414eff4139540311d`, lines
329–399 4,593 bytes / `0aafb11f272714690e0790da13cc4d048419f21f1f540362c6701d57516408c2`; SIZING
18,100 bytes / `5225c957e5f49c29ac54b23177e224f9c7f387f947a292f4061c90ab6a7328dc`, projection
14,051 bytes / `4a3f0784d3917e82ab8d9e230ca3ed7fd8b017f804be76545d9f5e8b11468799`; support selection
lines 383–390, 297 bytes / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912`; and exact v2 candidate
2,292 bytes / `2c3c51eb1a7ff53e268d38b81e660539ec93d1d6ef775e8389d40db267b86660`. The reviewer did not
inspect candidate or source/test bodies. The schedule requires a 500-token cap
for the complete correction and regression, fresh execute preflight, and
three count-only requests including 5,000 output, 2,000 cushion and 31,000
reserve. No source-body change is authorized until all counts pass.

## Task 2 candidate v3 exact schedule — active

The 500-token limit applies only to source correction/reread spans. The v1/v2
759/743-token requests bundled generated diffs with the support reread and are
preserved as mixed counts, not source-cap failures. The v3 diff is generated
output and is charged to the separate 5,000-token output allowance. The
Task1-read target-source test region remains bound by its original file
identity and is reused without a new reread; only the narrow support decision
tail is scheduled as new source input.

| File/input | Current identity | V3 selection | Budget classification |
|---|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 bytes / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | `attach_target_sources!/3` lines 383–390; 297 bytes / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` | Existing source reread; direct count against 500-token cap. |
| `test/contract/tier_sweep_test.exs` | 768,677 bytes / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | No new source read; the target-source fixture area was read in Task 1. | Existing test file identity is unchanged; new regression bytes are generated output. |
| Temp-only v3 candidate | 2,159 bytes / `4919cc453cf1686bede0d9a3d65cb217609ca622bc0c9015dc7e6075fc8b948e` | Exact diff for the narrow gap-derived flag and true/false regression cases. | Generated output; direct token count must be ≤5,000. |

The exact Task 2 source reread ceiling remains 500 tokens across at most five
files; the generated diff has a separate 5,000-token output cap. Count context,
source reread spans, generated output and combined request separately. Apply
the 2,000 cushion and 31,000 reserve when checking the 99,000 total ceiling.
Current context bindings are the full hash-bound STATE, REPLAN, REVIEW and
SIZING files and only the latest handoff/blocker excerpts listed above. Obtain
independent metadata PASS, fresh execute preflight and direct counts before
emitting the candidate. No source edit or test run is authorized before those
gates pass.

The finalized count-only harness is `/private/tmp/fablebook_plan03_04_task2_count.py`,
SHA-256 `ad65e9e380bc8890ae19daecdec06b969f7ddb244536ae1d4736136379518c99`.
It verifies the current hash-bound context selections and candidate identities,
then sends separate context, source-span, candidate-output and combined
requests to the input-token endpoint. The span request contains only support
lines 383–390; the v3 patch is separately charged to the 5,000-token output
cap. The combined request contains context, reread span and exact output; its
total calculation adds remaining output allowance, 2,000 cushion and 31,000
reserve. Count outputs remain pending; no source body is emitted beforehand.

## Task 2 candidate v3 metadata review — PASS

Independent metadata-only review on 2026-11-15 bound the pre-receipt schedule
SHA-256 `60758be24a6f24fed91ab9c4240a9de18b1b472f39fdcff640bf780461b79175`.
Current full-file/excerpt bindings were reproduced: STATE 18,481 bytes /
`7cbde995192c7ec8c2ab2e2fe556a344793910d3b8255536c9f950a43fbef81e` with
line 41 636 bytes / `bdfa9b1233bfd467b0941873ce3c8646f71053971cc5ceac9c4ae9695f4ca346`
and lines 49–51 1,213 bytes / `51b12310d7914181e0b936c40dcc2f38280b94ee478222b07ddf6172a6f62acf`;
REPLAN 17,147 bytes / `3f0900b0dd8a0ae342434e8c4d915ba9116fb59100334435227d29d687de065f`,
lines 227–242 1,011 bytes / `975363882a3fec9e197887989d9466984e78508bc01066e4ea5c9cffc72de6be`;
REVIEW 32,430 bytes / `1cba2d2586ad338fe5887f395e68deecd0d877fa8fefa1a350cbabc0cc0206db`,
lines 454–466 825 bytes / `9dfcc8368146810c65524844b893ca8ad561ba36483d07f32927b529488d6306`;
SIZING 19,092 bytes / `3f98ec287f98276951ffdb8ce45e5792b4dc3019111b6401f31d631c17e2e7c8`,
projection 14,744 bytes / `fc9da203c8490a16ee736d8d3f582ca12342e437b28f4d3e7a09305c34286a98`.
The support reread is 297 bytes / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912`;
v3 output is 2,159 bytes / `4919cc453cf1686bede0d9a3d65cb217609ca622bc0c9015dc7e6075fc8b948e`;
the count harness is SHA-256
`ad65e9e380bc8890ae19daecdec06b969f7ddb244536ae1d4736136379518c99`. The
reviewer confirmed the 500-token cap applies only to source rereads and the
5,000-token cap applies to generated output. V1/v2 counts are historical mixed
requests. Fresh execute preflight and separate direct counts are still required;
no source body may be emitted until each cap and the total envelope passes.

## Task 2 candidate v4 exact schedule — active; v3 counts superseded

The previous v3 count is preserved as historical only. Its zero-context test
hunk landed at EOF outside the test module. The test file was restored and no
test ran. During diagnosis, test lines 5905–5960 were read; bind that exact
span and use its existing caller-graph tag/declaration as the insertion
anchor. The corrected candidate inserts immediately before that declaration
with both lines present as context in the patch hunk.

| File/input | Current identity | Exact Task 2 selection | Classification |
|---|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 bytes / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | lines 383–390; 297 bytes / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` | Source correction reread. |
| `test/contract/tier_sweep_test.exs` | 768,677 bytes / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | lines 5905–5960; 2,125 bytes / `c6c5fa526f2ebaf6f19e76abe650a79b3a65a76f1472cc715fd24a3c1103a6b3`; insertion anchor lines 5936–5937 | Accidental diagnostic reread plus exact hunk anchor; charge all selected bytes to the 500-token source cap. |
| Temp-only v4 candidate | 2,285 bytes / `ad4206158f28e7193c85c58a291cb4a60d0dd375a52dfbb23456638e271326df` | Gap-derived flag and both true/false cases; test hunk anchored to the existing caller-graph test declaration. | Generated output; separate 5,000-token cap. |

The corrected source/output selection must be counted as source spans and
generated output separately. Rebind current STATE, REPLAN, REVIEW and SIZING
full identities and selected projections in the harness. Preserve the 38,500
context cap, 500 source-span cap, 5,000 output cap, 2,000 cushion, 31,000
reserve and 99,000 overall limit. Obtain independent metadata PASS, fresh
execute preflight, and four direct count-only requests (context, source spans,
output, combined) before applying either hunk. Do not use the v3 count receipt
to authorize these changed bytes or selections.

### v4 count-context bindings

| Context artifact | Current full identity | Selected current excerpt/projection |
|---|---|---|
| `.planning/STATE.md` | 18,437 bytes / `829c6923c11c7bc3f771d57d743aafc4d000853061710a7b6f222a5fcc659309` | lines 40–52, 2,966 bytes / `7c50feb7349db7808cdaff2fb808ab7de17d2ba4968038f4ac15b4681bc06225` |
| `03-04-REPLAN.md` | 18,315 bytes / `f48ad2c9839d20a3472641e2ca20166bf41f4edd13b6570c9f7c9cd890022f08` | lines 244–260, 1,167 bytes / `9aac30a49f1c94a36fbbb684088c74c0c15021ef8ca04d9e126e7f0aac578898` |
| `03-REVIEW.md` | 33,744 bytes / `a809b5123818ddf8ab16411e3e1e1cbf08b1b2492fe16d313727adf11a3af66b` | lines 471–491, 1,313 bytes / `005963e2ac66fb8c4657319d137f4fe41ab402f61cecb8c0e9daa2ed277a666d` |
| `03-SIZING.json` | 19,092 bytes / `3f98ec287f98276951ffdb8ce45e5792b4dc3019111b6401f31d631c17e2e7c8` | keyed projection, 14,744 bytes / `fc9da203c8490a16ee736d8d3f582ca12342e437b28f4d3e7a09305c34286a98`; unchanged because no corrected source has been applied and candidate remains null |

The deterministic count-only harness is `/private/tmp/fablebook_plan03_04_task2_v4_count.py`,
17,831 bytes / SHA-256 `66aa31a4fa0335916bf911acdc629abbeac337d1097488214e2b440ff764c58d`.
Its metadata-only builder verified the exact current bindings and serializes
the selected context, both source spans and v4 output separately. The receipt-
bearing schedule SHA-256 must be reviewed before a fresh execute preflight
and the four approved direct count-only requests.

## Task 2 candidate v4 metadata review — PASS

Independent metadata-only review on 2026-11-15 bound the pre-receipt schedule
SHA-256 `eeee54827314e5c47b074e338107e2c2309bdbaed82b5b386afb96d8add5197a`.
The reviewer reproduced current STATE/REPLAN/REVIEW full-file and excerpt
identities, the SIZING 14-key projection, support lines 383–390, and the
2,125-byte test selection at lines 5905–5960 including the line 5936–5937
insertion anchor. The exact v4 candidate is 2,285 bytes /
`ad4206158f28e7193c85c58a291cb4a60d0dd375a52dfbb23456638e271326df`; the
count harness is 17,831 bytes /
`66aa31a4fa0335916bf911acdc629abbeac337d1097488214e2b440ff764c58d`.
The independent reviewer confirmed separate 500-token source, 5,000-token
output, 38,500-token context, 2,000-token cushion, 31,000-token reserve and
99,000-token total limits; v3 counts are historical. This PASS covers metadata
only. Fresh execute preflight and four direct count-only requests remain
required; no source body may be emitted until token fit is confirmed.

## Task 2 candidate v4 direct count — source-span cap failed

On the receipt-bearing schedule SHA-256
`a7b4dd86dbaa784eafd06def2f952587ee5f094bf9be0038293e443791b26381`, the
fresh execute preflight passed and the v4 harness
`66aa31a4fa0335916bf911acdc629abbeac337d1097488214e2b440ff764c58d` made four
count-only requests. Results: context 34,069 tokens / payload SHA-256
`79474c3463b6fb8d449647b95b0596e0c03dbad37fa7c6b35e8533578e97f18e`; source
spans 611 / `7186a70d6d43b1cc5b6b8039adf95f2cd99ee7bfa268281f90db3e861ed3eeb5`;
candidate output 638 / `65f19e763707a4ca1aa405b3af6657d7d6920990c3293ed497811578e51f53fa`;
combined 35,306 / `d39033d17fcb9ee66c2c02e6cacfd745117a1b809c05aee3db857bb73b9d0f7c`.
Context/output/total pass; source spans exceed 500 by 111. With 4,362
remaining output, the 2,000 cushion and 31,000 reserve, projected total is
72,668. No patch was applied and no test ran. Before another attempt, determine
whether an exact smaller source selection can preserve the already reviewed
anchor and both behavioral assertions without exceeding 500; otherwise retain
the finding as an owner-facing gap. The v4 count does not authorize source
emission.

## Task 2 candidate v5 exact schedule — active; reviewed-span reuse pending

The conservative v4 count included the 2,125-byte accidental diagnostic read
and failed the 500-token Task 2 cap. Do not erase that read; it remains fully
bound as history. The complete diagnostic range 5905–5960 is already covered
by two contiguous, unchanged, independently reviewed Task 1 spans: lines
5789–5935 (4,935 bytes / `a82bca9e9dcdd78d2022af3da33c699f0cb380b9d0c81c41257c6e16e21c0b28`)
and 5936–6137 (7,797 bytes /
`39d0c8cb47e88d1a42b4849e2afe0736439eb65aff2dbac41f0490ea5a94798c`). Their
union covers every line of the diagnostic read. The test file remains
768,677 bytes / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5`.
The exact patch anchor at lines 5936–5937 is 126 bytes /
`194b0665bb52289e99a0dbf328a40727dbd8c74673b0e15eeb61ab7725fd0998`.

This schedule proposes to reuse those already reviewed and counted Task 1
spans as existing context, with no new Task 2 test-body reread. This is a
plan-accounting interpretation only if the independent reviewer confirms it
satisfies “including every reread”; otherwise v4 remains the controlling cap
failure and the source-join finding stays open. The accidental read remains
disclosed, including its exact 5905–5960 range/hash from the v4 receipt.

| File/input | Current identity | Task 2 source/output selection | Classification |
|---|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 bytes / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | lines 383–390; 297 bytes / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` | Only new correction reread; direct source cap. |
| `test/contract/tier_sweep_test.exs` | 768,677 bytes / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | Reuse Task 1 spans 5789–5935 and 5936–6137; no new body span. Anchor lines 5936–5937 are hash-bound above. | Prior reviewed/read context, no new Task 2 source tokens if reviewer accepts. |
| Temp-only v4 candidate | 2,285 bytes / `ad4206158f28e7193c85c58a291cb4a60d0dd375a52dfbb23456638e271326df` | Gap-derived flag and both true/false cases; hunk context includes anchor lines. | Generated output; count against 5,000. |

Current sizing record after recording the v4 result: 20,325 bytes /
`4270068bed3effe358e65dc6b3592025d3c320a43ff26cc490e7780d60a8767e`; its
14-key projection is 15,740 bytes /
`4ea8be4f115e2397b9310b13842f25fb947ac17e61b00aa272d0d6d2f73de84d`. STATE,
REPLAN and REVIEW identities must likewise be refreshed after their v4
interpretation notes. If reviewer accepts the reuse interpretation, run fresh
execute preflight and direct context/source/output/combined counts on this
exact schedule. No source emission until the new source count is ≤500 and all
other caps pass.

### v5 current hash-bound context

| Artifact | Full identity | Selected excerpt/projection |
|---|---|---|
| `.planning/STATE.md` | 18,752 bytes / `3d17a6908e9742c6a20786651319716df6998574f04662728e0766ca0d0aa834` | lines 40–52, 3,281 bytes / `b560ba99fbe6d9b4e5362251ccc8e49af21a13d9b1389f74be02d8d2f95b7a52` |
| `03-04-REPLAN.md` | 20,209 bytes / `7123123af28a73220ecd096b94dbd2d167741f0be4701a7b49acdbc6a77892a4` | lines 276–290, 1,057 bytes / `8ece57754788a2377cad5fa15090e2685c7a028676c0fdbac5785c189ffb18de` |
| `03-REVIEW.md` | 36,973 bytes / `9db9a4f3ce0740c102a55985230b10cc930e0d706d3842b50d3a2590a2faa2dc` | lines 522–542, 1,300 bytes / `612e89f8e1c857f3ea4b52bc16f66ef980515862fea7324437f7ded4de6a244c` |
| `03-SIZING.json` | 20,325 bytes / `4270068bed3effe358e65dc6b3592025d3c320a43ff26cc490e7780d60a8767e` | 14-key projection 15,740 bytes / `4ea8be4f115e2397b9310b13842f25fb947ac17e61b00aa272d0d6d2f73de84d`; candidate remains null |

The current schedule SHA-256 is pending the fresh independent metadata review.
This schedule supersedes v4 only if the reviewer accepts the explicit
Task1-span reuse interpretation; the v4 failed count remains fully recorded.

The v5 metadata/count harness is `/private/tmp/fablebook_plan03_04_task2_v5_count.py`,
18,290 bytes / SHA-256
`b4ab162673861a771f404751d10c9dd8e04be8c5103dc2cd13d7f19525ceddf5`. It
checks both prior Task 1 span identities and the accidental diagnostic span
metadata-only, while placing only the new 297-byte support span in the Task 2
source-token request.

## Task 2 candidate v5 accounting review — BLOCK

Independent metadata review on 2026-11-15 bound the pre-receipt schedule
SHA-256 `09caf25576d2aabb550dfc0ddfb1b09766b1dfa2391510ccda26cf194147f076`.
It rejected reclassifying the Task2 diagnostic reread as existing Task1
context: the plan requires counting every reread, and the lines were actually
read again during Task2. The prior reviewed spans do not erase this read.
Therefore the v4 direct 611-token source count remains the controlling failure
against the 500-token cap. No v5 direct count, source emission, patch
application or test is authorized. Preserve this candidate/interpretation as
historical and proceed only with permitted Task3 work that has zero new
source-body reads and its own schedule, review, preflight and count gates.

## Task 3 zero-source-read report schedule — active

Task 2 remains an owner-facing source-join gap after the reviewer-confirmed
611-token cap failure. Task 3 is limited to publishing the report from current
validated machine records and recording the unresolved finding; it makes zero
new source-body reads. It does not imply the collector correction passed.

| Context/output | Current identity | Selection | Classification |
|---|---|---|---|
| STATE | 18,544 bytes / `22d7680fc905d325d321862962ecb24212901884b71a713f6a3f956e5780cac9` | lines 40–52, 3,073 bytes / `a00e7735e3877fa9099d5dd4d8bf50cf209d1d447310b47f5030260fd2784a89` | Current handoff and unchanged stops. |
| REPLAN | 20,659 bytes / `ef198242423f7ebfb264e8bdb30ace5ee119116e988ab09bf64e017ecde667a2` | lines 284–299, 1,075 bytes / `a6b5ed023233df91eb108c21532ed96f1892d808eebf9e2e464b26223af5d86e` | Task2 cap result and Task3 fallback. |
| REVIEW | 38,082 bytes / `af1815a05e2b3ad105b922e4d6afad5c29892041b199f2a8d06e51376da50efe` | lines 544–561, 1,108 bytes / `895787e608c6f25f88b12884d277deac232bd1947c903964b4d35f3e19ef049f` | Reviewer block and finding consequence. |
| SIZING | 20,677 bytes / `75aaae97afb0e0c082f638edad33195c83be2b529655a69e1a5cb8dae4398ba2` | 14-key projection, 16,037 bytes / `e9a6d216877d99dff7ac4726a37d5ec72018b308e604db91718693486070677c` | Candidate null; failed Task2 schedule preserved. |
| Existing report | 13,115,491 bytes / `3ee538cdce64372ffe9a6641894ba309f976572118bae3f3c73d90fdfd488c61` | lines 5–12, 528 bytes / `4522ccd14b59c0441f105f5aa0ac30e69f6b98b3cc6b6e0e6e77c7238d453cf3` | Only complete concise report section enters context; full body stays closed. |

Task 3 adds zero source-body spans. Its context still accounts for the
previously measured Task 1 spans (21,172 tokens, request SHA-256
`ef1d84f91dbe93dafb018a8567c161a9482eac7621a2bf4c1fd39d967f5a94ef`) and the
failed Task2 reread (611 tokens, request SHA-256
`7186a70d6d43b1cc5b6b8039adf95f2cd99ee7bfa268281f90db3e861ed3eeb5`) in the
overall projection; neither body is re-emitted. Keep Task3 new source reads at
zero, preserve output≤5,000, cushion≤2,000, reserve31,000 and total≤99,000.
The approved automated sequence is the Task3 bundle-write command followed
by full aggregate tag runs in both lanes. The report hash/concise section and
review disposition must be recounted after regeneration if their bytes change.
Obtain independent metadata review, fresh execute preflight and direct
count-only context/zero-span/combined requests before report publication.
The Task3 metadata/count harness is `/private/tmp/fablebook_plan03_04_task3_count_v3.py`,
16,796 bytes / SHA-256
`87f94214446c510ca4ec451964a7faf6fbb18cf5510335234aa1dbefb46e4183`; its
metadata-only build validates current file identities and the concise report
section without reading any source/test bodies. The deterministic report
artifact is generated by the approved lane command; up to 5,000 tokens remain
reserved for model-authored output/review text.

## Task 3 schedule metadata review — PASS

Independent metadata-only review on 2026-11-15 bound the pre-receipt schedule
SHA-256 `a425f4266dcf35b7e8ed8493ce731918e7cb795ab2322b12c018c138a25e3391`.
The reviewer confirmed current STATE/REPLAN/REVIEW identities and excerpts,
SIZING 14-key projection, concise report section and full report identity. The
16,683-byte harness matches SHA-256
`e0bfe4dce7db7491d0bbb6d62c8ddef4ce23f993457e5efee87b0b3290929a2d` and reads
only planning/machine-evidence/report artifacts, with zero source/test body
reads. It preserves the Task2 cap gap and every safety stop. Accounting is
38,500 + 21,172 Task1 + 611 Task2 + 5,000 output + 2,000 cushion + 31,000
reserve = 98,283, within 99,000. Fresh execute preflight and direct
context/zero-span/combined counts remain required before report publication.

## Task 3 first count attempt — empty-span request rejected

The first approved attempt passed fresh execute preflight and received a
context count of 37,242 tokens / request SHA-256
`eefa1498280ebd5fcdf746d8c2f3a680e537eac917c42aaffeae545846c45e53`. The
next request used an empty `input` for zero source spans; the endpoint rejected
it with HTTP 400 `missing_required_parameter`. No span or combined count ran,
and no report or source body was emitted. The v3 harness uses a short explicit
zero-span marker instead of an empty request; it remains metadata-only until a
fresh independent review, execute preflight and direct recount pass.

## Task 3 updated schedule metadata review — PASS

Independent metadata-only review on 2026-11-15 bound pre-receipt schedule
SHA-256 `06b4036de37b0bf292168cd9bf4afa710ff142f261fdc5503c18d66f72a43495`.
The v3 harness matches its scheduled 16,796-byte size and SHA-256
`87f94214446c510ca4ec451964a7faf6fbb18cf5510335234aa1dbefb46e4183`.
Current planning, sizing and report bindings match. The nonempty zero-span
marker is 53 bytes / SHA-256 `226ba7e3…34336e26c` and contains no source body.
The failed empty-input API call remains recorded; no report/body was emitted.
Task3 remains zero-source-read publication only, with the Task2 owner gap and
all safety stops preserved. Worst-case accounting remains 98,283 of 99,000.
Fresh execute preflight and direct context, zero-span and combined counts are
still required.

## Task 3 count and publication checks — PASS

After fresh execute preflight passed, the v3 harness
`87f94214446c510ca4ec451964a7faf6fbb18cf5510335234aa1dbefb46e4183` made three
count-only requests on the receipt-bearing schedule SHA-256
`f7064028e4023f08c0f96b476a4a76b342177c978a576660b84e45fc5116efd5`:

| Request | Tokens | Request SHA-256 | Result |
|---|---:|---|---|
| Current context | 37,387 | `914304c20ee62b62ef3bf6e1bdec6033a9bc7484768260a99484a5e7b736d3b3` | Passes 38,500 |
| Nonempty zero-source-span marker | 19 | `3d2a3977f9b170e7b2f1bd2d69fbf001fc03779cf45d15bc0562ed6f8df5a34a` | No source body selected |
| Combined context and marker | 37,400 | `0293526844aa4aa67433933d2ef0b8d15d7e2aebfe884df2cc3fabd7238f7d5f` | Passes |

Projected total including the previously counted Task 1 spans (21,172),
Task 2 failed reread (611), 5,000 output, 2,000 cushion and 31,000 reserve is
97,183 / 99,000. The approved report/both-lane checks then passed: report
bundle selector 5 passed / 103 excluded; core aggregate selector 5 passed /
103 excluded; floor aggregate selector 108 passed / 0 failed / 103 excluded.
The generated report remained byte-identical at 13,115,491 bytes /
`3ee538cdce64372ffe9a6641894ba309f976572118bae3f3c73d90fdfd488c61`; lines
5–12 remain 528 bytes / `4522ccd14b59c0441f105f5aa0ac30e69f6b98b3cc6b6e0e6e77c7238d453cf3`.
Core/floor machine evidence hashes were unchanged. The Task2 source-join gap
remains open, `candidate=null`, and all safety stops remain unchanged.

## Owner-authorized Task 2 reallocation — active v6 schedule; count pending

This section supersedes prior active 500-token Task 2 envelopes. Earlier caps,
counts and review receipts remain historical. On 2026-11-15 the owner
authorized moving 300 tokens from the prior 1,000-token global slack to Task
2. Active caps: context 38,500; Task1 spans 22,000; Task2 correction/reread
800; Task3 new reads 0; output 5,000; cushion 2,000; reserve 31,000; working
maximum 68,300; total maximum 99,300, leaving 700 below 100,000. Keep the
entire 611-token Task2 source selection, including the diagnostic reread; do
not apply v5's reuse exclusion.

Current planning input identities (pre-review schedule):

| Input | Full bytes / SHA-256 | Selection bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 18,967 / `2726cc811719570477fa90b499c8646926199926720c1de2adf5cf31f6569c3c`; 3,419 / `27c3c984ef4ab24f5febbe655ffde28dbdb93023a246ada7b02db584fe41d04b` |
| `03-04-PLAN.md`, lines 70 and 90 | 19,989 / `1b73fb56733f5e3e9afbe92b245e253d129ec02e8469d414b1aa35d78f47c32d`; 1,695 / `ce4ecba8f778bfcb97f8eb519adbb024657cdc859ef7f497eef63d7d6a45d715` and 795 / `e8e6adceeeb45c47004eede23ae4bd8f01be7115f10c56e48bf3a89b16724520` |
| `03-04-REPLAN.md`, lines 301–318 | 21,973 / `09181a89ac39bdd55727d4db9ad201197b8968af05a11422f6b527c10b3cb2f7`; 1,184 / `23e2b288fc6ff494d3d32696dd32b20be9f15595407ec64b9aa0b37ac6b0d7ea` |
| `03-REVIEW.md`, lines 563–575 | 40,486 / `68c4a91e27136faa76bde25fbdeb835e731292519b5eba7b6e4234c85bf7f8c3`; 850 / `5d76f8c9d0dc0521afd217d15cceadb47feb4b220c70c91a3c6ffb70330c2232` |
| `03-SIZING.json`, exact 14-key projection | 22,113 / `924c5a009ff124dda7d7cf1bf0530ad3ac30fa050e4a0fc03176e0b659400ebe`; 17,163 / `4cb20a3c2f827f37b3ff6d1b6e886154daa6b7e2e643b8f1eb77f90ea449a86e` |

The opaque candidate is `/private/tmp/fablebook_plan03_04_task2_candidate_v4.patch`,
2,285 bytes / SHA-256 `ad4206158f28e7193c85c58a291cb4a60d0dd375a52dfbb23456638e271326df`;
its prior output count was 638 tokens / SHA-256
`65f19e763707a4ca1aa405b3af6657d7d6920990c3293ed497811578e51f53fa` and
requires recount. Do not inspect its body before the count gate.

| Exact correction/reread input | Full bytes / SHA-256 | Selected span | Span bytes / SHA-256 |
|---|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 58,686 / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | lines 383–390 | 297 / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` |
| `test/contract/tier_sweep_test.exs` | 768,677 / `f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5` | diagnostic reread plus actual test-module anchor, lines 5905–5960 | 2,125 / `c6c5fa526f2ebaf6f19e76abe650a79b3a65a76f1472cc715fd24a3c1103a6b3` |

The exact test insertion anchor is lines 5936–5937, 126 bytes / SHA-256
`194b0665bb52289e99a0dbf328a40727dbd8c74673b0e15eeb61ab7725fd0998`; it is
not an EOF insertion. The selected source reread previously counted 611
tokens, including every diagnostic byte, and must be recounted under 800.
Fresh direct counts are also required for compact context, exact candidate
output, combined request and the 99,300 total projection. No source body may
be emitted unless all caps pass; candidate remains null and every safety stop
is unchanged. Independent metadata review passed for the exact pre-receipt
schedule digest recorded below; fresh execute preflight has now passed. Direct
count is still pending.

## Independent review receipt — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`815686c46108e1fedfe79097f822a67aba02b5f025739ebbece4850b4a7840cd`.
The reviewer verified all current file identities and selected excerpts,
the exact sizing projection, both complete source-span hashes, the test
anchor, and opaque candidate bytes/hash. It explicitly accepted that all
611 source tokens including the diagnostic read fit the owner-authorized
800-token cap. It confirmed working 68,300 + reserve 31,000 = 99,300, leaving
700 below 100,000. No body was read or emitted, no patch applied, no tests or
count calls run. This receipt does not authorize source emission; fresh
execute preflight and direct counts remain mandatory.

## Candidate v5 syntax repair — supersedes v4 output; fresh count pending

The v6 count passed all then-bound caps, but inspection after that count found
that the v4 test patch concatenated the inserted `end` with the existing
caller-test `@tag`. No source edit or test occurred. The temp-only v5 payload
repairs that one newline and retains the same source behavior, true/false
regression intent, insertion point and selected spans. V6 candidate counts do
not bind the changed v5 bytes. Active payload:
`/private/tmp/fablebook_plan03_04_task2_candidate_v5.patch`, 2,287 bytes,
SHA-256 `da85e456a9a7cbb85bb25fdedbbd8fbd8adaf4ec3ea3b7be276b6aa02a636b42`.
The prior v4 count remains historical: output 638 tokens /
`65f19e763707a4ca1aa405b3af6657d7d6920990c3293ed497811578e51f53fa`.

Current exact inputs for a fresh count:

| Input | Full bytes / SHA-256 | Active selection bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 19,051 / `78393615a39df58e3a497e9b2c7ee35eaf08cd004245169d346d01574c70fea8`; 3,482 / `e3f069ea095b096f3eceda7d314a7d18f4b33ea30218fbdc0719057a6bb20893` |
| `03-04-PLAN.md`, lines 70 and 90 | 19,989 / `1b73fb56733f5e3e9afbe92b245e253d129ec02e8469d414b1aa35d78f47c32d`; 1,695 / `ce4ecba8f778bfcb97f8eb519adbb024657cdc859ef7f497eef63d7d6a45d715`; 795 / `e8e6adceeeb45c47004eede23ae4bd8f01be7115f10c56e48bf3a89b16724520` |
| `03-04-REPLAN.md`, lines 319–334 | 22,672 / `8d97a9b0e23c2b4fa60244194147abdc4e6e456792aa920d9b09002a388db0d3`; 828 / `a8494b919a7f559cbaf9bd2fc74bb9920031a34290c16cce3fb5cc81ef8077aa` |
| `03-REVIEW.md`, lines 576–589 | 41,259 / `326ce724d8d9e5c0151f2b4f819e2697ae6c3012a2dc66dade13a4047483a201`; 786 / `577349e9c31b762fdaff56d8e2db082d14038b5a2f27cb7b47f0f21a5f4e66c9` |
| `03-SIZING.json`, exact 14-key projection | 22,114 / `9e55c8669b461cf725b58bbc5f217b56eb6a9e7be1b47144ab9b4cff0534a644`; 17,164 / `77f4c241b42e37b98cd6c7eec0b3d0f754d111a452267f41261cdccd7a276449` |

The two Task2 source spans remain unchanged at 611 prior direct tokens and
retain the exact full-file/span hashes in the v6 active schedule above,
including all lines 5905–5960 and the 5936–5937 module anchor. Recount current
context, these spans, v5 output and combined input, adding Task1's established
21,172-token count, remaining output allowance, 2,000 cushion and 31,000
reserve. Required caps remain context 38,500, Task1 22,000, Task2 800,
Task3 0, output 5,000 and total 99,300. Independent metadata review of this
v5 amendment, a fresh execute preflight and a fresh direct count are required;
no source emission is authorized by the v6 receipt.

## Candidate v6 hunk repair — active schedule; fresh review/count pending

After v5 metadata review, `git apply --check` caught one missing indentation
byte in the existing caller-test context line; it made no source edits. The
temp-only v6 candidate fixes the hunk boundary and passes `git apply --check`.
Active payload: `/private/tmp/fablebook_plan03_04_task2_candidate_v6.patch`,
2,288 bytes / SHA-256
`05998c2c9adf88e6e1c3e96998fb94ef4c6e2cb734a522cc34aa64b2a54dbac3`. V4/v5
counts remain historical and do not authorize v6 emission.

| Current input | Full bytes / SHA-256 | Active selection bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 18,988 / `aa15e4c9aba48f05388ebd18ab2bd632787425170c23eb97359cf675accdbbc4`; 3,426 / `48b6d833dc3c2c041e1a3449a1b56ed5e75c95e2479596b1003dceccfafe4f82` |
| `03-04-PLAN.md`, lines 70 and 90 | 19,989 / `1b73fb56733f5e3e9afbe92b245e253d129ec02e8469d414b1aa35d78f47c32d`; 1,695 / `ce4ecba8f778bfcb97f8eb519adbb024657cdc859ef7f497eef63d7d6a45d715`; 795 / `e8e6adceeeb45c47004eede23ae4bd8f01be7115f10c56e48bf3a89b16724520` |
| `03-04-REPLAN.md`, lines 335–351 | 23,415 / `866d7ca2b35fa187cb56a8a7a999339a00eaee79170bebca76514d5eeeafc6e9`; 635 / `c758e205d4e2efbb2c8b8cf3188f46c1724a09ac4f979e42e7b2a69796ce9c1f` |
| `03-REVIEW.md`, lines 590–603 | 41,868 / `b5c9a94637b69e3357f15dac2c06ab6ae3c8f8d68e8a893f59c5d1a450b57322`; 822 / `3893eb4f11d1c28562cb440304fc4afb166cb3061a0d0153c58ebfdeaa541ddd` |
| `03-SIZING.json`, exact 14-key projection | 22,280 / `61d90851c4e90b17bcd40b1dad47af712bb2e270f568284f428e1f8bfb11982d`; 17,306 / `fbd18068c11338a8de12f78585a5784457cffd4d6c00251403054ea13eafed49` |

The support/test source spans and anchor remain byte-identical to the complete
611-token selection above; retain the full test diagnostic read and do not use
v5 reuse. Recount context, the exact spans, v6 output and combined request;
include Task1 21,172, remaining output allowance, cushion and reserve under
the unchanged 99,300 total cap. Fresh independent metadata review, execute
preflight and direct count are mandatory before source edits.

## Candidate v5 metadata review receipt — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`49fa278e9ea00811e7a15e811b715c1dfa44fc5cf074c3bcbe03d5baa8cdb807`.
The reviewer matched current planning identities/selections, SIZING projection,
source full-file/span hashes, actual insertion anchor and opaque v5 candidate
metadata. It confirmed all 611 diagnostic-inclusive Task2 tokens remain
selected under the 800 cap; v4 output count is historical, and v5 must be
freshly counted. Reallocation totals and all unchanged stops were verified.
No bodies were read, no edits/tests/counts occurred. This receipt does not
authorize emission; fresh execute preflight and v5 direct count remain needed.

## Candidate v6 metadata review receipt — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`d42517978faf9c62005c320cb803aeac3e06579e800462f7c38d07abb7325f7f`. Current
planning identities/selections, SIZING projection, source spans, anchor and
opaque candidate v6 metadata all match. The reviewer verified the complete
611-token Task2 read under the 800 cap, the successful non-mutating
`git apply --check`, and that v4/v5 counts are historical. Reallocation totals
remain 99,300 with 700 slack. No source/test bodies were read or edited; no
tests or counts ran. Fresh execute preflight and v6 direct count remain
mandatory before source emission.

## Candidate v8 test syntax correction — active schedule; count pending

The prior v6 count remains historical and includes 611 Task2 source tokens,
including the diagnostic reread. V6's invalid RED is recorded at
`03-04-TASK2-INVALID-RED.log`. A temp-only v8 patch reorders a mixed-key test
map; it passes syntax parsing and `git apply --check`. The dirty workspace test
hunk has not been changed again; support source remains unchanged.

| Current planning input | Full bytes / SHA-256 | Selected excerpt bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 18,497 / `71ebe22f95d09cc040c878c60a9e45bb79c9969521d1496618f0d7a543bc21df`; 2,930 / `3e22682809437964cdbc9ca15be1e6c03242a69f8a81d82958f40466733af3a6` |
| `03-04-PLAN.md`, lines 70 and 90 | 19,989 / `1b73fb56733f5e3e9afbe92b245e253d129ec02e8469d414b1aa35d78f47c32d`; 1,695 / `ce4ecba8f778bfcb97f8eb519adbb024657cdc859ef7f497eef63d7d6a45d715`; 795 / `e8e6adceeeb45c47004eede23ae4bd8f01be7115f10c56e48bf3a89b16724520` |
| `03-04-REPLAN.md`, lines 352–369 | 24,283 / `72b94786dcacd5778426a4be0d04c7f05dcfc20094faad36d1a42045fe644342`; 477 / `9e2c5b42326c40e2f45e9f4c9339a8af4d5fc64f35b41eeb8348f0ee9eecdb63` |
| `03-REVIEW.md`, lines 604–618 | 43,436 / `6b7814f0493fee6a8ae656611a4d8a5ad51e6c01ac51c7db56345af8426e6f2b`; 861 / `e95fa97c5e3feebbc2b09d76b91289f6af346e54f99643aaa4114437c398ea50` |
| `03-SIZING.json`, exact 14-key projection | 23,562 / `1cda964641e88731322b9437adeb88167e545e83bd7524ab2cbf93987bb47a81`; 18,365 / `2616b868c40e5831a0bdfe23a8113857ef803e7738cf582e1c5cef2d7bf38556` |

Candidate v8 test-only correction: `/private/tmp/fablebook_plan03_04_task2_candidate_v8_testfix.patch`, 1,132 bytes / SHA-256 `780d00f33ce8a6d1f3686a8648f7cb68a9f8c431c76506969b46c45090f7c534`. It changes only the test line after the already-counted v6 test insertion. Current incremental source selection is `test/contract/tier_sweep_test.exs` lines 5943–5945, 580 bytes / SHA-256 `26600a05898ee51de1a525ad227a0e9ed731513face9f4a4df9d874c0f6e797f`; full current file 770,007 bytes / SHA-256 `2a09a5d4e11795f7d39db52dc76b7ef64f643e95aa718655f7a00d6657075b5d`.

For cumulative Task2 source accounting, retain prior v6's complete 611-token
source selection and add only the incremental 5943–5945 reread; the cumulative
source total must remain ≤800. Keep previously counted v6 output 639 tokens
plus the v8 patch's fresh output count within the 5,000 output cap. The fresh
combined request must include current context, incremental source span and
v8 candidate, and the projection must add Task1 21,172, prior Task2 source 611,
remaining output, cushion 2,000 and reserve 31,000 under 99,300. Trim only
superseded repeated attempt narratives from the count context; bind the full
current files and retain complete history in place. Independent review,
execute preflight and fresh direct count are required before applying v8.

## Candidate v6 direct count receipt — passed

The pre-count receipt-bearing schedule was SHA-256
`db428855f12abbae923fb974cdd0e6697f83258fe4967495c88151fabeefe291` and the
count harness was SHA-256
`09c29d9210b4d61b0de3afd47d887ac175d385b12427f0eb9dd0774e2f9b1f32`.
Four direct count-only requests to the approved input-token endpoint returned:

| Request | Tokens | Serialized request SHA-256 |
|---|---:|---|
| Current context | 38,335 | `2080cd66a37eaf0a24e90ff0b6e71ac81a422f1ae9d07076712a56cd18634091` |
| Complete Task2 source selection | 611 | `7186a70d6d43b1cc5b6b8039adf95f2cd99ee7bfa268281f90db3e861ed3eeb5` |
| Candidate v6 generated output | 639 | `250edbf84760cdf7c67c59fa70487201de05c4d80ddc97f6e84642aea606a6d9` |
| Combined context, source selection and candidate | 39,573 | `460abad6a479a547dd1d7c8b49d8dc621fb9b9e2c3008f294b3a9cd1577d81bd` |

The projection is 39,573 combined + 21,172 already-counted Task1 spans +
4,361 remaining output + 2,000 cushion + 31,000 reserve = 98,106 / 99,300.
Context, Task1, Task2, Task3, output, cushion, reserve and total caps all pass.
This receipt records results for the pre-count schedule; it is excluded from
the selected count context. The v6 patch may now enter the planned RED/GREEN
cycle, subject to normal test and independent review gates. No API key or
credential was printed or recorded.

## Task 2 invalid RED receipt — stop before implementation

After the valid v6 count, only the test hunk was applied. The focused core
command exited 1 before executing its target because Elixir could not compile
the mixed-key `inventory_universe` map at test line 5944. This is not valid
RED; no TAP report was emitted, no source implementation was applied, and no
GREEN run occurred. The exact command/output is preserved in
`03-04-TASK2-INVALID-RED.log`, with the review disposition in `03-REVIEW.md`.
Keep the count and candidate-size receipt as historical evidence for v6; it
does not certify behavior. The test-only patch remains uncommitted. Do not
proceed to Task 2 GREEN or Plan 03-05 until the invalid RED is resolved and
the planned supported-report evidence gate passes.

## Candidate v8 metadata review receipt — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`86d1cecca44dc74f6ac7f81b84c47e17efa533fa70f06c381ac00c0f3ecf8f30`.
Current planning identities/selections and SIZING projection match. The
incremental test span and candidate v8 metadata match; support source is
unchanged. The prior 611-token diagnostic-inclusive selection remains charged
and cumulative fit requires a fresh count. V8 output also requires a fresh
count. Invalid-RED evidence remains preserved. No body was read or emitted,
and no test or count ran. Execute preflight and direct count remain required.

## Candidate v8 count result — source cap failed; superseded

The receipt-bearing v8 schedule SHA was
`db95bd8a2fb4d7514aa58e11a17ce8e0a8965aeead465cd7571c629347f207c5`; harness
SHA was `ce82f221bb9360bc8ab4e78222ed5f064f046f728c00fa7efe05ca0ca9170893`.
Direct counts: context 34,373 / request SHA
`49ff88314c2789e4a7726ee1fa2d18f3f1cd4a81502d87b245f984ce022c07cf`;
incremental spans 193 / `f347d0890265eda892dbe11f82af0223a1c7838f6fd84ffe358f918c28783754`;
candidate output 354 / `e0378fcae9dab12710c88cdab21178a5c38e99f4146db1cb30029b0345672625`;
combined 34,908 / `7e970cf42bfe6c61f28d8f69f8e4f6cb2b8032c6bbb75dcc70bf48629c0f835c`.
The cumulative source total was 611 + 193 = 804 / 800, so v8 was not applied.
Other caps passed; total projection was 93,698 / 99,300. This failure is
history and does not authorize v9.

## Candidate v9 exact-line test correction — active schedule; count pending

V9 narrows the incremental reread to the current changed test line only; the
prior 611-token diagnostic-inclusive selection remains charged. The correction
is a line replacement at the bound module location, not an EOF insertion. It
passes `git apply --unidiff-zero --check` and syntax parsing of the corrected
full test file. Active patch `/private/tmp/fablebook_plan03_04_task2_candidate_v9_testfix.patch`:
909 bytes / SHA-256
`9affdec4f4d579ebff5748b9e8ecba4548421956278b5015429b6e86ffc2d371`.

| Current input | Full bytes / SHA-256 | Exact selected bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 18,606 / `e9ce6955c31063e98bee17a1acd41a53e0770654c056567dad5c01a4075a9dc7`; 3,051 / `13d65d4261c9cc2fe1532635b399750674c0294970c7d3d81d7745ff34f70b92` |
| `03-04-PLAN.md`, lines 70 and 90 | 19,989 / `1b73fb56733f5e3e9afbe92b245e253d129ec02e8469d414b1aa35d78f47c32d`; 1,695 / `ce4ecba8f778bfcb97f8eb519adbb024657cdc859ef7f497eef63d7d6a45d715`; 795 / `e8e6adceeeb45c47004eede23ae4bd8f01be7115f10c56e48bf3a89b16724520` |
| `03-04-REPLAN.md`, lines 348–360 | 25,103 / `72bb67c4a9e8a021301f5c0881a137611391e846ea06bdf22ea8e462fc60996d`; 820 / `5d160b51211f1fbcb86b8e0535ec8c59b9a35910740061cfc018abdcd432f338` |
| `03-REVIEW.md`, lines 654–665 | 44,151 / `1dd7f8bb5e58379b36319b87dc7e988ee535f975d465f52afeb34181f591a9ac`; 714 / `7951d03120efef5164383be6bbfc6459ec637a30114a8194936aa2375c1eae1b` |
| `03-SIZING.json`, exact 14-key projection | 24,462 / `0b230cb3afa240dce3618e79682bfff177435e7d593eff39101c44f6aa0a00fc`; 19,120 / `e1d5af22288e735fb0cd397e9b566333b5f72d94aa2569af71788364fbc7b9f7` |

The current test file is 770,007 bytes / SHA-256
`2a09a5d4e11795f7d39db52dc76b7ef64f643e95aa718655f7a00d6657075b5d`;
incremental selection line 5944 is 363 bytes / SHA-256
`76a4371ffa978f0a3d37bcac688560677304c0607f9afef35d168d0a7be54121`.
Together with the prior 611-token selection, fresh cumulative direct count must
remain ≤800. Include current context, line, v9 output, Task1 21,172, prior
Task2 output639, remaining output, 2,000 cushion and 31,000 reserve in the
99,300 projection. Independent review, execute preflight and direct count are
pending; no v9 workspace patch is applied.

## Candidate v9 metadata review receipt — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`87758ce347aff64bb07f6e408a35daef22f984469b2f68b15b2b04495d95cc72`.
Current planning identities/selections and SIZING projection match. The
current test full identity and line 5944 span match; candidate v9 metadata and
syntax/apply-check receipts match. The reviewer confirmed v8's failed 804
token cumulative source count is preserved and was not applied, while the
prior 611-token diagnostic-inclusive read remains charged. V9's incremental
source/output counts remain pending. No body was read or emitted, and no test
or count ran. Fresh execute preflight and direct count are required.

## Post-RED support correction v10 — active; count pending

V9 passed its exact count and produced valid TAP RED. Direct counts: context
34,635 (`9872b40002888cff37023de18440a64719678f747c7b9e07d482421c75711485`),
incremental source span 133 (`b1c44774289c7f19c8cc4b6ecf1dbeb960fd6ec8cbc594e21470eadcfbd8716c`),
generated test output 293 (`4bbb6e1e12e39ce903b5628bcb47036f8bb909b2b6fd14818f3838cdfc8132f7`),
combined 35,050 (`9d93b560d2f5ef2d78ea62debc5da111b1b496b6187431c572331ddeaec9a88e`),
projected total 93,901 / 99,300. Prior Task2 source 611 plus v9 incremental
133 equals 744/800; output 639 + 293 equals 932/5,000. The focused run
returned exit 2 and the classifier returned `RED_EVIDENCE_OK` for the exact
gap-free source-join assertion. Complete report and record are bound below.

| Current input | Full bytes / SHA-256 | Selected bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 18,666 / `c9567011de29151747c971e5a1244337c36131ec4be5f69ccf13744b423dbb9e` | 3,111 / `6d40a3c438505965e46ad4a6a4794ff49fc04eb04f364246ebb0b97a288beac5` |
| `03-04-PLAN.md`, lines 70 and 90 | 19,989 / `1b73fb56733f5e3e9afbe92b245e253d129ec02e8469d414b1aa35d78f47c32d` | 1,695 / `ce4ecba8f778bfcb97f8eb519adbb024657cdc859ef7f497eef63d7d6a45d715`; 795 / `e8e6adceeeb45c47004eede23ae4bd8f01be7115f10c56e48bf3a89b16724520` |
| `03-04-REPLAN.md`, lines 373–385 | 25,955 / `6a57a5c68172d8a2eae1188ea704ffa0f944df8de20175b81451ede8159d51cd` | 851 / `ec4e970ba366ab46a496f8d061ba0eb1a3c9dfc60968d0c803bdc6936d48fd21` |
| `03-REVIEW.md`, lines 667–676 | 44,761 / `194547dab5641dfdd66453199714c1cb87f9a10c6f46eef808f738f9a06abc90` | 609 / `1be29b1e27f62ab62b55fe247b919f57b39dd1ffbb87efdc5d551ab8df296f4c` |
| `03-SIZING.json`, exact 14-key projection | 24,462 / `0b230cb3afa240dce3618e79682bfff177435e7d593eff39101c44f6aa0a00fc` | 19,120 / `e1d5af22288e735fb0cd397e9b566333b5f72d94aa2569af71788364fbc7b9f7` |
| Core evidence record after failed write check | 1,418,156 / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` | exact keyed projection: 3,334 / `66b0a31b95b4c1c647bb63b2de0a3d943d4e59f62abc2edbeb5a1330dd8c8369`; changed output has not passed validation |
| Floor evidence record | 11,828,076 / `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121` | exact keyed projection: 6,196 / `57fd78a919b9f5dae6c446682439764b29cba25c26de1a96ee4ddd3ef3b0aff8` |
| TAP RED report / semantic record | 14,139 / `057cc0b9208e7900bc338bd30f4c52d80303604f999369bdc534bd503cfec7ee`; 15,103 / `ee9ed7fd31bab020062b98455c6a71a7e943173c7f853d01a4b97769a72c1fd7` | compact result: target failure, exit 2, 109 tests, 1 failed, 2 passed, no report errors |
| Test source after v9 | 770,007 / `f97ef3bb5cb94e8c47f3baed38d3d6387808488879e5b59980e5e1f620bcf333` | line 5944: 363 / `65d6460c2b44e47d0d8f4f6e1b4c78397979c610bf9235eed1147bcddf48adea` |
| Support source | 58,686 / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | prior-reviewed lines 383–390: 297 / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` |

The test's map-order correction is now applied and the intended assertion has
failed; support source remains unchanged. Active temp-only implementation
candidate `/private/tmp/fablebook_plan03_04_task2_support_green_v10.patch` is
626 bytes / SHA-256
`e1db5fb8cfa0f917f28f548f37255fcc5fc9139f46d3706237d5916287945414`; it is
the support-only hunk from the previously reviewed correction. Preserve the
complete prior 611-token selection and v9's 133 incremental source tokens.
Count the exact support reread and this output freshly; cumulative source must
stay ≤800, cumulative output ≤5,000, context ≤38,500, and projected total
≤99,300 with 2,000 cushion and 31,000 reserve. Obtain independent metadata
PASS, fresh execute preflight and direct context/span/output/combined counts
before applying the support correction. Rebind all post-test identities and
the current SIZING projection. The existing library-collision stop, caller
AST/explanation checkpoints, candidate null, implementation authorization
boundary, aggregate gate, Walking Skeleton stop and SEC-01 Pending remain.

The deterministic count harness is `/private/tmp/fablebook_plan03_04_task2_v10_count.py`,
17,608 bytes / SHA-256
`85beca85e0b794de8102fefcda42b18cb0acd18f9faf1681888341bca298a773`. It
binds the current schedule content and verifies every full-file and excerpt,
current 14-key SIZING projection, source span and candidate payload; it sends
only the four scheduled count-only requests and reports each request hash.

## Post-RED support correction v10 metadata review — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`8e1ac71d9ee211936235d4bbad652dd5e1611ce4f407f898d9ad4b456d68d11b`.
The reviewer verified current planning and sizing bindings, valid RED report
and record identities, post-test test-file identity, unchanged support span,
temp-only candidate, and the bound count harness. Previous Task2 source is
744 tokens, leaving 56 for the fresh support-span count under the 800 cap;
previous output is 932 tokens. Fresh support/output/combined counts remain
pending. No bodies were read; no source edit, test or count was made.

## Post-RED support correction v10 direct count — source cap failed

On receipt-bearing schedule SHA-256
`f317ae6309b7fe1014e58b73591d57e5f85c681020157d741683d5e5ca15414d`, the
bound harness `85beca85e0b794de8102fefcda42b18cb0acd18f9faf1681888341bca298a773`
made the four scheduled count-only requests after fresh execute preflight
passed. Results: context 35,173 / `d9505af66e65984ce057dcecb9372f43ecda9b31e8ff3d93cc04f7b9e54b4499`;
support span 95 / `b7bcafb2c5e46c515e4d3c8d99dfbd16d8d9a2c7a01971095edaf8db0fafb69d`;
candidate output 158 / `595807cedc8a24a4d4c34ce54af6415571a7f0585949a5c67566f1a421f20c8e`;
combined 35,414 / `ddad6f8419a3952f206d76a89bcddb4615b653d871886e0f48b6c5e6c2623479`.
Task2 source total is 611 prior +133 v9 +95 =839/800, so source cap fails;
output is 639+293+158=1,090/5,000 and projected total 94,240/99,300. No
support patch was applied. The unchanged span was previously counted, but this
fresh combined request re-emitted it; the 95 tokens cannot be excluded as
reuse. Stop unless an authorized revised cap or narrower exact span passes a
new independent review, preflight and count. Preserve candidate null and
every original safety stop; do not start Plan 03-05.

## Post-RED support correction v11 — final 1,000-token cap; count pending

The owner authorized one final 200-token reallocation from global slack after
the v10 95-token support span made cumulative Task2 source 839/800. That
failed count is retained above; no source patch was applied. Final active
limits are context 38,500; Task1 22,000; Task2 1,000; Task3 0; output 5,000;
cushion 2,000; reserve 31,000; total working 68,500 + reserve 31,000 =99,500,
leaving 500 under 100,000. No further cap increase is authorized. The full
prior Task2 source read and test fix remain charged: 611 +133 v9 =744 before
the fresh support span. Prior generated output remains 639+293=932 tokens.

| Current input | Full bytes / SHA-256 | Selected bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 18,759 / `130e56d6bea7f2aa03c4fcf73be6e61e86341310d6fac14d70fee33701e04bff` | 3,204 / `06494c4946e63df2927bf2a36efae8f8d586a30212f376ede0fc5f7d60c8be89` |
| `03-04-PLAN.md`, lines 62–90 | 20,186 / `e7fd3dd62cae19f731793861e0f06ec0baea3291410574db3aff1a36aee2183f` | 8,323 / `da5abf3c2ebeb00cdf4a1d81f6b301931a4f2c4e3c4a813dea2c8e6c20cd6319` |
| `03-04-REPLAN.md`, lines 387–399 | 26,909 / `b7ea527c715246fa31a380674b52799ce672402334f227caa78a8906e2d86f8a` | 902 / `3e5a773f7c1d2819e6b09ce697bfae14ebbe88ecfff708868f766d30d8dd63f4` |
| `03-REVIEW.md`, lines 678–690 | 45,386 / `924705f5622013e0a1ac0d1fd82bdaffef61001db9ac779b729b378762a27ac8` | 624 / `452222040ee5ba85d83d228017dacf7560aa55f2f1a621ee065971d867b49036` |
| `03-SIZING.json`, exact 14-key projection | 24,462 / `0b230cb3afa240dce3618e79682bfff177435e7d593eff39101c44f6aa0a00fc` | 19,120 / `e1d5af22288e735fb0cd397e9b566333b5f72d94aa2569af71788364fbc7b9f7` |
| TAP RED report / semantic record | 14,139 / `057cc0b9208e7900bc338bd30f4c52d80303604f999369bdc534bd503cfec7ee`; 15,103 / `ee9ed7fd31bab020062b98455c6a71a7e943173c7f853d01a4b97769a72c1fd7` | compact result: target failure, exit 2, 109 tests, 1 failed, 2 passed, no report errors |
| Test source after v9 | 770,007 / `f97ef3bb5cb94e8c47f3baed38d3d6387808488879e5b59980e5e1f620bcf333` | line 5944: 363 / `65d6460c2b44e47d0d8f4f6e1b4c78397979c610bf9235eed1147bcddf48adea` |
| Support source | 58,686 / `2d618ea779ca33fff9b90398f96476b495311fd780b92a207cc3e34edf5f83a9` | lines 383–390: 297 / `598d385a248ecd5951dbbd51e1ee9e673dca862aa51f2010a257260dc6853912` |

Active temp-only implementation candidate
`/private/tmp/fablebook_plan03_04_task2_support_green_v10.patch` is 626 bytes /
SHA-256 `e1db5fb8cfa0f917f28f548f37255fcc5fc9139f46d3706237d5916287945414`.
Fresh count must include the exact support span and candidate output, plus
current context and combined request. Cumulative Task2 source must be ≤1,000;
output ≤5,000; context ≤38,500; projected total ≤99,500, adding 21,172 Task1
tokens, remaining output allowance, 2,000 cushion and 31,000 reserve. Obtain
independent review, fresh execute preflight and all four direct count-only
requests before applying the patch. If any cap fails, preserve the accepted
finding open and do not start Plan 03-05. All original collision, AST,
candidate-null, implementation, aggregate-gate, Walking Skeleton and SEC-01
stops remain unchanged.

The v11 deterministic count harness is `/private/tmp/fablebook_plan03_04_task2_v11_count.py`,
17,626 bytes / SHA-256
`6a1a19922142d21a84bc3d7a25429b4f4185518818cf63a75669a4627227c8fe`. It
binds the current full files and selected excerpts/projections, exact support
span and temp candidate, and serializes current schedule context for the four
count-only requests. It retains 744 prior Task2 source tokens and 932 prior
output tokens, applying the final 1,000 / 5,000 caps and 99,500 projection.

## Post-RED support correction v11 metadata review — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`753f880d2579251016c7058a9a500f6cfc2e76fd16c7f1af223171c8c7836e3e`.
Current planning/sizing bindings, valid RED record, test and support file
identities, exact support span, temp correction and v11 harness all match.
The prior 839/800 failure is preserved as history. Fresh direct counts remain
required under the final 1,000 source, 5,000 output and 99,500 total caps;
reserve 31,000 and all stops are unchanged. No body was read or emitted.

## Post-v10 validation diagnostic v12 — active; exact line count pending

The v10 support patch passed its 839-token source/99,500 total count and was
applied. Focused core verification then failed at a distinct assertion before
the intended join check: `validate_aggregate_lane!/1` raised `MatchError` on
false at support line 138 while `build.([])` ran. Two of three selected tests
passed; the target failed and 106 tests were excluded. The floor check did
not run. The candidate is still null and no further support edit is planned
until this exact diagnostic line is counted and reviewed.

| Current input | Full bytes / SHA-256 | Exact selection |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 18,822 / `cace0b7b9190695b7ea95f82ad7bf05dab599d47e8c3fe110f365785fdc678f3` | 3,267 / `efea4d7690a647b22a940bd53420656523c32f98bd89ef686a08b0484b3e2115` |
| `03-04-PLAN.md`, lines 62–90 | 20,186 / `e7fd3dd62cae19f731793861e0f06ec0baea3291410574db3aff1a36aee2183f` | 8,323 / `da5abf3c2ebeb00cdf4a1d81f6b301931a4f2c4e3c4a813dea2c8e6c20cd6319` |
| `03-04-REPLAN.md`, lines 402–413 | 27,818 / `fc57b2fa38721f39f51d78a74819b56d95d1b250d92e5a41464605f30134b76f` | 832 / `e1c7a1759cbbd435abb60c1a37361396ad50b3018c55b180f45e4f6740fdc425` |
| `03-REVIEW.md`, lines 689–703 | 46,069 / `8955bac806e5fb056981a683d5058b640692a2ed6915e19566431378d818458b` | 682 / `f3a45678a8f99cf088dfa74ce9079cbce7dc2c7ad709aead5577ca74ca3dbdc9` |
| `03-SIZING.json`, exact 14-key projection | 24,462 / `0b230cb3afa240dce3618e79682bfff177435e7d593eff39101c44f6aa0a00fc` | 19,120 / `e1d5af22288e735fb0cd397e9b566333b5f72d94aa2569af71788364fbc7b9f7` |
| Test source / prior valid RED record | 770,007 / `f97ef3bb5cb94e8c47f3baed38d3d6387808488879e5b59980e5e1f620bcf333`; RED JSON 15,103 / `ee9ed7fd31bab020062b98455c6a71a7e943173c7f853d01a4b97769a72c1fd7` | unchanged valid assertion-failure receipt |
| Updated support source | 58,737 / `e342ddd81a91a734d2e4610b7772ed580e380964b73b71290ac14352fa58653c` | line 138: 51 / `4053c800580b092b963a6702768285bc072b7b20cdf794f583a4de5286a29a8d` |

Final source cap is 1,000. Prior Task2 source charge is 839 (611 +133 +95),
leaving 161 for this exact line and any subsequent correction reread. Prior
generated output is 1,090 of 5,000. The diagnostic-only count has no new
candidate output; after this line is reviewed, any new correction must receive
its own independent review, execute preflight and fresh direct count before
emission/application. Keep 38,500 context, 22,000 Task1, Task3 zero, 2,000
cushion, 31,000 reserve and 99,500 total. Do not increase any cap.

The diagnostic count harness is `/private/tmp/fablebook_plan03_04_task2_v12_diag_count.py`,
17,618 bytes / SHA-256
`f7e3e4032dc4e7259dee82f0201d958fe205c7907d6b981d197b02b12e806554`. It
binds the exact current inputs and line 138 span, uses an empty output
selection for this source-diagnosis checkpoint, and verifies the 839 prior
source tokens against the final 1,000 cap before the four count-only requests.

## Post-v10 validation diagnostic v13 — active; combined count pending

The first v12 attempt is preserved: context count 33,807 /
`b05d4f60be69f1c9b2f5e9093149ec3deb57963e27e3b951bab126fb72c347d3`; support
line count 33 / `36c387424f95fc819b34621537e0b5e0c7115a5e45e3c875045ad1c48f05d8c7`;
the zero-length output request returned HTTP 400 `missing_required_parameter`,
so no combined count ran and no source body was inspected. These 33 source
tokens are now charged: cumulative prior Task2 source is 872, leaving 128 of
the final 1,000. V13 repeats the exact line 138 span once and skips the empty
output request; it directly counts current context, span, and the combined
context+span request before any line inspection. Generated output remains
1,090 prior tokens, within 5,000. The schedule and exact bindings in the v12
section above remain current except for this diagnostic receipt and harness.
No code patch is prepared for this validator issue.

The v13 harness is `/private/tmp/fablebook_plan03_04_task2_v13_diag_count.py`,
17,751 bytes / SHA-256
`e24dcef376e9b53b242a5c922f49af15fce67ec9eb469f79878cc1fdcecddfcd`. It
retains current file and projection assertions, line 138 identity, and the
final 1,000 / 99,500 caps. Its output selection is intentionally empty at
this diagnostic-only stage; it skips that endpoint call and still requests a
nonempty combined context+span count. Fresh independent metadata review,
execute preflight and three direct count-only requests are required.

## Post-v10 diagnostic v13 metadata review — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`68efb9d4598e0926458c0e4f10c60848d9727e3ba5dc8213ac75cb56bf308ffd`.
Current bindings and v13 harness match. The v12 400 response and 33-token
source charge remain historical; cumulative Task2 source is 872, with 128
remaining. V13 skips the empty output endpoint and requires a nonempty
combined context+line request. Fresh execute preflight and all three direct
counts must pass before line inspection.

## Post-v10 diagnostic v12 metadata review — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`354e7bc18592508fcb9dce535545942d53ab96fa4aa5a2f31db417fa1254ffc2`.
The reviewer verified current support/core/floor identities and compact
projections, the exact line 138 selection, canonical planning bindings,
SIZING and RED receipts, and the diagnostic harness. Cumulative Task2 source
was 839/1,000 before this 51-byte span; the output selection is empty. Fresh
execute preflight and direct counts are required before reading the line.

## Post-v13 validator fix v14 — active; candidate count pending

The v13 diagnostic count passed; line 138 was inspected only afterward and
identified the stale hard-coded false assertion. V14 is a temp-only one-line
correction to validate `source_join_complete` against canonical empty gaps.
It must receive a fresh count before application. Preserve the current source
limit: prior Task2 source is 905 tokens, including all earlier failed attempts
and both diagnostic line counts. The exact line 138 span is 51 bytes /
`4053c800580b092b963a6702768285bc072b7b20cdf794f583a4de5286a29a8d`; a fresh
span count is expected to add 33, for 938/1,000 before any further read.

| Current input | Full bytes / SHA-256 | Selected bytes / SHA-256 |
|---|---|---|
| `.planning/STATE.md`, lines 40–52 | 19,052 / `c89f98c536753a8f4a4500237cd3c4f2359444217d11d963859dd4b99a7acfd6` | 3,497 / `af8f97d42176446ab01e3020d950bf934e725895432dd03b340227018a0470a8` |
| `03-04-PLAN.md`, lines 62–90 | 20,186 / `e7fd3dd62cae19f731793861e0f06ec0baea3291410574db3aff1a36aee2183f` | 8,323 / `da5abf3c2ebeb00cdf4a1d81f6b301931a4f2c4e3c4a813dea2c8e6c20cd6319` |
| `03-04-REPLAN.md`, lines 416–429 | 28,699 / `d8d2a63bf499e11b8fd0b41b763bd7c2b9f2ec3c072afced07f71f6c0b0fdd01` | 880 / `182afa990d3e704ddc3470a3c1845ce86fe8ab6deccedf6c9872876984a0bc38` |
| `03-REVIEW.md`, lines 701–710 | 46,657 / `dc0918e1b9b2a6aa5a544a699e91c9ecf8509d0ce87e5b117a2446a9723281fa` | 587 / `6b785cdf476c8fb2ac095238095abc28a16098c78388b57281af220bbe8c7f42` |
| `03-SIZING.json`, 14-key projection | 24,462 / `0b230cb3afa240dce3618e79682bfff177435e7d593eff39101c44f6aa0a00fc` | 19,120 / `e1d5af22288e735fb0cd397e9b566333b5f72d94aa2569af71788364fbc7b9f7` |
| Core record / keyed projection | 1,418,156 / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` | 3,334 / `66b0a31b95b4c1c647bb63b2de0a3d943d4e59f62abc2edbeb5a1330dd8c8369` (not validated after failed run) |
| Floor record / keyed projection | 11,828,076 / `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121` | 6,196 / `57fd78a919b9f5dae6c446682439764b29cba25c26de1a96ee4ddd3ef3b0aff8` |
| Test source / valid RED record | 770,007 / `f97ef3bb5cb94e8c47f3baed38d3d6387808488879e5b59980e5e1f620bcf333`; RED 15,103 / `ee9ed7fd31bab020062b98455c6a71a7e943173c7f853d01a4b97769a72c1fd7` | unchanged valid target assertion failure |
| Support source | 58,737 / `e342ddd81a91a734d2e4610b7772ed580e380964b73b71290ac14352fa58653c` | line 138 as above |
| Temp-only V14 patch | 402 / `109911cf99e42ecb51f0f43982ff103b0b0d9dd30993cc858a7dd8da1ffef35a` | one-line validation correction; not applied |

The final cap is Task2 source 1,000, context 38,500, Task1 22,000, Task3
zero, output 5,000, cushion 2,000, reserve 31,000 and total 99,500. Prior
output is 1,090 tokens. Obtain fresh independent metadata review, execute
preflight and direct context/span/output/combined counts for this exact
candidate. If any cap fails, stop with the accepted finding open; no further
cap increase is permitted and Plan 03-05 must not start.

The V14 count harness is `/private/tmp/fablebook_plan03_04_task2_v14_count.py`,
17,739 bytes / SHA-256
`12e5ae279010b77f5a755ebd14778707577117adc4e92df7462a6002414677bd`. It
binds the exact source line, one-line candidate, current tree/projections and
current schedule context, then makes fresh context/span/output/combined
count-only requests. It retains 905 prior Task2 source tokens and 1,090 prior
output tokens under the final 1,000/5,000/99,500 limits.

## Post-v13 validator fix v14 metadata review — PASS

Independent reviewer `independent_review_03_04` passed metadata-only review of
the exact pre-receipt schedule SHA-256
`8e5f3c543171950e6a1828df25e2e6a518682deff1c0c85d00644d8a72750e2d`.
Current planning, machine-record, RED, source, patch and harness bindings
match. The prior cumulative Task2 charges are 905 source tokens and 1,090
output tokens. Final caps remain 1,000/5,000 with 99,500 total and fixed
31,000 reserve. Fresh execute preflight and four direct counts remain before
any patch application.

## V14 candidate count and focused verification — PASS; Task2 review pending

The receipt-bearing pre-count schedule was SHA-256
`c86ecf770d997f38b1e86b91fe53c429ec8b22fb31711363c4d2d54dc23b0a0f`;
the independent v14 metadata PASS and execute preflight preceded the four
count-only requests. Counts: context 34,105 /
`53a34dcb22c8e905ebf7481b1faa23a39c5c5ceeb27d90c4ad0d73162dee7f6a`;
support line 138 span 33 /
`36c387424f95fc819b34621537e0b5e0c7115a5e45e3c875045ad1c48f05d8c7`;
v14 output 103 /
`c028ed3cf3c351cf0f03171593e9f63fc471222634a850e69cc74bce81b9132e`;
combined 34,229 /
`152b2ee8d982b170fd0a16ad3e3e12672dfd6c93d80bab67b95895518aaf702a`.
Task2 source totals 611+133+95+33+33+33=938/1,000; output total is
639+293+158+103=1,193/5,000; projected total 93,113/99,500. V14 patch
`109911cf99e42ecb51f0f43982ff103b0b0d9dd30993cc858a7dd8da1ffef35a` was
applied after the gate; whitespace check passed.

Focused checks passed with `FABLEBOOK_GUARD_AGGREGATE_WRITE=1` in both lanes:
core selector exit 0, 3 passed / 106 excluded; floor selector exit 0, 3
passed / 106 excluded. The run regenerated core and floor records. Current
identities/projections: core 1,418,156 / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd`, projection 3,334 / `66b0a31b95b4c1c647bb63b2de0a3d943d4e59f62abc2edbeb5a1330dd8c8369`; floor 1,390,810 / `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d`, projection 3,337 / `17a4940bc3e22d8467a1dd9a91c98443826532684f67d665722302cbdc0dd0a4`.
Source file identities: support 58,768 / `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63`; test 770,007 / `f97ef3bb5cb94e8c47f3baed38d3d6387808488879e5b59980e5e1f620bcf333`.

SIZING remains 24,462 / `0b230cb3afa240dce3618e79682bfff177435e7d593eff39101c44f6aa0a00fc`, projection 19,120 / `e1d5af22288e735fb0cd397e9b566333b5f72d94aa2569af71788364fbc7b9f7`. It remains conservative (`candidate=null`, join false) but its `lane_record_sha256s` still name the prior core/floor hashes. Reconcile this via the plan's existing records workflow, or record the mismatch as an owner-facing gap; do not carry a positive candidate. Independent review of the applied code/test diff, SIZING disposition, and zero-source-read Task3 report/review remain. Plan 03-05 must not start.


## SIZING reconciliation after V14 — current lane hashes bound; Task3 count pending

The previous V14 receipt is retained as history. After the focused core/floor
write checks, SIZING was updated to bind the current generated lane records and
the final owner-authorized allocation. Current exact identities:

| Input | Bytes / SHA-256 | Selected projection |
|---|---|---|
| `03-SIZING.json` | 25,713 / `648bd752997cda4372c385980775ebc7402b2931ee67dcbc086921bd0a2905e9` | exact 14-key projection, 20,098 / `e9c49dc21e4ce8c211a402d72c99a4add758af4bd5fdfe70ff1dd5d57c70a395` |
| Core lane evidence | 1,418,156 / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` | keyed projection, 3,334 / `66b0a31b95b4c1c647bb63b2de0a3d943d4e59f62abc2edbeb5a1330dd8c8369` |
| Floor lane evidence | 1,390,810 / `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` | keyed projection, 3,337 / `17a4940bc3e22d8467a1dd9a91c98443826532684f67d665722302cbdc0dd0a4` |

SIZING retains `candidate=null`, `source_join_complete=false`,
`implementation_authorized=false`, `aggregate_gate=open`, Walking Skeleton
blocked and SEC-01 Pending. The current V14 Task2 receipt remains 938/1,000
source tokens, 1,193/5,000 output tokens and 93,113/99,500 projected total.
All superseded cap failures and count receipts remain historical. The Task3
context must now be rebound to these updated SIZING, STATE and REPLAN identities;
obtain independent metadata review, execute preflight and a fresh direct count
before report publication. Task3 remains zero new source-body reads. Do not start
Plan 03-05.


## Task3 V4 post-reconciliation count schedule — metadata review required

Task3 remains zero source-body reads. It will publish the deterministic report
from the current validated records, then run the approved bundle/core/floor
selectors. This fresh count replaces the historical Task3 count after its SIZING
and Task2 receipts changed. The model-authored output allowance remaining is
3,807 tokens (5,000 cap less 1,193 counted Task2 output). Count context, a
nonempty zero-source-span marker, and combined context+marker. Projected total
is combined + 21,172 Task1 spans + 938 cumulative Task2 source reread + 3,807
remaining output + 2,000 cushion + 31,000 reserve, capped at 99,500.

| Input | Current full identity | Exact selected content |
|---|---|---|
| STATE | 18,714 / `22ed5f5c9ae4fbc103327231bd5aff11288f24966169a300c538b8fe744f3fc3` | lines 40–52, 3,159 / `bf65d7ea46dcd6d833c95adf47c47eb295fe06c95ec1a8ad0387ac8751fcac61` |
| PLAN | 20,186 / `e7fd3dd62cae19f731793861e0f06ec0baea3291410574db3aff1a36aee2183f` | lines 62–70: 2,804 / `f3a2553ba02aa160f8a37ff4d1917dbf602a5ab9a5af8bee3da3b12ff3fe6f20`; lines 104–108: 2,192 / `7f9005b7e2f498fa2e717120c5986b347bae42ec392be4e4c7fddf484c74c475`; lines 116–147: 2,284 / `85c63e2bcc9002674210a198311e72c394c6de05bf09bd8cfc4f7e5f2a519d19` |
| REPLAN | 29,669 / `6953e05833346c2e4fa41c4b6e88a15b52cc0f6ffbbeb41f4366724dd66aa6bb` | lines 430–443, 969 / `dcce6abaa976bbb831e811285541ef5a1303f58da0a651296409029d05386220` |
| REVIEW | 48,315 / `8c4938f881be45b23f18c3c53ea41e6c14d1799efdc92e71d0a32122d430b9bf` | lines 711–742, 1,657 / `38ef422684e12dee9f9aa7971203fd7a1959b2fdd1ad3de93941f427d060c477` |
| SIZING | 25,713 / `648bd752997cda4372c385980775ebc7402b2931ee67dcbc086921bd0a2905e9` | exact 14-key projection, 20,098 / `e9c49dc21e4ce8c211a402d72c99a4add758af4bd5fdfe70ff1dd5d57c70a395` |
| Core record | 1,418,156 / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` | keyed projection, 3,334 / `66b0a31b95b4c1c647bb63b2de0a3d943d4e59f62abc2edbeb5a1330dd8c8369` |
| Floor record | 1,390,810 / `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` | keyed projection, 3,337 / `17a4940bc3e22d8467a1dd9a91c98443826532684f67d665722302cbdc0dd0a4` |
| Existing report | 13,115,491 / `3ee538cdce64372ffe9a6641894ba309f976572118bae3f3c73d90fdfd488c61` | lines 5–12, 528 / `4522ccd14b59c0441f105f5aa0ac30e69f6b98b3cc6b6e0e6e77c7238d453cf3` |

The zero-source marker text is exactly `Task3 source-body spans: none; zero new source reads.`
The context also contains the required project/phase instructions, locked
decisions, requirements, concise delivery receipts and the specific schedule
sections bound by the count harness. No test/support source content is selected.
Candidate remains null and all owner/safety gates remain unchanged.


### SIZING reconciliation metadata review — PASS

Independent metadata reviewer confirmed the exact pre-receipt schedule SHA-256
`de9f2b73c69748a72d047eabea681e7de70248f3a6ca93ffa0d4a3dadcc358f5`, current
SIZING 25,713 bytes / `648bd752997cda4372c385980775ebc7402b2931ee67dcbc086921bd0a2905e9`,
14-key projection 20,098 /
`e9c49dc21e4ce8c211a402d72c99a4add758af4bd5fdfe70ff1dd5d57c70a395`, and
current core/floor record hashes. Candidate and safety dispositions remain
fail-closed; STATE no longer reports stale SIZING bindings.

### Task3 V4 count harness metadata

The count-only harness is `/private/tmp/fablebook_plan03_04_task3_count_v4.py`,
16,864 bytes / SHA-256
`56df22fa45538989ae0b059e1dca88f39e8fc7d3f72460f5693e7a4a1e0d189e`.
Metadata-only run validates every selected full-file identity, excerpt and
keyed projection without API calls or source-body reads. It issues only three
count-only requests: context, marker, and combined. Exact payload byte counts
are printed by the harness for the final receipt-bearing schedule. It accounts for Task1 21,172, cumulative Task2 source 938,
remaining output 3,807, cushion 2,000 and reserve 31,000 under the 99,500 cap.
The fresh schedule needs independent metadata PASS and execute preflight before
`--count`; source-body reads remain zero.


## Task2 V15 diagnostic schedule — exact line 394; count pending

The Task3 bundle selector exposed a second failing validator at support line
394. It failed before publishing the report; current report and machine records
remain unchanged. This is a bounded Task2 diagnostic, not a Task3 source read.
Previous cumulative Task2 source is 938/1,000, leaving 62 tokens. Schedule only
the exact complete line below; do not emit or apply a patch until fresh review,
execute preflight and count pass. The correction output remains empty at this
diagnostic checkpoint.

| Input | Current identity | Selection |
|---|---|---|
| Support | 58,768 bytes / `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63` | line 394, 61 bytes / `d17d00204d49b02e495b9719a0569e450bc694a6ae5c3ab0cb8e6f44a1818c49` |
| STATE | 18,942 / `da5fe800c26afcaa0c773b7b1b2d102f5d29928f368410a8586fd3441d0f2021` | lines 40–52, 3,387 / `08c68532da471f0a3baea13003b3b3c5aec05077e519763e2fd093c95d29b923` |

| REPLAN | 30,784 / `60833a7d32e7de15832f9b530ab1ccea20fa94d777e5ac8a5e99c8af2dc263cb` | lines 446–462, 1,113 / `c202e0c892926a0e7abc4224a679d1b49e8f45ddcb7b68b5c95d9508a5ec12e0` |
| REVIEW | 49,083 / `2b31af7159df2217f020c107c5465961bf7b4b509572e0641bc9b1f53e1c2271` | lines 711–751, 2,425 / `03a3e1df4192e0337ffde1c88878c00e5b06216e9d2000ccd4846589731d52ca` |
| SIZING | 26,528 / `2f97210de61e0831fb9411d244f6e94ee3aae0143a30fb2a12de209177ba7617` | exact 14-key projection, 20,751 / `700d69adcc936784860168ceeec57040c55204a4107fac089993524eb6aaa1ca` |

Count current context, exact line 394, and combined context+line only. Add
21,172 Task1 spans, prior 938 Task2 source tokens, 3,807 remaining output,
2,000 cushion and 31,000 reserve to projected total; preserve 99,500 ceiling.
Task3 remains zero new source reads. Candidate remains null; implementation
unauthorized; collision, Macro, SEC-01, aggregate-gate and Walking Skeleton
stops unchanged.


### Task2 diagnostic count harness metadata

The count-only diagnostic harness is `/private/tmp/fablebook_plan03_04_task3_count_v4.py`,
17,488 bytes / SHA-256
`37abeeee19170e6dda633aed276df9faf9f85e3e9335f1ba4f285d791f198e3f`.
Its metadata-only run validates current context and exact line 394 without
printing that source line or calling the endpoint. It makes three count-only
requests: context, exact selected line, and combined. No output candidate or
source patch is emitted.


### Task2 V15 diagnostic schedule metadata review — PASS

Independent metadata reviewer passed the exact pre-receipt schedule SHA-256
`ec091d08606c5e641a886cf879fab1e9a878371ce45ff6d9d6f64db499d32b21` and
harness SHA-256
`37abeeee19170e6dda633aed276df9faf9f85e3e9335f1ba4f285d791f198e3f`. The
active table has one current STATE binding; it matches the exact current
STATE and records the bundle failure. The support file and line 394 identities,
count-only harness behavior, remaining 62-token source cap, zero diagnostic
output and 99,500 envelope match. No source body was inspected.


## Task2 V16 adjacent diagnostic — line 393; count pending

The exact line 394 diagnostic was counted and inspected; its hard-coded
`target_source_coverage_complete == true` assertion fails in the bundle selector.
Cumulative Task2 source is 974/1,000, with only 26 tokens remaining. Count only
the adjacent line 393 (no reread of line 394) plus current context and combined
payload. Do not inspect it unless the direct measured span keeps the cumulative
source count ≤1,000. No patch output is selected at this stage. If the adjacent
line does not provide enough already-bounded context to correct this predicate
truthfully, preserve the unresolved owner-facing gap. Task3 source reads remain
zero.

| Input | Exact current identity | Selection |
|---|---|---|
| Support | 58,768 / `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63` | line 393, 43 bytes / `cd292c6d5b35850c08eca37b4ca58758569d9e27628dd448d6fd52e31fe8957a` |
| STATE | 19,057 / `5fc46d2691e330cc555df7c3ecbb16814cd59c2d07a2da8fbce131b9bb641d26` | lines 40–52, 3,502 / `6346eb897e0563a8124fba0bca965cca7bd8553e2998e31dcbfdd98d32ba55e9` |
| REPLAN | 31,496 / `341c990f2d2aa58cc66767b6e7f71541e52779730f10f9681ceb31f26286c938` | lines 465–475, 710 / `bee3f18b847180379870ff8e146c305f761d23be66e7bb988b3d0092966f2c63` |
| REVIEW | 49,688 / `fb07e68eb296f7ac809ceb7f61c0816c37b01844352f84119ad91283a51c39df` | lines 711–762, 3,030 / `7519dd5d1945a98f7f6b0b812e4f422373c71014e91225622efa65dfc51a3993` |
| SIZING | 27,662 / `5b7dd4d89eb52548e84068e0cc7176a7c1b61b6d5719a2ddfad9b18ff15e738e` | exact 14-key projection, 21,657 / `cb686554381d7753e80a64cd62cf60be8c8af7be1e1649dbe540f78dd78d0d29` |

Use the established required project/phase context and current keyed lane
projections. The direct count requests are context, line 393, and context+line
393. Charge the measured new line tokens to prior 974; include Task1 21,172,
remaining model output 3,807, cushion 2,000 and reserve 31,000 under 99,500.
Candidate remains null and all safety stops remain.

### Task2 V16 count harness metadata

The count-only harness is `/private/tmp/fablebook_plan03_04_task3_count_v4.py`,
17,223 bytes / SHA-256
`3580eef199367c913546d152aeeee72d2bccd579a35f6105872569ab0b71e02b`. Metadata-only
validation does not emit line 393 or call the endpoint. The count path makes
only context, selected line, and combined count-only requests.


### Task2 V16 diagnostic schedule metadata review — PASS

Independent metadata reviewer passed exact pre-receipt schedule SHA-256
`bd4636d8d7b8cb232d7e8ff14baf528c73e40e5c5f90e7e2e45e7570c797c5bd` and
harness SHA-256
`3580eef199367c913546d152aeeee72d2bccd579a35f6105872569ab0b71e02b`. The
current STATE, REPLAN, REVIEW, SIZING, lane-record and support bindings match.
The line 393 selection is 43 bytes; prior source usage is 974/1,000 and the
count remains pending. No output candidate or source body was emitted.


### Task2 V16 direct count — BLOCKED by final source cap

After the independent PASS and fresh execute preflight, count-only requests
returned context 30,920 / `f71b00dccc3cc4e41b48fb49736bb2bce20cbec44dbfd62c07c1927a950a2470`,
line 393 33 / `e7050b4d296983af9e40c6f58d99abda12e44482eb9750fe855f831933abe221`,
and combined 30,947 /
`c17c1da16db3dff63e58713718bd2befad111fd08413bb2219e9b5031f60a30e`. The
selection makes cumulative Task2 source 1,007/1,000, so it fails by 7.
Projected total 89,900/99,500 passes, but the source cap is hard. Line 393 was
not emitted. Stop with the validator finding open, no further cap increase, no
Task3 report publication and no Plan03-05.

## Final V16 handoff — hard source cap blocks the accepted correction

The V16 count selection was prepared against SIZING 27,662 bytes /
`5b7dd4d89eb52548e84068e0cc7176a7c1b61b6d5719a2ddfad9b18ff15e738e` and
projection 21,657 / `cb686554381d7753e80a64cd62cf60be8c8af7be1e1649dbe540f78dd78d0d29`.
Its direct receipt is above. The post-count canonical handoff now records the
cap failure in SIZING 28,604 bytes /
`dbf4258a8755d624986c53b498780a9a49870f5438f9aa1a2ac67c321324fc5c`, projection
22,426 / `a35a14e3f47c50ed819ffa87fb48e690ba3c227558dc5105a2746bea081580bb`, and
STATE 19,201 / `39abf1ad273313e00f2482d654ee195df23a0451bd1dbdb456ad6e591a3634d5`.

Line 393 measured 33 tokens, taking cumulative Task2 source selection to
1,007/1,000; it was not emitted. No more cap increase is authorized. The line
394 assertion remains the exact open blocker. Task3 report publication did not
occur; do not claim Plan03-04 completion or start Plan03-05. No patch, commit,
push or PR was made. Next action is for the owner to decide whether to leave
this accepted finding open or separately authorize a new scoped replan.

## Task2 V17 final reallocation — line 393 fresh count pending

This supersedes the V16 source-cap failure only within the owner's prior
“Replan within limits” authorization. The final allocation is context 38,500;
Task1 spans 22,000; Task2 source 1,500; Task3 new source reads 0; output 5,000;
cushion 2,000; fixed reserve 31,000. Total is 69,000 working + 31,000 reserve
=100,000. Preserve 1,007 cumulative prior Task2 source selections, including the earlier
failed 33-token line393 count. Count exact line393 anew and add it to 1,007; do
not exclude the earlier selection or substitute its count for this fresh count.

| Input | Current full identity | Exact selection |
|---|---|---|
| PLAN | 20,248 / `0a763e39f5deffbb76beec038b6e08bfa982c9daecc7a45329a4278654464e43` | lines 62–70, 2,866 / `a33a0abf3232c6a494ede0c7470957c8d96877a81074266e2f06a69dc5c41035` |
| STATE | 18,460 / `5b604336e34bbf2e55e09496313f7f4ae86e5949296a7b56df2e98734818ea13` | lines 40–52, 2,905 / `2594c6b19f3849a3d9e652de07836249dfbdc6472b9a7edb97ef408f6557b076` |
| REPLAN | 33,570 / `4e1791699ad986b43d798291eb75e26750d25e44ca3888e6bfd8ad61c54ffe00` | lines 492–510, 1,123 / `eeccaf464c637e89bdf62ac93661bd916c4f2f737d9f8f767c93f62395ca774c` |
| REVIEW | 51,172 / `85bf51b05b37ea4e7fa2131972ce3aeb76d9567f6c701769e87201d0a2de83ff` | lines 776–792, 888 / `a38df718cf54589702b3a1f0adf498974df9950e42021b4589dbfb0b00727bc8` |
| SIZING | 28,872 / `a3a06ff56547e906941147390f8c544c7baab4baec2d04411a89f44cfc6b5538` | exact 14-key projection, 22,634 / `a507dcb266742ee6f54e0f34e9d2bae00d38d018c93c4439c21509386794de78` |
| Support | 58,768 / `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63` | line393, 43 / `cd292c6d5b35850c08eca37b4ca58758569d9e27628dd448d6fd52e31fe8957a` |

Count current compact context, exact line393, and combined only. The prior 33-token
selection is retained as a failed attempt; add the fresh measured span to 1,007.
Projected total is combined + Task1 21,172 + prior Task2 1,007 + remaining output
3,807 + cushion 2,000 + reserve 31,000, capped at 100,000. Do not inspect line393
unless this fresh count and the Task2 source cap pass. Candidate remains null,
implementation unauthorized, and all safety stops remain.

### Task2 V17 count harness metadata

The fresh count-only harness is `/private/tmp/fablebook_plan03_04_task3_count_v4.py`,
17,008 bytes / SHA-256
`177c6f29cddc93e21c583f82086e24fb9dbdb530b7246aa9ce218c53d609b20f`. It selects
current context and exact support line393 only, with no output candidate. Its
three requests are context, span, and combined. Metadata-only validation emits
no source body and makes no endpoint call.


### Task2 V17 final schedule metadata review — PASS

Independent reviewer passed pre-receipt schedule SHA-256
`76b37b115e48167e5976959d89f395edc35114b74107324fee2d5b2dbf439114` and
harness SHA-256
`177c6f29cddc93e21c583f82086e24fb9dbdb530b7246aa9ce218c53d609b20f`. STATE
bindings match, and the ledger preserves 1,007 prior Task2 tokens before adding
the fresh line393 selection. Task2 cap 1,500, fixed reserve31,000 and total
100,000 are respected; no output/source body was emitted.


## V18 final-allocation validator-context recount — pending independent review

V17 passed line393 at 33 tokens, leaving cumulative Task2 source at 1,040/1,500 and 460 tokens. The line394 mismatch remains the Task3 bundle blocker. This amendment supersedes only stale handoff statements that line393 remains unread; all previous cap failures/counts remain historical and charged.

The next permitted selection is exactly: path: test/support/guard_aggregate_reconciliation_evidence.ex; full identity 58,768 bytes / 54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63; lines 392–400 (validate_target_sources!/1 context), 382 bytes / 3776304570990785c8ab5dedb0ff3246321a9765f99a03411b396c4cb725c841; exact selection includes the previously counted lines 393 and 394 and will be counted in full again.

Count current compact context, the entire exact span, and combined. Add the fresh span token count to 1,040; do not reuse or exclude line393/394 counts. Include the current receipt-bearing schedule, exact SIZING projection, output allowance still available under 5,000, 2,000 cushion, and fixed 31,000 reserve in the projected total. Hard limits remain context 38,500, Task1 22,000, cumulative Task2 source 1,500, Task3 reads 0, output 5,000, and total 100,000. No source body may be emitted unless every direct count passes. Candidate remains null and implementation unauthorized.

Independent metadata review must bind this exact pre-receipt schedule, full file and selection identities, cumulative 1,040 baseline, limits, and no-body gate. Then run fresh execute preflight and direct count. If any cap fails, stop with the line394 owner-facing gap; do not begin Plan03-05.


### V18 current input bindings

The count input uses these current canonical artifacts; the independent reviewer should verify full identities and selected excerpt/projection identities without reading source or test bodies.

| Input | Full identity | Selected context |
|---|---|---|
| PLAN | 20840 bytes / `51bda471591fc4e634dc1a8d95158f999bc0d88e298817ad49ba8bd9d39fecc7` | lines 62–70: 2866 bytes / `a33a0abf3232c6a494ede0c7470957c8d96877a81074266e2f06a69dc5c41035`; V18 lines 150–152: 590 bytes / `ad59f551859a1c8c5a9b7a03c6afd683ab6ddaa5fe349c881c5c59f5c8d42925` |
| STATE | 18570 bytes / `b98d5aa19437da17c56ee934d1a0536fe0496d7f86652cae9913008cb56aec36` | lines 40–52: 3015 bytes / `beaa3fca838f6d3918dd0135da31ab4d3b1b25dfd0b7e1c5e74b0f491c4d8f24` |
| REPLAN | 34773 bytes / `8c717b681234086a0fa92db5777cf58371ff219e775184d4ce99ec34d36180dd` | lines 492–510: 1123 bytes / `eeccaf464c637e89bdf62ac93661bd916c4f2f737d9f8f767c93f62395ca774c`; V18 lines 526–528: 639 bytes / `48ff7341134e27691fae94b47e3ccdb4c83235d06a5ba502225f8e5c619a41a5` |
| REVIEW | 52324 bytes / `5d523573c7ddad95ef97a5e97ee1c41a91d14b36607938a407db83468fe0e5c5` | lines 776–792: 889 bytes / `ef60523d21581e88e6b9d86cae14ed34dd3b757da0027f82dc3207ad3758f032`; V18 lines 803–805: 747 bytes / `bf57bdb363f1246709ca7bf3055a576081730d944ddd1576a4cb83b041d3f949` |
| SIZING | 29947 bytes / `124d39a27298b422265ed606e1b6a03fa0bed99b43c8d4507de309cb2a213b75` | exact 14-key projection: 23500 bytes / `106479e20acbf9b5c0c1ac21bfb3326329cef3ae68d10a619517a063d1739d70` |

core lane full identity: 1418156 bytes / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd`.
floor lane full identity: 1390810 bytes / `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d`.

This binding supersedes prior active V17 input identities only for the new V18 recount. Historical receipts remain preserved. The Task2 source baseline is 1,040, the exact next selection is lines 392–400, and its measured token cost must be added in full. Count harness metadata will be bound after the reviewer confirms this exact schedule.

Count harness binding: `/private/tmp/fablebook_plan03_04_task3_count_v18.py`, 17460 bytes / `f02901ea6a2b3f1c0ba56718c79bf1e72dc87b231d35ef5bf165285c0647a399`; syntax check passed, no count endpoint request made. The harness binds exact support lines 392–400 and cumulative source baseline 1,040.


## V18 final schedule metadata review — PASS

Independent review passed exact pre-receipt schedule SHA-256 `cc467bc2c329b4848e2acdc68006896dd83db31be2aa75fb2f5eeec288a559f7` and harness SHA-256 `f02901ea6a2b3f1c0ba56718c79bf1e72dc87b231d35ef5bf165285c0647a399`. Reviewer confirmed all selected PLAN/REPLAN/REVIEW excerpts, current SIZING and lane bindings, exact support selection, cumulative source baseline 1,040, 1,500 source cap, 100,000 total, fixed 31,000 reserve, and no-body-before-count gate.


## V18 direct count receipt — partial validator span only

V18 direct count-only receipt: pre-receipt reviewed schedule `cc467bc2c329b4848e2acdc68006896dd83db31be2aa75fb2f5eeec288a559f7`; receipt-bearing schedule used `fe391f4ea28c9138586e070e8183da3b3e835e03abd1452ba16929e549e1a7a5`; harness `f02901ea6a2b3f1c0ba56718c79bf1e72dc87b231d35ef5bf165285c0647a399`. Context 28,824; exact lines392–400 111; combined 28,929. Request hashes: context `82da42f7551d76472fe7b7d35cce8a8116eee047dcdc2cfad99b6208d19fd439`, span `50f8528414d4eb6763f56ff3b7600f9d2dbafd1d250ab5de8b16739c839712b8`, combined `109c3f27633f00e797b43253a668befcb33a595f5a8abc63bfc460040057c70e`. Cumulative Task2 source 1,151/1,500; projected total 87,948/100,000. All limits pass. After the count, only selected lines392–400 were inspected. Metadata-only function boundary check shows `validate_target_sources!/1` continues to line476 (next function starts line477); lines401–476 are 2,574 bytes / `6954af9f5ebb1bf4ca6e6c686794397d1da52a4fec28b047e5f7deaee54c9d06`. Those lines have not been token-counted or inspected. Remaining Task2 source allowance is 349. Since the counted span was not the complete validator, no safe correction can be selected from it; candidate remains null, no patch applied, report remains unpublished. Do not begin Plan03-05.


## V19 count-only feasibility selection — validator remainder

This is a feasibility check only. Do not emit or inspect the body. The active source baseline is 1,151 tokens; only 349 remain under the fixed Task2 cap of 1,500. Preserve V18’s 111-token count and all previous reads. Count exactly the complete function remainder and no other newly selected source span.

| Input | Current full identity | Exact selected context |
|---|---|---|
| PLAN | 20840B / `51bda471591fc4e634dc1a8d95158f999bc0d88e298817ad49ba8bd9d39fecc7` | lines 62-70: 2866B / `a33a0abf3232c6a494ede0c7470957c8d96877a81074266e2f06a69dc5c41035`; lines 150-152: 590B / `ad59f551859a1c8c5a9b7a03c6afd683ab6ddaa5fe349c881c5c59f5c8d42925` |
| STATE | 18620B / `2e8a140ac81d946576cce9505cd38220e100b5901d86273374dcb02ce62978bb` | lines 40-52: 3065B / `0b8f90204097b2e345d484cfd5ab0e779ba91403c81617e559da04d2c2aa858d` |
| REPLAN | 35492B / `8c80a2b79d3e4e4fb2a18df3e29a308fa4c355e02f2c1c0c621d0dc71f48848f` | lines 492-510: 1123B / `eeccaf464c637e89bdf62ac93661bd916c4f2f737d9f8f767c93f62395ca774c`; lines 526-528: 639B / `48ff7341134e27691fae94b47e3ccdb4c83235d06a5ba502225f8e5c619a41a5`; lines 531-533: 717B / `900e121e0068fdaca0453a27939dfc31db4fe494566416f3f89fdc0988b07d7e` |
| REVIEW | 52943B / `ec8e887105c8f30a9af1bd026fa48602694c9a93027599de695aa02f6d733098` | lines 776-792: 889B / `ef60523d21581e88e6b9d86cae14ed34dd3b757da0027f82dc3207ad3758f032`; lines 803-805: 747B / `bf57bdb363f1246709ca7bf3055a576081730d944ddd1576a4cb83b041d3f949`; lines 808-810: 617B / `973fee2dce0180eb0e4a1e859f57e12fc441efdcd77637e8cd4e750dd76483cf` |
| SIZING | 31384B / `819240df50f4fe7968bddde64dcee46d27109d798e388d244d5b04f0abae95d5` | 14-key projection 24673B / `de5c482a2d2c9ed12f5907555ff6ed48b3526c4327fe6483baf1dab53cd43686` |
| core lane | 1418156B / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` | full identity |
| floor lane | 1390810B / `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` | full identity |

The source selection is exactly `test/support/guard_aggregate_reconciliation_evidence.ex` full identity 58,768B / `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63`, lines 401–476, 2574B / `6954af9f5ebb1bf4ca6e6c686794397d1da52a4fec28b047e5f7deaee54c9d06`. Count context, exact span, and combined using the direct count-only endpoint. Cumulative source is 1,151 + fresh measured span; hard cap 1,500. Task1 spans ≤22,000; output ≤5,000 (1,193 already used, 3,807 remaining); context ≤38,500; Task3 new reads 0; cushion 2,000; reserve 31,000; total ≤100,000. If the fresh span exceeds 349 tokens, stop without displaying it. No generation or body emission.

Count-only harness: `/private/tmp/fablebook_plan03_04_task3_count_v19.py`, 17,602B / `463393f8eff3d359f56f20f0a3ef60a12a82478beb1e9a060c3c26b06ba35f8e`; Python syntax check passed. It binds exact lines401–476 and cumulative baseline 1,151. No endpoint call has been made.


## V19 feasibility schedule metadata review — PASS

Independent reviewer passed exact pre-receipt schedule SHA-256 `20430031ea2e2fc767d1a7bd713cdab1fa92b602ca30eb5e928a9842f1196f37` and harness SHA-256 `463393f8eff3d359f56f20f0a3ef60a12a82478beb1e9a060c3c26b06ba35f8e`. The reviewer verified current PLAN/STATE/REPLAN/REVIEW/SIZING bindings, the exact lines401–476 selection, count-only behavior, all caps and the 1,151-token baseline with 349 remaining.


## V19 count-only feasibility result — BLOCKED by Task2 source cap

V19 direct count-only feasibility receipt: independent pre-receipt schedule `20430031ea2e2fc767d1a7bd713cdab1fa92b602ca30eb5e928a9842f1196f37`; receipt-bearing schedule `a0f9c2eff271fdb61a471fcfa1ee9562282f1050b2fa5075b68e41113f06256a`; harness `463393f8eff3d359f56f20f0a3ef60a12a82478beb1e9a060c3c26b06ba35f8e`. Exact lines401–476: 618 tokens / `3273858a7b05c3a8ca665a5f86523099f007f57131e676534a0c4dfe4a3ee683`; context 29,549 / `e79b6428a3b2d531ee01c882b8e3054a63091fe41be20b7cd774476377f5965d`; combined 30,161 / `8d76f3576ad3a5d1a24bac3a8835602ccd31d1c5e347cf2a01f2da51c2b0806e`. Cumulative source selections 1,151 + 618 = 1,769/1,500, fails by 269. Projected total 89,291/100,000 passes; context cap passes. The selected body was not emitted or inspected. No source patch, report publication, or Plan03-05. Candidate remains null, implementation unauthorized, aggregate gate open, Walking Skeleton blocked, SEC-01 Pending.


## V20 exact remainder recount — final source reallocation

Owner-authorized final reallocation moves 1,000 from context to Task2 source: context 37,500; Task1 22,000; cumulative Task2 source cap 2,500; Task3 reads 0; output 5,000; cushion 2,000; fixed reserve 31,000; total 100,000. V19 count 618 is preserved as history; current cumulative source selection baseline is 1,769. Freshly count the exact same remainder and add it to 1,769. No source body may be emitted unless the new count and all caps pass.

| Input | Full identity | Selected excerpt/projection |
|---|---|---|
| PLAN | 21574B / `d00bda6467c9c250c7d1aa5562fb08a0716692d311dac0e8d11ee53008799367` | lines 62-70: 2866B / `a33a0abf3232c6a494ede0c7470957c8d96877a81074266e2f06a69dc5c41035`; lines 150-152: 590B / `ad59f551859a1c8c5a9b7a03c6afd683ab6ddaa5fe349c881c5c59f5c8d42925`; lines 155-157: 732B / `96a74c3c86438983afb20f2fe9a54a9663ef903b16e23dd32cdac86d9898bc12` |
| STATE | 18778B / `2890bcc367facb55cf008e5663fdb9e93407c46fd8c7b55f079c3c7d6f9bfdc0` | lines 40-52: 3223B / `b3d1e92b25f428a03a91bf6ffc9de73c6f6c7ab31d0aa15e85144f98cdfac0d8` |
| REPLAN | 36682B / `a0c20604ce4dad81413d0d97f68ad367fd14f03b4606d21abc319def4cad367a` | lines 492-510: 1123B / `eeccaf464c637e89bdf62ac93661bd916c4f2f737d9f8f767c93f62395ca774c`; lines 526-528: 639B / `48ff7341134e27691fae94b47e3ccdb4c83235d06a5ba502225f8e5c619a41a5`; lines 531-533: 717B / `900e121e0068fdaca0453a27939dfc31db4fe494566416f3f89fdc0988b07d7e`; lines 541-543: 695B / `1be1dd9e6cb6120e36545dd76ebf64ccb338de4f41c2345c0ef2e9c73d6ee570` |
| REVIEW | 53981B / `73b61552d78cc8605e9a22919c26097ef5afa2fc84ee37f20981ec663770b443` | lines 776-792: 889B / `ef60523d21581e88e6b9d86cae14ed34dd3b757da0027f82dc3207ad3758f032`; lines 803-805: 747B / `bf57bdb363f1246709ca7bf3055a576081730d944ddd1576a4cb83b041d3f949`; lines 808-810: 617B / `973fee2dce0180eb0e4a1e859f57e12fc441efdcd77637e8cd4e750dd76483cf`; lines 818-820: 543B / `91af7758360214d06df2f775819fc3d955b9705e6f72ff18af1b3c2eb8fbb436` |
| SIZING | 31745B / `cd0b737056c789a7c7624b5002fbd6b040dcfe50ee2078dde4f1bbb589bc738c` | exact 14-key projection 24901B / `2d1fd5f5e4a0dfa10b8a77ceeadce496fa38484c9ebbe107a4b3d4dfaee82abe` |
| core evidence | 1418156B / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` | full identity |
| floor evidence | 1390810B / `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` | full identity |

Exact count-only source selection: support file 58,768B / `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63`, lines401–476, 2,574B / `6954af9f5ebb1bf4ca6e6c686794397d1da52a4fec28b047e5f7deaee54c9d06`. V19’s old-cap failure remains historical; the fresh V20 selection is a distinct direct count and is charged again. Count context, exact span, and combined. If cumulative source exceeds 2,500, stop without body emission. Preserve all safety gates.

Count harness binding: `/private/tmp/fablebook_plan03_04_task3_count_v20.py`, 17,737B / `8456b747fc1206b916f13e788d0bfb85605d1793b097d028555f8fddf0e31da5`; syntax check passed, no count endpoint call. It binds current context, exact lines401–476, cumulative source baseline1,769, and caps context37,500/source2,500/total100,000.


## V20 final reallocation metadata review — PASS

Independent reviewer passed exact pre-receipt schedule SHA-256 `7ade26dc21843fc56d8e20e34073cfed9cb7059ba05d4489eadd163eba4d3686` and harness SHA-256 `8456b747fc1206b916f13e788d0bfb85605d1793b097d028555f8fddf0e31da5`. Current artifact bindings, exact remainder selection, prior cumulative baseline 1,769, context cap37,500, source cap2,500, reserve31,000 and total100,000 all verified.


## V20 fresh count passed; full validator confirms evidence gap

V20 fresh direct count: pre-receipt reviewed schedule `7ade26dc21843fc56d8e20e34073cfed9cb7059ba05d4489eadd163eba4d3686`; receipt-bearing schedule used `c9dbd313a598a0ff5a5a9d78ca8af0e2d9aa444a9d56c0f20067c5924bc04699`; harness `8456b747fc1206b916f13e788d0bfb85605d1793b097d028555f8fddf0e31da5`. Context 30,397 / `9948e9897986a4bb88300e434950204760d02851c575dcde2319feae105085d2`; exact lines401–476 618 / `3273858a7b05c3a8ca665a5f86523099f007f57131e676534a0c4dfe4a3ee683`; combined 31,009 / `071a3d279315ebeffda0c6e4be495293826f5be86af172c734ca5479b54505fe`. Fresh cumulative source 1,769 + 618 = 2,387/2,500; context cap37,500 and total cap100,000 pass. The remainder was inspected only after this count. The validator confirms line394 intentionally requires complete target-source coverage, followed by consistency checks for mappings, gaps, statuses, and source identity. No narrow safe correction was identified from the authorized scope: the failing input record lacks complete target coverage, and Task3 forbids new lane-record reads. No source change or report publication; candidate null, safety stops unchanged.
