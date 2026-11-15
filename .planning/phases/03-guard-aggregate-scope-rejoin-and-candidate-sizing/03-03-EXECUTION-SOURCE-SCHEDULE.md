---
phase: 03
plan: 03-03
status: task-1-complete; task-2-zero-read-rebind-count-pending
date: 2026-11-15
---

# Plan 03-03 execution source schedule

Metadata only. No source text is emitted or authorized by this schedule. The prior failed review receipt, `03-03-SOURCE-SCHEDULE.md`, remains unchanged.

## Current plan and evidence inputs

| Input | Bytes | SHA-256 |
|---|---:|---|
| Revised `03-03-PLAN.md` | 24,590 | `5c71e01e7fbf93cdf7316911d8f138d5a7cbef24c4d7d40b5fa8f1878cbd006b` |
| `03-03-REPLAN.md` | 12,988 | `24063279de2c809eb21f0220032c50e4a70cc7c73673e2d38ebe4c1b9fa58a3e` |
| Core lane evidence | 12,107,528 | `ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a` |
| Floor lane evidence | 11,828,076 | `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121` |

The two lane records share generation `09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b`. Membership joins pass; source joins and caller evidence do not. Core has 1,761 target-source gaps and 5,287 required evidence gaps; floor has 1,716 target-source gaps and 5,152 required evidence gaps. All keyed target-source gaps are `source_mapping_not_present_in_scoped_findings`; required gaps also include missing current-graph reconciliation and unreviewed callback/delegate provenance. No pending source closure is complete enough to rank. No diagnostic candidate or candidate target/caller source is scheduled. Candidate remains null.

## Compact, hash-bound context manifest

Only the complete sections below are selected from project documents; each selected byte span is bound by its exact file and span SHA-256. Unselected sections are out of this task's isolated context. This manifest removes unreferenced documents and whole project/summary files while retaining the instructions, phase intent, current stops, previous-lane findings, and sizing bounds needed for this plan.

