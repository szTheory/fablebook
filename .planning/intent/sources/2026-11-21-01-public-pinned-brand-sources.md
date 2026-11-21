---
id: INT-20261121-01
date: 2026-11-21
source: Direct owner message in the active Fablebook planning conversation
captured_by: Codex
context: Replaces local-folder source custody with public commit-pinned brand repositories and authorizes public citations for the approved demo source subset.
---

# Owner direction: fetch brand sources from pinned public repositories

**Date:** 2026-11-21
**Provenance:** Direct owner message in the active Fablebook planning conversation.

> “please don't ask for a folder path again, and don't depend on copies under `docs/brand/`.”
>
> “Every brand book made for FableBook is now a public git repository with a version tag, so take them the same way you'd take any pinned dependency. That makes it reproducible, keeps the files out of this repository, works the same locally and in CI, and makes updates a one-line diff.”
>
> “The books are public on purpose, so citing them publicly is fine.”
>
> “When I publish an update to a book, I'll tell you the name and the new tag, and you run the update command in a PR.”
>
> “Then continue Plan 08-01 Task 2 from the cache copy, run `--check-pinned`, and go on to 08-04 if it passes. If the source supports too little for the dispatcher job, tell me exactly what is missing instead of filling the gap.”

Use the seven public repositories, tags, and commit pins supplied in this conversation and recorded in `brand_sources.lock.json`. Fetch their exact commits into the gitignored `.cache/brand_sources/<name>/` directory. Never copy full source repositories, PDFs, or unrelated assets into Fablebook. A reviewed public PR may include only the approved, minimal, hash-checked Logistify excerpt manifest and the one dev/test Book content it supports, with repository, tag, commit, and source path citations. Keep names explicitly demo-only and do not claim trademark clearance.

Updates are explicit: when the owner names a brand and new tag, run `bin/fetch_brand_sources --update <name> <tag>` and submit the lock change for review. Normal checks never resolve floating tags or update pins automatically. This source-distribution direction does not broaden v0.7 beyond one Logistify operator Book, close the guard aggregate, enable `walking-skeleton`, authorize other Books, or permit a release or deployment.
