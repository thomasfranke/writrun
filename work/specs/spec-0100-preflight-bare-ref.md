---
id: spec-0100
task_ref: task-0072
status: implemented
created: 2026-09-17T19:50:00Z
---

# spec-0100 — Arguments told apart by shape, and a warning read at the range's head

**References:** [task-0072](../tasks/task-0072-preflight-bare-ref.md)


- **Goal:** `preflight.sh origin/main` runs the three stages against the
  working tree, and a two-ended run over uncommitted completion edits
  says so instead of passing.

## Scope

One script, `.writrun/scripts/stage-1-tasks-and-specs/preflight.sh`,
and its tests. The stage-2 gates already read the bare shape through
`ql_range_ends`; nothing in them changes.

`.writrun/` is carried whole by `tests/kit_mirrors.txt`; the kit copies
come from `make kit-sync`.

**Out of scope.** The default range stays `origin/main...HEAD`: with no
argument, preflight judges what CI will judge. No flag is added — the
rule chose shape over a named option so that no caller changes. The
stages' own reading of the bare shape is not re-specified here.

## Steps

1. Replace the `*..*` / `*` arms of the argument loop with a
   classification: an argument is a task list when every comma-separated
   entry matches a task id (`task-NNNN`, `task/NNNN…`, or digits alone);
   otherwise it is the range. Two of either kind stay refused with the
   existing wording; `-*` stays the unknown-option refusal.
2. Hand `RANGE` to stages 2 and 3 exactly as classified — the bare ref
   included — and print it in the `PREFLIGHT OK` line as given.
3. Read `completed` for the warning at the range's head: resolve the
   range with `ql_range_ends`; an empty `QL_HEADREF` reads the task
   file from the checkout, a non-empty one reads it with
   `git show <headref>:<path>`. A task file absent at the head — a task
   created on this branch and not yet committed — is read as having no
   completed date, and the warning says which end it read.
4. Extend the usage line and the header to name the bare shape and what
   the warning reads — documentation of the change, not an addition.
5. `make kit-sync`.
6. Record the decision: preflight's arguments are told apart by the
   task list's shape, and the warning reads the end the stages read.

## Acceptance criteria (EARS)

- When `preflight.sh task-0001 origin/main` is run, the run shall treat
  `origin/main` as the range and hand it to stages 2 and 3 unchanged.
- When `preflight.sh origin/main` is run on a `task/` branch, the task
  shall still be inferred from the branch and the bare ref taken as the
  range.
- When a bare ref is the range and the completion edits sit uncommitted
  in the checkout, stage 2 shall judge the promised deltas and stage 3
  shall judge the transitions those edits make.
- When a two-ended range is given and the task's `completed` is null at
  the range's head, the warning shall print, whatever the checkout's
  copy says.
- When two arguments both read as task lists, or both as ranges, the
  run shall exit 4 with the existing refusal.
- When no range is given, the default shall stay `origin/main...HEAD`.

## Edge cases

- **A ref that looks like digits** — a branch named `0034` — reads as a
  task list. That is the rule's own trade, stated as such: name the
  range with `..` or `...` to disambiguate, as before.
- **`HEAD` bare** is the working tree against `HEAD`, which is what
  `check_deltas.sh` defaults to alone; preflight passes it through.
- **A task file that exists only in the checkout** has no head-side
  copy under a two-ended range; the warning names that as the reason
  rather than crashing on `git show`.
- **Offline.** The bare shape needs `origin/main` to resolve as much as
  the default does; the existing stale-base note covers it.

## Tests required

- Unit for the classification: each accepted id form, a comma list, a
  bare ref, a two-dot and three-dot range, two lists, two ranges.
- Integration: a checkout with uncommitted completion edits — bare ref
  judges them (stage 2 names the spec), two-ended range prints the
  warning and does not name it. A task created on the branch and read
  at a head that lacks it.
- The kit mirror unit test passes with no new exception.

## Definition of Done

- [ ] `preflight.sh <ids> origin/main` and `preflight.sh origin/main`
      both run the three stages against the working tree.
- [ ] The completion warning reads `completed` at the range's head.
- [ ] `make kit-sync` leaves the kit byte-identical, no new entry in
      `tests/kit_exceptions.txt`.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- none — no product chapter changes; the rule is technical and already
  written in `technical/distribution/preflight.md#a-bare-ref-reaches-the-working-tree`
  by the change this task derives from.

## Proposed technical changes

- `technical/distribution/preflight.md#preflightsh--the-completion-gates-in-order`
  — the usage block names the bare shape beside the default.
- `technical/decisions/pull-requests/0080-preflight-tells-its-arguments-apart-by-shape.md`
  — the record: why shape over a flag, and why the warning follows the
  range rather than the checkout.
- `technical/decisions/README.md` — the index gains the record's line.

## Outcome

Built as planned, in one script and its cases, with the classification
split in two where the spec wrote it as one.

**`is_task_id` and `is_task_list`.** The rule is per-entry — *every*
comma-separated entry is a task id — so the per-entry question is its
own function and the per-argument one calls it. The three spellings it
accepts are the three the queue uses: `task-NNNN`, the branch form
`task/NNNN-…`, and the bare number that every `[TASK-NNNN]` tag and
every filename prints. One entry that is not an id makes the whole
argument a range, because a task list with a ref in it is not a list
this run could honour.

**An empty argument is skipped rather than classified.** It used to land
harmlessly in the task list; under the new rule it would have landed in
the range and silently occupied the slot a real range wanted.

**The warning's wording names the end it read**, which the spec asked
for as a clause and is here a phrase in the sentence itself — *"has no
completed date in HEAD"*, *"in the working tree"*. A warning that says a
date is missing without saying where it looked is the same silence one
step quieter.

**The two cases that reproduce the finding are one file.** The spec
listed them as three fixtures; they share one setup — a queue held
mid-flight at the base, the implementation committed, the completion
edits written and not committed — and reading them apart would hide that
the bare shape and the two-ended one are two readings of *one* tree.
Getting that fixture right took two attempts: a range whose ends are the
same commit is refused by the state gate for selecting nothing, and a
spec committed inside the range is read as implemented there — neither
is the reported flow, and both had to be excluded for the case to be
about this rule rather than about the gates it calls.

The chapter's usage block gained the bare shape as a second example
rather than a sentence, since what a reader needs there is the command
they can paste.
