# Current core source schedule review

**Verdict:** PASS

**Reviewer:** Independent read-only reviewer: schedule_rebaseline_final

**Schedule SHA-256:** `4234596c2d4dcd7c04fada75468e809d7bbe32896982a5199702310518bc224d`

## Findings

- The schedule contains only the five core entries. It binds the current `mix.lock` SHA-256 (`3c55e9ec28da1fe2f8ded5a8b5e6504542c3536df25c704933cd7ace85224207`), LiveView 1.2.14 package and repository checksums, manifest SHA-256 (`10a940e92bbb948a9763b52b503f88d9c4a0ffe2149c7b936f79db6df5b4bec5`), and export generation `phase7-security-rebaseline-10a940e92bbb948a`.
- The five historical IDs remain closed: `new_requests` is zero, each entry has no new request ID and is not reused, and retry/reopen is unauthorized. Prior observation records and consumption markers agree.
- Plug is the sole carry-forward. Its prior parsed source SHA-256 remains `8d1b87dd51870df64b20e0ad203a18f072ecb47a15f11132e75e3e0ca47f766b`; package `plug` 1.20.4 and its package/repository checksums match the prior identity. The captured and current lock bindings are both explicit.
- The other four entries remain evidence gaps: Regex (`core-source-01`) was parse-failed with no retry; Phoenix Digester (`core-source-02`) stopped without a durable hash and has no retry; LiveView (`core-source-03`) changed from 1.2.13 to 1.2.14 and remains a no-retry gap; OTP `re` (`core-source-05`) remains parse-failed, with its captured hash as provenance only.
- The schedule records `target_source_bodies_read: false`. This review used only schedule, lock, manifest/export metadata, and prior observation/consumption records; no target source body was read or reread.
