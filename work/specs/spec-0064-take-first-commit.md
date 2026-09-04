---
id: spec-0064
task_ref: task-0045
status: implemented
created: 2026-09-04T15:18:28Z
---

# spec-0064 — The taking act commits before it asks for the pull request

**References:** [task-0045](../tasks/task-0045-take-first-commit.md)

- **Goal:** `take_task.sh` leaves behind the state its contract promises —
  a branch on the forge with a draft pull request open — on a fresh take,
  every time.

## Scope

In: the one act `take_task.sh` performs, on both its paths.

- The fresh path commits between cutting the branch and pushing it, so
  the push carries something the forge will open a pull request against.
- The `--resume` path does not commit a second time onto a branch that
  already carries one.
- The refusal that judges `--title` names the cause it actually found.

Out: `--resume`'s refusal of a branch already on the forge. It is
correct as written — what `--resume` finishes is an interrupted take —
and once the fresh path stops failing, the state it refuses stops being
reachable by this defect. Widening it while the cause is still there
would paper over the cause.

Out: the pull request body's own shape, which is
[spec-0062](spec-0062-body-references.md)'s and lands separately.

**What the commit carries is the decision, and the answer is nothing.**
Three candidates were weighed:

- *Stamp the task file* — rejected, and not by taste. `taken_by` and
  `in-progress` have exactly one writer from Stage 2, and it is the
  machinery reacting to the `pull_request` event on the authority
  branch; `product/stage-2-pull-requests/statuses.md` states that a
  branch never edits the status line, because two writers on one line is
  a merge conflict by construction. The take would be the second writer.
- *Open the provenance ledger* — rejected. It is the one machine field a
  branch may write, but only by appending, and an entry is never edited
  once written (`record_provenance.sh`). An entry opened before any work
  exists could never be filled in.
- *An empty commit* — chosen. The take genuinely produced no content,
  and an empty commit is the honest record of that. The squash-merge
  discards it, so nothing of it reaches `main`.

## Steps

1. In `take_task.sh`, between the `git switch` block and the `git push`,
   commit with `--allow-empty` and a Conventional Commits subject under
   an existing scope — `chore(tasks): take task-NNNN`.
2. Guard it on the resume path: commit only where
   `origin/main..HEAD` is empty, so an interrupted take that already
   committed is finished rather than given a second marker.
3. Carry the credit the pull request will declare. Where
   `stage_2.agent_coauthor` is `true`, this commit is an authored commit
   in the pull request's range and owes the trailer like any other.
4. Move the `--title` refusal off the wrong cause: state that the
   `[TASK-NNNN]` tag is this script's to prepend and that `--title`
   takes the summary alone, beside the example that already prints.
5. `make template-sync` — `.writrun/` is mirrored into `template/`.
6. Update `technical/distribution/take-task.md` to state the first
   commit as part of the act.

## Acceptance criteria (EARS)

- When `take_task.sh` runs on an eligible task with no `--resume`, the
  system shall create one commit on the new branch before pushing it.
- When that commit is created, the system shall write it empty, with a
  subject the commit vocabulary in `conventions/commits.md` accepts.
- When `stage_2.agent_coauthor` is `true`, the system shall write that
  commit with the same co-author trailer the pull request body's credit
  line declares.
- When `take_task.sh` runs with `--resume` on a branch already carrying
  a commit ahead of `origin/main`, the system shall push and open the
  pull request without committing again.
- When `--title` is given a summary the declared style refuses, the
  system shall name the `[TASK-NNNN]` tag as the script's own before
  printing the example.

## Edge cases

- **`agent_coauthor` is `false`.** The commit carries no trailer and no
  generated-with line; `check_observance.sh` faults the other direction
  on the same commit if it does.
- **A dirty tree.** Already refused before the branch is cut, so the
  commit can never pick up unrelated work — the guard that made the
  empty commit safe was there before it.
- **`auto_push` or `auto_pr` is `false`.** The script composes and
  stops before cutting anything, so the commit is not reached; the gate
  is unchanged.
