# Post-read source reader hardening

The approved one-use reads are complete. No scheduled target source was reopened to make these changes, and no additional source read is authorized by this note.

## Preserved read-time approval

`07-SOURCE-READER-REVIEW-CONTINUATION.md` remains immutable. Its reader, launcher, bootstrap, and observer hashes are checked against the exact files under `07-READ-TIME-CODE/`, whose digest manifest is `07-READ-TIME-CODE-SNAPSHOT.json`. The validator hash remains the original hash in `07-REDACTION-RECEIPT.json`. This preserves the code identity for the observations already recorded.

The current helper files have changed after those reads. The existing launch chain still checks their current hashes against the preserved read-time review and therefore fails closed. No additional batch may run under that old approval. The new code is reviewed separately in `07-REVIEW.md`; it does not replace or amend the read-time approval.

## Changes after the reads

- Read-only control-file and scheduled-source opens use `O_NONBLOCK` with no-follow flags, then verify the opened descriptor is a regular file with the expected identity. A path changed to a FIFO cannot hold the reader after its one-use marker is consumed.
- Newly written observations and STOP receipts sync both file contents and the containing directory entry before reporting success.
- Batch failure handling catches `BaseException`, writes a STOP receipt first, and then re-raises keyboard interrupts and system exits. For each newly consumed request without a durable observation output, the STOP lists a typed `batch_stopped_no_retry` gap with missing source-hash and selector-span facts and retries disabled. Reconstructed prior failures have their own field.
- The bounded Elixir observer rejects interpolating strings and lowercase sigils instead of silently omitting calls that may be inside executable interpolation.
- `phase7_source_hardening_selftest.py` uses only synthetic in-memory snippets, temporary regular files, and a temporary FIFO. It does not read scheduled target source paths.

The three already-consumed requests without durable hashes/spans remain gaps. They were not reopened, and this hardening does not change the selected family, complement, candidate status, aggregate gate, or inherited safety stops.