| Required input | Exact complete section(s) | File bytes / SHA-256 | Selected lines | Selected bytes / SHA-256 |
|---|---|---|---:|---|
| `AGENTS.md` | full file | 6,295 / `86f3c829e1853ff1ba66e54f7301da9d2706e4d3a6b9353fd5d118663936e1c7` | 1–40 | 6,295 / `86f3c829e1853ff1ba66e54f7301da9d2706e4d3a6b9353fd5d118663936e1c7` |
| `CLAUDE.md` | full file | 3,743 / `7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2` | 1–36 | 3,743 / `7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2` |
| `.planning/intent/NORTH-STAR.md` | full file | 3,559 / `c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248` | 1–34 | 3,559 / `c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248` |
| `.planning/intent/CLEARANCE.md` | full file | 2,154 / `1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff` | 1–16 | 2,154 / `1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff` |
| `GLOSSARY.md` | vocabulary rule and scope | 15,891 / `e1f8dbee98abf437ee6851f103a93e119dff97a0416b93754a8dd41ae55e25c6` | 1–6, 352–355 | 577 / `2f1fa561631ee01d3007824f6813ff69463338a46315fc9aacc87315592b7dd7`; 124 / `98d73f71be69f94926209f3964d35748ace13f3197ccec68194a3c22e2d902b9` |
| `docs/adr/README.md` | full locked-decision index | 2,597 / `8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5` | 1–32 | 2,597 / `8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5` |
| `.planning/VERIFICATION.md` | verification and evidence policy | 5,352 / `0295edd62cb7b6351075b8ace1ddfa1203ab18fe175b757950cc1caa5b048e66` | 1–18 | 3,840 / `b0cdb522982ba4b3911daefa7b653b55187a355d5ac387e032d2797192b6254b` |
| `.planning/PROJECT.md` | core value, shipped/current state, active requirements, constraints | 59,317 / `4d541583b0d820581d73369e5b70e6dd9b457a5aa9b81e248a97e5001a03affb` | 9–56, 334–362 | 4,277 / `1d39c6d42e693be20700cc32e9b798f14794024710b974562fcdfd2e1ebb172d`; 3,662 / `9a8498f4680c0deb67bc056b10569e7b5d6616f79d94e03df27c29f0f46a2b5e` |
| `.planning/ROADMAP.md` | Phase 3 goal, acceptance, stopping boundary | 2,986 / `b4d9ac03da1141b66b65d57540be1980e9ffe28d9f9e44b0de6cae3af11e681b` | 16–45 | 2,187 / `85cdf97b63e7a8c2ca80de391fc9910de90ce355bf402831286635391b34816c` |
| `.planning/STATE.md` | current position/handoff, active decisions and blockers, session/next action | 16,300 / `0657569e02d8c30b446a80045d7468b44cdfe3e60a7445feb94a4b6d7c7a91fb` | 34–53, 73–95, 155–189 | 2,181 / `b63f62829f1b2f81e7b9b64c5ef54d6fed7e7fd1197ab82536f066ad85e9978e`; 3,589 / `af4c5f6088afa95e1b25b0fb249f0cbfec35058f2e9c2ae33e80224715d2fd65`; 3,493 / `e7193cd1866f3e4fa995dad267780629d863ed40a0727c9aa8dae17f08869e6e` |
| `.planning/REQUIREMENTS.md` | active milestone requirements, out-of-scope and traceability | 3,954 / `01603c2fe55a57b87a7b6c1aada319c1428d43162f2a15747d78831bd44b1781` | 1–15, 22–39 | 2,584 / `0b679c7d7c623dd4bfc1b9c85cbdd644b80c2fcf24ae2b7b61b57b7ee4e3407b`; 1,039 / `7b088650f115415c328ebef97d7aa3ff8e2b326d4cd65d52fc7d9a4cbb1c71f9` |
| `03-CONTEXT.md` | phase boundary, decisions, deferred gates | 10,916 / `a2a66a691e9026d3e97821a82aafa14c63460137912813b27f7018677cbef22b` | 1–34, 109–117 | 3,518 / `412f3ea65e9f6cdf8793438d967c15022ee8a7ac4249415992942baf4c7e1866`; 333 / `ff97bc18461701847407f7c348f785b50076ce05e38ebd5173cfd9b94e8e1673` |
| `03-02-SUMMARY.md` | completed join, tested receipts, remaining source/caller gaps | 11,799 / `140abc752b9d1454eacc73033f3819bd8658f9be91a493e5b6e7cd6ab6a0602b` | 72–110, 151–165 | 4,038 / `e0fef52d9c19d3a53d1f3d08159c3cbc54a7c8dadd65c48996429c5db55c182f`; 792 / `11d12e5a2f0b6c6849e618d849802600ae0d4c154e6006f28ab7dbca4e417d4f` |
| v0.2 `01-SIZING.md` | all inherited context/source limits and stops | 5,328 / `937df8ec8e79b8bbf673df69149461d45728dd92a9fc12ffdb6ba7ebe958cff2` | 1–31 | 5,328 / `937df8ec8e79b8bbf673df69149461d45728dd92a9fc12ffdb6ba7ebe958cff2` |
| v0.3 `02-CONTEXT.md` | phase boundary, decisions and deferred obligations | 14,424 / `d769dfd143534ba5272f88a140f261462a020dc348c305e399dde624af7b9c78` | 9–18, 43–67, 137–145 | 467 / `547f4e6a06db9339e24777bb7bf25ca88197628f44d025ac05b78f4ce2dd3d7c`; 3,561 / `2ecb48c44457ccde1c2420d2683e6dbbe14071065a292faa3fce9a60d4cb0630`; 744 / `ced4ccc240073b9853fc304ed1bc01ea4d7775ed7fa59ec21a69d9b4e9aaff9c` |
| rolling allocation intent | full owner direction and inherited limits | 1,802 / `fe2e185f27481fb340b995583485604925a1b1e9c1863f2c76f13ae92c098e66` | 1–14 | 1,802 / `fe2e185f27481fb340b995583485604925a1b1e9c1863f2c76f13ae92c098e66` |
| `PLANNING-GATES.json` | full guard/SEC-01 current gate record | 503 / `ca2fc6d23ad474dad7d72688fee03a71dfff38e4d8e4d3237e1ecef0bec1271b` | 1–22 | 503 / `ca2fc6d23ad474dad7d72688fee03a71dfff38e4d8e4d3237e1ecef0bec1271b` |
| ADR 0021 | delivery size, review cap and contract-test separation | 3,072 / `2074bc6920a6bc36cd4e295a5649a2b82036f37899cb3fa9d26fa69441582a56` | 14–34 | 2,368 / `a6d3292ce48db0cd4e605d50948be9d250c857150cc1381803f2fcc95c5fc4af` |
| revised Plan 03-03 | full plan | 24,590 / `5c71e01e7fbf93cdf7316911d8f138d5a7cbef24c4d7d40b5fa8f1878cbd006b` | 1–143 | same as file |
| current Plan 03-03 replan | current limits and Task 1 → Task 2 hash-rebind procedure | 12,988 / `24063279de2c809eb21f0220032c50e4a70cc7c73673e2d38ebe4c1b9fa58a3e` | 1–229 | same as file |

