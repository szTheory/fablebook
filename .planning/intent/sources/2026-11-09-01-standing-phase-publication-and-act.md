---
id: INT-20261109-01
date: 2026-11-09
source: Codex session, owner direction
captured_by: Codex
context: Phase 01.1.1.16 hosted CI gap and the owner's standing authorization for local GitHub Actions preflight and routine phase publication.
---

> Verbatim owner direction: “So whenever possible. i want u to use the project for github actions called "act" ... So, try to do as much of the work whenever you're optimizing CI or whatever. Do that locally as much as possible to reduce the burden on CI. But then, yes, I authorize the publishing, the tested candidate, et cetera, et cetera. I'm just saying do as much as possible locally to reduce the burden on CI. But then, after that, going forward, I never want you to have to ask me for permission to do this again. You always are authorized. And it's important because if I am having to give you authorization for every time we do this, We're not going to develop fast. It's going to slow us down significantly. So you must remember this going forward through opengsd development. like thru all our phases plans milestones etc etc... never ask me for this kind of thing again after applying the lessons learned here.”

**Resolution:** For all Fablebook OpenGSD phases, plans, and milestones, preflight relevant GitHub Actions with `act` locally whenever feasible, then push reviewed/tested phase candidates and open or update PRs to obtain required hosted CI receipts without recurring permission requests. Local results do not replace hosted receipts. Follow branch protection and existing phase gates; this standing authorization does not extend to unrelated releases or production deployments.
