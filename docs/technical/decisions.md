# Decisions

**The dated why behind each piece of machinery — and what was
rejected.** Append-only history: an entry is never edited, the next one
is added. The living reference — schemas, the selection algorithm,
distribution, the public contract — is [README.md](README.md); this
file is where its shape came from.

- **2026-08-21 — `blocked` is a status, not a folder or a tag.** Consistent
  with "status lives in front-matter" and "identity is never order". Paired
  with mandatory `blocked_reason` so a blocked task always states its own
  unblock condition. Rejected: a separate `blocked/` folder (breaks the
  no-file-moves rule) and overloading `depends_on` with non-task blockers
  (destroys its machine-checkability).
- **2026-08-21 — selection resumes `in-progress` before picking `pending`.**
  Prevents abandoned half-done work from becoming invisible: without this, an
  interrupted agent session leaves a task that no future selection pass will
  ever surface. Ownership is defined per adopter; single-agent setups may
  treat "this session" as the only owner.
- **2026-08-21 — skills install into `.writrun/skills/`, not a top-level
  `skills/`.** Matches the convention already live in both source projects
  (swoop and TOM). Rejected: a dedicated top-level `skills/` — that shape is
  right for a project shipping a skill as a *product feature to its own
  users* (swoop's `bootstrap-taskfile` is the real example), which is not
  what WritRun's four skills are; they operate the methodology on the
  adopting project itself, the same role swoop's `.writrun/skills/` fills for
  swoop.
- **2026-08-21 — `writrun-create-task-and-spec` gains a generator script
  (`new.sh`).** A hand-written task deviated from the documented schema on
  four fields (scalar `spec_ref` instead of a list, a bare filename instead
  of a path+anchor for `doc_ref`, missing `blocked_reason`/`created`/
  `completed`) while drafting this repository's own `product/` chapters —
  direct evidence that prose instructions alone don't reliably prevent this
  class of drift. Rejected: leaving `writrun-create-task-and-spec` prose-only, on
  the same reasoning that already put a script behind `writrun-check-spec-deltas` —
  a mechanically checkable step should be checked mechanically.
- **2026-08-21 — script-backed skills target POSIX `awk`/`sed`, never gawk
  extensions.** `check_deltas.sh` originally used `match($0, re, arr)`, the
  gawk-only 3-arg form, which fails on macOS's stock `/usr/bin/awk` (BWK
  awk) — the default environment for a large share of adopters. Rewritten as
  a portable `awk` + `sed` pipeline, and made a standing rule for both
  scripts: no construct that needs gawk, tested against `/usr/bin/awk` and
  not merely whatever is on `$PATH`. Rejected: declaring gawk a dependency —
  a methodology whose non-goal is "not tied to one language, framework, or
  agent platform" should not require a package install to verify a doc
  change.
- **2026-08-21 — `writrun-check-spec-deltas` normalises promised paths to
  repository-root before comparing.** A spec writes its Proposed-changes
  paths relative to `docs/` (`product/pipeline.md`), while `git diff
  --name-only` reports relative to the repository root
  (`docs/product/pipeline.md`). The two never matched, so every run reported
  every promised path MISSING *and* every touched doc UNDECLARED at the same
  time — the check had never passed and could not have. The script now
  prefixes `docs/` when extracting. Two related changes in the same pass: a
  failing `git diff` exits 3 instead of being swallowed into an empty file
  list that looks like a real "nothing was touched" result, and UNDECLARED
  no longer overwrites a MISSING exit code, since a forgotten doc update is
  the drift this check exists to catch. Rejected: writing Proposed-changes
  paths relative to the repository root instead — the `docs/`-relative form
  is what `doc_ref` already uses, and diverging the two would be a
  second thing to remember.