The full `03-02-SUMMARY.md` and `03-03-PLAN.md` are not duplicated outside the selected sections/current full revised plan. The full 12 MB core and 11 MB floor evidence files are never placed in the count input: use the compact keyed projections below, each bound to its source file, generation, and exact list digests. The preserved failed first schedule remains available at `03-03-SOURCE-SCHEDULE.md` (whole-file SHA-256 `13645ad6c32398479dd7d87a0a68271b22c45fdb0b7d7b7e85b28d105d91160f`) and is represented here only by its failure status and hash.

## Selected keyed lane evidence projection

The materialized compact projection is `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-KEYED-EVIDENCE.json`, 9,958 bytes, SHA-256 `5e8e6a92e870ab2ea7373017c93da70d50d5cb0fede817b8e1b586cfc0ae99c4`. It binds both immutable lane-record paths, byte sizes, SHA-256 digests, and shared generation. In each lane record (`03-CORE-AGGREGATE-EVIDENCE.json` or `03-FLOOR-AGGREGATE-EVIDENCE.json`), original membership is read from `$.identity_rows[*].original_live_mfas`; delivered membership from `$.identity_rows[*].delivered_scope_mfas`; and the record's pending list from `$.identity_rows[*].pending_mfas`. The projection's `$.lanes.<lane>.identity_rows` is a summary object (226 rows plus digest), not an array. `$.lanes.<lane>.existing_selected_mfas` summarizes the existing selection; its membership is checked against both source-record `$.selected_mfas` and `$.live_mfas`. `$.lanes.<lane>.inventory_universe` retains its source record's `$.inventory_universe` count and `exported_mfas_sha256`. `$.lanes.<lane>.pending_complement` records the selector `unique_sorted_union($.identity_rows[*].pending_mfas)` and independently proves it equals `unique_sorted_union($.identity_rows[*].original_live_mfas) minus unique_sorted_union($.identity_rows[*].delivered_scope_mfas)`; its nested original/delivered summaries, count, canonical set digest, source-record SHA, and empty `new_selected_mfas` are metadata only. Core: original 1,754 / `d2c6b170422f1c0fe2c64992a343814ecd55e6006513bbd6f4a4a66a9b36aef2`, delivered 5 / `ed87d6cc8721622f09cf6b4461e694945d6a5e7825fa1ce340bd72d6cbddd0af`, pending complement 1,749 / `d95ac86383d315efb443dd80d95cc5715f5234b824bf5f4bceb132d9858e9d44`. Floor: original 1,709 / `d0f9fc159fa9c01e695df6b84891a8629db20e2af50c559fba2e9b7052d6dd45`, delivered 5 / `ed87d6cc8721622f09cf6b4461e694945d6a5e7825fa1ce340bd72d6cbddd0af`, pending complement 1,704 / `668eb9d03c554c7fc9f3c5c7a581066a8d192e7670ab72f046f7f6658d5da0e6`. Set digests use canonical JSON over sorted MFA tuples, UTF-8, sorted object keys, and compact separators. `$.selection.core` and `$.selection.floor` are intentionally empty because `$.candidate` is null; no new candidate membership is inferred. All complete association/gap arrays remain reachable by their exact `$.<field>[*]` source-record selectors and immutable record digest; the projection retains only counts, reason/status counts, and digests. Deterministic extraction prints metadata only (no MFA arrays): `python3 -c 'import hashlib,json,sys; d=json.load(open(sys.argv[1])); rows=d["identity_rows"]; enc=lambda x:json.dumps(x,sort_keys=True,separators=(",",":")); u=lambda f:sorted({enc(m) for r in rows for m in r.get(f,[])}); o=u("original_live_mfas"); v=u("delivered_scope_mfas"); p=u("pending_mfas"); q=sorted(set(o)-set(v)); assert p==q; h=lambda xs:hashlib.sha256(("["+",".join(xs)+"]").encode()).hexdigest(); print(json.dumps({"original_count":len(o),"original_sha256":h(o),"delivered_count":len(v),"delivered_sha256":h(v),"pending_count":len(p),"pending_sha256":h(p),"difference_matches":True},sort_keys=True))' <lane-record-path>`. This command yields the recorded exact counts/digests without expanding arrays.

