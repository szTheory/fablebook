# Deferred items, Phase 1

## Flaky prod-guard route assertion (WINDOWS entry 2)

- **Where:** `test/contract/prod_guard_test.exs:23`, `refute routes |> String.split("\n") |> Enum.any?(&(&1 =~ ~r/fablebook/i))`.
- **Seen:** floor job, PR #7, https://github.com/szTheory/fablebook/actions/runs/40805617266 attempt 1. The prod `phx.routes` output began with `==> fablebook` and `Generated fablebook app`, so the dep was recompiled between `compile` and `phx.routes` in the same env. Attempt 2 passed. core and the earlier floor runs on PR #3 and main passed.
- **Not fixed in Plan 01-05:** the plan touches no tests, and an edit to this assertion must not weaken the guard.
- **Fix direction:**
  - find why the path dep recompiles (mtime of mix.exs, the lockfile or config);
  - or assert only on route lines, so `==>` and `Generated` lines are excluded by shape rather than by name.
  - The fix goes in its own PR with no `lib/` or `.github/` changes (ADR 0021).
