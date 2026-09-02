# Contributing to WritRun

Thanks for being here. WritRun is built in spare time, so anyone who turns
up — with a typo fix, a worked example from their own project, or an
afternoon of real work — is choosing to spend it on this.

WritRun is a documentation methodology: docs as the executable source, code
as the derived artefact. [docs/about.md](docs/about.md) is worth the two
minutes — it covers what the project is reaching for, and what it happily
leaves to other tools.

Not sure whether an idea fits, or where to start? Open an issue and ask.
Asking early is usually faster than guessing — for both of us.

## Before you start

- **Check the non-goals.** [docs/about.md](docs/about.md) lists what
  WritRun deliberately will not become. A quick look before you start is
  the surest way to have your work land well. If one of them strikes you
  as wrong, that is genuinely worth hearing: open an issue and make the
  case.
- **Read the rules you are changing.** [docs/product/](docs/product/README.md)
  is the source of truth for what the methodology prescribes, written as a
  book — start at the `concepts/` chapters. If your change contradicts a
  rule there, that is a conversation for an issue, not a surprise in a PR.
- **Read the decisions.** [docs/technical/README.md](docs/technical/README.md)
  carries WritRun's own dated decisions — the *why*, and what was rejected.
- **This repository dogfoods itself.** Its own `docs/` follows the
  structure it ships. A change here should read, when it's done, like a
  worked example of the methodology it's documenting.

## The work is defined in tasks and specs

[`work/tasks/`](work/tasks/README.md) is **the queue** — what to do, when,
and what blocks it. [`work/specs/`](work/specs/README.md) is **the
detail** — scope, steps, criteria, edge cases. A tracked task has zero, one,
or several specs.

**Nothing is "planned" in prose:** it is either a task in the queue or it
does not exist yet.

- **See what is available**, rather than browsing `work/specs/`:

  ```bash
  bash .writrun/skills/writrun-select-next-task/list_tasks.sh
  ```

  It prints what is eligible, what must be resumed first, and what is held
  back with the reason. **You may take any task it lists as available** —
  the order shown is priority, then `created`, then `id`, and it is a
  suggestion to you. An agent is bound by it, so that repeated sessions
  agree; you are not, and taking a lower one bypasses nothing.
- Trivial work does not become a task — a typo or a one-line fix goes
  straight to a commit. `work/tasks/` exists only for work that justifies
  tracking.
- **One change = one branch = one PR.** A PR normally carries one task,
  and legitimately carries several when they are facets of one atomic
  change — landing them apart would ship something half-true. Branch
  name: `task/NNNN-short-name`, after the task being worked — the lead
  one, when the PR carries several — whether that task has one spec,
  many, or none; the `[TASK-NNNN]` tags leading the PR title name every task the
  PR carries. The task is what the branch is named after because the
  task is what is being worked: a spec is one task's elaboration, and
  `spec_ref` is 0..N, so a spec-named branch would force an arbitrary
  pick the moment a change implements two of them. A change that
  *authors* a rule rather than
  implementing one uses `docs/short-name` — it creates specs it will not
  implement, so naming it after one would misdescribe it. See
  [Pipeline](docs/product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes) for
  which kind of change you have.
- **Take a task only when it is `ready`.** The machinery wrote that
  status from the fact that every spec it references is `approved` —
  cross-check it. A `backlog` task has not passed the approval gate —
  leave it, and say so rather than reporting an empty queue.
- **Taking it means opening its draft PR**, before the work starts — a
  branch on your machine is invisible to everyone else, and the draft is
  the signal that the task is under way. It reserves nothing; it reports.
