# Plan 03-03 exact-source and context schedule

Status: count-only schedule; source-body emission is not authorized.

## Fresh checkout and evidence identity

- Branch: `gsd/phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing`
- Execute preflight: `bin/planning_health --stage execute --phase 3` passed with no errors on 2026-11-15.
- Core aggregate record: 12,107,528 bytes, SHA-256 `ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a`, generation `09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b`.
- Floor aggregate record: 11,828,076 bytes, SHA-256 `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121`, same generation.
- Both records report complete membership join but incomplete source join, incomplete caller evidence, `candidate=null`, `implementation_authorized=false`, aggregate gate open, Walking Skeleton blocked, and SEC-01 Pending.

## Scope decision before source scheduling

No diagnostic candidate source is scheduled. The current two lane manifests have no complete pending source closure to rank: the core record has 1,761 target-source gaps and 5,287 required evidence gaps; the floor record has 1,716 target-source gaps and 5,152 required evidence gaps. Their target-source gaps are all `source_mapping_not_present_in_scoped_findings`. Required gaps also include missing current-graph reconciliation and unreviewed callback/delegate provenance. Existing exact source/caller findings are limited to the two delivered `inets:enable_trace/2,3` matches and cannot support a new candidate. Therefore there is no evidence-supported pending row or connected within-row slice to name from the generated lane-specific manifests. No alternatives were inspected or ranked.

This is a diagnostic conclusion from current keyed evidence metadata only. It does not close the aggregate or change any owner, disposition, safety stop, candidate, or implementation authority.

## Required implementation-source reads

Each task requires the two exact source files below. A full-file read is conservatively charged as one exact-source read per file; no excerpt is scheduled before source-body inspection. Task-specific read count is 2/5, with 3 reads available only if a newly justified and named candidate source later passes the gate.

| Task | Exact source | Bytes | SHA-256 | Token count |
|---|---|---:|---|---|
| 03-03-01 | `test/support/guard_aggregate_reconciliation_evidence.ex` | 43,379 | `3454989a6fa501f4fcb5386dbabf522f6132addd6d3ef74179e5906ecd637494` | unknown; body not emitted |
| 03-03-01 | `test/contract/tier_sweep_test.exs` | 756,777 | `bf315d6a88aa3fc692a34b78aa0c2bdc4b136be557d7038581cacfe30727946a` | unknown; body not emitted |
| 03-03-02 | `test/support/guard_aggregate_reconciliation_evidence.ex` | 43,379 | `3454989a6fa501f4fcb5386dbabf522f6132addd6d3ef74179e5906ecd637494` | unknown; body not emitted; reread charged |
| 03-03-02 | `test/contract/tier_sweep_test.exs` | 756,777 | `bf315d6a88aa3fc692a34b78aa0c2bdc4b136be557d7038581cacfe30727946a` | unknown; body not emitted; reread charged |

Candidate target/caller/delegate source reads: 0. Candidate rereads: 0. The candidate-source set remains empty because the source/caller closure is incomplete and no candidate can be ranked without fabricated source totals.

## Exact context inputs for a later direct count

These are the current source/context inputs selected for the count. Hashes bind exact UTF-8 bytes and line endings. The two 11–12 MB aggregate JSON files are inputs only for the keyed metadata already summarized above; the full JSON bodies must not be emitted into the execution context. A future count must include the exact selected keyed records, this schedule, the independent review receipt, every full required document below, both implementation source bodies, current output allowance, execution framing, and the fixed 31,000-token reserve.

