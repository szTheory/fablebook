# 0007. Version floors: Elixir 1.18 / OTP 27, Phoenix ~> 1.8.16, LiveView ~> 1.2.9

**Status:** Accepted · **Cites:** INT-20261028-01 ("we dont have to worry about anything legacy")

## Context
As of 2026-10-28 the latest releases are Phoenix 1.8.16 and LiveView 1.2.13. LiveView 1.2.7 and 1.2.9 were security releases. Elixir 1.18 ships `JSON` in the standard library. LiveView 1.2 adds ColocatedCSS and `:colocated_assets`, and aligns `:global` attrs with MDN (a breaking change).

## Decision
- **Floor lane:** Elixir 1.18 / OTP 27, Phoenix 1.8.16 and LiveView 1.2.9, pinned by `mix.floor.lock`.
- **Latest lane:** Elixir 1.19 / OTP 28, with the versions from `.tool-versions`.
- **Canary (nightly):** LiveView `main` and the latest `phx.new`.
- No support for LiveView 1.1. The owner's dogfood hosts (accrue_admin, scrypath_ops, the mailglass demo and threadline, on 1.1.31–1.1.33) upgrade before dogfooding. **This upgrade path is the recommendation pending owner confirmation (OPEN-QUESTIONS Q2);** the floor itself is accepted.
- Floors are raised only in a minor release, and the change is announced.

## Reversal trigger
A dogfood host can't move to LiveView 1.2 within the roadmap. That would be an owner decision (OPEN-QUESTIONS Q2).