- **A second take of a task already in flight.** Refused earlier, on
  `taken_by` and on the branch already existing.

## Tests required

- A unit case over the fresh path: the branch has exactly one commit
  ahead of `origin/main` when `git push` is called, and it is empty.
- A unit case over `--resume` with a commit already present: no second
  commit is made.
- A unit case over the refusal text: a title carrying `[TASK-0001]` is
  refused by a message naming the tag as the script's.
- The existing `gh`-stubbed integration tier covers the act end to end;
  the fresh-take case must reach `gh pr create` rather than stopping at
  the push.

## Definition of Done

- [ ] `take_task.sh` commits on the fresh path and not on a resumed one.
- [ ] The refusal names the tag as the script's own.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] `take-task.md` states the first commit.
- [ ] A fresh take on this repository opens a draft pull request with no
      hand-work — the observation in
      [report-0019](../reports/report-0019-take-needs-commit.md) is not
      reproducible.

## Proposed product changes

- none — the rule already stands. `conventions/prs.md` states that the
  push and the opening are one act, and
  `product/stage-2-pull-requests/statuses.md` states who writes the
  status line. This spec brings the script up to both; restating either
  beside it is the second copy that disagrees later.

## Proposed technical changes

- `technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command`
  — the act's description gains its first commit: what it is, that it is
  empty, and that `--resume` does not repeat it.

## Outcome

Built as planned, steps 1–6. `take_task.sh` commits between the switch
and the push — `git commit --allow-empty`, subject
`chore(tasks): take task-NNNN` — guarded on
`git rev-list --count origin/main..HEAD` being zero, so a resumed take
that already committed is pushed as it stands. The `--title` refusal
gained a line naming the leading `[TASK-NNNN]` tag as the script's to
prepend, above the example it already printed. `template/` is synced and
`take-task.md` carries a new subsection, *The first commit, and why it
is empty*, holding what it is, that the squash-merge discards it, why it
writes neither the status line nor a ledger entry, and that it is made
once.

**Step 3 needed an interface the spec did not name, and got one.** The
trailer has to name the model, and the model is the one thing the script
cannot read: an agent commits under the same name and address as the
person who ran it, and no environment variable carries the model. So the
name is given — `--coauthor "Name <address>"` — rather than inferred.
Where `stage_2.agent_coauthor` is `false` the flag is refused, which is
the other direction `check_observance.sh` reads. Where it is `true` and
no `--coauthor` is given, the commit carries no trailer and the run says
so in two lines, because a person taking a task owes none and a silent
omission is what an agent would ship. `resume_command()` carries the flag
too, on the same reasoning that already put `--slug` and `--confirm`
there: the printed rerun performs the act that was interrupted.

**One consequence not closed here.** Neither `AGENTS.md` take example
passes `--coauthor` — this repository's, nor the kit's in
`.writrun/AGENTS.md` — so an agent following either gets an untrailered
first commit, and the printed reminder rather than silence. Correcting
them is a permanent-doc edit this spec's Proposed changes does not list,
so it is left to a change that declares it.

Two smaller divergences. `--resume` on a branch cut but never committed
now commits, which is step 2's guard read literally and a slight widening
of what the resume does; the case is covered. And
`the_act_is_one_motion_test.sh`'s "cut from `origin/main`" assertion had
to move from `HEAD` to `HEAD^`, since the tip is now the first commit.

Tests: the Tests required list's fourth item asks the `gh`-stubbed
integration tier to reach `gh pr create`. That tier is
`tests/unit/take_task/`, which stubs only `gh` and runs real git against
a real bare remote — there is no take_task directory under
`tests/integration/` — so the end-to-end assertion sits in the new
`the_first_commit_opens_the_draft_test.sh` beside it, together with the
fresh-path, credit and resume cases. The refusal-text case went into the
existing `the_title_is_held_to_the_style_test.sh`, which already owns
that refusal.
