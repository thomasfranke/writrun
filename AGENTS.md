# AGENTS.md — entry point for AI agents

You are working on the repository of the methodology itself, and this repo
follows its own structure. Read in this order, stopping as soon as you have
what the task needs:

1. [`docs/about.md`](docs/about.md) — what this project is. Always read.
2. [`docs/product/README.md`](docs/product/README.md) — the prescriptive
   rules this repo's own structure is checked against. Read the chapter
   relevant to what you're touching before proposing a behaviour change.
3. [`docs/technical/README.md`](docs/technical/README.md) — schemas and the
   selection algorithm. Read before touching `tasks/` or `specs/`.
4. The specific task and its referenced specs/anchors — never code from the
   task title alone.

## Picking work

Use the [`writrun-select-next-task`](.writrun/skills/writrun-select-next-task/SKILL.md) skill. In
this repo, "active owner" for its resume step means **this session**: any
`in-progress` task not started by you in the current session is resumable,
and you resume it before selecting new work.

A task is available only when it is `pending` **and** every spec in its
`spec_ref` is `approved`. A draft spec has not passed the approval gate, so
the task is not authorized work — if every task is held back that way, say
so rather than reporting an empty queue.

**Taking a task ends with its draft pull request open, not with the
branch created.** Branch as `task/NNNN-short-name`, set the task
`in-progress`, push, and open the PR as a draft *before* implementing —
the branch is invisible until it reaches the forge, and the draft is
what moves the mirror to `status:in-progress`. Mark it ready for review
when the work is done, which moves the mirror to `status:in-review`.

## Creating tasks and specs

Use the [`writrun-create-task-and-spec`](.writrun/skills/writrun-create-task-and-spec/SKILL.md)
skill — it covers id assignment, front-matter, when a spec is warranted,
and how to fill the Proposed changes sections.

Any queue file touched by hand — a body edited, a status flipped,
anything `new.sh` did not write — must pass
[`writrun-check-front-matter`](.writrun/skills/writrun-check-front-matter/SKILL.md)
before it is committed: the generator only ever produces canonical form,
and the line-based readers silently misread anything else.

## Which kind of change you have

Two, and they are not handled the same way — see
[`tasks-and-specs/authoring.md`](docs/product/tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes).

| | Authoring | Tracking | Implementing |
|---|---|---|---|
| Is | a rule that isn't true yet | work discovered that an existing rule already authorizes | an approved spec |
| Touches | `docs/` + the work it derives | `work/` only — no permanent doc | code + the docs its spec promised |
| Branch | `docs/short-name` | `queue/short-name` | `task/NNNN-short-name` |
| PR states | the tasks and specs it created | the tasks and specs it adds, and the rule they derive from | the spec(s) it implements, every carried task tagged `[TASK-NNNN]` leading the title |
| `writrun-check-spec-deltas` | does not apply | does not apply | must exit 0 |
| `writrun-check-task-state` | must exit 0 | must exit 0 | must exit 0 |

Never more than one kind in one change. A change that closes the loop on
one rule while introducing another is two changes.

When derivation runs (authoring or tracking), **present the derived tasks
and specs in the session before opening the PR** — the human reviews the
queue the rule creates while the feedback loop is still cheap. Open
directly only when the declaration itself says so ("deriva e abre
direto"). The default is the adopter's to change.

Commit messages, branch names, PR titles, and task/spec style follow
[`.writrun/conventions/`](.writrun/conventions/README.md) — read the relevant file before
writing; it is this repository's own convention and every project you
work in may have rewritten it.

**The values live in
[`settings.json`](.writrun/conventions/settings.json); the `.md` files
explain them.** Read the settings before writing a branch name, a commit
subject or a PR title — the tag, the branch prefixes and the label names
are settings, not constants, and a project you work in may hold different
ones. Where the two ever disagree, the settings file is what the machinery
obeys, so it is what you obey.

When you edit anything under `docs/`, check `work/tasks/` for
non-completed tasks whose `doc_ref` points into the files you are
editing, and name them to the human while the edit is still in front of
them — CI re-checks the same overlap (`writrun check`, queue impact), but
at review time the warning is already one step late. A spec invalidated
by the edit follows the special flow: amended, returned to `draft`,
re-approved. Never edit an approved spec's body while it stays
`approved`.

## Human gates — explicit, per principle 7

This is this repo's concrete answer to the general rule in
[`docs/product/tasks-and-specs/gates.md`](docs/product/tasks-and-specs/gates.md)
— every adopting project states its own version of this table.

| Transition | Who |
|---|---|
| Writing or changing anything under `docs/` | Human writes or human reviews before merge. Agents may draft; permanent docs never merge on agent approval alone. |
| An authored rule is finished, so derivation may start | **Human declares it.** No event marks the last edit of a rule, so the handoff is a signal, never an inference: invoking `writrun-create-task-and-spec`, or marking the authoring PR ready for review. An agent never derives from a doc edit nobody declared finished. A forgotten handoff is caught, not remembered: `writrun check` fails an authoring PR that neither adds tasks nor declares "Derived work: none". |
| Spec `draft → approved` | **Human only.** The assenting act here is **the maintainer's squash-merge** — this repository's pull requests are authored by its maintainer, who cannot review them, so a review-based gate would never be satisfiable. CI records the flip on `main` after the merge. Never self-approve, and never write the field on verbal permission relayed through you: a merged PR is the record, and nothing else is. |
| Task with empty `spec_ref` | If the task body + `doc_ref` is not a sufficient brief, **stop and ask for a spec** — do not improvise scope. |
| Everything else (creating tasks, drafting specs, implementing approved specs, filling Outcome) | Agent, autonomously. |

## Completing a task

1. Implement against the approved spec.
2. Update every permanent doc listed in the spec's **Proposed changes** — in
   the same change. Touch nothing permanent that isn't listed; if reality
   demands it, update the spec's proposal first.
3. Run [`writrun-check-spec-deltas`](.writrun/skills/writrun-check-spec-deltas/SKILL.md). Do not
   proceed on anything other than exit 0.
4. Fill the spec's **Outcome** section, including divergences, and set
   spec `status: implemented`, task `status: completed`, `completed` date
   (also covered by `writrun-create-task-and-spec`).
5. Run [`writrun-check-task-state`](.writrun/skills/writrun-check-task-state/SKILL.md), **after**
   step 4 and not before. Every rule it has is about a transition, and the
   transitions it exists to reject are the ones step 4 makes — run it
   earlier and it passes without reading anything. Do not open the PR on
   anything other than exit 0.

## Never

- Never create a spec without an existing task (`task_ref` is mandatory and
  must resolve).
- Never rename or move a task or spec file. Identity is never order.
- Never track trivial work. A typo is a commit.
- Never leave a task `in-progress` at the end of a session without either
  completing it or noting its state in the task body for the next session to
  resume from.

