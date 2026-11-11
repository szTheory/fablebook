---
id: SEED-261111-80s
status: dormant
planted: 2026-11-11
planted_during: v0.2 guard-recovery Phase 1 execution
trigger_when: Before Workbench UX Phase 1 or any later README, docs, catalog chrome, package-listing or social-card brand work; use the verified 2.1 source and surface-specific asset mapping
scope: Brand-source review and future surface-specific planning; implementation remains for its owning future phase
target_milestone: workbench
target_phase: 1
---

# SEED-261111-80s: Use the Fablebook brand source in future product surfaces

## Why This Matters

Fablebook has an upstream brand book that can guide the catalog and public-facing assets. Version 2.1 is verified at upstream commit b2e3441218f9d62f857ab9ff7b4b62fdc320078c; the initial 2.0 mismatch is resolved. The current glossary and accepted UX ADRs also conflict with the newer product vocabulary. Capturing the source and conflict list now keeps later changes evidence-based and prevents this intake from starting a product phase.

## When to Surface

**Trigger:** Before planning Workbench UX Phase 1 or changing Fablebook's README, docs, catalog chrome, package listing or social card. Surface again for Design canon Phase 4 and Installer and DX Phase 3 when those surfaces are in scope.

Read .planning/references/fablebook-brand-intake.md and INT-20261111-06 first. Use the verified source, surface product-model conflicts, and map asset destinations before applying them.

## Scope Estimate

The provenance, owner direction and conflicts are captured. The eventual implementation slice must be scoped by the future phase that owns the affected surface. This seed does not create a phase, update the product roadmap or change current requirements.

## Breadcrumbs

- .planning/references/fablebook-brand-intake.md — source provenance, version mismatch, conflict matrix and asset limits.
- .planning/intent/sources/2026-11-11-06-fablebook-brand-intake.md — settled owner direction and open decisions.
- .planning/references/PRODUCT-ROADMAP.md — Workbench UX, Design canon, and Installer and DX future phases.
- GLOSSARY.md, docs/adr/0012-canon-format.md, docs/adr/0013-workbench-ux.md, docs/adr/0023-vocabulary-scenario-and-tiers.md — current terms and accepted UX/data contracts.

## Notes

Read the upstream source at its pinned repository commit; do not treat a local copy as product content. Keep source recommendations distinct from owner decisions, verify every product claim against shipped behavior, and map actual asset destinations and record publication rights limits for the surface being changed.

Owner decision INT-20261111-07: wait for 2.1 and keep the intake and assets staged. This hold does not pause guard Phase 1.

Refresh INT-20261111-08: verified upstream 2.1 satisfies the earlier version wait. Do not reopen that resolved discrepancy; asset application remains for the surface-owning work.
