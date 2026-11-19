---
id: INT-20261118-02
date: 2026-11-18
source: user
captured_by: Codex
context: Separate assistant/session context limits from the owner's explicit project budgets; avoid repeated small budget bumps and unnecessary workspace switches for serial work.
---

# Keep execution limits and workspaces clear

## Verbatim owner direction

> "why are we bumping this "limit" just a little bit over and over again. why do we even need a limit"
>
> "yes plz get us back on track no token limit just get it done..."
>
> "why do we need to go into a separaet workspace? and can't u just run it using --ws flag anyways if u truly needed to?"
>
> "i hate going onto other worktrees when we're not actually doing parallel work..."

## Recorded defaults

Do not add a separate cumulative assistant-side goal/token ceiling that stops work already authorized by the owner. Keep assistant/session context management separate from explicit project source, effort, reserve, and safety limits; those project limits remain binding unless the owner changes them. When a project budget needs a change, measure the complete remaining authorized scope once and present one viable bounded plan instead of a sequence of small extensions. For serial work, stay in the current checkout; use another worktree only for real parallel work or a concrete isolation need.
