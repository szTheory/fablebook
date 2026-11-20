# Current core export manifest review

**Verdict:** PASS
**Reviewer:** Independent read-only reviewer: manifest_rebaseline_final
**Producer SHA-256:** `674b7472cfd01edeb93ab1604f756c4accbd5b6ac2104b04e01a5560e57dd05e`
**Manifest SHA-256:** `10a940e92bbb948a9763b52b503f88d9c4a0ffe2149c7b936f79db6df5b4bec5`
**Root summary SHA-256:** `a2c886c9fbfa86290621e20f9293dace7c3418077d26613d173926e2a2bceabb`

## Findings

- Manifest schema `fablebook.phase7.compiled_manifest.v3` binds the current full `mix.lock` SHA-256 `3c55e9ec28da1fe2f8ded5a8b5e6504542c3536df25c704933cd7ace85224207`, `mix.exs` SHA-256 `0d8aae670b99fd5d3d519c0ec16bd44455397bc98f1a8f8b33864255f3e61ac9`, `.tool-versions` SHA-256 `0d8e4f1d2fbde0cd63e4c45a60bbb4827058a592ee8b37057980627fcb517233`, and OTP 29.1.2 / Elixir 1.20.4-otp-29. These hashes match the current files and the producer's pinned identity.
- The manifest contains exactly 2,061 BEAM file rows across 53 roots. The root summary reports the same counts and binds the exact manifest SHA-256 above.
- The patched `phoenix_live_view` root is version 1.2.14 and records package checksum `80a248539e566eea8598079b12bfb1a9c1f3180d4db3ecd215d28798dcebc44b` and repository checksum `1ca75ed52d3916f93299de990f152f3f49202d12849e526bf5f9b89b4ccf25f2`, matching the dependency patch record and current lock identity.
- Manifest paths are limited to pinned `@OTP_ROOT/lib` and `@ELIXIR_ROOT/lib` roots and `_build/lanes/core/build/test/lib/`. Producer path generation checks containment; scanning resolves only those labels and requires exact regenerated manifest membership.
- The BEAM parser reads only the `AtU8` or `Atom` atom table and the `ExpT` exports table, requires exactly one of each, applies size/read bounds, and seeks over all other chunks. This review read producer and metadata files only; it did not inspect BEAM contents, target source bodies, or run the scan.
