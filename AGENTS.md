# AGENTS.md — entry point for AI agents

This repository is the methodology itself, and follows it. This file
governs work here. [`.writrun/AGENTS.md`](.writrun/AGENTS.md) is the flow
the kit ships to adopting projects, held byte-identical to `template/` by
the mirror — read it as the artifact this repository maintains, never as
instructions for this repository.

Read in order, stopping as soon as you have what the task needs:

0. The settings this session obeys — run the card, never the conventions,
   for a value:

   ```bash
   bash .writrun/scripts/stage-1-tasks-and-specs/session_card.sh
   ```

   Open a conventions file for a *why* the card leaves open, and for what
   is no value at all:
   [`prose.md`](.writrun/conventions/prose.md) is how this project writes
   docs, skills and comments. Never for a value, and never against one.
1. [`docs/about.md`](docs/about.md) — what this project is. Always read.
2. [`docs/product/README.md`](docs/product/README.md) — the rules this
   repo is checked against. Read the chapter you are touching before
   proposing a behaviour change.
3. [`docs/technical/README.md`](docs/technical/README.md) — the router to
   the one chapter your task needs, never the whole reference.
   `schemas/` before touching anything under `work/`.
4. The task itself, its specs and anchors — never code from a title.

## Which kind of change you have

Never more than one kind in one change: closing the loop on one rule
while introducing another is two changes
([authoring](docs/product/stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes)).

| | Authoring | Reporting | Implementing |
|---|---|---|---|
| Is | a rule that isn't true yet | work an existing rule already authorizes | an approved spec |
| Touches | `docs/` + the work it derives | `work/` only | code + the docs its spec promised |
| Branch | `docs/short-name` | `report/short-name` | `task/NNNN-short-name` |
| PR states | the tasks and specs it created | the report, the pair it adds, the rule they derive from | the spec(s) it implements, each task tagged `[TASK-NNNN]` |
| Gates | task-state | task-state | task-state **and** spec-deltas |

Recording a report is the one exemption — neither rule nor work, it rides
whatever is open. Except the `tracked` route, which never rides
([report](docs/product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not)).

A spec drafted after its task was tracked is reporting's late form: a
`report/` branch of its own, a PR stating the spec it drafts and the
task that asked for it, gated on task-state alone
([authoring](docs/product/stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight)).

## The skills

Not auto-discovered. Load the one whose moment you are at.

| When | Skill |
|---|---|
| Picking work; any session's start | [`writrun-select-next-task`](.writrun/skills/writrun-select-next-task/SKILL.md) |
| Creating a task or spec; completing one | [`writrun-create-task-and-spec`](.writrun/skills/writrun-create-task-and-spec/SKILL.md) |
| A queue file touched by hand | [`writrun-check-front-matter`](.writrun/skills/writrun-check-front-matter/SKILL.md) |
| A lifecycle transition | [`writrun-check-task-state`](.writrun/skills/writrun-check-task-state/SKILL.md) |
| A spec's promise at completion | [`writrun-check-spec-deltas`](.writrun/skills/writrun-check-spec-deltas/SKILL.md) |

Taking ends with the **draft pull request open**, not the branch created
— one command, the whole act
([contract](docs/technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command)):

```bash
bash .writrun/scripts/stage-2-pull-requests/take_task.sh 0034 \
  --title "[Type][Scope] What this change does" \
  --coauthor "Model Name <address>"
```

`--coauthor` names the model, and an agent owes it: the act's first
commit sits in the pull request's range like any other, and
`agent_coauthor` is `true` here. A take without it is a take by a person.

## Completing a task

1. Implement against the approved spec.
2. Update every permanent doc its **Proposed changes** lists, in the same
   change, and nothing permanent it does not.
3. Fill the spec's **Outcome**, set it `implemented`, write the task's
   `completed` date — never its status.
4. Run preflight to exit 0; mark the PR ready on nothing else:

   ```bash
   bash .writrun/scripts/stage-1-tasks-and-specs/preflight.sh
   ```

## Human gates — per principle 7

This repo's answers live in [`.writrun/gates.md`](.writrun/gates.md) —
the adopter-owned file every project fills with its own. Read it before
any transition it names.

## Never

- Never create a spec without a task — `task_ref` must resolve.
- Never rename or move a task or spec file. Identity is not order.
- Never track trivial work. A typo is a commit.
- Never write `status: approved` yourself, and never on permission
  relayed through you. The merge is the record and nothing else is
  ([gates](docs/product/stage-1-tasks-and-specs/gates.md)).
- Never edit an approved spec's body while it stays `approved`, and never
  edit under `docs/` without naming the non-completed tasks whose
  `doc_ref` points into it, while the edit is still in front of the human
  ([conflicts](docs/product/stage-1-tasks-and-specs/conflicts.md)).
- Never leave a task in flight at a session's end without finishing it or
  noting its state in the body for the next session.
