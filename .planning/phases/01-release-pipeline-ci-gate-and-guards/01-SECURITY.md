---
phase: "01"
slug: release-pipeline-ci-gate-and-guards
status: verified
threats_open: 0
asvs_level: 1
register_authored_at_plan_time: true
created: "2026-10-30T02:21:07Z"
---

# Phase 1 security disposition

L1 verification of the authored PLAN threat registers, performed inline under the skill adapter. This checks existing mitigations and prior acceptances; it is not a new penetration audit or a claim that transferred security work is complete. Current evidence: `01-UAT.md`, `01-LIVE-EVIDENCE.json`, fresh `mix ci` (257 passed), and follow-up Phase 01.1.1 verification.

## Trust Boundaries

| Boundary | Control |
|---|---|
| Host router to production build | Returned CompileError; clean dev/prod fixture controls |
| Library source to compiled/runtime code | Source/BEAM bans, generated probes, dependency closure |
| PR contents to CI gate | Intent integrity, contract pairing and CI shape checks |
| CI runner to publication | Pinned actions, clean release setup, main-commit provenance and checksum |
| GitHub/Hex metadata to evidence | Fail-closed reads; isolated external-write seams; current vs historical evidence labels |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation evidence | Status |
|---|---|---|---|---|---|---|

| T-01-01 | Elevation of privilege | lib/fablebook/router.ex prod branch | high | mitigate | lib/fablebook/router.ex; prod_guard_test.exs dev/prod/unguarded integration; fresh mix ci; main CI floor. Story exclusion is the host fixture precondition (AR-01.1-03). | closed |
| T-01-02 | Information disclosure | storybook/ beams in a prod build | high | mitigate | lib/fablebook/router.ex; prod_guard_test.exs dev/prod/unguarded integration; fresh mix ci; main CI floor. Story exclusion is the host fixture precondition (AR-01.1-03). | closed |
| T-01-03 | Tampering | Mix.env() hoisted into a module attribute | high | mitigate | lib/fablebook/router.ex; prod_guard_test.exs dev/prod/unguarded integration; fresh mix ci; main CI floor. Story exclusion is the host fixture precondition (AR-01.1-03). | closed |
| T-01-04 | Tampering | nested mix inherits MIX_* vars | medium | mitigate | test/support/mix_cmd.ex explicitly scrubs each planned variable and sets MIX_ENV; nested host integration passes. | closed |
| T-01-05 | Information disclosure | CompileError text names the host app and router file | low | accept | Compiler diagnostics are developer-visible only; accepted by original plan. | closed |
| T-01-06 | Repudiation | owner sign-off paraphrased | medium | mitigate | INT-20261028-18 and 01-05-SUMMARY owner checkpoints preserve prior explicit approval; intent add-only/citation tests pass. No automated replacement of owner judgment. | closed |
| T-01-38 | Repudiation | auto-mode selecting a sign-off option | high | mitigate | INT-20261028-18 and 01-05-SUMMARY owner checkpoints preserve prior explicit approval; intent add-only/citation tests pass. No automated replacement of owner judgment. | closed |
| T-01-SC | Tampering | Hex installs (mix deps.get) | high | mitigate | Committed lockfiles; setup uses deps.get --check-locked; pinned phx_new smoke; historical package audit and current main security job. | closed |
| T-01-07 | Tampering | `${{ }}` in `run:` (template injection) | high | mitigate | Pinned .github workflow/action contents and passing ci_shape_test mutations; main security job success. Live repo SHA pinning true, default workflow permissions read, no workflow approval privilege. | closed |
| T-01-08 | Tampering | mutable action refs, impostor commits | high | mitigate | Pinned .github workflow/action contents and passing ci_shape_test mutations; main security job success. Live repo SHA pinning true, default workflow permissions read, no workflow approval privilege. | closed |
| T-01-09 | Tampering | cache poisoning into a release | high | mitigate | Pinned .github workflow/action contents and passing ci_shape_test mutations; main security job success. Live repo SHA pinning true, default workflow permissions read, no workflow approval privilege. | closed |
| T-01-10 | Spoofing | leaked or over-broad HEX_API_KEY | high | mitigate | hex-production secret name/timestamp re-read: HEX_API_KEY updated 2026-10-29T02:15:03Z. Prior package-only rotation/revocation attested in 01-05-SUMMARY and INT-20261028-20; not independently reverified. Workflow restricts key to key-check and publish steps. Separate tag-policy residual remains Q37. | closed |
| T-01-11 | Elevation of privilege | GITHUB_TOKEN default write | medium | mitigate | Pinned .github workflow/action contents and passing ci_shape_test mutations; main security job success. Live repo SHA pinning true, default workflow permissions read, no workflow approval privilege. | closed |
| T-01-12 | Information disclosure | checkout credential persistence | medium | mitigate | Pinned .github workflow/action contents and passing ci_shape_test mutations; main security job success. Live repo SHA pinning true, default workflow permissions read, no workflow approval privilege. | closed |
| T-01-13 | Information disclosure | PII or home paths published with the repo | high | mitigate | tarball_test exact file/privacy contracts pass; release workflow reads secrets only through GitHub env, no secret values read in this audit; scoped changed-file privacy check before commit. | closed |
| T-01-14 | Elevation of privilege | RELEASE_PLEASE_TOKEN scope | medium | mitigate | 01-05-SUMMARY records fine-grained repository PAT setup; successful release-please main run 40987211854 supports operation, not independent proof of token scope. | closed |
| T-01-15 | Tampering | ci-gate passing with an empty or partial needs set, `if: always()` removed or a neutered step | high | mitigate | ci_shape_test pins needs/always/gate/test wiring and mutation cases; all-checks merge rule in ADR 0017; accepted residual T-01-37 remains. CI-health scheduled shape scan is present. | closed |
| T-01-37 | Elevation of privilege | any PR (agent- or human-merged) that neuters the test steps of core and floor and also edits ci-health's shape step | medium | accept | Owner explicitly accepted the PR-defined gate/test-neutering residual in INT-20261028-18; Q35 remains the separate possible expansion. | closed |
| T-01-16 | Tampering | publish of a non-reproducible or different artifact | high | mitigate | hex_publish_test executes actual ancestry/commit/checksum/recovery shell steps; historical green release 40803980465 and live Hex checksum. Original publication approval recorded in 01-05-SUMMARY. No new publish. | closed |
| T-01-17 | Tampering | runtime eval in lib/ | critical | mitigate | banned_calls_test, tier_sweep_test and Credo fixtures/generated probes pass in fresh mix ci. Phase 01.1.1 verified source and BEAM fixes. Explicit broader transferred guarantees remain 01.1.1.1; SEC-01 completion remains Phase 5. | closed |
| T-01-18 | Denial of service | atom-table exhaustion from input | high | mitigate | banned_calls_test, tier_sweep_test and Credo fixtures/generated probes pass in fresh mix ci. Phase 01.1.1 verified source and BEAM fixes. Explicit broader transferred guarantees remain 01.1.1.1; SEC-01 completion remains Phase 5. | closed |
| T-01-19 | Tampering | guard silently passing on stripped beams | medium | mitigate | banned_calls_test, tier_sweep_test and Credo fixtures/generated probes pass in fresh mix ci. Phase 01.1.1 verified source and BEAM fixes. Explicit broader transferred guarantees remain 01.1.1.1; SEC-01 completion remains Phase 5. | closed |
| T-01-20 | Tampering | `credo:disable` used to bypass source bans | medium | mitigate | banned_calls_test, tier_sweep_test and Credo fixtures/generated probes pass in fresh mix ci. Phase 01.1.1 verified source and BEAM fixes. Explicit broader transferred guarantees remain 01.1.1.1; SEC-01 completion remains Phase 5. | closed |
| T-01-21 | Tampering | banned or unexpected dep in the prod closure | high | mitigate | dependency_budget_test validates exact runtime set and metadata BFS with positive/negative controls in fresh mix ci. | closed |
| T-01-22 | Information disclosure | test/, .planning/ or home paths shipped in the tarball | high | mitigate | tarball_test exact file/privacy contracts pass; release workflow reads secrets only through GitHub env, no secret values read in this audit; scoped changed-file privacy check before commit. | closed |
| T-01-23 | Tampering | inline style attributes defeating the future canvas CSP | low | mitigate | style_attr_test scans lib/ and passes; canvas runtime CSP receipt belongs to its later phase. | closed |
| T-01-24 | Tampering | edits to intent sources | high | mitigate | intent_test and contract_rule_test pass, including real temporary git repos and CI diff-base fail-closed controls. Historical intent red run 40802432347 failed and PR #4 remains closed/unmerged. | closed |
| T-01-25 | Repudiation | guard weakened together with its implementation | high | mitigate | intent_test and contract_rule_test pass, including real temporary git repos and CI diff-base fail-closed controls. Historical intent red run 40802432347 failed and PR #4 remains closed/unmerged. | closed |
| T-01-26 | Elevation of privilege | ci-gate bypass via needs drift, `if: always()` removal or bypass idioms | high | mitigate | ci_shape_test pins needs/always/gate/test wiring and mutation cases; all-checks merge rule in ADR 0017; accepted residual T-01-37 remains. CI-health scheduled shape scan is present. | closed |
| T-01-27 | Repudiation | unresolvable diff base passing silently | medium | mitigate | intent_test and contract_rule_test pass, including real temporary git repos and CI diff-base fail-closed controls. Historical intent red run 40802432347 failed and PR #4 remains closed/unmerged. | closed |
| T-01-28 | Tampering | making the guards vacuous through test/support, test_helper, `test_ignore_filters` or the `ci` alias (outside the D-21 guard paths) | medium | mitigate | ci_shape_test pins needs/always/gate/test wiring and mutation cases; all-checks merge rule in ADR 0017; accepted residual T-01-37 remains. CI-health scheduled shape scan is present. | closed |
| T-01-29 | Information disclosure | local-only gitignored files changing results | low | mitigate | intent_test and contract_rule_test pass, including real temporary git repos and CI diff-base fail-closed controls. Historical intent red run 40802432347 failed and PR #4 remains closed/unmerged. | closed |
| T-01-30 | Tampering | `GITHUB_EVENT_NAME` or `EVENT_BEFORE` forged by a PR | low | accept | Runner event env is trusted within the owner-approved CI model; shape tests guard the workflow. | closed |
| T-01-31 | Tampering | publishing an unintended artifact | high | mitigate | hex_publish_test executes actual ancestry/commit/checksum/recovery shell steps; historical green release 40803980465 and live Hex checksum. Original publication approval recorded in 01-05-SUMMARY. No new publish. | closed |
| T-01-32 | Spoofing | over-broad Hex key left in CI | high | mitigate | hex-production secret name/timestamp re-read: HEX_API_KEY updated 2026-10-29T02:15:03Z. Prior package-only rotation/revocation attested in 01-05-SUMMARY and INT-20261028-20; not independently reverified. Workflow restricts key to key-check and publish steps. Separate tag-policy residual remains Q37. | closed |
| T-01-33 | Information disclosure | secret values in logs or docs | high | mitigate | tarball_test exact file/privacy contracts pass; release workflow reads secrets only through GitHub env, no secret values read in this audit; scoped changed-file privacy check before commit. | closed |
| T-01-34 | Tampering | the D-22 edit reaching main | medium | mitigate | Live PR #4 state closed, merged_at null; intent sources in the current change are additions only. | closed |
| T-01-35 | Denial of service | PAT expiry silently stopping releases | low | accept | PAT expiry risk accepted by original plan and owner sign-off; visible failures retained. A separate expiry reminder is not independently evidenced. | closed |
| T-01-36 | Elevation of privilege | ruleset drift after setup | medium | mitigate | Live required contexts exactly [ci-gate]; new ci_health_test drift cases and live script read pass; weekly scan remains scheduled. First Monday observation is pending in UAT test 13. | closed |
| T-01-39 | Tampering | a merge on ci-gate alone after a PR rewrote ci-gate | high | mitigate | ci_shape_test pins needs/always/gate/test wiring and mutation cases; all-checks merge rule in ADR 0017; accepted residual T-01-37 remains. CI-health scheduled shape scan is present. | closed |
| T-01-40 | Information disclosure | SUMMARY or amendment files pushed with PII | high | mitigate | tarball_test exact file/privacy contracts pass; release workflow reads secrets only through GitHub env, no secret values read in this audit; scoped changed-file privacy check before commit. | closed |
| T-01-41 | Repudiation | amendments merged without the owner seeing them | medium | mitigate | INT-20261028-18 and 01-05-SUMMARY owner checkpoints preserve prior explicit approval; intent add-only/citation tests pass. No automated replacement of owner judgment. | closed |

## Accepted Risks Log

| Threat | Existing acceptance | Scope |
|---|---|---|
| T-01-05 | Original plan | Developer-visible compiler location/app name |
| T-01-30 | Original plan and INT-20261028-18 | Trusted runner event inputs |
| T-01-35 | Original plan and INT-20261028-18 | PAT expiry visible failure; reminder not independently verified |
| T-01-37 | INT-20261028-18 | A PR can neuter both checks and their tests; no new acceptance here |

INT-20261028-20 also accepts the non-expiring package-only Hex key. Key scope/revocation are prior owner attestations. Q35–Q37 remain existing open decisions; this report does not settle them or reopen their prompts. Parser/unswept-OTP/exclusion work is a binding Phase 01.1.1.1 transfer, with Phase 5 owning SEC-01 completion.

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open at high+ | Run By |
|---|---|---|---|---|
| 2026-10-30 | 42 unique (T-01-SC repeated across plans) | 42 within authored scope | 0 | Codex, inline L1 |

All authored threats have dispositions and cited controls or prior acceptances. `threats_open: 0` describes the phase register, not an unconditional security guarantee. Scheduled timing observation and canonical phase execution verification remain separate gates.
