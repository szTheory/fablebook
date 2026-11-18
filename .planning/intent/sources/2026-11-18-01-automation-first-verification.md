---
id: INT-20261118-01
date: 2026-11-18
source: owner conversation during Phase 3 verification
captured_by: Codex
context: Default verification, CI/CD feedback-time, and serial-checkout preferences. Automate only where checks provide useful evidence; do not weaken phase, product, security, or release gates.
---

# Automation-first verification and faster feedback

## Verbatim owner direction

```text
for verification... use this <boilerplate>
automate verification shift left
----
integration/e2e/smoke/seam test... automate the world devops mindset shift left (onto CI even ... iff
recurring value there tho..) goal is 0 human verificaiton/uat required. and remember this in our
GSD .planning so that u do this by default going forward always whenever possible so that only the
absolutely necessary is handed off to me. that will make our GSD workflow more automated which i like.
and make sure that after we do this it's recorded so we never loop back to this i dont want to waste our time churning here. reduce toil, automate

that's my boilerplate prompt for this kind of thing  adjust details as needed to match our circumstances

btw side note in general u should always whenever a CI run is happening or done evaluate low hanging fruit
to make it more efficient in terms of speed/iteration time/github actions dont mess up its quality just
saying we dont need pointless bottlenecks wasting our time/money etc. make sure this is encoded in the
opengsd project in a way that is discoverable like for CI and release steps (CD)

if applicable in designs consider adding/running cheap consistency checks before the long test/process/suite...
(always lessons learned find bottleneck low hanging fruit sanity check take a step back to keep things
moving fast instead of banging our head against the wall)

By the way, can you remember all of this so that whenever we do a verification step in the future, you
kind of just automatically, as soon as possible, start automating everything as possible? I understand
that sometimes I'm going to need to do some human verification, but if you could just take it as far
as you can without me, but only if it's going to give you useful feedback. Don't put yourself into a
corner. Only do what's useful. And it's okay if you do throwaway verification. Everything doesn't have
to be in the CI. Only CI if those requirements. Current value.
</boilerplate>
```

I hate going onto other worktrees when we're not actually doing parallel work.

## Recorded defaults

- Automate repeatable facts at the cheapest boundary that proves them; use local throwaway checks when they answer a one-off question, and CI only for recurring value.
- Reconcile each human UAT item against the current phase goal, existing receipts, and approved decisions. Do not repeat approval or turn an out-of-scope future decision into a blocker for a bounded current result.
- Run cheap consistency/provenance checks before long suites. On failure, fix the cause and rerun only checks invalidated by changed inputs; reuse passing receipts when the tested inputs are unchanged.
- After every completed CI or release/CD run, review measured critical-path and comparable-history data for safe iteration-time improvements. Never lower coverage, security, or release gates to save time.
- For serial work, stay in the current checkout. The --ws flag selects a logical GSD workstream; it does not change the filesystem checkout. Use another worktree only for actual parallel work or a concrete isolation/preservation need.
