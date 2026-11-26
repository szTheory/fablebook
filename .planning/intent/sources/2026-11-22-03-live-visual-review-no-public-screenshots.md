---
id: INT-20261122-03
date: 2026-11-22
source: Direct owner instruction in this Phase 8 continuation
captured_by: Codex
context: The owner prefers to inspect the Book live in the local browser at the end-of-milestone review and does not want screenshots included in public PRs.
---

# Owner direction: live visual review without public screenshots

> “Well, when you're talking about a final visual review, I'd rather, wouldn't it be better to just open up the storybook so I can see it? I'd prefer you do that. For now, I don't want to have PRs in public with all these screenshots and stuff. I think it's overkill.”
>
> “u can re-ask for access i had stopped sharing it b/c i thought u were done with it and had left it dangling”

## Reconciliation

- Open the local Phoenix Book in Chrome for the owner's end-of-milestone visual review.
- Remove Phase 8 screenshot files and embeds from public PR #106; do not publish replacement screenshots.
- This changes the review medium only. It is not visual-baseline acceptance or rejection; preserve the existing owner decision gate until the owner gives feedback at the end of v0.7.
- Keep the local Book available for the owner to inspect. The review route is `/admin/dev/fablebook/book/operator?scenario=failed_shipment` on the local operator host.
