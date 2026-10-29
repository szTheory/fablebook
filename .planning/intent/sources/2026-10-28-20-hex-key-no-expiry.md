---
id: INT-20261028-20
date: 2026-10-28
source: Claude Code session, /gsd-execute-phase 1, owner reply at the 01-05 Task 2 checkpoint (secrets and amendment-diff review)
captured_by: Claude (Opus 5.5)
context: The bootstrap Hex key was created with a 30-day expiry, and after 0.1.0 it is to be rotated to a key scoped to the fablebook package. The owner also confirmed that both secrets (RELEASE_PLEASE_TOKEN, HEX_API_KEY) were set. The reply was relayed by the orchestrator.
---

> Verbatim.

Okay, I did that. By the way, for the hex API key, 30 days is. Oh, okay, we're going to swap it later on. I was going to say, I don't really want to be freaking in the business of generating keys constantly. I'd rather have it never expire because I just don't have time to be rotating keys all the time. But yeah, I did those two things, by the way.

**Resolution:** The package-scoped key that replaces the bootstrap key after 0.1.0 is created with no expiry, so there is no recurring rotation. The accepted residual risk is a publish key that never expires. Mitigations: it is scoped to package `fablebook` only (`package:fablebook`, with no account-wide `api:write`), it is stored only as the `hex-production` environment secret, and that environment deploys only from `main` and tags `v*`.