| Lane | Complete record bytes / SHA-256 | Generation | Original − delivered = exact pending complement | Exact source gaps (status) | Required evidence gaps (reason counts) |
|---|---|---|---|---:|---|
| Core | 12,107,528 / `ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a` | `09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b` | 1,754 / `d2c6b170422f1c0fe2c64992a343814ecd55e6006513bbd6f4a4a66a9b36aef2` − 5 / `ed87d6cc8721622f09cf6b4461e694945d6a5e7825fa1ce340bd72d6cbddd0af` = 1,749 / `d95ac86383d315efb443dd80d95cc5715f5234b824bf5f4bceb132d9858e9d44` | 1,761 `source_mapping_not_present_in_scoped_findings` | 5,287: 1,763 current graph; 1,763 callback/delegate; 1,761 selected graph observation |
| Floor | 11,828,076 / `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121` | same | 1,709 / `d0f9fc159fa9c01e695df6b84891a8629db20e2af50c559fba2e9b7052d6dd45` − 5 / `ed87d6cc8721622f09cf6b4461e694945d6a5e7825fa1ce340bd72d6cbddd0af` = 1,704 / `668eb9d03c554c7fc9f3c5c7a581066a8d192e7670ab72f046f7f6658d5da0e6` | 1,716 `source_mapping_not_present_in_scoped_findings` | 5,152: 1,718 current graph; 1,718 callback/delegate; 1,716 selected graph observation |

Task 1 span metadata and its historical independent PASS receipt below remain in this file, but that receipt covers only the earlier span schedule digest and is superseded for current review. The exact selected document/excerpt and keyed-record manifest, including the corrected selectors above, must receive independent review. After that PASS, rerun execute preflight and directly count the current complete context bundle plus every Task 1 span. Count-only endpoint: `POST /v1/responses/input_tokens`, model `gpt-6-luna`, existing ignored `.env.local` credential only. Record request SHA-256 and response count; never print or persist the credential or call any other endpoint. Include the current plan/replan, both schedule receipts, exact excerpts and keyed projection, exact spans, framing, 5,000-token output allowance, 2,000-token cushion, the 31,000 reserve, and the Task 2 zero-new-read cap. The context manifest and source schedule must remain hash-stable after the count. Proceed to source-body emission only if the measured selected context plus keyed evidence is at most 52,000, Task 1 exact spans are at most 10,000, and the full projection is at most 69,000 working / 100,000 total. Otherwise keep all bodies un-emitted and stop with the precise excess.

