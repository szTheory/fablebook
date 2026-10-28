# 0016. Telemetry emits only; a closed error set

**Status:** Accepted · **Cites:** INT-20261028-01

## Context
phoenix_storybook #647: its event-log handler was attached to *every* LiveView `handle_event` in the host.

## Decision
- **Spans.** `Fablebook.Telemetry.span/3` wraps `:telemetry.span`. The event catalogue is in `docs/domain/DOMAIN-MODEL.md` §1 and `Fablebook.Telemetry.events/0`.
- **Catalogue test.** It fails on any emitted event that isn't listed, and on any listed event that is never emitted.
- **Metadata whitelist.** Only ids, kinds, counts and enums. A property test rejects any other key. Fixtures may contain realistic PII-like data, so values are never forwarded.
- **No handlers.** Fablebook **never attaches handlers**. It ships a copy-paste `Telemetry.Metrics` recipe for LiveDashboard and takes no `telemetry_metrics` dependency.
- **Logging.** Logger metadata is `domain: [:fablebook]`. The hot path never logs at `:info` or above.
- **Errors.** `%Fablebook.Error{type:}` uses the closed set in DOMAIN-MODEL §2. Declaration mistakes raise `CompileError` with file, line, value and a suggested fix. Error-message snapshot tests guard their wording.
