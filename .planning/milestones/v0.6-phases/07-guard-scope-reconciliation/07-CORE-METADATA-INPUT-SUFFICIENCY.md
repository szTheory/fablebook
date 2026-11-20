# Current-core metadata input sufficiency

**Date:** 2026-11-20
**Status:** NO-GO — the selected metadata does not provide complete current-core lane maps.
**Scope:** Read-only review of the exact lock/toolchain and Phase 3/4/6 metadata listed in Plan 07-01, following the complete R11 producer inspection.

## Question and decision rule

R11 found that `build_lane!/1` transforms caller-supplied lane maps but does not create them. This check asks whether the selected existing metadata supplies every required current-core map and binds it to the current full lock and pinned runtime without target-library/OTP bodies or audited runtime APIs.

The check passes only if it provides complete current-core identity and selected/live MFA membership, lane evidence, delivery, runtime and lock identity with reproducible provenance. Otherwise Plan 07-01's generation precondition remains false. Historical rows cannot be relabelled as current.

## Reviewed input set

Only these inputs were reviewed. SHA-256 values pin the exact bytes examined.

| Input | SHA-256 |
|---|---|
| `.tool-versions` | `0d8e4f1d2fbde0cd63e4c45a60bbb4827058a592ee8b37057980627fcb517233` |
| `mix.lock` | `31c244c80a750309f4cc82c8840fdf78bba642ba78a00df31b3acfe208b94112` |
| `mix.floor.lock` | `ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847` |
| `.planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-KEYED-EVIDENCE.json` | `5e8e6a92e870ab2ea7373017c93da70d50d5cb0fede817b8e1b586cfc0ae99c4` |
| `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-VERIFICATION.md` | `a3dcf9d3a307bf093ce2b617d8fd3394cbb5dac38422a15fea1f0bc9046f5d5e` |
| `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-TYPED-GAPS-ENV06.jsonl` | `128032ab929f831bb516186bbe9844b6bd36e0b55327a9cc998f16c65b0d4011` |
| `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-PROVENANCE-MANIFEST.json` | `24bd4c93c6fbfaa599de664365acbae266720f95d86dd18c4cb36bb009ae8c23` |
| `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json` | `304a82168d9e19b11cd208ed02d577d880bc0407f3d088012cae4206cfb7735b` |
| `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py` (read only) | `44837e93328507e910de20d3b8d1824b9bcb0dfabdeaa104448c6c6f1d6a3620` |

## Findings

- **Pins identify the current dependency graph, not evidence membership.** `.tool-versions` pins Elixir `1.20.4-otp-29` and Erlang/OTP `29.1.2`. The current core lock is `31c244…94112`. The floor lock is `ed16ea…d3847`, which matches the retained ENV06 floor lock. Lock entries provide versions, checksums and dependency edges; they do not provide the complete lane-specific identity/MFA maps or caller/source evidence required by the producer.
- **Phase 3 is a historical compact projection.** Its keyed evidence carries saved aggregate summaries and complement digests, but source joins remain incomplete and it does not bind complete membership to the current core lock/runtime. It cannot supply the current-core maps on its own.
- **Phase 4 is the immutable ENV06 generation.** Its typed-gap file has 9,716 rows (4,944 core and 4,772 floor) for 226 original IDs per lane. The retained core lane uses lock `4638a2d1c25b5be2bfaf6b6a3309e9147612f343aa694d64b2af99cc46f33a85` and Elixir `1.20.4` / OTP `29`; these are not the current full core lock and exact OTP patch pin. The floor lane uses the retained `ed16…d3847` lock and its historical Elixir `1.18.5` / OTP `27` runtime. The typed-gap rows preserve historical baseline/live membership-role selectors, but those selectors are references, not the referenced membership maps. The target-source-association file is empty. The manifest marks source access closed, candidate null and implementation unauthorized.
- **Phase 3/4/6 records do not complete the producer input contract.** The Phase 6 supplement covers four EX-177 source/caller observations with historical lane pins and explicitly non-exhaustive caller closure; its validator is scoped to that supplement. Neither supplies a full current-core inventory, all required lane evidence and delivery inputs, or current-lock membership provenance.
- **The historical/current distinction is decisive.** The ENV06 core rows describe their own old generation and lock. Matching a subset of fields or retaining the unchanged floor lock cannot rebind those rows to the current core lock. No exact current-core map can be derived from this allowlist without guessing or reading beyond it.

## Outcome and bounded stop

The selected inputs are insufficient. Plan 07-01 Task 2's generation precondition is not met; do not generate a core baseline, calculate a family/complement, or make a source schedule. ENV06 remains unchanged. Plans 07-02–07-05 remain blocked. R9 remains denied; R10 and R11 remain spent. The actual-library-collision stop, candidate-null and implementation stops, Macro caller-AST and explanation gaps, SEC-01 Pending, legacy digest gap, aggregate gate, and Walking Skeleton stop remain unchanged.

No target-library/OTP source body or recorded source path was opened. The supplement validator was read but not executed. No helper, test, build, compile, Mix command, audited runtime API, or evidence producer was run. This check does not make or test a dependency update; it only establishes that the current baseline cannot be reconstructed from the selected metadata.

Further progress on the guard baseline needs a separately scoped and reviewed source of the exact current-core maps and its permitted operations. That is a material boundary change, not an automatic continuation. The owner decides whether to scope that boundary or retain the stop and redirect the next milestone toward the product/demo roadmap.

## Review roles

Independent read-only reviews covered (1) current lock/toolchain pins, (2) Phase 3 and Phase 6 metadata, and (3) Phase 4 ENV06 metadata. Their findings agree: saved metadata provides historical comparison context but no complete current-core maps. The Plan 07-01 producer analysis provides the required map fields and the R11 no-go rationale.