- **2026-08-22 — a permanent doc changes in two named directions, not one.**
  Calling the docs the input work derives from, and also saying a permanent
  doc changes only through a completed task, are both true of different
  situations — and an adopting project cannot tell which applies without
  being told. Named here: **authoring** (the doc moves ahead of the system,
  no task precedes it) and **loop closure** (a completed task updates the doc
  it derived from, bounded by its spec's contract). "Never a plan" survives
  authoring because the rule is written as a rule and the gap lives in the
  task queue, not hedged in the prose. Rejected: declaring authoring
  illegitimate, which makes the docs a changelog of shipped work and
  contradicts the pipeline's own "input, not a record"; and declaring loop
  closure optional, which removes the merge contract `writrun-check-spec-deltas`
  exists to enforce.
- **2026-08-22 — "ready for development" is derived, never stored.** It is a
  task that is `pending` with every spec in its `spec_ref` `approved` — two
  facts the [selection algorithm](README.md#task-selection-algorithm) already reads.
  A status recording it would duplicate a derivable fact, and a duplicated
  fact eventually disagrees with its source. The same reasoning applies to
  "waiting for review", which is an open pull request and nothing else.
  Rejected: adding `waiting-for-review` and `ready` to the task status
  vocabulary — it puts a forge's own state into a file the forge does not
  write.
- **2026-08-22 — nothing in this methodology reserves a task.** Reserving
  work is a tracker's job, and `docs/about.md`'s non-goals already say so.
  The `in-progress` status cannot serve as a reservation anyway: it rides on
  the worker's branch and reaches `main` only at merge, by which point the
  task is `completed` and the warning is worthless. What `list_tasks.sh`
  reports instead is work **in flight** — an open pull request for a task,
  the one real-time signal a forge can be asked for. That is not a lock, and
  the lister says so; two people can still take the same task. Rejected:
  making a tracker assignment the claim — it works, and it makes a core
  mechanic depend on one vendor's feature while contradicting the non-goal
  in the same move; a draft pull request opened at the start, which runs CI
  on an empty branch, notifies watchers for days, and fills the review queue
  with things that are not reviewable; and writing a reservation into `main`
  from a workflow, which needs an App token to pass branch protection and
  fails the way the one-direction mirror already rejected.
- **2026-08-22 — CI splits into a mandatory read-only check and a
  best-effort write.** A protected `main` cannot be pushed to by
  `GITHUB_TOKEN`, and a fork's head branch cannot be pushed to by it either
  — no setting changes either fact. Rather than pick one contribution model,
  the workflows decide at runtime: `writrun check` runs on every pull
  request from anywhere with no secrets and no write permission, and is the
  half that carries the guarantee; `writrun approve` records `draft →
  approved` onto the pull request's own branch, and simply does not run for
  a fork. An adopter without the write permission configured loses the
  convenience and keeps the guarantee. Rejected: requiring a GitHub App
  token to adopt at all (a methodology non-goal is platform lock-in, and App
  setup is a barrier well above copying files), and firing the flip
  post-merge on `main` (the one place the token provably cannot write).
- **2026-08-22 — the GitHub Issues mirror runs one direction only, and
  follows the pull request.** The file under `work/tasks/` is the authority;
  the Issue is a projection for people who read the queue in a browser.
  Writing an edit made in an Issue back into the file requires pushing to a
  protected `main`, which needs a GitHub App token, so that direction is
  absent rather than half-built — a sync that silently fails one way is
  worse than one that was never claimed. The mirror also has to move with
  the work: it is created when the authoring pull request opens, relabelled
  on merge, `status:in-review` while an implementation pull request is open,
  and closed once a merge carries the task to `completed`. Closing keys on
  an actual `+status: completed` line in the merged diff, because a pull
  request can merge partial work and closing then would hide a task still
  outstanding. `in-review` is a label of its own rather than part of
  `in-progress` because the two ask opposite things of the maintainer: one
  means leave the worker alone, the other means the maintainer is the
  blocker. The mirror is found by task id prefix rather than by a stored
  issue number, because an id is permanent and an issue number is not this
  project's to depend on. On the naming this creates — a forge's "issue"
  against this methodology's "task" — **task is the noun and the Issue is
  only its mirror**, and the `writrun:task` label is what separates mirrors
  from the bug reports and feature requests an adopting project also files
  as Issues; every workflow filters on it. Rejected: making the Issue
  authoritative (`writrun-select-next-task` reads files, and an agent working
  offline would read a queue the browser disagrees with), and renaming the
  concept to "issue" (it is the methodology's noun across every chapter,
  `work/tasks/`, and `task_ref` — and it would still collide).
- **2026-08-22 — the script-backed skills carry a test suite.** "There is
  nothing to build" is true of the docs and of trivial scripts, and these
  are neither: one of them is the mechanical guard on a human gate, and the
  rest encode rules the methodology is unusable without. A check nobody
  executes is a check nobody can trust — the failure mode is not a wrong
  answer but a silent one, which looks exactly like a clean result.
  The suite is two tiers — `unit/` for the skill scripts, `integration/`
  for the workflow step logic — one directory per script under test, one
  file per behaviour suffixed `_test.sh`; each sources the fixture for
  its domain (`tests/pipeline_lib.sh`, `tests/release_lib.sh` — layered
  on `tests/harness.sh`),
  builds a throwaway repository, asserts exit codes, and runs standalone
  or under the discovering `tests/run.sh`; all of it under the same
  constraints as the scripts themselves: git, `bash`, POSIX `awk`/`sed`,
  no framework — the one external voice, the forge's review count, arrives
  through `gh` and is a PATH-stubbed fake in tests. The integration tier
  exists because the workflows' step logic used to live inline in YAML,
  where no test could execute it: it moved to `.writrun/scripts/`, and the
  YAML thinned to wiring events onto scripts. Rejected: a test framework — a package
  manager to verify a doc change contradicts the portability rule these
  scripts already live under; and leaving them untested on the grounds that
  they are short, since length was never the argument.
- **2026-08-22 — `new.sh` reads git history, not only the filesystem, when
  assigning an id.** An id must never be reused, including after its file
  was deleted — and a deleted file is invisible to a directory scan, so
  filesystem-only assignment hands the next task an id the history still
  refers to. It therefore also asks `git log --diff-filter=A` for every id
  the directory ever held. Outside a git repository the filesystem is the
  whole answer, which is correct there: nothing was deleted from a history
  that does not exist. Rejected: a counter file — a second source of truth
  for something the history already records exactly.
- **2026-08-22 — the merge stays a separate manual act; approval does not
  auto-merge.** `writrun approve` pushes the `draft → approved` commit to
  the pull request's branch, so an automatic merge races it: either the
  merge lands first and the specs reach `main` still `draft`, defeating the
  point, or the commit lands on a branch that is already merged and gone.
  Worse, the property this project relies on elsewhere — a push made with
  `GITHUB_TOKEN` does not trigger workflows, which is what keeps the Issues
  mirror from looping — becomes a deadlock here: the bot's commit never
  re-triggers `writrun check`, so an auto-merge gated on that check waits
  forever for a run that cannot start. The manual merge lives with the same
  fact: nothing re-checks the flip commit either, so while `writrun check`
  is a required check, the maintainer's merge goes through only because
  branch protection does not bind administrators — a named bypass,
  tolerable because the flip is deterministic and the checks passed on the
  exact state it was derived from. Rejected: merging inside the approve
  workflow itself (removes the race, but only by making `writrun check`
  non-required, which turns the guarantee into advice), and a GitHub App
  token, whose pushes *do* re-trigger checks and would make native
  auto-merge work correctly — deferred rather than dismissed, since it is
  the right answer once contributors other than the maintainer are
  regularly opening pull requests. Until then, approving and merging are two
  decisions and cost one click.
- **2026-08-22 — a spec that enters the tree already `approved` is judged
  against the forge's review record.** `check_state.sh` reads transitions
  out of a diff, and a spec the pull request itself adds has no
  `-status: draft` line to read — in the diff, the legitimate flip
  (recorded after a maintainer approved, by `writrun approve` or by a fork
  contributor's own hand per CONTRIBUTING) and self-approval look
  identical. The difference between them is the review, and only the forge
  holds it: `writrun check` accepts a born-approved spec only when the
  pull request carries an approving review from an owner, member, or
  collaborator — the same associations `writrun approve` requires before
  writing the field, so the convenience and the guarantee agree on who
  counts. Born `implemented` needs no API call and `check_state.sh`
  rejects it outright: no legitimate path produces a spec past both gates
  at birth. Rejected: hardening rule A to "an added spec must be draft",
  which would also reject every legitimate recording of an approval — the
  fork contributor's manual flip arrives on a push, and the check that
  runs on that push would refuse the very transition the maintainer just
  authorized.
- **2026-08-22 — a multi-spec completion is checked against the union of
  its promises.** Completing a task flips every spec it references to
  `implemented` in the same change (`check_state.sh` rule C), and running
  `check_deltas.sh` once per spec against the whole diff then reports each
  sibling spec's promised docs as UNDECLARED — failing a legitimate change
  against an invariant nobody stated. The script therefore takes a
  comma-separated list of ids: MISSING stays per spec, each contract
  honoured in full and the report naming which spec's promise went unmet;
  UNDECLARED is judged against the union; CI passes every spec the change
  implements in one call. One spec per PR remains the recommended shape
  (CONTRIBUTING), not a rule — a task may equally complete across several
  pull requests, one spec each, and a merge that implements without
  completing lands the task on `main` as `in-progress`: the one way that
  status reaches `main`, surfaced by the lister as work to resume.
  Rejected: forbidding multi-spec changes outright — the methodology
  nowhere claims sibling specs are independently shippable, and a check
  verifies a stated contract rather than inventing a stricter one.
- **2026-08-22 — the queue lives in `work/`, not `docs/`.** Permanent and
  ephemeral never mix (principle 3), and they shared a roof: the queue sat
  beside the permanent chapters under `docs/`. Tasks and specs are
  machine-managed pipeline artefacts, not documentation for people, so
  they moved to `work/tasks/` and `work/specs/` — named by the
  methodology's own axis, permanent state vs. work in progress. The move
  bought the simplification that is the real point: a permanent doc is now
  simply anything under `docs/`, so the checks (`check_deltas`'
  UNDECLARED, the derived-work gate) stopped enumerating `product/`,
  `technical/`, `about.md` — which frees the inside of `docs/` for the
  adopting project's own structure, while the audience split stays
  prescribed as content rather than as the only tolerated tree. Rejected:
  `flow/` and `pipeline/` as names, since both already name the process in
  this repo's vocabulary and the folder holds what passes *through* the
  process; and a hidden `.writrun/` — these files are the authority behind
  the Issue mirror, and authority does not hide.
- **2026-08-22 — an approved spec's content changes only through draft.**
  The body of an approved spec is what a human assented to. When it must
  change — usually because a later authoring change moved the doc ahead of
  the queue, and the doc always wins — the amendment returns it to `draft`
  in the same change and passes the gate again (README: special flows).
  Three pieces of machinery close the cycle: `writrun approve` also flips
  back a spec the pull request itself moved `approved → draft`, so the
  merged squash carries the amended body with net status unchanged, while
  a spec parked in draft on `main` and merely edited is still never
  flipped; `writrun check` treats an approved spec modified with no
  status move exactly like one born approved — legitimate recording and
  silent edit are indistinguishable in a diff, so the PR's own reviews
  referee both; and a queue-impact job names, on any change under
  `docs/`, the non-completed tasks whose `doc_ref` it touches — a
  warning, never a failure, because file-level overlap is a signal and
  whether the brief survived is the reviewer's judgement. Rejected:
  freezing the doc's content into the spec so implementers never read the
  doc (a second source of truth, drift by construction), and blocking the
  authoring change on queue impact (the doc is the input; the queue
  adjusts to it, never the reverse).
- **2026-08-22 — the task's doc reference is `doc_ref`: any path under
  `docs/`.** The field was born `product_ref` with "null if purely
  technical" — which left every task derived from a technical doc with no
  reference at all: invisible to reverse traceability and to the
  queue-impact guard that crosses edited docs against the queue. With
  `docs/` free-form (the stakeholders', not the methodology's, to shape),
  "product" in the name meant nothing anyway. `doc_ref` points at the doc
  that authorized the task, wherever it lives under `docs/`; null is
  reserved for tasks that originate in code or machinery, not in a doc.
  The spec's two Proposed-changes sections keep their audience names — the
  checks verify their union and never distinguish them, so they cost
  nothing and keep principle 2 visible at the spec level.
- **2026-08-22 — a CLI is welcome, as a separate repository, never as a
  dependency.** The Distribution section (once titled "skills, not a
  CLI") argued against
  *replacing* skills with a binary, and those arguments stand — an agent
  needs no porcelain. What it left unanswered is human-shaped: adopting a
  repo in one command (`init`), updating copied skills (`update`),
  verifying the forge settings the approve convenience depends on
  (`doctor`), reading the queue without typing script paths (`list`) — and
  opening the pull request each flow ends in (`author`, `take`, `finish`,
  `amend`): branch name, Conventional-Commit title, template fields filled
  from the diff, and the local checks run in their load-bearing order
  first, refusing to open on anything non-zero. Two more: `init` installs
  a commit-msg hook that validates the Conventional-Commit convention
  (validation, never generation — the message belongs to whoever made the
  change); and `work [task-id]` runs the selection algorithm and launches
  whatever agent command the adopter configured, prompt pointed at
  `AGENTS.md` and the task — the CLI launches agents, never is one, and
  the gates are unchanged for what it launches. Packaging, never deciding
  — and no `approve` command ever: that gate stays on the forge, operated
  by a human on purpose. Those belong to a client, `writrun-cli`, in its
  own repository: it wraps
  the same scripts and files, reimplements no logic, and this repo works
  identically without it. The contract it builds on — schemas, the
  `docs/`+`work/` split, script arguments and exit codes — is declared in
  Distribution; alpha means it moves without notice and a client pins.
  Deferred to after the first adoptions: `init` and `doctor` should be
  shaped by the friction swoop and TOM actually hit, not guessed. Two
  intents are already fixed for them: `init` extracts the adopting repo's
  existing conventions (its log, its CONTRIBUTING) into `.writrun/conventions/`
  rather than imposing the shipped defaults, and grafts — never overwrites
  — an existing `AGENTS.md`, into which WritRun's part enters as one
  titled section fenced by `writrun:begin`/`writrun:end` markers; `update`
  refreshes only what sits between those markers, preserving the lines
  marked "yours" (the gates table, the deriving default); and `doctor`
  guards the contract/taste boundary — the markers survived edits, the
  declared merge policy matches the forge's settings.
  Rejected: the CLI inside this repository — it would version the
  methodology and its client together and make the optional look
  mandatory.
- **2026-08-22 — the adoption kit is `template/`: a full copy, guarded by
  a test.** One folder an adopter pastes beats a manifest of paths to
  collect by hand, but a copy is a second source of truth — so the copy
  is legal only because a unit test holds every mirrored path
  byte-identical to the root (`tests/template_mirrors.txt` is the single
  list; `make template-sync` refreshes; hand-editing `template/` is never
  the fix). The split also cleaned up what ships: the test-suite job left
  `writrun-check.yml` — an adopter has no `tests/run.sh` for it to run —
  into a home-only `tests.yml`, so the kit carries exactly the four
  writrun workflows and nothing of this repository's own CI. Versions are
  tags on `main`; adopters and the future CLI pin the tag they took the
  kit from. The kit's second invariant, added when a blind `cp -R` was
  audited: **copying must destroy nothing**. Its first cut shipped
  `README.md`, `AGENTS.md`, and `docs/` skeletons at the kit root — a
  blind copy would have replaced the adopting project's own README, the
  worst possible first impression. Now every path that lands outside the
  kit's folder is WritRun-namespaced, and all adaptable skeletons arrive
  quarantined in `writrun-kit/`, grafted and then deleted. Rejected: a
  delta-only template (no duplication, but the adopter assembles from two
  places and the future `init` would too), and a separate template
  repository (a second repo to keep in sync with no test spanning the
  two).
- **2026-08-22 — derivation is reviewable before it is public.** Two
  pieces, one idea. First, the session default: when derivation runs
  (authoring or tracking), the agent presents the derived tasks and specs
  before opening the PR — the human reviews the queue a rule creates
  while the feedback loop is still cheap; the declaration itself can say
  "open directly", and the default is each adopter's to invert. Second,
  the machinery honours draft PRs as the same idea on the forge: the
  mirror and progress workflows skip open drafts and fire on
  `ready_for_review` — a draft's tasks are not public queue entries yet,
  and `status:in-review` would misname a PR nobody asked to review.
  Alongside: **tracking is the third kind of change**, next to authoring
  and implementing — work discovered mid-flight, already authorized by an
  existing doc, entering as a `queue/short-name` PR that adds only tasks
  and specs. The `queue/` prefix deliberately carries no `task-NNN` id at
  the start: a tracking PR records work, it is not working it, and must
  not read as in flight. Skill names ship with the `writrun-` prefix, the
  same way swoop prefixes its own — the namespace collision the adoption
  chapter used to push onto adopters is solved at the source.
- **2026-08-22 — mirrors defer to authority, and tell a draft from a
  review.** Two refinements to the Issues mirror, one concern: the mirror
  never says more than the forge knows. A pull request from an author
  without authority (not owner, member, or collaborator — the same trio
  every other check here uses) gets its task mirrors **at merge**, when
  the queue really gains them, not at open — deferred, never denied, and
  a drive-by fork PR cannot spray Issues into the repository. And an open
  PR's mirror now distinguishes the two states the labels were built to
  oppose: draft means `status:in-progress` (leave the worker alone),
  ready means `status:in-review` (the maintainer is the blocker), with
  `ready_for_review` and `converted_to_draft` flipping between them.
  Rejected: skipping drafts entirely — a mirror frozen at `status:ready`
  while someone visibly works is the exact lie the in-flight signal
  exists to prevent.
- **2026-08-22 — generated shapes resolve in layers: the project's, then
  `.writrun/`, then the script.** The body a generator writes is the kind
  of default that evolves with the methodology, and a default copied once
  never updates — so it lives in a refreshable layer: `new.sh` takes
  `.writrun/conventions/templates/{task,spec}.md` when the project defined one
  (authority, visible, the adopter's), falls back to the shipped default
  in `.writrun/templates/` (machinery's layer, `writ update`'s future
  target, never hand-edited), and finally to its own built-in skeleton so
  the script works in a bare repository. Front-matter is never templated
  — it is contract — and a spec template must keep the two
  Proposed-changes headings and Outcome or generation refuses: a shape
  that drops them would blind the delta check silently. A dot-folder does
  not contradict "authority does not hide": the WritRun-owned parts of
  `.writrun/` hold defaults, not authority — the project's layer wins,
  always — and `.writrun/conventions/` is that project layer, the
  adopter's from the moment of adoption (a root `conventions/` was tried
  first and rejected: dropped into a foreign repo it reads as a second,
  unprovenanced set of commit and PR conventions beside the project's
  own; under `.writrun/` the origin and the purpose are unmissable).
  What cannot consolidate is what the platform dictates — workflows in
  `.github/`, `AGENTS.md` at the root — and each such file declares in
  its own header that WritRun shipped it. The PR template escaped that
  list because agents consume its *content* while only GitHub consumes
  the workflows': it lives solely in `.writrun/templates/`, and GitHub's
  pre-fill (which reads `.github/`, `docs/`, or the root, and nowhere
  else) is deliberately forgone — the flows' PRs are written by agents,
  and a human opening one by hand is guided by the derived-work check's
  own failure message. Rejected: a `.github/` projection kept
  byte-identical by a test — it worked, but two copies of one file inside
  one repository is the disease this project exists to treat, and the
  pre-fill was not worth the carrier.
- **2026-08-22 — the selection algorithm's filters and its sort bind
  different parties.** Steps 2–4 are the gates expressed as a query —
  `pending`, dependencies `completed`, specs `approved` — and nobody
  overrides them, human or agent. Steps 5–6 exist so repeated agent sessions
  reach the same answer rather than each re-deriving one; they were never a
  claim that the highest-priority eligible task is the only legitimate one.
  Stated explicitly because a blanket "never pick the one that looks
  easiest" would otherwise make a maintainer choosing their own next task a
  violation of their own methodology. Rejected: letting a direct request
  open the gates too — being asked for a blocked task is not a reason to
  start it, and an agent that treats a request as authorisation has no gate
  left to enforce.
- **2026-08-22 — the queue is printable, not just selectable.** The sort was
  declared advisory for a person, and a suggestion nobody can see is not a
  suggestion. `list_tasks.sh` prints the eligible set, what must be resumed
  first, what is held back with the reason for each, and what is already in
  flight — so a developer chooses from the queue instead of asking an agent
  to choose for them. Completed tasks are omitted from "held back" rather
  than listed as obstacles: that list would otherwise grow with the project
  until it buried the part needing attention. Rejected: having the skill's
  prose ask the agent to enumerate the queue by hand — the filters are
  exactly the mechanical, self-grading-prone step the other scripts exist
  for.
- **2026-08-22 — the diagrams paint their own background.** A forge swaps
  its mermaid theme with the page theme, so a diagram that inherits colours
  is legible in one theme and not the other. Each diagram fixes its own
  background, node fill, text and line colours, and therefore renders
  identically in both. The surface is dark and the arrows are white, in that
  order — white arrows alone would fix dark mode by making the diagram
  vanish in light mode, but once the diagram owns its background that
  objection disappears. Rejected: styling the arrows without setting a
  background, which is the version of this fix that only works on the theme
  its author happened to be using.
- **2026-08-22 — acceptance criteria are not judged by a model, and CI does
  not run the adopter's tests.** An LLM returns a *judgement*, and what
  acceptance criteria need is a *guarantee*: non-deterministic, billed per
  pull request, and dependent on an API key a documentation methodology
  should not require — against which "it usually gets it right" is not the
  standard a merge gate is held to. Rejected on a second count too: **CI
  here verifies the methodology, not the code.** An adopting project already
  runs its own suite in its own pipeline when the pull request opens;
  whether the code works is that pipeline's answer, and WritRun neither
  duplicates it nor stands in for it. What remains unsolved is real —
  nothing mechanically ties an EARS criterion to the thing that proves it.
  The shape that would: each criterion carries a reference to the test that
  proves it (or an explicit not-testable marker with a reason), and a check
  requires every criterion to have one, requires the referenced test to
  appear in the diff that introduces the criterion, and requires the
  adopter's suite to report it passing. Its real gain is not the gate but
  the timing — a criterion with no plausible test is caught at spec
  approval, before implementation, rather than at merge. Not built: it
  changes the spec schema and needs a portable way to read pass/fail across
  test runners, and neither is worth designing before an adopting project
  has exercised the rest of this.
- **2026-08-22 — `writrun-check-task-state` runs after the completion statuses are
  set, not before.** Every rule it has is about a transition — `draft →
  approved`, `draft → implemented`, a task reaching `completed` — and those
  transitions are exactly what filling the Outcome and setting the statuses
  produces. Run before that step and the diff contains none of them, so the
  script exits 0 having read nothing: not a wrong answer, a vacuous one,
  which is worse because it looks like a clean result. `writrun-check-spec-deltas`
  is indifferent to the same ordering, since `work/tasks/` and `work/specs/`
  are not permanent docs and touching them does not change its verdict, so
  it sits immediately after the work, where a forgotten doc update is caught
  soonest. The two therefore sit on either side of the status change rather
  than together.
- **2026-08-23 — the version number is computed, never typed.** `make
  release` derives the next tag from the last one and walks the whole
  path — stamp `.writrun/VERSION`, sync the template, run the suite,
  commit, tag, push, publish the GitHub Release with generated notes — so
  a bad tag (dirty tree, wrong branch, unsynced mirror, red suite) is
  unrepresentable rather than forbidden. The bump vocabulary is WritRun's
  own, not SemVer's: `minor` moves the third digit, `major` the middle
  one, and `epoch` — a name with prior art in Debian and RPM — the first,
  reserved for historic milestones. The stamp travels with the kit and is
  the anchor `writ update` will diff from. The release path is tested at
  two depths: an integration suite drives `scripts/release.sh` against a
  local bare origin with `make` and `gh` stubbed, and one e2e case runs
  the real `make release` in a throwaway copy of this whole repository —
  real sync, real suite nested inside (an env guard stops the
  recursion), real push to a bare origin, only the forge faked.
  Rejected: standard SemVer
  naming (patch/minor/major — the day-to-day release deserved the humble
  word, and the first digit needed something above `major`), a version
  argument typed by hand (derivable numbers drift when typed), a
  maintained CHANGELOG file (release notes are generated from the
  conventional commits), and shipping the automation to adopters in the
  kit — **an adopting project's versioning is not WritRun's business**,
  out of scope entirely: each repository versions however it likes, and
  `.writrun/VERSION` in an adopter already means the kit's own tag, not
  the project's version. The maintainer's own repositories sharing this
  same scheme is a personal-tooling concern, solved outside WritRun: the
  plan is a small standalone repository (the core — guards, bump, tag,
  push, forge release — calling an optional per-repo `release-prepare`
  hook), extracted from this script once a second consumer exists;
  WritRun's home repo will then consume it like any other project.
- **2026-08-23 — the mirror workflows' logic moved out of the YAML too.**
  The test-suite decision above moved every workflow step into
  `.writrun/scripts/` — except the two Issues-mirror workflows, whose
  reconciliation lived on as inline `github-script` JavaScript no test
  could execute. The cost arrived on schedule: when the queue moved to
  `work/`, the mirror's file filters kept matching `docs/tasks/` — a
  regression a review caught, not a test, in exactly the code the earlier
  decision had left exempt. Both are now bash — `mirror_issues.sh`,
  `reflect_progress.sh` — under the same constraints as every other
  script (`gh` where the forge must be asked, PATH-stubbed in tests;
  POSIX `awk`/`sed`), with a third fixture, `tests/mirror_lib.sh`, faking
  the forge's answers and recording every mutation for the cases to
  assert against. Two behaviour notes the port makes explicit: the pull
  request's files are still read as API patch data, never checked out —
  the workflows now check out only the *base* branch, and only to obtain
  the scripts themselves — and `reflect_progress.sh` resolves a spec
  branch through the base checkout's own `work/specs/` file, the same
  resolution `list_tasks.sh` performs. Rejected: keeping the JavaScript
  and testing it under node — a runtime the suite's own constraints
  exclude, for logic that is plumbing, not language-bound; and extracting
  it untested, which is the state this entry exists to end.
- **2026-08-23 — a status transition is read from the front matter at
  the range's two ends, never grepped out of the diff.** The checks used
  to grep the diff text for lines like `^+status: approved` — which also
  match a *quoted* status line in a body, and this repository's own
  chapters quote the schema at column 0. That shape produced one false
  positive and two quiet routes around gates: a body edit swapping a
  quoted example read as a forbidden `draft → approved`; a quoted
  `+status:` line exempted an approved spec's silent edit from the
  review requirement; and a quoted `status: implemented` turned an
  authoring change into loop closure, waiving its derived-work
  declaration. Every reader now resolves the base side of its range
  (the merge base for the three-dot form, the left rev for two-dot, the
  rev itself when diffing the working tree) and compares the
  front-matter block at both ends — `flip_approved_specs.sh` already
  wrote only front matter; now every reader agrees with it. Rejected:
  locating the front matter inside the unified diff by hunk arithmetic,
  which re-derives fragilely what the two endpoints already know; and a
  convention forbidding column-0 status quotes in bodies — this repo's
  own docs break it, and a rule that outlaws documenting the schema is
  self-defeating.
- **2026-08-23 — an approving review vouches for the pull request, not
  for a commit.** `check_recorded_approvals.sh` accepts any authorized
  approving review on the PR, including one older than the commits it
  now covers — deliberately. Both legitimate recording paths push
  *after* the review by construction (`writrun approve`'s recording
  commit; the fork contributor's hand flip per CONTRIBUTING), so
  pinning the review to the head commit would reject exactly the
  transitions the review authorized — and the required "dismiss stale
  approvals: off" setting means the forge itself keeps the review
  standing across those pushes. What bounds the exposure is the merge:
  content pushed after an approval still reaches `main` only through
  the maintainer's own squash-merge, the last gate on everything.
  Rejected: requiring the review to sit on the head commit (breaks both
  legitimate recordings), and re-requesting review on every push —
  that is the forge's dismiss-stale feature, deliberately off.
- **2026-08-23 — the flows live in the permanent docs; the README
  summarizes.** The five flows and their special cases — validated by
  the maintainer, and declared the source of truth for the mechanics —
  lived in the README, which is not under `docs/`: the one surface the
  machinery guards. Nothing there is checkable — `check_deltas` cannot
  demand it, the derived-work gate does not read it, queue impact never
  crosses it. The flows moved verbatim into
  `docs/product/pipeline.md#flows-and-statuses`; the README keeps a
  one-line-per-flow sketch and links. Rejected: keeping both in full —
  restatement is drift by construction, and the mirror regression above
  is what that costs; and `technical/` as the home — the flows name
  actors and gates, stakeholder-facing behaviour, while the machinery
  each node invokes stays linked from here.
- **2026-08-23 — canonical front matter is enforced, not assumed.** The
  line-based readers are the portability choice, and they were an
  assumption: YAML allows the same meaning in forms `sed -n 's/^status:
  *//p'` cannot see — a block list under `spec_ref:` reads as *no
  specs*, which would hand out a task whose approval gate was never
  passed; a quoted `doc_ref` matches no path comparison; a folded
  `blocked_reason` reads as nothing. Silent every time, and silent
  wrongness is this repository's named worst case. Rather than teach
  every reader more YAML, the canonical form became a checked contract:
  `check_front_matter.sh` validates shape (one `key: value` per line,
  bare values, inline lists), schema (every field exactly once, closed
  status and priority vocabularies, `blocked`/`blocked_reason` paired
  both ways, `YYYY-MM-DD` dates, `doc_ref` relative to `docs/`), and
  identity (`id` agrees with the filename) — run by `writrun check`
  before the lifecycle rules, which is what makes those rules'
  line-based reads legitimate. Unknown keys in canonical shape pass: an
  adopter may extend the schema, not reshape it. Rejected: a YAML
  parser dependency (the portability non-goal), teaching each reader
  the alternate forms (half a parser in awk, and the ceiling only
  moves), and stating the rule as prose (a contract nobody executes is
  the assumption again, wearing a heading).
- **2026-08-23 — the template sync is a script, not a Makefile recipe.**
  The Makefile's own header says thin aliases only, and `template-sync`
  was the one exception: real logic inline where no test executes it —
  the same shape the workflow YAML had before its extraction, carrying
  the same cost on order. It also told a quiet lie: a path in the
  mirror list but gone from the root had its template copy deleted and
  still printed "synced". Now `scripts/sync_template.sh` (home
  automation, beside `release.sh` — an adopter has no `template/`) is
  the single writer: a missing root path is a named error that leaves
  the stale copy in place, and the integration tier executes every
  behaviour, the silent lie included. Rejected: leaving the recipe
  inline (the Makefile's own contract forbids it), and folding the
  sync into `release.sh` (the sync is useful alone, and the release
  already reaches it through the alias).
- **2026-08-23 — decisions are history, split from the living
  reference.** This log had grown to two thirds of `README.md`, and the
  file is on `AGENTS.md`'s mandatory reading path: every working session
  paid ~600 lines of history to reach a schema. The log moved here — its
  own file, still append-only, one subsystem's `decisions.md` exactly as
  the folder layout in `README.md` prescribes for adopters and this
  repository had never given itself. `README.md` keeps a `## Decisions`
  stub so old anchors resolve. Entries were moved verbatim; only
  intra-file links were repointed. Rejected: trimming or summarizing old
  entries (append-only means append-only), and a numbered ADR directory
  (this methodology's own default is decisions-per-subsystem, and there
  is one subsystem).
- **2026-08-23 — contract front matter is generated; extension front
  matter is the template's.** The canonical-form decision promised that
  an adopter "may extend the schema, not reshape it" — and the generator
  kept no such promise: adding a project field (owner, estimate) to
  every new task meant hand-editing each generated file or editing
  `new.sh`, which `writ update` will overwrite. Now a project template
  may open with a front-matter block of its own: `new.sh` appends those
  **extension fields** to the contract block it generates, placeholders
  and all, with the same placeholders (`{{id}}`, `{{title}}`,
  `{{task_ref}}`) substituted — and refuses, before writing anything, a
  template that redefines a contract field or writes a line the
  canonical check would reject at the merge: a shape that would blind or
  fail a check is stopped where it is born, the same pattern as the spec
  template's contract headings. The skill instructs the agent to treat
  each extension's placeholder text as the project's brief and fill it
  like the body. The earlier "front matter is never templated" narrows,
  deliberately, to the contract fields — the reason it existed (a
  reshaped contract blinds the machinery silently) applies only to them.
  Rejected: templating the whole block (that reason, still standing),
  and leaving extensions hand-edit-only (a promise the tooling didn't
  keep).
- **2026-08-23 — a release verifies the sync produced nothing but the
  stamp.** The release decision above declared an unsynced mirror
  unrepresentable, and the implementation did not deliver it: the
  release commit stages only the two `VERSION` files, so if
  `template-sync` had found real drift — a mirror-test failure merged
  past `main` — the fix would be left uncommitted, the suite would pass
  (it runs on the synced working tree), and the tag would ship a
  template disagreeing with its own root, looking green throughout.
  `release.sh` now aborts when the sync's output goes beyond the two
  stamps, naming the drifted paths: a release records, it does not fix —
  drift gets its own reviewed change. The guard's first real execution
  caught exactly this: an e2e run against a working tree whose
  `new.sh`/SKILL edits had not yet been re-synced. Rejected:
  auto-committing the drift inside the release commit, which would hide
  an unreviewed template change inside a `chore(release)`.
- **2026-08-23 — main gets a release pipeline of its own; the cut stays
  local.** The home CI (`tests.yml`) ran only on pull requests, so a
  change landing on `main` without one — an admin push — was never
  re-checked on the branch releases are cut from. The two questions CI
  answers are different — *is this change good?* on the PR, *is this
  branch releasable?* on `main` — so they are two pipelines now:
  `tests.yml` stays the pull-request suite, and `release-readiness.yml`
  runs on every push to `main` with a dedicated named job for the
  release signal: the template mirror case alone, fast, so a template
  diverging from its root breaks a pipeline named for what it guards —
  the same drift `make release` refuses locally — with the full suite
  beside it. The cut itself deliberately does not move into CI: the
  stamp commit cannot be pushed to a protected `main` by
  `GITHUB_TOKEN`, and the tokens that could (a PAT, an App) are the
  dependency this project has rejected three times over. Rejected: a
  workflow_dispatch release pipeline (it ends at the push it cannot
  make); one workflow carrying both triggers (a red run would not say
  which question failed); and a third comparator script for the
  divergence check — the suite's own mirror case is the comparison, run
  alone rather than reimplemented.
- **2026-08-23 — the Issues mirror is severable, and the kit says so.**
  The mirror was always a projection with the queue files as authority,
  one direction only — nothing in the methodology reads an Issue back —
  so an adopter who wants no GitHub Issues loses nothing structural by
  not running it. What was missing was the statement: the kit shipped
  "the four workflows" as one block, and severing two of them looked
  like surgery when it is configuration. Named now, in `WRITRUN.md` and
  in Distribution: delete `writrun-issues.yml` and
  `writrun-progress.yml`, keep `check` and `approve`, done. For the
  future CLI this is an install choice (`writ init` asking, or
  `--no-issues` skipping the pair) — recorded here as intent, like the
  rest of the CLI's scope, since the CLI lives in its own repository.
  Rejected: a config flag the workflows read at runtime — two files an
  adopter deletes need no switch, and a switch would be a second way to
  say what absence already says.
- **2026-08-24 — an unusable gh aborts the release before anything is
  mutated.** The cut ends at the forge (`gh release create`), which runs
  after the push — so a missing or unauthenticated `gh` used to fail
  there, with the tag already public: a half-release, from a script
  whose whole design is that a bad tag is unrepresentable. The guard now
  sits with the others, up front (`command -v gh` + `gh auth status`,
  which reads local config and needs no network). Rejected: checking
  only that the binary exists — an unauthenticated gh fails at the same
  worst moment.
- **2026-08-28 — the merge is this repository's assenting act, because
  its maintainer cannot review his own pull requests.** `writrun approve`
  listened for `pull_request_review: submitted`, an event no forge will
  ever emit here: every pull request in this repository is opened by the
  maintainer, and GitHub does not let a person approve their own. The
  gate was therefore unsatisfiable — and an unsatisfiable gate is worse
  than none, because it gets worked around. It was, three times in one
  session: specs sat `draft` while their work was done, and the flip was
  typed by hand, off the record, which is precisely what the gate exists
  to prevent. The assenting act becomes the merge, which the maintainer
  performs anyway and which the forge does allow; `writrun approve`
  triggers on a merged pull request and writes the flip to `main`. Whoever
  may merge is exactly whoever may approve, so the gate loses no strength
  — it only stops asking for a signal that cannot exist. The trade-off is
  named where it lands: the recording now writes to `main`, which is why
  `main` stays unprotected here, and protecting it later means allowing
  the Actions token to push or the recording stops. `pipeline.md` needed
  no new permission for any of this — it already said a project may
  record assent however it likes; what it lacked was the instruction to
  *name* the act, which it now carries as a criterion. Rejected: keeping
  the review trigger and letting the maintainer hand-write the field —
  that is the workaround, not the fix, and it leaves the machinery
  describing a flow nobody can run. Also rejected: a second account to
  cast the review — a credential invented to satisfy a check, which buys
  a green tick and no actual second opinion.
