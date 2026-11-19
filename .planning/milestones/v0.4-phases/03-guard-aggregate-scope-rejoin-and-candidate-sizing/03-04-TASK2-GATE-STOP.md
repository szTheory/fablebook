# Plan 03-04 Task 2 direct-count gate stop

## Gate result

No source or test body was emitted, no source file was edited, and no test was
run. The independent schedule review passed, and `bin/planning_health
--stage execute --phase 3` passed before this count. The fresh direct count
used only the approved input-token-count endpoint; no generation endpoint was
called.

| Measure | Fresh result | Active limit | Result |
|---|---:|---:|---|
| Compact context | 44,396 tokens | 34,000 | fail by 10,396 |
| New scheduled Task 2 spans | 882 tokens | 3,260 remaining | pass; charge this selection |
| Context plus scheduled spans | 45,271 tokens | 37,260 combined allowance | fail by 8,011 |
| Task 1 historical source ledger | 21,172 tokens | 22,000 | pass |
| Task 2 cumulative source | 13,622 tokens | 16,000 | pass; 2,378 remain |
| Task 3 new source reads | 0 tokens | 0 | pass |
| Cumulative output allowance | 5,000 tokens | 5,000 | pass; 3,807 remain after 1,193 prior use |
| Cushion / fixed reserve | 2,000 / 31,000 tokens | 2,000 / 31,000 | preserved |
| Projected total | 117,190 tokens | 110,000 | fail by 7,190 |

Context SHA-256: `80b59c2958680a662e2d807bb312e1692c0398ef80b23e277b35c1cf54298882`.
New-source payload SHA-256: `fcd4ec71db30df3d69760bfe4db01e9b705d4f5ce02def297a71028047bfa99d`.
Combined payload SHA-256: `6a955a173d6dac8cf5fe590841e912fecd3d0f5279ee2aef407c73fd9494eb0a`.
The count inputs include the exact schedule and independent schedule receipt.
The schedule digest is
`9e09560dd50b71d95f5f1e3b397cce48441cbc1fd6c42d0c110471f107d25a9a`; its
metadata-only review receipt digest is
`1cbd44b9bcb72f6a42f0aee686fe49872bd4adacb25025246919fbf26370cbcd`.

## Affected identity set and evidence status

This is the complete affected identity key set for the bounded trace, not a
claim that every identity is proven missing. Core and floor each have 226
identity rows and the same exact identity IDs. The canonical identity
projection selects `identity_rows[*].identity.{id,identity_class,table,owner}`
in original order: 17,474 bytes, SHA-256
`37df141d5a40a52c129ad1517c9e627e9c39049fcff4d903547061af085b97b7`. The
sorted ID-only projection is 2,060 bytes, SHA-256
`4277d546a212f99f36b9a3b113d80902e71b4bff5e4f89cd0c6429fda4017d67`.

Core record SHA-256:
`70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd`.
Floor record SHA-256:
`955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d`.
Both report `source_join_complete=false`; SIZING reports
`evidence_complete=false`, `candidate=null`, and
`global_gaps=[target_source_and_caller_evidence_incomplete]`. A complete
recursive-key scan of both records found no target-source-specific,
association, or typed-gap key. Therefore the present record package does not
identify per-identity target source paths, source hashes, associations, or
typed-gap provenance. The cause is still untraced because the source gate
failed before body inspection.

Affected identity IDs, sorted and serialized as compact UTF-8 JSON:

```json
["BD-001","BD-002","BD-003","BD-004","BD-005","BD-006","BD-007","BD-008","BD-009","BD-010","BD-011","BD-012","BD-013","BD-014","BD-015","BD-016","BD-017","BD-018","BD-019","BD-020","BD-021","BD-022","BD-023","BD-024","BD-025","BD-026","BD-027","BD-028","BD-029","BD-030","BD-031","BD-032","BD-033","BD-LANE-001","BD-LANE-002","BD-LANE-003","BD-LANE-004","CN-001","CN-002","CN-003","CN-004","CN-005","CN-006","CN-LANE-001","EX-001","EX-002","EX-003","EX-004","EX-005","EX-006","EX-007","EX-008","EX-009","EX-010","EX-011","EX-012","EX-013","EX-014","EX-015","EX-016","EX-017","EX-018","EX-019","EX-020","EX-021","EX-022","EX-023","EX-024","EX-025","EX-026","EX-027","EX-028","EX-029","EX-030","EX-031","EX-032","EX-033","EX-034","EX-035","EX-036","EX-037","EX-038","EX-039","EX-040","EX-041","EX-042","EX-043","EX-044","EX-045","EX-046","EX-047","EX-048","EX-049","EX-050","EX-051","EX-052","EX-053","EX-054","EX-055","EX-056","EX-057","EX-058","EX-059","EX-060","EX-061","EX-062","EX-063","EX-064","EX-065","EX-066","EX-067","EX-068","EX-069","EX-070","EX-071","EX-072","EX-073","EX-074","EX-075","EX-076","EX-077","EX-078","EX-079","EX-080","EX-081","EX-082","EX-083","EX-084","EX-085","EX-086","EX-087","EX-088","EX-089","EX-090","EX-091","EX-092","EX-093","EX-094","EX-095","EX-096","EX-097","EX-098","EX-099","EX-100","EX-101","EX-102","EX-103","EX-104","EX-105","EX-106","EX-107","EX-108","EX-109","EX-110","EX-111","EX-112","EX-113","EX-114","EX-115","EX-116","EX-117","EX-118","EX-119","EX-120","EX-121","EX-122","EX-123","EX-124","EX-125","EX-126","EX-127","EX-128","EX-129","EX-130","EX-131","EX-132","EX-133","EX-134","EX-135","EX-136","EX-137","EX-138","EX-139","EX-140","EX-141","EX-142","EX-143","EX-144","EX-145","EX-146","EX-147","EX-148","EX-149","EX-150","EX-151","EX-152","EX-153","EX-154","EX-155","EX-156","EX-157","EX-158","EX-159","EX-160","EX-161","EX-162","EX-163","EX-164","EX-165","EX-166","EX-167","EX-168","EX-169","EX-170","EX-171","EX-172","EX-173","EX-174","EX-175","EX-176","EX-177","EX-178","EX-179","EX-180","EX-181","EX-182"]
```

## Bounded next action

Reduce the compact context by at least 10,396 tokens while retaining the
complete affected identity/provenance/gap projections and every existing
safety stop. Keep the 110,000 ceiling and all sub-caps unchanged. Then prepare
a new hash-bound schedule, obtain a new independent metadata review, rerun the
execute preflight, and make a new direct count. Only if those checks pass may
the two scheduled Task 2 spans be opened. The count above charges 882 Task 2
tokens, leaving 2,378; do not increase the source allowance. If the narrowed
trace cannot establish exact per-identity source provenance within that
remainder, preserve these identities as unresolved, keep candidate null and
the report unpublished, and leave Plans 03-04 and 03-05 incomplete.
