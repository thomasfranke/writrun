---
id: spec-0053
task_ref: task-0037
status: draft
created: 2026-09-02T19:43:20Z
---

# spec-0053 — Rule K refuses a tracked flip that carries anything outside work/

**References:** [task-0037](../tasks/task-0037-rule-k-diff.md)

- **Goal:** a report reaches `tracked` only in a change that is actually
  a reporting change — on a `report/` branch *and* carrying nothing
  outside `work/` — so the rename that clears the name clears nothing,
  and the gate task-0033 built stops being a rule agents keep.

## Scope

In: the second condition in rule K; its refusal message; the
`writrun-check-task-state` Never bullet that today tells agents the
rename "does clear the check", which this change makes false; the
fixture tests; the template mirror; the product sentence naming the
property the prefix only names.

**The two conditions, and why neither alone.** A `tracked` flip is legal
only when both hold:

- **(a) the head branch is `report/…`** — the existing test, kept. It is
  free, and it catches the honest case: a session flipping a report on
  the implementing branch it is already standing on.
- **(b) the diff touches nothing outside `work/`** — new. This is the
  one the rename cannot clear, because an implementing change carries
  code and docs whatever its branch is called.

(b) alone is not enough: a completion change whose spec promised no doc
delta touches only `work/`, and a `tracked` flip riding *that* is still
a ride. (a) alone is what this task exists to end. The rule is the
conjunction.

**(b) is decidable where (a) is not.** The branch half already announces
a skip when no name is readable — detached HEAD with `HEAD_REF` unset.
The diff half needs no name, so it runs there too: a change carrying
code is not a reporting change whatever it is called. The announcement
changes from "Rule K skipped" to naming which half stood down, or a
reader is told the route went unguarded when half of it did not.

Out: **`apply_pr_event.sh` is not a second finding.** Exiting 0 on a
non-`task/` head is correct — a `report/` branch has no task to record.
It reads as a defect only in the rename scenario, which the Never list
already forbids and which no legitimate path reaches; renaming a `task/`
branch is the abuse, and the silence is its cost, not a bug of its own.

Out: the four other report statuses. The rule fires on a `tracked` flip
and on nothing else, so `fixed` and `declined` keep the exemption whole
— [report-0001](../reports/report-0001-conventions-scope.md) is the
worked example, `fixed` with its whole outcome a one-word change to
`check_observance.sh`. A rule shaped "a `report/` branch touches only
`work/`" would refuse it and must not be written.

## Steps

1. Compute, once, whether the range touches any path outside `work/`,
   and the list of those paths for the message.
2. Add condition (b) to rule K, refusing with its own text: name the
   report, name the offending paths, and say the route travels alone.
3. Run (b) on the skip path, and reword the skip so it names the half
   that stood down.
4. Rewrite the skill's Never bullet: the rename no longer clears the
   check, and what it still costs is the ride.
5. The product sentence; `make template-sync`; tests.

## Acceptance criteria (EARS)

- When a report reaches `tracked` in a range touching a path outside
  `work/`, the check shall exit non-zero, naming the report and the
  paths that put it outside.
- When a report reaches `tracked` on a branch not named `report/…`, the
  check shall exit non-zero, as it does today.
- When a report reaches `tracked` on a `report/` branch whose range
  touches only `work/`, the check shall pass.
- When a report reaches `fixed`, `declined` or `authored`, the rule shall
  not fire, whatever else the range touches.
- When no branch name is readable, the check shall announce that the
  branch half skipped and shall still judge the diff half.
- When the stage is below 2, the whole rule shall stand down silently.

## Edge cases

- **A report already `tracked` at the base.** Not re-judged; the flip is
  history. The base is read at the file's own path, as it is today.
- **A completion change touching only `work/`.** Passes (b), fails (a).
  Kept refused — this is why (a) survives.
- **The route recording further reports on its own branch.** All under
  `work/`; passes. The change that routed report-0006 also recorded
  report-0009 and report-0010, and must stay legal.
- **An edit to `work/README.md`.** Inside `work/`, so allowed. The rule
  is about not carrying implementation, not about naming three folders.
- **A range that renames a queue file.** Unchanged: a rename is not a
  report reaching `tracked`, and the existing case pins it.

## Tests required

Extend `tests/unit/check_state/the_tracked_route_never_rides_test.sh`:
a `report/` branch whose diff also edits `docs/product/chapter.md` is
refused; the same diff without that edit passes; `fixed` and `declined`
still ride a change that edits a permanent doc; a detached HEAD carrying
code and a `tracked` flip is refused while a `work/`-only one passes.
Every existing case in that file must still hold unchanged. Mirror test.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] The existing rule K cases pass without edits to their assertions.
- [ ] The skill's Never bullet no longer claims the rename clears the
      check.
- [ ] Template synced; suite green.

## Proposed product changes

- `product/concepts/report.md#recording-rides-any-change--routing-to-the-queue-does-not` —
  say what the `report/` prefix is: the name a reporting change carries,
  never what makes it one. What makes it one is that it carries the
  report, the task and the spec the route mints, and nothing else.

## Proposed technical changes

- none — `technical/reporting.md` defers the route's statement to
  `concepts/report.md` on purpose, "so the route has one statement and
  not three", and the machinery this change touches is a script, not a
  technical chapter.

## Outcome

_(fill after execution)_