## Task 03-03-01 exact spans

Both implementation files are counted once each against the task's five-file cap. The 756 KB test module is excluded as a full-file read. All span byte counts and digests cover exact UTF-8 bytes with existing line endings and inclusive 1-based line bounds.

| Exact source file | File bytes | File SHA-256 | Complete function or test span | Lines | Span bytes | Span SHA-256 | Token count |
|---|---:|---|---|---:|---:|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | 43,379 | `3454989a6fa501f4fcb5386dbabf522f6132addd6d3ef74179e5906ecd637494` | `build_lane!/1` (16–115) | 100 | 3,678 | `0e068f898909e25d0c46d332143e30c2d7f4b5fdf35d49a16bbc72692cea554c` | pending direct count |
| same | 43,379 | same | `validate_aggregate_lane!/1` (135–206) | 72 | 3,250 | `8424140a85d47a0b751ea7c9e48be5611cf7a371a8ecbac4b7a056a46f180c74` | pending direct count |
| same | 43,379 | same | `render_crosswalk!/2` (207–293) | 87 | 3,278 | `2fdb3f0ab5121a50f201064eee1fa90193ad5ed5294d1ef9f526c020fccd010b` | pending direct count |
| same | 43,379 | same | `attach_target_sources!/3` (317–383) | 67 | 2,333 | `5b35380088727820c427244a81779b067a0fb6aaff9afbe7f80c9524f8940003` | pending direct count |
| same | 43,379 | same | `validate_static_callers!/1` (678–719) | 42 | 1,470 | `03e660314f3648182687ee8b18ec5811e4e31d7c65f258fbb94834169dacb2a3` | pending direct count |
| `test/contract/tier_sweep_test.exs` | 756,777 | `bf315d6a88aa3fc692a34b78aa0c2bdc4b136be557d7038581cacfe30727946a` | `aggregate input identities and references are complete before writes` (5097–5141) | 45 | 1,647 | `fc384b293a3c1158aa8153fe08460104781829052f210decc09137c1ca02cee8` | pending direct count |
| same | 756,777 | same | `two lane records reproduce the complete original-identity crosswalk` (5602–5659) | 58 | 1,907 | `a1b7dc36c712d675344cbd1afede7da330e12215d6111f2837dfa3964e8f4a0c` | pending direct count |
| same | 756,777 | same | `target source links preserve exact identities and enumerate every gap` (5662–5806) | 145 | 4,849 | `fd7315285a29bac1b21cfef07b4544dd9bc7b67cf3c7ddf7a4d4e663eaf1fa7e` | pending direct count |
| same | 756,777 | same | `caller graph records preserve exact observations and explicit gaps` (5808–6008) | 201 | 7,750 | `3985ca3958d55b6c5d6054243c6dcd3e4e935daae461866172622c8db1a5cf12` | pending direct count |
| same | 756,777 | same | `caller-chain index preserves duplicate edges and lowest caller arity` (6009–6064) | 56 | 1,684 | `63d5caa6dcc720406b90471c181d8de2a053a802c3b92799700b9d919fe89378` | pending direct count |

Task 03-03-01 unique exact-source files: 2/5. Candidate target/caller/delegate source files: 0. Task semantic-source token total: pending direct count; limit 10,000. No source reread is scheduled.

## Task 03-03-02 zero-body-read rebind

