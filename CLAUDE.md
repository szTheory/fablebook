# Fablebook: agent instructions

## Read first, every session that plans or reviews
1. `.planning/intent/NORTH-STAR.md` and `.planning/intent/CLEARANCE.md`
2. `GLOSSARY.md`, the only source of vocabulary. Never call a scenario a "variant" or "variation".
3. `docs/adr/README.md` (locked decisions)
4. `.planning/VERIFICATION.md` when discussing, planning, executing, reviewing, verifying or resuming work; automate acceptance checks and reuse recorded evidence before handing work to the owner.
5. `.planning/references/MILESTONE-START-RESEARCH.md` whenever starting or recommending a milestone; it defines the evidence-first fan-out, rolling roadmap, and product-progress vocabulary.

GSD researchers, synthesizers and the roadmapper also read `FABLEBOOK-SEED.md`, `docs/adr/*` and `docs/research/*` before writing anything. Every REQ keeps its INT/ADR citations.

## Precedence
Verbatim intent (`.planning/intent/sources/`) > ADR > REQUIREMENTS > PROJECT. When a plan conflicts with intent, add an entry to `.planning/intent/OPEN-QUESTIONS.md`. Never reinterpret the owner's words.

## Recording intent
When the owner gives direction, add a verbatim entry to `.planning/intent/sources/` (`id: INT-YYYYMMDD-NN`, `date`, `source`, `captured_by`, `context`). Entries are add-only. Corrections use `supersedes:`.

At every new-milestone start, reconcile delivery receipts and gates, fan out bounded research across relevant lenses with an adversarial pass, prefer primary sources, synthesize one immediate recommendation, and refresh the directional rolling roadmap before executable GSD work. Keep future work directional until separately activated and its typed prerequisites pass. Distinguish sourcebooks, applied canon, Fablebook Books/scenarios, runnable demos, and adopter dogfood in progress reports.

## Non-negotiables
- Never lower a quality gate to finish a phase. Split the phase instead.
- No runtime eval, and no atoms created from input (ADR 0004).
- Copy-paste beats a new dependency. A new dependency needs an ADR. Adopters never need Node (ADR 0018).
- Push early. Every phase ends in a merged green PR. Evidence means a CI run link, not prose.
- End every GSD flow with the next command and its purpose, including partial/blocked flows (INT-20261029-09).
- Report model profiles and effort levels only when the owner asks; omit routine GSD model-routing footers (INT-20261029-11).
- Never edit a contract test in the same PR as the implementation it guards (definition and enforcement: ADR 0021).
- Never auto-accept a visual baseline.
- No PII in git: no email addresses, no absolute home paths (write `~/`).
- Code is idiomatic, minimal and self-documenting. No comments that restate the code.

## Execution preferences
- Prefer a clear, opinionated default; optimize the adopter's DX and UX, use idiomatic Elixir, and keep useful investigation evidence.
- Before long tests or suites, run cheap consistency checks that can catch malformed inputs or artifacts early. When repeated retries or gates stall progress, identify the narrow bottleneck and replan within the approved limits before repeating costly work.
- For serial work, stay in the current checkout. The --ws flag selects a logical GSD workstream; it does not switch the filesystem checkout or Git branch. Use another worktree only for actual parallel work or a concrete isolation/preservation need, and leave dirty recovery checkouts intact.
- Follow .planning/VERIFICATION.md by default: automate objective acceptance checks, reuse fresh evidence when guarded inputs have not changed, and keep human UAT for irreducible judgment or owner authority. Keep later product decisions as recorded stops when they are outside the current phase result. Use local throwaway checks for one-off questions; add recurring CI checks only when their value justifies their maintenance.
- After each completed CI or release run, review measured queue and critical-path time, repeated work and setup; record a measured improvement or why none is safe. Preserve all gates and coverage. See .planning/CI-PERFORMANCE.md.
- Do not impose an assistant-side cumulative token ceiling or reserve by default. The model's per-request context limit still applies; continue long work across requests and preserve progress in project artifacts. If the owner explicitly sets a cumulative budget for a task, meter each participating session from the newest `payload.thread_token_usage` record in its local JSONL, compare the same fields, and keep one ledger of thread ID, log, timestamp, and input/output baseline. Never mix this with `info.total_token_usage` or estimate tokens from characters. Include expected context/setup, task work, review, and contingency before dispatch; at each boundary, wait for child counters to flush and reconcile the measured totals. A missing measurement does not create a new limit or renew an existing one.
- Explain risks and decisions in plain, concrete language. Prefer local contract tests and dry-runs when they establish the same behavior; do not change public release state just to create a test case. (INT-20261108-01)
- Before hosted CI, run the relevant GitHub Actions locally with `act` whenever feasible to catch failures and reduce CI work. Local `act` results supplement, but do not replace, required hosted receipts.
- The owner has granted standing authorization across Fablebook OpenGSD phases, plans, and milestones to publish reviewed/tested phase candidates by pushing the phase branch and opening or updating a PR to trigger hosted CI, without asking for permission again each time (INT-20261109-01). Follow existing branch protection and phase delivery gates; this does not authorize unrelated releases or production deployments.
- When the owner says green required CI is enough to merge, squash-merge a completed PR without asking for another review prompt, pinned to the exact reviewed head. Never bypass required checks, branch protection, or a merge queue; if the head changes or a required check is not green, diagnose that state before merging.
- Put cheap, scope-relevant consistency checks before long verification. For shipping, if a note commit changes a PR head after CI starts, treat the earlier checks as stale and require one green run on the final head. Avoid `[ci skip]` plus empty-commit recovery when branch protection requires checks; use a single normal note commit and track that final head.
- Record exact-head hosted CI durations and compare repeated runs before changing the pipeline. Preserve coverage; only change caching or job structure when measurements show a safe reduction in the critical path.
- Once a phase is approved, complete its required local validation and bookkeeping without asking about routine steps. Ask only for a real scope change or an external action not covered by standing authorization. End with one exact next command and its purpose.
- For a single read-only inspection of a local repository file needed by an already authorized task, do not ask for separate per-file approval. Keep the read within the task boundary; this does not authorize executing code, writing evidence, accessing target source bodies, or crossing a recorded gate.
- Within an already owner-authorized phase, treat routine bounded dependency-security evidence refreshes, local validation, and bookkeeping as authorized; do not ask for repeat confirmation at each step. This does not lift a recorded source/request cap, reopen a denied request, authorize target-body/API access, weaken a gate, or cross a real phase boundary. Complete the authorized scoping first and bring one concrete decision only when an explicit stop would otherwise be crossed.
- For serial GSD work, stay in the current checkout; `--ws` is a logical workstream selector, not filesystem isolation. Use another worktree only for actual parallel work or a concrete isolation need. Do not impose an additional assistant-side cumulative token ceiling on approved project work; keep it separate from the project's explicit source, effort, reserve and safety limits. If a project limit needs to change, measure all remaining authorized work once and propose one complete bounded option.
- Preserve recovery worktrees and investigation artifacts unless their disposition is explicitly changed. Delegate only when the workflow and runtime allow it and authorization is present.
