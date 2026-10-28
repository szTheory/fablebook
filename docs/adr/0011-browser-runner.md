# 0011. Browser runner: phoenix_test_playwright, with a runner-agnostic probe and a spike-backed reversal trigger

**Status:** Accepted (provisional pending the phase-1 spike) · **Cites:** INT-20261028-05, INT-20261028-01

## Context
The owner's other libraries run JS `@playwright/test` with axe against host apps. phoenix_test_playwright (0.16.x) keeps everything in ExUnit and reads the manifest from Elixir directly. Its `assert_screenshot/3` supports `:mask`, `:animations`, `:threshold` and `:max_diff_pixels`, but by default it **auto-accepts a missing baseline**. The owner asked: "follow ur rec now then if we get signals … port later?" The answer is yes.

## Decision
- Use phoenix_test_playwright as an optional dev/test dependency, wrapped by `Fablebook.Test.Visual`.
- The **probe JS** (`priv/static/fablebook-probe.js`, `window.__fablebook.probe()`) and the **Evidence JSON schema** are runner-agnostic. Any runner just navigates, calls the probe, and captures.
- The **phase-1 spike** runs both runners against these criteria:
  1. ARIA snapshot access;
  2. byte-identical screenshots, 3 captures, in the pinned `mcr.microsoft.com/playwright:vX-noble@sha256` container;
  3. a `securitypolicyviolation` listener;
  4. WebSocket frame byte counts;
  5. axe injection under a strict nonce CSP;
  6. sharding.
- Guards against auto-accepted baselines:
  - fail if the baseline is missing when `CI=true`;
  - fail if `git status --porcelain test/__screenshots__` is non-empty after the run;
  - fail if the baseline set doesn't equal the manifest's visual selection.

## Rejected for now
- A generated `@playwright/test` spec (`mix fablebook.gen.runner`): it means a second runner and test code in Node. It remains the fallback.
- An Elixir CDP client: reimplements Playwright.

## Reversal trigger
Any spike criterion is blocked, or needs more than about 50 lines of workaround, or there are 2 or more upstream bugs blocking us for over 2 weeks. If triggered, port to a generated JS spec. The probe and schema stay unchanged.
