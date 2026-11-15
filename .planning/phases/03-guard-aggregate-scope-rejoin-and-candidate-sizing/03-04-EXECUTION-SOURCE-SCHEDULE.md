---
phase: 03
plan: 03-04
status: metadata-only schedule; body gate closed
---

# Plan 03-04 exact context and source schedule

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
| Task 03-04-02 correction/reread spans | 500 tokens |
| Task 03-04-03 new source reads | 0 tokens |
| Output | 5,000 tokens |
| Cushion | 2,000 tokens |
| Fixed reserve | 31,000 tokens |
| Maximum working / total | 68,000 / 99,000 tokens |

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
The approved current replan is the 38,500 / 22,000 / 500 / 0 / 5,000 / 2,000
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
