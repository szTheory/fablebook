# 0005. Workbench chrome is packaged like LiveDashboard

**Status:** Accepted · **Cites:** INT-20261028-01, INT-20261028-02

## Context
Owner DNA (mailglass_admin, oban_powertools) and LiveDashboard prove the pattern. phoenix_storybook problems this avoids:
- it could not nest under `/dev`;
- it required a separate `storybook.css`/`storybook.js` and a Tailwind build;
- it ignored CSP (#149).

## Decision
- **Mounting:**
  - `import Fablebook.Router` and `fablebook "/fablebook", MyAppWeb.Storybook`. The installer default is `/dev/fablebook` inside `dev_routes` (the Book module).
  - The prefix comes from `Phoenix.Router.scoped_path/2`, so nesting under any scope works.
  - Options are validated by NimbleOptions: `on_mount`, `live_session_name`, `csp_nonce_assign_key`, `as`, `canvas_pipeline`, `canvas_root_layout`.
- **Chrome assets:**
  - `priv/static/fablebook.css` and `fablebook.js` are committed, built in Fablebook's own repo with the standalone `tailwind`/`esbuild` Hex binaries (no Node).
  - They are embedded at compile time (`@external_resource` + `File.read!`), served from MD5-hashed URLs with `immutable` caching, and every inline tag carries a nonce.
  - CI checks the committed bundle against a fresh build and fails on drift.
- **Phoenix JS:** `phoenix.js` and `phoenix_live_view.js` are read from the host's deps via `Application.app_dir`, so client and server versions always match and the tarball stays small.
- **Processes:** zero. There is no application callback and no supervisor (owner rule: no `name: __MODULE__` singletons).

## Rejected
- Requiring host asset pipeline changes.
- daisyUI in the chrome (see ADR 0013).

## Reversal trigger
None expected.