| Input | Bytes | SHA-256 |
|---|---:|---|
| `CLAUDE.md` | 3,743 | `7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2` |
| `.planning/intent/NORTH-STAR.md` | 3,559 | `c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248` |
| `.planning/intent/CLEARANCE.md` | 2,154 | `1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff` |
| `GLOSSARY.md` | 15,891 | `e1f8dbee98abf437ee6851f103a93e119dff97a0416b93754a8dd41ae55e25c6` |
| `docs/adr/README.md` | 2,597 | `8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5` |
| `.planning/VERIFICATION.md` | 5,352 | `0295edd62cb7b6351075b8ace1ddfa1203ab18fe175b757950cc1caa5b048e66` |
| `.planning/PROJECT.md` | 59,317 | `4d541583b0d820581d73369e5b70e6dd9b457a5aa9b81e248a97e5001a03affb` |
| `.planning/ROADMAP.md` | 2,986 | `b4d9ac03da1141b66b65d57540be1980e9ffe28d9f9e44b0de6cae3af11e681b` |
| `.planning/STATE.md` | 16,300 | `0657569e02d8c30b446a80045d7468b44cdfe3e60a7445feb94a4b6d7c7a91fb` |
| `.planning/REQUIREMENTS.md` | 3,954 | `01603c2fe55a57b87a7b6c1aada319c1428d43162f2a15747d78831bd44b1781` |
| `03-CONTEXT.md` | 10,916 | `a2a66a691e9026d3e97821a82aafa14c63460137912813b27f7018677cbef22b` |
| `03-02-SUMMARY.md` | 11,799 | `140abc752b9d1454eacc73033f3819bd8658f9be91a493e5b6e7cd6ab6a0602b` |
| `03-03-PLAN.md` | 18,332 | `91d9e5e2f76f1200e05190b29051c10ab7935d25f071c97250bc642812cc87a2` |
| `03-CORE-AGGREGATE-EVIDENCE.json` (keyed metadata only) | 12,107,528 | `ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a` |
| `03-FLOOR-AGGREGATE-EVIDENCE.json` (keyed metadata only) | 11,828,076 | `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121` |
| `01-SIZING.md` | 5,328 | `937df8ec8e79b8bbf673df69149461d45728dd92a9fc12ffdb6ba7ebe958cff2` |
| `02-CONTEXT.md` | 14,424 | `d769dfd143534ba5272f88a140f261462a020dc348c305e399dde624af7b9c78` |
| `2026-11-10-01-rolling-allocation-for-bounded-work.md` | 1,802 | `fe2e185f27481fb340b995583485604925a1b1e9c1863f2c76f13ae92c098e66` |
| `PLANNING-GATES.json` | 503 | `ca2fc6d23ad474dad7d72688fee03a71dfff38e4d8e4d3237e1ecef0bec1271b` |
| `PLANNING-LIFECYCLE.md` | 7,775 | `5e1e5a09d270d496b73f9d11f346a9bd95f0eb7dc79fe0101c5900eecef01255` |
| `CARRY-FORWARD.md` | 3,456 | `c3362c64769ba4d6a770defd65263a1b1d7c2781dc03d7aad50250dca0b2302f` |
| `docs/adr/0004-no-eval-no-new-atoms.md` | 1,649 | `5d9232471b38fc7e038749bbc85145e6a608b70412c9d15c50b425e442c4fb23` |
| `docs/adr/0014-testing-strategy.md` | 2,323 | `42c70f5792c98c3ea8a77eb9cc7aec8c94c7d1f8b6101306bb3d8fb76cea34e4` |
| `docs/adr/0018-dependency-budget.md` | 3,066 | `3ca266284f17d26ee5f2044d00ffa4b7e8d60336fe6e1d3191aa393927ad46cf` |
| `docs/adr/0021-delivery-rules.md` | 3,072 | `2074bc6920a6bc36cd4e295a5649a2b82036f37899cb3fa9d26fa69441582a56` |

## Count gate

No `tiktoken` installation is available in the current Python environment (`ModuleNotFoundError` on import); no package was installed. No alternative tokenizer has been positively identified. Consequently exact token counts for the selected documents, keyed evidence, implementation bodies, candidate source/caller closure, prompt/tool overhead, and output remain unknown. Byte counts and historical measurements are not substituted for token counts.

The final combined count is therefore **not measured**, so the 70,000-token working projection plus 31,000-token reserve cannot be shown to fit under 100,000. The fresh source/context gate is **not passed**. Do not emit either scheduled implementation source body or any candidate source body until an already available compatible tokenizer is identified, the independent reviewer returns PASS for this exact schedule, execute preflight is rerun, and a fresh direct combined count includes the review receipt and all charged inputs. If no compatible tokenizer is available, preserve candidate null and report this exact missing measurement with the bounded remedy: make a compatible `o200k_base.encode_ordinary` tokenizer available outside this phase, then rerun the count gate without installing any dependency as part of this plan.

## Independent schedule review — FAIL

**2026-11-15 — not ready to authorize source-body reads.** The four scheduled
task/file entries identify two exact full-file inputs and stay within the plan's
two named implementation files and five-read-per-task limit. An opaque-byte
check matched each recorded byte count and SHA-256; line counts are 1,216 for
`guard_aggregate_reconciliation_evidence.ex` and 19,594 for `tier_sweep_test.exs`.
No source text was emitted or semantically inspected. The candidate source set
remains empty, consistent with the incomplete lane source/caller closure; the
recorded candidate, implementation authority, aggregate, Walking Skeleton, and
SEC-01 stops remain unchanged.

The source/context token total is unknown, so neither task fit nor the aggregate
fit is certified. In addition, the plan's 70,000-token working projection plus
31,000-token fixed reserve is 101,000, above the 100,000 ceiling. No
`03-03-REPLAN.md` exists in `.planning`; therefore this review cannot verify a
03-03-specific replan. Correct the projection to preserve the 31,000 reserve
within the hard ceiling, provide or identify the applicable replan, then obtain
a fresh direct combined count that includes this receipt. The count gate remains
closed; do not emit implementation or candidate source bodies.
