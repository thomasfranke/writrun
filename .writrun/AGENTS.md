# WritRun — the agent flow

This file is WritRun's: `writ update` replaces it whole, and hand edits
here do not survive a refresh. The project's own answers — who approves
what — live in [`gates.md`](gates.md), which no update touches. Humans:
this file is written for agents; the guide written for you travels with
the kit as `WRITRUN.md`.

## Picking work

Use the [`writrun-select-next-task`](skills/writrun-select-next-task/SKILL.md)
skill. A task is available only when it is `ready` — a status the
machinery writes from the fact that every spec in its `spec_ref` is
`approved`. A `backlog` task has not passed the approval gate, so it is
not authorized work.

## Creating tasks and specs

Use the
[`writrun-create-task-and-spec`](skills/writrun-create-task-and-spec/SKILL.md)
skill — it covers id assignment, front-matter, when a spec is warranted,
and the Proposed changes sections. A queue file touched by hand — a body
edited, a status flipped — must pass
[`writrun-check-front-matter`](skills/writrun-check-front-matter/SKILL.md)
before it is committed.

## Taking a task

Branch as `task/NNNN-short-name`, push, and open the pull request **as a
draft before the work starts** — the branch is invisible until it
reaches the forge, and the draft is the event the machinery answers by
writing `in-progress` and your login onto the queue. Never write the
task's status line yourself; it has one writer, and it is not you. Mark
the pull request ready for review when the work is done.

From Stage 2 that whole act is one command — the eligibility re-checked,
the branch cut from a fresh `origin/main`, pushed, and the draft opened:

```bash
bash .writrun/scripts/stage-2-pull-requests/take_task.sh NNNN \
  --title "<summary>"
```

**The push and the opening are one act.** Under `stage_2.auto_push` or
`stage_2.auto_pr` set to `false`, compose the branch name, the title and
the body, present them together, and put nothing on the forge before an
explicit yes — the gate is about work becoming public, so it holds the
whole moment rather than its second half.

## Recording what you noticed

Something observed mid-work that is not this task is a **report**: one
file in `work/reports/`, one paragraph, no commitment. It says what was
seen — what should be done about it is triage's output, never the
report's content.

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh report "<title>" \
  --slug <two-or-three-words> [--doc-ref path/to/doc.md#anchor]
```

**Recording rides whatever change is already open.** A report is neither
a rule nor work, so the one-kind-per-change rule does not reach it, and
a finding that costs its own branch is a finding nobody writes down.

Triage ends it, one of four ways: `tracked` when a task now carries the
work, `authored` when no rule said what "correct" was and a rule was
written, `fixed` when a trivial change handled it, `declined` when it is
not a defect or not worth acting on — with the reason kept in the body.
`fixed` and `declined` are yours to write; declining destroys nothing,
and the file stays where a person can disagree with it.

**The `tracked` route is the one that never rides.** It puts work in the
queue, so it takes a `report/` branch of its own carrying the report,
the task and the spec together — and the merge of that pull request is
the assent that the finding deserves the work.

## Human gates

Who operates each gate is the project's own answer, and it lives in
[`gates.md`](gates.md) — read it before any transition it names:
approving a spec, touching `docs/`, deriving work, changing forge
settings, or acting on a task whose brief is insufficient. A gate
`gates.md` leaves unnamed is a question for the human, never a default
to assume.

## Deriving work

When derivation runs (a rule authored, or work discovered), whether the
derived tasks and specs are presented in the session before the PR opens
is [`gates.md`](gates.md)'s to say.

## Completing a task

1. Implement against the approved spec — never from the task's title.
   The title names the act; the spec and the anchors it references are
   the brief.
2. Update every permanent doc listed in the spec's **Proposed changes** —
   in the same change; touch nothing permanent that isn't listed.
3. Fill the spec's **Outcome**, set the spec to `implemented`, then run
   preflight — `writrun-check-front-matter`, `writrun-check-spec-deltas`
   and `writrun-check-task-state`, in the one order they must run, which
   is CI's own — and mark the pull request ready on nothing else:

   ```bash
   bash .writrun/scripts/stage-1-tasks-and-specs/preflight.sh
   ```

**The task's status line is not yours to write.** From Stage 2 the
machinery owns it: the draft pull request makes the task `in-progress`,
ready-for-review makes it `in-review`, the merge makes it `done`. What
you write on the task is its `completed` date — by hand, when the work is
finished. At Stage 1 no workflow runs, so a person moves the status
deliberately and says so in `gates.md`.

## The settings

[`settings.json`](settings.json) is the adopter's file and the first
edit after adoption: the stage, the conduct flags that say who presses
commit, push and open, and the title style everything else here obeys.
It ships cautious — `stage: 1` and all three flags `false` — so a fresh
copy does nothing on its own until the project says otherwise. It is
adopter-owned like [`gates.md`](gates.md), and `writ update` touches
neither. The schema is in the WritRun repository's
`docs/technical/settings/`.

Commit messages, branch names, PR titles, and task/spec style:
[`conventions/`](conventions/README.md).