Task 2 has zero source-body reads and zero source rereads. It reuses the exact Task 1 source context, measured fit-interface notes, and persisted Task 1 patch. At the Task 1 handoff, record the binary patch SHA-256 and both post-edit implementation-file SHA-256 values here. Before Task 2, verify those exact values with metadata-only `sha256sum` and `git diff --binary` piped directly to `sha256sum`; do not reopen a source body. If either current file hash or patch hash differs from the recorded handoff, stop without reading a body. The Task 2 five-file cap remains, with zero files read. Its 6,000-token semantic-source allowance is unused; Task 1 fit-interface notes and test/control case list must be preserved as a compact, hash-bound handoff in the sizing/report artifacts.

## Emission gate

The independent schedule review must pass against this exact file digest. Then rerun `bin/planning_health --stage execute --phase 3` and record its result. Then use only the already approved `POST /v1/responses/input_tokens` count-only endpoint for model `gpt-6-luna`, with the existing ignored `.env.local` credential and no other endpoint, to count the exact selected documents, keyed metadata, this schedule, review receipt, scheduled spans, output allowance, 2,000-token cushion, and 31,000-token reserve. Record the redacted harness, response count, and SHA-256 of the exact serialized request payload. The working total must be at most 69,000 and the total at most 100,000. Any schedule, receipt, selected-input, plan, or source change requires a fresh review as applicable and a new direct combined count before emission. Until all gates pass, keep every scheduled body un-emitted.

Static-only proof remains binding. Do not invoke audited OTP functions, callbacks, atom sinks, runtime eval, or generated-code paths. Stop on an actual-library collision; preserve the Macro caller-AST and wording checkpoints; keep `candidate=null`, `implementation_authorized=false`, aggregate open, Walking Skeleton blocked, and SEC-01 Pending.

## Independent Task 1 schedule review

**Historical PASS — 2026-11-15; superseded schedule digest:**
`71ddb7685be82515b838f0eefe72e9257dc62f989285e0370eeb390d1d5a38d4`.
This review checked only the ten inclusive source span metadata and then-current plan/replan bindings. It did not review the later compact context manifest or corrected keyed-evidence selectors. The ten spans match their recorded line and byte counts and SHA-256
digests; each starts at its named complete function or test and closes at its
`end` boundary. The current plan and replan byte/digest bindings match. The
schedule uses two unique source files against the task's five-file limit and
does not schedule candidate source reads. The full 756 KB test module is not
read or emitted as a body; file hashing was metadata-only. Scope remains limited
to the collector's lane/source/caller support and corresponding contract tests.

All span token counts remain **pending direct count**. The 10,000-token Task 1
cap and 69,000/100,000 combined fit are not yet certified. Candidate remains
null; static-only proof, actual-library collision stop, Macro checkpoints,
aggregate open, Walking Skeleton blocked, SEC-01 Pending, and
`implementation_authorized=false` remain binding. This historical span review
does not authorize source emission. Rerun execute preflight and direct-count the
current payload, including a fresh review receipt, before any body is emitted.

## Independent compact-context and exact-schedule review

**PASS — 2026-11-15; exact reviewed schedule digest:**
`fbf4f9334a861a5af82a2d0d54c095bc6ac66d6893123c82c1193cbc6518b4b3`.
The reviewer verified all 20 selected context rows and 29 excerpt ranges, the
keyed-evidence projection and selector/complement mapping, all ten scheduled
Task 1 spans, and the zero-new-body-read Task 2 hash-rebind contract. This
receipt certifies schedule metadata only; it does not certify token fit or
authorize source-body emission. The exact payload still requires fresh execute
preflight and direct count against all stated limits.

## Task 1 execution receipt and Task 2 fit-interface notes

The independent review above was followed by `bin/planning_health --stage
execute --phase 3`, which passed with no errors and `route_phase: 03`. The fresh
count-only requests used model `gpt-6-luna` and the already approved
`POST /v1/responses/input_tokens` endpoint. The credential was read from the
existing ignored `.env.local` file by the redacted harness and was not printed
or persisted. The exact reviewed pre-emission schedule digest included in the
count was `d04f64a95fd2a74ab573d875c0c38b19ed6809fea8ad2c66762fde9eec463bae`.

