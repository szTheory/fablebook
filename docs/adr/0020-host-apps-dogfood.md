# 0020. Host apps for CI ("digital twins in CI") and the dogfood plan

**Status:** Accepted · **Cites:** INT-20261028-01 ("digital twin in the ci itself … dont want to over do it")

## Decision
The host apps live in `hosts/`. They have no Ecto, depend on Fablebook via `{:fablebook, path: "../.."}`, and each has its own lockfile and cache key. They are named "host apps" so that **Twin** stays reserved for the fictional organizations in a canon (see GLOSSARY).

1. **`hosts/vanilla`**: literal `phx.new 1.8.16 --no-ecto --no-mailer` output with daisyUI and the installer applied. It drives the floor lockfile, the installer goldens and the clean-room shape. The PR lane runs compile plus 2 smoke specs.
2. **`hosts/operator`**: the adversarial host. It has:
   - custom Tailwind v4 `@theme` tokens, with no daisyUI;
   - self-hosted fonts (the regression case for the serif override);
   - a mount at `/admin/dev/fablebook`;
   - a strict nonce CSP;
   - a custom root layout;
   - `current_scope` `on_mount`;
   - colocated hooks, JS commands and `<.portal>`;
   - streams and async assigns;
   - `to_form`, `:let` slots, and LiveComponents with no attr declarations;
   - Gettext with an RTL locale;
   - a design canon, including an abracabrand-shaped brandbook fixture.

   The PR E2E suite, the visual-core suite and the prod-guard build all run against it.

The five showcase twins (`docs/research/TWINS.md`) live in `hosts/operator`, one Book per product (seven Books; Logistify has three) with its own theme and canon. Shared stories live in `hosts/shared/stories/`. Bomb components and the N-scenario generator live in `test/support/`. There is no third app.

## Dogfood plan
A **skeleton** `hosts/operator` exists from phase 1 (nested `/admin/dev/fablebook` mount, strict nonce CSP, self-hosted fonts, custom tokens) so the prod-guard build, PR E2E and visual-core have an adversarial target from day one; the canvas-fidelity phase fills in the rest of the list above. CI jobs: `core` compiles both host apps; `e2e` runs the vanilla smoke specs and the operator specs plus visual-core. In the dogfood phase:
1. migrate the **mailglass demo** (it has the most stories and the methodology);
2. then **accrue_admin**;
3. then scrypath_ops and threadline.

The LiveView 1.2 upgrade comes first (ADR 0007). Clearance is defined in `.planning/intent/CLEARANCE.md`.
