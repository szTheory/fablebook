---
phase: 07-guard-scope-reconciliation
plan: 04
subsystem: evidence-reconciliation
status: complete
requirements: [RSC-04]
---

# Plan 07-04: Join observations and stop at the owner decision

The machine record and human summary now agree on all ten outcomes, both complete complements, all no-retry gaps, source provenance, and preserved safety stops. The refreshed schedule covers 275,031 bytes; hashes were captured for 218,450 bytes and not captured for 56,581 bytes. The context estimate is a byte-to-token approximation, not a tokenizer measurement: 61,118–91,677 tokens for all scheduled files and 48,544–72,817 for hash-captured files. Estimated remaining effort was 5 hours (range 4–8); actual elapsed time was not measured.

The recommendation is to keep the candidate null, leave the aggregate gate open and make no implementation change. Three consumed requests lack durable hashes and spans, including one selector-key mismatch. This bounded record does not establish candidate fit or support implementation. It ends at the owner's decision about whether to authorize any separately scoped guard increment. Automatic follow-up remains disabled.

## Verification

The final reconciliation check and human-summary check pass. The summary is generated from the validated machine record and retains the owner decision boundary.
