# Migration review

One inline review covered the entire two-file source delta, every new planning/control artifact, the 318-file hash inventory, requirement/status/citation preservation and the old-to-new phase mapping. No independent subagent sign-off is claimed. No blocking finding remains in this review; hosted CI is still required.

Physical evidence files move into the fixed v0.1 archive. Stored logical ownership/provenance/review paths stay unchanged. The two debugger metadata comparisons still demand exact equality with the original logical path; only the known archive prefix of the trusted expected path is translated. Incoming metadata is never normalized. Tampered metadata therefore cannot gain acceptance through the path translation. Calibration still validates a regular file at the expected archived summary location and retains source hashes and all previous assertions.

The first focused run failed because physical relocation altered the expected historical-authority address. The fix preserves the historical address instead of editing recorded metadata or weakening comparison. The core rerun passed. Earlier invalid setup results remain failures, not passes. The requirement validator likewise caught missing canonical colon syntax; only the new requirement text was corrected, and no planning guard was edited.

The archive is explicitly superseded/incomplete. The standard milestone-complete helper was not used because it writes shipped claims. Supported milestone-switch/phase-clear helpers moved history without force. A read-only verifier confirms exact archive bytes, unchanged original checked states and citations, exhaustive phase 2–35 mapping and the sole active integer phase. New source/phase membership is not guessed or executable yet. The phase plan/implementation and owner merge remain real boundaries.

No lib, workflow, binary producer, dependency, lockfile, acceptance threshold or runtime safety rule changes. The Python verifier is read-only standard-library tooling for this one migration and is not an adopter dependency or a new CI lane. Existing protected runtime source, historical source identities and all current safety/product gates remain. Primary/recovery worktrees, uncommitted review artifacts and brand assets are preserved.

| Reviewed source | SHA-256 |
|---|---|
| `test/contract/tier_sweep_test.exs` | `8dc1ff13659e5296a6003c411a8390e61169134fa832fa953bfca91dbe640daa` |
| `test/support/debugger_settings.ex` | `f6d8d4fde360977517899164c4b6aba17cf280073305415ac105b2d6e228098e` |
