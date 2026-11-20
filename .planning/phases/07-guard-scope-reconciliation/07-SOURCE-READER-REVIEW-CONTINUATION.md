**Verdict:** PASS
**Reviewer:** verify_export_inventory_contract
**Reader SHA-256:** `2bacf07e689b9d1fcf469c73fcbd1bf60161f3b515c4b2ff6370589e377676e9`
**Launcher SHA-256:** `92a6af9ba11f727653dd645d23867c8224e90daebc071d503932f748330be6fd`
**Bootstrap SHA-256:** `4978f25cc40fdc2a4784cce4dcc2b4a634aaf6eabde8a6f4305469fbc85b98c3`
**Parser SHA-256:** `6a4d44911a4f9e7e12140d348d5f1ebe2b80aba1a863376dc00bb896d4e6e387`
**Validator SHA-256:** `4b625cb79d01acf28f0a9055198ee5434db3a72a803a67e8c65dd6e235cbb4b3`
**Launch gate SHA-256:** `6ccd5dd6ab75fbc069003f8da0ba8956f16b9aa2deeb2033e85e37a839669e76`
**No-retry request ID:** `core-source-01`
**Prior STOP SHA-256:** `609d035c28cdd0b351273d83e2fd30674bc2fa63f57f63a55512446dada6eec4`
**Prior marker SHA-256:** `810a5f74c46afe81426e5e25cb7e29447ae0401028e799f1fb3cae396fb7fe4a`
**Initial review SHA-256:** `d75119bb910ac98740eeb8fa6b388d4871e05774dc410870c7ca41d5edd2024a`
**Interrupted request IDs:** `core-source-01,core-source-02,core-source-03`
**Interrupted STOP SHA-256:** `b24c444733f896db8898266cf89dc7b7431a8fe9e27149ea4e336254b7fb9cb4`
**Interrupted marker core-source-02 SHA-256:** `36f8039b02f9c0feac2ed7eba8728f9874d64dcf3f2517076e8206c05f2a12c4`
**Interrupted marker core-source-03 SHA-256:** `52a70e1f5f91c69dd549da161301abc88dac466bbb281bdf49c2f37d7f3b571b`
**Interrupted review SHA-256:** `39ae7c1356f7d8b8ace6472eb84b1f2a7ec1c4a235223e42b4240dc274262234`
**Reviewer opened target source bodies:** no
**Target source bodies read:** no

## Findings

- The launch gate checks the continuation review and bootstrap using bounded no-follow descriptor reads, verifies the review-pinned bootstrap digest, and executes those captured bytes. The bootstrap verifies and executes the reviewed launcher; the launcher verifies and executes the reviewed reader. The reader loads the parser and validator from captured bounded bytes and checks their exact digests before use. The gate digest above identifies the exact source intended for stdin to `python3 -`; executing the gate by path is outside this review.
- The consumed history is preserved. The original `core-source-01` STOP and marker match their pinned hashes and show parsing stopped on an unbalanced delimiter before an observation output was written. The interrupted STOP records all three request IDs and matches its pinned digest. The `core-source-02` and `core-source-03` markers bind to the exact schedule, approval, paths, consumed status, and preserved interrupted review. That review remains separately saved at `07-SOURCE-READER-REVIEW-CONSUMED.md` with SHA-256 `39ae7c1356f7d8b8ace6472eb84b1f2a7ec1c4a235223e42b4240dc274262234`.
- Recovery preserves distinct evidence: `core-source-01` remains `parse_failed_no_retry`; `core-source-02` is `BatchOutputLost`; and `core-source-03` is `SelectorKeyNormalizationMismatch`, explaining that the prior reader used an `Elixir.`-prefixed key while parser results normalized that prefix. The validator pins these exact errors, STOP/marker/review pointers, selectors, and row shapes. All three requests enter `consumed_before_batch` and are excluded from both prechecks and `read_one`. Missing or mismatched historical evidence, existing output, a recovery STOP, or an unexpected consumed marker prevents reads.
- The reader now applies normalized module keys to both parser-result validation and observation construction while preserving the scheduled MFA in output. If a future parser result omits a selected MFA, the reader raises `ObserverError` and produces a bounded `parse_failed` row with a captured source hash, no spans, explicit parser-failure gaps, and retry disabled. Validator checks cover the exact scheduled selectors and failure shape. The parser's synthetic source includes a namespaced Elixir module and distinguishes adjacent `do:` syntax from a block `do`; parent-reported parser regression checks passed.
- Unexpected read, parser-result construction, or output-write failures use a batch-specific STOP written with `O_EXCL` to the phase-local absolute path. Recovery uses a separate path after the existing continuation STOP; existing STOPs are never overwritten, and a later invocation refuses a recovery STOP. Failure to persist the STOP now raises a distinct error naming the consumed IDs and failed path; durable one-use markers still prohibit retry. Before opening any new source, the reader prechecks the remaining files, then writes and fsyncs a marker, opens each exact path once through a no-follow parent descriptor, reads only the approved bounded full file, and checks its identity and size before and after the read. Output contains spans and hashes, never source text.
- Schedule and approval validation bind the ten exact paths, lane/source identities, selectors, and batch assignments. Batch validation checks request coverage, hashes, marker lineage, parser output bounds, and the three historical no-retry gaps. Finalization validates every batch before joining evidence. Source path handling in the validator resolves and stats metadata only (`source_stat`, `07-validate-reconciliation.py:1224–1238`); finalization consumes planning and observation artifacts and does not open target source bodies (`finalize_reconciliation`, lines 2303–2326).

## Limits

- Earlier readers had already opened the bodies for `core-source-01`, `core-source-02`, and `core-source-03`; this reviewer did not. The adjusted reader skips all three, and unavailable hashes/spans remain explicit gaps.
- This review assumes the exact launch gate bytes above are supplied on stdin to `python3 -`. Parent-reported compile checks, parser synthetic checks, validator self-tests in normal and optimized modes, and diff checks passed. I did not run the reader, tests, or builds.
- Observations cover only selected static spans in the approved files. They do not establish package-wide caller closure or resolve dynamic dispatch, aliases/imports, callbacks, macros, or generated code. Floor membership remains accepted retained evidence and was not rescanned.
