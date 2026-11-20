# Phase 7: Guard Scope Reconciliation

**Result:** `reconciled_with_explicit_source_gaps`

## What this establishes

This phase reconciles one proposed evidence family and its full complement across the pinned core and floor lanes. The family is evidence scope only; no code candidate was selected, no implementation was authorized, and the aggregate gate remains open.

- Core: 7 family memberships; 1756 complement memberships out of 1763; membership digest `be2e44b8f59c2121ba7b8c8c358baed7cd355de6cceba419c40034e34c140327`.
- Floor: 7 family memberships; 1711 complement memberships out of 1718; membership digest `7777eccd50d42a1d38acaba73b0ac6cc7e699ff09e4cd5b9c595890cfb8aaef2`.
- Exact read-time schedule: `e8fe99a560ee3edc63fe2ffa9bbfd5bf5978f9b8f036abef2aa1c1a35a9c8e8c`; schedule review `afd1298d630669c4e367857c48205b14039c67c0b644ae2b31c0159a193fc738`; approval `23bc39bc8637e7757ee07d40fb2ff0c088668e86bbc8a50919c3d9c12458e411`.
- Local home paths are shortened to `~/` in delivered files. The [path-redaction receipt](../../07-REDACTION-RECEIPT.json) binds the original read-time schedule to its redacted form (`34ac655df3883f145821e7a59c2f494dc8641f0b4b48e1e4cc82da07d1328c6b`).
- The selected family is CN-002 through CN-006. CN-001 remains in the complement because neither lane has a live MFA for it. The EX-124/125 cross-references remain unresolved context and were not added to the family or source schedule.

## Bounded source observations

The schedule covered 10 exact files totaling 275031 stat-sized bytes. Outcomes: 4 parsed, 3 parser failures with a captured hash, 1 parser failure without retry, and 2 batch-stopped requests without durable observations.
Captured source hashes cover 218450 bytes. 56581 scheduled bytes have no captured source hash. These are byte-size estimates, not token measurements: all scheduled files are estimated at 61118–91677 tokens; hash-captured files at 48544–72817 tokens.

| Request | Lane | Status | Exact source path | Source SHA-256 |
|---|---|---|---|---|
| `core-source-01` | core | `parse_failed_no_retry` | `~/.asdf/installs/elixir/1.20.4-otp-29/lib/elixir/lib/regex.ex` | `not captured` |
| `core-source-02` | core | `batch_stopped_no_retry` | `~/projects/fablebook/_build/lanes/core/deps/phoenix/lib/phoenix/digester.ex` | `not captured` |
| `core-source-03` | core | `batch_stopped_no_retry` | `~/projects/fablebook/_build/lanes/core/deps/phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex` | `not captured` |
| `core-source-04` | core | `parsed` | `~/projects/fablebook/_build/lanes/core/deps/plug/lib/plug/builder.ex` | `8d1b87dd51870df64b20e0ad203a18f072ecb47a15f11132e75e3e0ca47f766b` |
| `core-source-05` | core | `parse_failed` | `~/.asdf/installs/erlang/29.1.2/lib/stdlib-8.1.1/src/re.erl` | `4f121979023d8e5011d2e026600250dedd284c3a5b909e38688efd34d5b74128` |
| `floor-source-01` | floor | `parse_failed` | `~/.asdf/installs/elixir/1.18.5-otp-27/lib/elixir/lib/regex.ex` | `7e31bdf96292d100598c520338dc757d28cbb2cf0cbfa3a53e23a672268885bf` |
| `floor-source-02` | floor | `parsed` | `~/projects/fablebook/_build/lanes/floor/deps/phoenix/lib/phoenix/digester.ex` | `01bc50dc2769f1e6e7dcbef274cb5bbe5f93b5edee6afff58cf85b6d78731d75` |
| `floor-source-03` | floor | `parsed` | `~/projects/fablebook/_build/lanes/floor/deps/phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex` | `06d0272db64b5d72559198114825b17d2b6b50e181993e81ef85db53163961eb` |
| `floor-source-04` | floor | `parsed` | `~/projects/fablebook/_build/lanes/floor/deps/plug/lib/plug/builder.ex` | `8d1b87dd51870df64b20e0ad203a18f072ecb47a15f11132e75e3e0ca47f766b` |
| `floor-source-05` | floor | `parse_failed` | `~/.asdf/installs/erlang/27.3.4.9/lib/stdlib-6.2.2.3/src/re.erl` | `25b7b7cde4828533a241cf84d7b3b08617f57ddda31e7a2b7a4c4fd57452f742` |

3 consumed requests have no durable source hash or spans and were not reopened:
- `core-source-01` (`parse_failed_no_retry`, ObserverError): unbalanced delimiter STOP `609d035c28cdd0b351273d83e2fd30674bc2fa63f57f63a55512446dada6eec4`, marker `810a5f74c46afe81426e5e25cb7e29447ae0401028e799f1fb3cae396fb7fe4a`, review `d75119bb910ac98740eeb8fa6b388d4871e05774dc410870c7ca41d5edd2024a`.
- `core-source-02` (`batch_stopped_no_retry`, BatchOutputLost): No durable observation was written before the batch stopped on core-source-03. STOP `b24c444733f896db8898266cf89dc7b7431a8fe9e27149ea4e336254b7fb9cb4`, marker `36f8039b02f9c0feac2ed7eba8728f9874d64dcf3f2517076e8206c05f2a12c4`, review `39ae7c1356f7d8b8ace6472eb84b1f2a7ec1c4a235223e42b4240dc274262234`.
- `core-source-03` (`batch_stopped_no_retry`, SelectorKeyNormalizationMismatch): Reader lookup used the Elixir-prefixed MFA key, but parser result keys had the prefix normalized. STOP `b24c444733f896db8898266cf89dc7b7431a8fe9e27149ea4e336254b7fb9cb4`, marker `52a70e1f5f91c69dd549da161301abc88dac466bbb281bdf49c2f37d7f3b571b`, review `39ae7c1356f7d8b8ace6472eb84b1f2a7ec1c4a235223e42b4240dc274262234`.

Static observations are limited to recognizable references in each exact file. They do not establish package-wide caller closure. Dynamic dispatch, external callers, callbacks, aliases/imports, macros, generated code, and unsupported syntax remain gaps where listed in the observation records.

## Refreshed effort and fixed limits

Estimated total effort is 5.0 hours (range 4.0–8.0). Active elapsed time was not measured. The observation cap remains five files per batch and 2 MiB per file; requests are one-use, source truncation is forbidden, runtime APIs and generated code were not used, package-wide search was not performed, and R9 remains unconsumed.

## Preserved stops

- Candidate fit unresolved; candidate remains null.
- Aggregate gate open; guard implementation unauthorized.
- R9 denied and not consumed; SEC-01 Pending; actual library collision unknown under the existing owner stop.
- Macro caller-AST and macro explanation remain unresolved; legacy digest unresolved.
- Walking Skeleton remains blocked; automatic follow-up disabled.

## Recommendation and owner decision

Keep the candidate null and aggregate gate open. Three scheduled requests lack durable source hashes and spans, and the reader's module-key normalization mismatch prevented durable spans for one scheduled file. This bounded evidence does not support implementation. Stop here for the owner to decide whether a separately scoped evidence increment is worthwhile; all consumed requests remain closed.

**Owner decision:** After reviewing these explicit source gaps and the complete complement, should any further guard increment be authorized?
