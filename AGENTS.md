# Agent instructions

Read and follow [CLAUDE.md](CLAUDE.md) for project intent, architecture, and workflow rules.

The owner has granted standing authorization across Fablebook OpenGSD phases, plans, and milestones to run relevant GitHub Actions locally with `act` when feasible, then push reviewed/tested phase candidates and open or update pull requests to obtain hosted CI receipts without repeated permission requests. Local `act` results do not replace required hosted receipts. Follow existing branch protection and phase delivery gates; this authorization does not cover unrelated releases or production deployments. See intent record `INT-20261109-01`.

## Phase recovery

Before declaring a requested phase missing, inspect the checkout branch and fetch the current default branch; reconcile merged planning PRs and preserved worktrees. A stale local checkout is not evidence that an approved phase does not exist. Preserve unrelated working changes when recovering its plan.