| Count | Tokens | Exact serialized request SHA-256 |
|---|---:|---|
| Compact context plus keyed evidence and schedule | 35,202 | `d794963538c8459e203f416d60882e1eee3c7429c381825d061aab89dad3d2eb` |
| Ten exact Task 1 spans | 8,023 | `393a1fc7dcab55d86644ab4f3e49341a7321b02589b75be9d525582aec07c875` |
| Combined context, spans, and framing | 43,310 | `6fa45eff7d6fac8c0fababf36ce9858e810632cc294d34ec66d7f8005dd9d36b` |

Combined-context framing is 85 tokens. With 5,000 output tokens and a 2,000
token cushion, working projection is 50,310/69,000; adding the fixed 31,000
reserve gives 81,310/100,000. Context (35,202/52,000), Task 1 spans
(8,023/10,000), working, and total gates pass. The count opened only the ten
reviewed spans after all gates passed. Their original complete-span SHA-256
values remain those in the Task 03-03-01 table above.

Focused validation passed after the renderer fix: core selector 5 passed, 103
excluded; floor selector 108 tests, 0 failures, 103 excluded. Before report
publication the test checks 226 identity rows, 452 source-crosswalk rows, 3,481
static-caller rows, explicit incomplete source status, and `check_bundle!/2`.
It then writes `03-RECONCILIATION.md` and `03-SIZING.json` atomically. The final
report is bound to generation `09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b`, contains 226 identity rows, 452 source rows with 3,477 source gaps,
and 3,481 caller rows with 10,439 caller-evidence gaps. Candidate remains null.
The sizing artifact records both immutable lane paths and SHA-256 values,
complete membership/complement selectors and digests, gap counts/reason hashes,
the count receipts, and candidate-specific source/context/effort as unknown
because source and caller closure remain incomplete.

| Task 1 output | Bytes | SHA-256 |
|---|---:|---|
| `03-SIZING.json` | 13,285 | `96763b2312124fa5109a204bd51063cd425bbda60c83930e32e27557e8f3711a` |
| `03-RECONCILIATION.md` | 13,114,187 | `662cdcb1f88c3fe5e266ad18f0fdf804b947891852178e8afac8a67196964dd4` |

| Task 1 implementation file | Original full-file SHA-256 | Post-Task 1 full-file SHA-256 |
|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | `3454989a6fa501f4fcb5386dbabf522f6132addd6d3ef74179e5906ecd637494` | `b3d0a1b3f039d45b339ec736fc4649e38b984e5a5ecf14add79aae903f4380d6` |
| `test/contract/tier_sweep_test.exs` | `bf315d6a88aa3fc692a34b78aa0c2bdc4b136be557d7038581cacfe30727946a` | `293570b02b302d8aa98dbc12ee202ca95a0704f41523d468ad0a793f4d27a808` |

Task 2 fit-interface notes are bound to the original ten complete span hashes
above and binary patch SHA-256
`b68315334d41bb2ff4dc71c9a61ee63bfc294667de17797768e33d6a0795aba6`. Task 2
must perform metadata-only whole-file SHA-256 checks and may use the notes only
if both files match the post-Task 1 hashes in this table. It makes zero new
source-body reads, reuses Task 1's source context and fit interface, and retains
the original-span hashes and patch lineage. A mismatch closes the gate; do not
open a replacement span. Run a fresh execute preflight and direct combined
count against the finalized schedule, Task 1 sizing/report outputs, this
receipt, Task 2 output allowance, cushion, and reserve before any Task 2 work.

Task 1 preserves `candidate=null`, `implementation_authorized=false`, aggregate
gate open, Walking Skeleton blocked, SEC-01 Pending, static-only evidence,
actual-library collision stop, and both Macro checkpoints.
