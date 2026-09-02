# Distribution

**How a project pulls the methodology in, and what it gets** — the
adoption kit, the skills and their scripts, the workflows, the release
contract. One chapter of [`README.md`](README.md), the technical router;
read it when working on the machinery itself.

## Distribution

The operational half of the methodology — selecting the next task, drafting a
task or spec, checking a spec's promised deltas against a diff — ships as
**skills**: copied files, no binary, no install step. A CLI exists as a
separate, optional client (`writrun-cli`, below); the methodology itself
never depends on it. Three reasons the skills are the mandatory form:

- **The agent already writes the files.** An agent with file tools and
  `AGENTS.md` in context can create a correctly-shaped task or spec directly —
  a CLI subcommand that also writes the file duplicates work the agent
  already does natively.
- **No language lock-in.** Skills are markdown instructions, all five of them
  backed by a small deterministic script for the one step each that must
  not be self-graded or hand-derived from memory — see below. This keeps
  the methodology's own non-goal — "not tied to one language, framework, or
  agent platform" — true of its tooling, not just its docs.
- **Distribution is already solved.** Skills install through the same
  mechanism adopters already use for other reusable instructions — no
  install script, no binary to build per platform.

The five skills, in `.writrun/skills/` — WritRun's own home, never the
project's skill folder; see
[Adoption's skills-namespacing note](../product/adoption.md#skills-namespacing)
for how the two sets stay apart by path and by prefix:

- **`writrun-select-next-task`** — runs the [selection algorithm](selection.md#task-selection-algorithm)
  exactly as specified, so every agent session gets the same answer instead of
  each one re-deriving it from the prose.
- **`writrun-create-task-and-spec`** — turns `AGENTS.md`'s prose instructions on task
  and spec creation into an active, checklist-driven skill: what front-matter
  to fill, when a spec is warranted, how to fill the Proposed changes
  sections. Backed by `new.sh`, which scaffolds a schema-correct
  `task-nnn.md` / `spec-nnn.md` — id increment, list-typed fields, every
  field present — mechanically rather than from an agent's memory of the
  schema (see [Task's worked example](../product/concepts/task.md#example)
  for the drift this replaces).
- **`writrun-check-spec-deltas`** — verifying that a completed diff touches
  everything a spec's Proposed changes section promised, and nothing
  permanent it didn't, is objective, mechanical checking. An agent grading
  its own diff is the wrong shape for that — the skill wraps a small
  deterministic script (grep/diff based, no runtime dependency) instead of
  asking the agent to self-attest.
- **`writrun-check-task-state`** — the same argument applied to status rather than
  paths. The transition it exists to reject is `draft → approved`, which an
  agent may never make, including on a spec it wrote itself; asking that
  agent whether it respected the gate is asking the wrong party. Backed by
  `check_state.sh`, which also rejects the two ways of routing around the
  gate: `draft → implemented`, and completing a task whose spec is not
  `implemented`.
- **`writrun-check-front-matter`** — every reader above is line-based on
  purpose, and YAML permits shapes those readers silently misread: a block
  list that reads as empty, a quoted value that never matches a path
  comparison. So the canonical form of
  [Front matter is canonical](schemas.md#front-matter-is-canonical) is a checked
  contract, not an assumption — `check_front_matter.sh` validates every
  queue file against it, on files alone, no git and no forge, which makes
  it the one check available at every adoption stage.

The whole adoption kit ships as [`template/`](../../template), one folder
**shaped exactly like the destination root** — that is what a template
is: `.writrun/`, the four `writrun-*.yml` workflows, `work/`, the
skeletons for `AGENTS.md` and `docs/`, and the guide itself as
`WRITRUN.md` — a name that collides with nothing and stays behind as a
provenance pointer after adoption. **Severing the mirror is the `stage`
setting, not a deletion.** An adopter that wants no GitHub Issues lowers
the top-level `stage` below `3`, and every mirror in the kit stands down
at once: `writrun-issues.yml` is wholly Stage 3, so is
`writrun-progress.yml`'s `reflect` job, and so are the two mirror steps
`approve` carries. Those steps are what changed the instruction — a
merged close has exactly one owner, and it has to be the workflow that
writes the queue, because a label derived from anything but the queue
after the recording commit is derived from a state the merge already
changed. Delete the two mirror workflows and leave `stage` at its
default of `3`, and `approve` goes on minting and labelling mirrors at
every merge; lower the stage, and deleting them is tidying rather than
severing. `writrun-issues.yml` is the only one a deletion severs
cleanly: `writrun-progress.yml` also carries Stage 2's in-flight status
recording, and `check` and `approve` stand alone. The guide names the
kit's two collision
points — an existing `AGENTS.md` is grafted, never overwritten; existing
docs are kept — while everything else the copy lands is
WritRun-namespaced. The kit deliberately ships **no README.md**: the one
file whose blind copy would replace the adopting project's own. The mirrored parts are a
**deliberate full copy**, kept byte-identical to this repository's own
root files by a unit test (`make template-sync` refreshes; the mirror
list is `tests/template_mirrors.txt`, the single source of what ships).

**A script's data file ships beside the script.** The vocabulary lives
in `.writrun/scripts/stage-2-pull-requests/`, next to the check that
reads it, and not in this repository's `tests/` — the mirror carries
`.writrun` whole and carries nothing else, so a data file left outside it
reaches no adopter, and the check they run passes by knowing nothing.
That is a silence, not a pass, which is why the absent case says so.

**The mirror holds bytes; the kit's own prose is held by words.**
Everything under `template/` that is *not* mirrored — its `AGENTS.md`,
its `WRITRUN.md`, its `docs/` and `work/` chapters — has no byte-for-byte
guard, and cannot have one: those documents differ from this
repository's on purpose. What they share is the vocabulary, so
`check_doc_shapes.sh` reads them for both halves — the front matter they
show, and the words they use. That is the structural reason the kit
shipped a retired status long after the queue stopped having it, and the
reason a second mirror was not the answer.

**One file leaves the mirror on purpose: `.writrun/settings.json`.** The
kit ships it cautious — `stage: 1`, every conduct flag `false` — because
a fresh copy of this repository's own file would start an adopter at
Stage 3 with every workflow armed and the Issues mirror opening issues on
their first pull request, while the guide is still telling them to
declare a stage. `tests/template_exceptions.txt` is the single source of
what differs, read by the sync and by the unit test alike. The sync
stashes each listed path before the mirror runs and restores it after —
not merely declining to overwrite it, because the mirror list names
`.writrun`, a directory, and a directory is refreshed by removing it and
copying it back; every path it keeps is named in the output. The test
drops the same paths from both sides before comparing, by path and never
by name, so `.writrun/conventions/settings.json` — the legacy address the
reader still honours — stays compared.
This repository's own CI beyond the writrun workflows — the pull-request
suite in `.github/workflows/tests.yml` and the release-readiness
pipeline on `main`, `.github/workflows/release-readiness.yml` — is not
part of the kit and stays home.

**A red `main` that a script can fix is the bot's to fix.** The
readiness pipeline separates two kinds of failure. Drift a
deterministic regeneration repairs — the template out of sync with the
root it mirrors — it repairs itself: the pipeline runs the
regeneration and, when that produces a diff, commits the sync to
`main` with the same token and the same rebase-not-force pattern the
queue recording uses. Because a `GITHUB_TOKEN` push triggers no new
runs, the same job then re-runs the suite itself, so the verdict on
the healed tree lands in the run that healed it. Readiness goes red
only for what regeneration cannot repair — a genuine breakage that
needs thought. A pipeline that fails asking a person to run
`make template-sync` is a machine demanding a human do a machine's
job, which is the failure the queue recording already refuses
everywhere else.

**Skills are the plumbing; a CLI is welcome porcelain — in its own repo.**
Nothing above forbids a human-facing command line (`writ list`,
`writ init`, `writ doctor` — the binary is `writ`, per About); it forbids
the methodology *depending* on one. A CLI lives in a separate repository (`writrun-cli`), wraps the
same scripts and files, and everything here keeps working without it —
agents use skills, CI uses scripts, files stay the authority. What tooling
like that builds on is this file's **public contract**: the task and spec
front-matter schemas, the `docs/` + `work/` split, each script's arguments
and exit codes, and the handful of grep-level markers the machinery reads
— the `## Derived work` heading in a PR body, the two Proposed-changes
headings in a spec, a task file's `# ` title line, a `task-nnn` /
`spec-nnn` id at the start of a branch name, and the labels the machinery
owns and filters on: `writrun:task`, the `status:*` values
(`proposed`, `backlog`, `ready`, `in-progress`, `in-review`, `blocked`)
and the `origin:*` values (`rule`, `report`)
— renaming any of these means adapting the workflows. One carve-out runs the other way:
`docs/writrun-instructions.md` is process metadata, not project truth —
no task derives from it and every check ignores it. **Everything else about
commits, pull requests, and task/spec style is the adopter's convention,
not the methodology's**, and it lives in one editable folder at the
repository root — `.writrun/conventions/`: commit types and scopes, branch naming,
the PR title rule, the merge policy, task and spec taste. The one commit
the machinery makes has its title as a variable at the top of
`writrun-approve.yml`, and the PR template ships as an editable default
alongside. Versions are tags on `main`
(the first: `v0.0.01`, and the third field stays two digits) — everything merges to `main` continuously, and a
version exists when its tag does. The number measures this contract, not
the code, and it is computed, never typed: `make release` cuts one, with a
vocabulary that is deliberately WritRun's own rather than SemVer's —
`minor` bumps the third digit (the default), `major` the middle one,
`epoch` the first, reserved for historic milestones. The target derives
the next number from the latest tag, stamps it into `.writrun/VERSION` —
the kit carries the stamp, so an adopter, and the future `writ update`,
knows which tag a copy came from — syncs the template, runs the suite,
and only then commits, tags, pushes, and publishes the GitHub Release
with notes generated from the conventional commits. While the methodology
is alpha (0.x), the contract itself moves without notice; a client or an
adopter pins the tag it targets.


## Running the checks

Three of the five skills are gates, and three rules about *how* they are
called belong to the caller rather than to any script — a wrong call
passes, which is why they are stated here and not left to whoever
remembers.

**`check_front_matter.sh` takes all four directories or none.** It
defaults to `work/tasks`, `work/specs`, `docs` and `work/reports`, and a
project whose queue lives elsewhere must name every one. Naming only the
first two leaves `work/reports` resolved against the working directory,
finds nothing there, and reports success over the reports it never read —
and hand-edited reports are exactly what the check exists for, since
three of triage's four ends are written by hand. A report directory that
is not there is zero reports and still exit 0: an adopter who has never
recorded one has a complete state, not a broken checkout.

**`check_deltas.sh` reads a multi-spec change in one call, never one
spec at a time.** A change completing a multi-spec task passes the ids
comma-separated: MISSING is judged per spec, so each contract must be
honoured in full and the report names whose promise went unmet, while
UNDECLARED is judged against the **union** of their promises. Run one
spec at a time against the same diff and every sibling's promised docs
come back as undeclared for the other — a red result the change did not
earn, and the fastest way to teach a reader to ignore the check.

**A `PR_*` name carries pull-request event data, set by the workflow
step that calls the script.** `PR_HEAD_REF`, `PR_TITLE`, `PR_AUTHOR`,
`PR_DRAFT` and `PR_MERGED` reach `apply_pr_event.sh` and its siblings
that way. A script an agent also runs locally reads the bare name:
`check_state.sh` reads `HEAD_REF`, because outside CI there is no pull
request for the prefix to be true about. Copying one workflow's `env:`
block into another's step therefore sets a name the callee never reads.
The callee announces the rule it could not run rather than passing
quietly — but it announces it on a check that still goes green, so the
log line is the whole signal.

**Neither result is resolved by editing the promise to match the diff.**
MISSING is either a forgotten doc update or a promise that was wrong, and
UNDECLARED is either an incomplete Proposed-changes section or a change
that touched what it should not have; both are surfaced and decided,
never papered over. A spec is marked `implemented`, and a task's
`completed` date written, on exit 0 and on nothing else.

## `take_task.sh` — the taking act, in one command

Taking a task is one act with two halves — the branch reaching the forge
and the draft pull request opening — and a script is what keeps them one:

```bash
bash .writrun/scripts/stage-2-pull-requests/take_task.sh <task-id> \
  --title "<summary>" [--slug words] [--resume] [--confirm]
```

It refuses a dirty tree, fetches `origin main`, and re-applies selection
steps 2–4 (`ready`, every `depends_on` done, every `spec_ref` approved or
implemented) — naming the filter that held. Then it composes, touching
nothing: the branch `task/NNNN-<slug>`, defaulting to the slug the
filename already carries; the title, its `[TASK-NNNN]` tag prepended and
the given summary read against `stage_2.pr_title_style` and the two
vocabularies with the same grammar `check_observance.sh` applies — an
invalid summary refuses here, before anything exists; and the body from
`.writrun/templates/pull_request_template.md`, implementing half kept,
`Implements spec-…` filled from `spec_ref`.

**The conduct flags are honoured by the script, not by prose re-read per
session.** With `auto_push` and `auto_pr` both `true` it performs the act;
with either `false` it prints the composed branch, title and body, touches
neither the tree nor the forge, exits **2**, and names the `--confirm`
rerun that performs exactly what it printed. The forge reads sit *after*
that gate: a run the flags hold asks the forge nothing, because a network
call about work the adopter has not allowed is a trace left on someone
else's server for an act that is not happening.

On the acting path the forge is verified first — `gh` present,
authenticated, reachable — so a failure there leaves the repository
untouched (**3**). Then the same two reads `list_tasks.sh` makes: an open
pull request carrying this task refuses the take (resuming is not
taking), and an open pull request carrying **no** task id that touches one
of the task's specs suspends it, named. Only then is the branch cut from
`origin/main`, pushed, and the draft opened. A forge failure *after* the
cut also exits 3, naming the branch kept local and `--resume`, which
finishes the act — push and pull request only, never a second branch.
That carve-out is narrow on purpose: a local branch that never reached
the forge is the leftover of an interrupted take; a branch that exists
anywhere else is a refusal.

Exit codes: **0** taken; **1** a refusal, with nothing created; **2**
composed and waiting on the word; **3** git or the forge failed. It
writes no queue file — the status line has one writer, and it is the
machinery answering the draft this opens.

## `preflight.sh` — the completion gates, in order

The three gates a change must pass before its pull request is marked
ready are CI's own three, and the order they run in is a rule:

```bash
bash .writrun/scripts/stage-1-tasks-and-specs/preflight.sh \
  [task-id[,task-id…]] [diff-range]
```

Task ids default to the `task-NNNN` marker in the branch name, and none
resolving is not an error — a reporting or docs branch carries none. The
range defaults to `origin/main...HEAD` after a `git fetch origin main`;
offline, the stale base is named out loud and the run continues, because
a gate nobody can run offline is a gate that does not run.

Then, stopping at the first failure and reprinting that check's own
output under a line naming the stage: **1/3** `check_front_matter.sh`,
its whole-queue sweep (the range plays no part in it); **2/3**
`check_promised_deltas.sh` with the range, which derives the specs the
range moved to `implemented` and runs `check_deltas.sh` on exactly that
set — when none moved, its "authoring change, deltas not applicable" line
prints and the stage passes *loudly*; **3/3** `check_state.sh` on the
range.

**The vacuous pass is encoded here.** The state gate exists to reject the
transitions the completion edits make, so a run before those edits passes
by having nothing to read. When a named or inferred task's `completed` is
still null, the run says so — the delta stage's not-applicable line is
that same fact seen mechanically — and the warning rides the summary
whether the run passed or stopped.

All green prints `PREFLIGHT OK` with the range and the specs the delta
stage checked, and exits 0. A failing stage exits with **that check's own
code**, printed under the stage's name: attribution is the named line,
never the number. Preflight's *own* failures — a malformed argument, an
explicit task id resolving to no file — exit **4**, a code no stage uses,
so a caller retrying on preflight's word never mistakes a stage's 3 for
preflight asking for different arguments.

It adds no rule of its own: the same three calls CI's `writrun-check.yml`
makes, so the local gate and CI render the same judgement on the same
branch.

## `session_card.sh` — the settings, rendered

Everything an agent obeys per session that is a *value* — the stage, the
conduct flags, the title style, the vocabularies, the constants — on one
~30-line card:

```bash
bash .writrun/scripts/stage-1-tasks-and-specs/session_card.sh
```

It computes nothing and decides nothing. Every line comes from
`settings.json` through `read_setting.sh` (defaults included, and marked
as defaults by its `--origin` flag), from `check_observance.sh`'s
`TYPES=`/`SCOPES=` lines — the machine half of the vocabulary, and the
half the door enforces — or is a methodology constant the contract
already fixes. An adopter who edited the vocabulary in
`conventions/commits.md` but not the script sees the script's list, which
makes the drift visible instead of ambient.

Exit 0 always, including with no settings file — pre-adoption is a state,
not an error — except **3** when the vocabulary lines cannot be found,
because a card missing them would look complete while stating nothing
about what a title may say. The card replaces reading, so its length is
part of its contract: growing is regressing.

