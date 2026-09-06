---
id: spec-0085
task_ref: task-0060
status: draft
created: 2026-09-06T02:23:44Z
---

# spec-0085 — The doc_ref draft refusal reads only what still derives

**References:** [task-0060](../tasks/task-0060-prerelease-fixes.md)

- **Goal:** the front-matter sweep refuses a `doc_ref` into a draft
  chapter only where the record still derives from it — a finished
  record is history, and history is not derivation.

## Scope

In: `check_front_matter.sh`'s `check_doc_ref` — the draft refusal #225
added, and only it. The resolution check (the file must exist) stays
universal: a broken link is broken in history too.

Out: the derived-work and promise gates — they judge changes, not
standing files, and already read the marker correctly per shape
(spec-0084's fix included).

Out: the resolution check's own retroactive shape — the day a chapter
is deleted outright, every historical `doc_ref` into it fails the same
sweep the same way. That is a real edge of the same class, but it is a
different rule (deletion is declared, demotion is marked) and nobody
has observed it biting; it earns its own report when it does, not a
ride here.

**Why the refusal overshoots.** The rule is "nothing derives from a
chapter that is not a rule yet" — derivation, present tense. A
completed task's `doc_ref` derives nothing; it records what the task
derived from, as it stood then. But the sweep reads every queue file
with no status filter, so the demotion `check_derived_work.sh`
explicitly supports — rule to draft, with a declaration — poisons the
queue retroactively the moment it merges: every completed task and
triaged report pointing into that chapter fails the sweep on every
later run, blocking unrelated pull requests until history is edited.
Editing history is the one repair the methodology forbids, so the gate
as written makes the sanctioned demotion unusable in practice.

**The line is the one `conflicts.md` already draws** — "the
non-completed tasks whose `doc_ref` points into it" is who an edit
under `docs/` answers to. The same line, applied to the sweep:

| Kind | Still derives — refusal applies | History — refusal passes |
|---|---|---|
| task | `backlog`, `ready`, `in-progress`, `in-review`, `blocked` | `done`, `dropped` |
| report | `open` | `tracked`, `authored`, `fixed`, `declined`, `routed` |

A `dropped` task derives nothing by definition; a report's status is
the route triage took, and every route but `open` is an end. A file
created today pointing into a draft is live by construction, so the
refusal #225 exists for — new derivation from a non-rule — still fires
on every path that creates one.

## Steps

1. Give `check_doc_ref` the file's status — read it from the same
   front-matter block the caller already holds, or pass it in from
   `check_task` / `check_report`; whichever keeps one read.
2. Guard the draft refusal, and it alone, on the live statuses in the
   table. The existence check and the shape check run for every status,
   unchanged.
3. Say why in the refusal's comment: present-tense derivation, the
   demotion path, and `conflicts.md`'s line — the next reader should
   not have to rediscover this spec.

## Acceptance criteria (EARS)

- When a task whose status is `done` or `dropped` carries a `doc_ref`
  into a draft chapter, the sweep shall pass it.
- When a task in any other status carries one, the sweep shall refuse
  with the draft message.
- When a report whose status is any route but `open` carries one, the
  sweep shall pass it.
- When an `open` report carries one, the sweep shall refuse.
- When any queue file's `doc_ref` names no file, the sweep shall refuse
  regardless of status, exactly as today.
- When a rule chapter is demoted to a draft with a declaration, the
  sweep over the existing queue shall still exit 0.

## Edge cases

- **A `blocked` task pointing into a draft.** Live — it will be worked,
  so it derives, so it refuses. The one legitimate shape, a task
  waiting on the chapter's graduation, states that in `blocked_reason`
  and points at the chapter the day the marker leaves; until then the
  refusal is telling the truth.
- **A `done` task whose chapter was a draft all along.** Impossible to
  create through the gates (the refusal fired at creation), but a hand
  -written file is exactly what this skill sweeps — passed, because the
  status filter cannot distinguish it from sanctioned demotion, and the
  merge that made it `done` is the record that someone accepted it.
- **Status unreadable or missing.** The file already fails the sweep's
  status checks on its own; the draft refusal need not fire twice. Treat
  unreadable as live if the guard needs an answer — strict by default.

## Tests required

- One fixture per row of the table: `done` and `dropped` tasks pass,
  one live status refuses (the loop over all five is the
  implementation's choice); non-`open` report passes, `open` refuses.
- The demotion scenario: a queue holding a completed task whose
  `doc_ref` points into a chapter, the chapter demoted, the sweep exits
  0 — the end-to-end shape that today deadlocks.
- The existing draft-refusal cases from #225 pass unchanged — every one
  of them creates a live file.

## Definition of Done

- [ ] A finished record pointing into a draft chapter passes the sweep.
- [ ] Every live queue file pointing into one still refuses.
- [ ] Resolution and shape checks unmoved, every status.
- [ ] The product chapter states the line the machinery now draws.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- `product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet`
  — one sentence beside "nothing may point into it": a finished
  record whose `doc_ref` names the chapter is history, not derivation,
  and the refusal binds live queue files only. The rule's word is
  already "derives"; this writes down what that tense means for the
  sweep.

## Proposed technical changes

- none — no technical chapter states the draft refusal;
  `check_front_matter.sh` carries its own contract, and `.writrun/`
  reaches `template/` through `make template-sync`.

## Outcome

_(fill after execution)_