- Follow the spec's Steps in order. Acceptance criteria are written in EARS
  form (`When <trigger>, the system shall <response>`) where the chapter
  asserts something testable — see
  [Product doc's chapter-writing rule](docs/product/concepts/product-doc.md#how-a-chapter-is-written).
- Before opening the PR, verify the spec's **Definition of Done**.
- **Close the loop:** fill in the spec's `Outcome` section with what was
  actually built and anything that diverged, and why. Do not silently edit
  the Proposed-changes sections to match reality after the fact.
- **Update the permanent docs in the same PR** —
  [docs/product/](docs/product/README.md) if behaviour changed,
  [docs/technical/](docs/technical/README.md) if machinery did. A spec is a
  historical record; it is not where current behaviour is documented.
- Run [`writrun-check-spec-deltas`](.writrun/skills/writrun-check-spec-deltas/SKILL.md) before
  marking anything complete — it verifies the diff touches every path the
  spec promised, and nothing permanent it didn't. **It does not apply to an
  authoring change:** that ships no behaviour and has no spec to check
  against, so its permanent-doc edit would report UNDECLARED. CI makes the
  same distinction automatically.
- Set the spec's `status` to `implemented` and write the task's
  `completed` date (UTC timestamp). **Leave the task's `status` line
  alone** — it is the machinery's, and the merge is what flips it to
  `done` when it lands your date.
- **Then** run [`writrun-check-task-state`](.writrun/skills/writrun-check-task-state/SKILL.md) —
  after those status changes, not before. It rejects the transitions the
  human gates exist to prevent, above all a PR that approves its own spec,
  and every rule it has is about a transition. Run before the line above and
  there are none in the diff yet: it passes without reading anything.

The full process, including the front-matter schemas, is in
[docs/technical/README.md](docs/technical/README.md) and the
[`writrun-create-task-and-spec`](.writrun/skills/writrun-create-task-and-spec/SKILL.md) skill —
its generator script scaffolds a new task or spec correctly rather than
relying on getting the schema right from memory.

## Development setup

**There is nothing to build.** WritRun is documentation and a handful of
shell-scripted skills — no compiler, no package manager, no runtime
dependency. The five skills backed by a script
([`writrun-check-spec-deltas`](.writrun/skills/writrun-check-spec-deltas/check_deltas.sh),
[`writrun-check-task-state`](.writrun/skills/writrun-check-task-state/check_state.sh),
[`writrun-check-front-matter`](.writrun/skills/writrun-check-front-matter/check_front_matter.sh),
[`writrun-create-task-and-spec`](.writrun/skills/writrun-create-task-and-spec/new.sh),
[`writrun-select-next-task`](.writrun/skills/writrun-select-next-task/list_tasks.sh)) need only
`bash` and a POSIX-portable `awk`/`sed` — deliberately, since one already
broke once on a machine with no `gawk` installed; see
[`technical/decisions/`](docs/technical/decisions/README.md).

**There is, however, something to run.** Those five scripts are the
mechanical half of the methodology — one of them guards a human gate — so
they have a suite:

```bash
bash tests/run.sh        # or: make tests
```

`make test-unit`, `make test-integration`, and `make test-e2e` run one
tier — the last one cuts a real release in a throwaway copy of this
repository, only the forge stubbed; `make test-check_state` (likewise
any suite directory, e.g. `test-flip_specs`) runs one suite; any case
file also runs on its own.

Same constraints as the scripts it exercises: git, `bash`, POSIX `awk`/`sed`,
no framework. Each case builds a throwaway repository and asserts an exit
code. If you change a script, add the case that would have caught the change
being wrong.

## How contributions reach the project

Nobody needs write access. **Fork the repository, work on a branch in your
fork, and open a pull request against `main`.**

Merging is restricted to the maintainer. This is not a comment on trust —
a permanent doc never merges on agent *or* single-reviewer approval alone,
per WritRun's own [human gates](docs/product/stage-1-tasks-and-specs/gates.md), and
keeping that responsibility in one place is the simplest way to honour it.

- **Keep your fork in sync.** Branch from an up-to-date `main` or your PR
  will be reviewed against a moving target.

## Workflow

**Trunk-based.** `main` is the only long-lived branch and is always green
— this repository's choice, per
[`.writrun/conventions/branches.md`](.writrun/conventions/branches.md); the methodology
itself only requires one authority branch, whatever the strategy around
it.

1. Branch off the latest `main`. Rebase on `main` rather than merging it in
   — it keeps the squash clean. For an implementing change, **push the
   branch and open the pull request as a draft before you start
   working**: until it reaches the forge nothing says the task is taken,
   and the draft is what moves its mirror to `status:in-progress`. Mark
   it ready for review when the work is done.
2. Commit, branch, and title per [`.writrun/conventions/`](.writrun/conventions/README.md)
   — Conventional Commits with this repo's types and scopes, and
   squash-only merges. **That folder is this repository's own convention,
   not the methodology's**: an adopting project rewrites it to its own
   taste, and everything WritRun ships that writes a commit or a PR is a
   copied, editable file.
3. Open the PR **against `main`** and fill in the template. An authoring
   PR fills **Derived work** — every task and spec it creates — because
   approving a rule is approving the work that rule commits the project
   to, and a reviewer shown only the prose is deciding half of something.
   An implementation PR fills **Spec** and **How to verify**, the latter
   being the `writrun-check-spec-deltas` result plus anything a reviewer should
   re-read by hand.
4. **One spec per PR is the recommended shape** — it is what the
   template's singular "Implements spec-NNNN" assumes. A task with
   several specs completes across several
   PRs, one spec each, the task reaching `done` at the last one's merge; a
   merge that implements a spec without finishing its task is fine, and
   the machinery lands the task back on `ready`, where the lister
   surfaces it as work to resume. When the specs are facets of one atomic change, a
   single PR implementing all of them is also legitimate — the checks
   verify the real contract either way: every implemented spec's promises
   honoured in full, every touched permanent doc promised by at least one
   of them. The same goes a level up: several *tasks* land in one PR when
   their changes form one atomic whole — the union contract covers their
   specs together, each task's transitions are still checked on their
   own, and the PR title tags every one of them.

Releases are tags on `main` (the first: `v0.0.01`, and the third field stays two digits): everything merges to `main`
continuously, a version exists when its tag does, and the changelog is
generated from commit messages. Cut one with `make release` — the number
is computed from the latest tag, never typed: `minor` (the default) bumps
the third digit, `major` the middle one, `epoch` the first (historic
milestones only). The target stamps `.writrun/VERSION`, syncs the
template, runs the suite, then commits, tags, pushes, and publishes the
GitHub Release. While alpha (0.x), a tag may move any part of the
contract without notice — adopters pin the tag they copied `template/`
from.

**What CI does, and what it deliberately doesn't.**

- `writrun check` runs on every PR, from a branch or a fork alike. No
  secrets, no write permission. It is the half that carries the guarantee.
- `writrun approve` records `draft → approved` once the maintainer has
  assented. **Here the assenting act is the merge**, not an approving
  review: every pull request in this repository is authored by its
  maintainer, and no forge lets a person approve their own — a
  review-based gate would be unsatisfiable, and an unsatisfiable gate gets
  worked around, which is worse than no gate. The flip is written to
  `main` after the merge, which is why `main` must stay reachable by the
  Actions token. On this user-owned repository the forge offers no
  bypass for the app, so `main` carries the ruleset half it can — no
  force pushes, no deletions — and everything human still enters through
  a pull request by the project's own rule. Fork PRs need nothing
  special: the merge is the maintainer's either way.
- `writrun issues` mirrors new tasks into GitHub Issues, one direction
  only. **The file under `work/tasks/` is the authority.** An edit made in
  an Issue is not written back.
- `writrun progress` writes the PR's events onto `main` (status and
  `taken_by`) and moves the mirror with them: `status:in-review` while
  open, closed when a merge lands the worker's `completed` date, back to
  `status:ready` if the PR closes unmerged. Without it a finished task
  keeps an open mirror labelled in-progress long after the work landed.

