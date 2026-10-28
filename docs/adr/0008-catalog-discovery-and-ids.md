# 0008. Catalog is a pure function; ids derive from module and function names

**Status:** Accepted · **Cites:** INT-20261028-04

## Context
phoenix_storybook's problems here:
- its enumeration API exists only in dev;
- children of a VariationGroup have no URL;
- its ids are path-derived, which is fragile on Windows.

`__components__/0` is undocumented, sorts attrs and slots by name rather than declaration order, and lists only functions that declare an `attr` or `slot`.

## Decision
- **Catalog build.** `Fablebook.Catalog.build(book)` filters `Application.spec(otp_app, :modules)` by namespace, loads each module, and checks `function_exported?(m, :__fablebook_story__, 0)`. It behaves identically in dev and test. Each story's data is compiled into its own `__fablebook_story__/0`; the catalog is assembled from those once per workbench LiveView mount and held in assigns (the sidebar renders once and never re-renders on control changes). A code-reload notification rebuilds it. No cache process, no ETS, no `:persistent_term` (avoids global GC churn on hot reload).
- **Ids.**
  - Story id is the namespace path, e.g. `deliveries/status_badge`.
  - Scenario id is the function name.
  - URL form: `<mount>/deliveries/status_badge/retrying?scheme=dark&vw=375`.
  - Every scenario has its own URL, including scenarios inside groups. `id:` overrides exist only to handle renames.
  - Ids are injective after slugging, and a collision raises a `CompileError` that names both sources.
- **`__components__` boundary.** `Fablebook.ComponentInfo` is the only module that reads `__components__/0`. It re-sorts by `line`, and it has a contract test on the floor, latest and canary lanes. If that contract breaks, Fablebook falls back to manual controls with a banner. It never crashes.
- **Auto-stories.** Discovery source is the Book's `components:` list (the installer seeds it with the app's CoreComponents and components modules). For each component without a story, required attrs are filled from the attr's `default`, else its first `examples` entry, else its first `values` entry; all three are author-declared, so nothing is invented. If none exists, the component is listed as **Unstoried** with a "Needs a story" tile and a Copy scenario template action.
