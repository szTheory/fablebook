# Core lane identity investigation

**Date:** 2026-11-20  
**Result:** exact identity not reconciled; Phase 7 remains stopped

## Scope

The owner authorized a bounded, read-only check of the core lane's lock/runtime identity and saved provenance, with Phase 7 resuming only if identity reconciled exactly. The accepted ENV06 receipt remains unchanged. No target source body, package-wide caller search, runtime API, build, compile, R9 request, guard implementation, or candidate promotion was used.

## Evidence

- The accepted ENV06 generation is `ENV-20261117-06-supported-20261117T204102Z`. Its typed-gap inventory contains 4,944 core rows and 4,772 floor rows; the associations input has zero rows.
- The accepted core `mix.lock` SHA-256 is `4638a2d1c25b5be2bfaf6b6a3309e9147612f343aa694d64b2af99cc46f33a85`. That exact lock exists in Git history at `675a783d4758258ee013281b8ef50ad579eddeea` and `f846002f0f6c6c3070b36059b900e63ae72f8bf4`.
- The current core `mix.lock` SHA-256 is `31c244c80a750309f4cc82c8840fdf78bba642ba78a00df31b3acfe208b94112`. Git attributes the only lock-entry change since the accepted lock to `af1783d89461253061568cd6880ef518adafadb2` (`security: update Plug to patched 1.20.4`, 2026-11-18): Plug changed from 1.20.3 to 1.20.4. Phoenix remains 1.8.16. This is an explained dependency-graph change, not a matching identity.
- Core `bin/lane core doctor` verified the pinned Elixir 1.20.4 / OTP 29.1.2 runtime. Floor `bin/lane floor doctor` verified Elixir 1.18.5 / OTP 27.3.4.9. The floor lock still exactly matches the accepted SHA-256 `ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847`; Phoenix remains 1.8.9.

## Decision and limits

Runtime identity is sound for both lanes, but the core source snapshot predates the Plug security update and is pinned to a different full lock. The accepted 4,944-row core inventory therefore cannot establish current core membership exactly. Explaining the patch does not make the old identity current, and the accepted receipt must not be rewritten to hide that change.

Plan 07-01 remains halted. No family, complement, source schedule, caller/delegate observations, or refreshed sizing was produced. Plans 07-02–07-04 remain blocked. Inherited safety stops remain unchanged; the candidate is null, implementation is unauthorized, the aggregate remains open, SEC-01 remains Pending, Walking Skeleton remains blocked, and R9 remains unconsumed.

## Recommended next decision

Choose whether to authorize a separately scoped refresh of the core evidence against the current lock, preserving ENV06 as historical evidence and defining its exact inputs, source-read limits, request budget, and cheap validation first; or keep Phase 7 stopped. A refresh must pass its own prerequisite review before any target source body is read. Do not proceed by weakening the full-lock identity check or resuming Plans 07-02–07-04 automatically.
