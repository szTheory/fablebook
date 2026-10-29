# 0007. Version floors: Elixir 1.18 / OTP 27, Phoenix >= 1.8.9, LiveView >= 1.2.9, open below 2.0

**Status:** Accepted · Amended 2026-10-28 (INT-20261028-18) · **Cites:** INT-20261028-01 ("we dont have to worry about anything legacy")

## Context
As of 2026-10-28 the latest releases are Phoenix 1.8.16 and LiveView 1.2.13. LiveView 1.2.7 and 1.2.9 were security releases. Elixir 1.18 ships `JSON` in the standard library. LiveView 1.2 adds ColocatedCSS and `:colocated_assets`, and aligns `:global` attrs with MDN (a breaking change).

## Decision
- **Requirements:** `{:phoenix, ">= 1.8.9 and < 2.0.0"}`, `{:phoenix_live_view, ">= 1.2.9 and < 2.0.0"}` and `elixir: "~> 1.18"`. The resolver never blocks Phoenix 1.9 or LiveView 1.3; the floor lane, the canary lane and the compatibility matrix are the safety net.
- **Floor lane:** Elixir 1.18.5 / OTP 27.3.4.9, Phoenix 1.8.9 (the security floor) and LiveView 1.2.9, pinned by `mix.floor.lock` and selected by `FABLEBOOK_FLOOR`.
- **Latest lane:** Elixir 1.20.4 / OTP 29.1.2, with the versions from `.tool-versions`. The library is warning-free under `--warnings-as-errors` on both lanes.
- **Canary (nightly):** LiveView `main` and the latest `phx.new`.
- No support for LiveView 1.1. The owner's dogfood hosts (accrue_admin, scrypath_ops, the mailglass demo and threadline, on 1.1.31–1.1.33) upgrade before dogfooding. **This upgrade path is the recommendation pending owner confirmation (OPEN-QUESTIONS Q2);** the floor itself is accepted.
- Floors are raised only in a minor release, and the change is announced.

## Reversal trigger
A dogfood host can't move to LiveView 1.2 within the roadmap. That would be an owner decision (OPEN-QUESTIONS Q2).

## Amendments (release pipeline sign-off, 2026-10-28)
- **Ranges (D-16, Q12(a)):** `~> 1.8.16` and `~> 1.2.9` become `>= 1.8.9 and < 2.0.0` and `>= 1.2.9 and < 2.0.0`, so a Phoenix or LiveView minor never strands adopters at the resolver. (INT-20261028-18)
- **Phoenix floor (D-16, Q12(b)):** 1.8.16 becomes 1.8.9, the security floor; at 1.8.16 the floor lane equalled the latest Phoenix and lost its signal. `mix.floor.lock` pins Phoenix 1.8.9 and LiveView 1.2.9. (INT-20261028-18)
- **Latest lane (D-16, Q12(c)):** Elixir 1.19 / OTP 28 becomes Elixir 1.20.4 / OTP 29.1.2; the floor lane runs Elixir 1.18.5 / OTP 27.3.4.9. (INT-20261028-18)