**Task is the noun; a GitHub Issue is only the mirror.** `work/tasks/` is
the authority and an edit made in the mirror is never written back. Where a
repository also uses Issues for bugs and feature requests, the
`writrun:task` label is what separates the two — every workflow filters on
it and touches nothing without it.

**These checks verify the methodology, not the code.** An adopting project
runs its own test suite in its own pipeline; WritRun does not execute it,
duplicate it, or stand in for it. Whether the code works is that pipeline's
answer. Whether the change kept its promises to the docs is this one's.

Approved is not merged: the spec becomes `approved` on your branch, and the
queue only really gains the task when the PR merges.

## Rules that PRs are checked against

- **Behaviour rule changed?** Update the chapter in
  [docs/product/](docs/product/README.md) in the same PR. A spec does not
  own a rule; it implements one.
- **Machinery changed?** Add a dated entry to
  [docs/technical/decisions/](docs/technical/decisions/README.md) in the
  same PR. Entries are append-only — never edit one, add the next.
- **Every path a spec's Proposed-changes sections promised is touched, and
  nothing permanent that isn't listed is.** This is what
  `writrun-check-spec-deltas` checks mechanically.
- **Front matter stays canonical** — one field per line, `key: value`,
  bare values, inline lists; see
  [Front matter is canonical](docs/technical/schemas.md#front-matter-is-canonical).
  `writrun check` rejects any other YAML form; the generator only ever
  writes this one.
- **No new gawk-only or otherwise non-portable shell.** The script-backed
  skills run on plain POSIX `awk`/`sed` — test on macOS's stock
  `/usr/bin/awk`, not just whatever is on your `$PATH`.
- **`bash tests/run.sh` passes**, and a script change brings the case that
  proves it.
- **English everywhere:** prose, commits, documentation.
- **No broken internal links or anchors.** Every `[text](path#anchor)`
  inside `docs/` should resolve to a real file and a real heading.

## Licence, and why there is no CLA

WritRun is [MIT-0](LICENSE) — MIT with no attribution requirement. **There
is no CLA to sign.** Inbound equals outbound: by opening a pull request you
offer your contribution under the same MIT-0 terms as the rest of the
project, and you keep the copyright to your own work.

That is a deliberate choice, not an oversight. A CLA exists to let a
project relicense contributed code — usually for a commercial edition.
WritRun has no commercial edition and no plan for one, so there is nothing
a CLA would secure and no reason to ask you for a signature. Rejected
alternatives: CC0 and the Unlicense — both marginally more permissive, but
MIT-0 is OSI-approved, keeps the warranty and liability disclaimer intact,
and is recognised by the tooling that scans licences.

## Code of conduct

Be decent. Assume good faith, critique the doc and not the person, and
remember that most people here are doing this in their spare time.
