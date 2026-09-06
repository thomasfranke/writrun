---
id: spec-0083
task_ref: task-0059
status: implemented
created: 2026-09-05T23:56:07Z
---

# spec-0083 — Nothing points into a draft chapter

**References:** [task-0059](../tasks/task-0059-nothing-points-into.md)

- **Goal:** a `doc_ref` into a draft chapter and a **Proposed changes**
  path naming one are both refused, each where it enters.

## Scope

In: `check_front_matter.sh`'s `check_doc_ref`, which today refuses a
`doc_ref` naming no file and accepts every path that resolves.

In: `check_promise_paths.sh`, which today refuses a promise path that
cannot resolve under `docs/` and accepts every one that can.

Out: `check_derived_work.sh` — [spec-0082](spec-0082-a-draft-only.md)
has it, and this task depends on that one for the marker reader rather
than growing a third copy.

Out: `check_deltas.sh`. It compares a spec's promised paths against the
diff at completion, by which point the promise has already been refused
at the door by `check_promise_paths.sh` — the door is where a promise is
judged ([observance](../../docs/technical/settings/observance.md#observance-is-checked-where-it-leaves-a-trace)),
and a second refusal at completion would be one rule with two
implementations.

**Both refusals are about the same thing, and it is not resolution.** A
path into a draft chapter resolves perfectly — the file is there, the
anchor is there. What is missing is the rule. So the refusal says that,
not "not found": a message reading `names no file` for a chapter sitting
in the tree would send the reader looking for a typo that is not there.

**Where the marker is read from differs between the two, and neither is
the diff.** `check_front_matter.sh` runs over the whole queue in a
checkout and has no range at all, so it reads the working tree.
`check_promise_paths.sh` takes a range and reads the head end, which is
the version whose promise is being judged. Stated here because a reader
who assumes one shape for both will write the second one wrong.

**The reader is spec-0082's.** That task lands `is_draft` inside
`check_derived_work.sh`. Whoever writes this one decides, against what
they find, whether it moves to a shared place or is copied with the
reason written down — a helper in a third script that neither of the
first two can call is the outcome to avoid, and `queue_lib.sh` is where
this repository puts a reader more than one script needs.

## Steps

1. Reuse or relocate spec-0082's marker reader; do not write a third.
2. `check_doc_ref`: after the existing resolution check passes, refuse a
   target whose file declares itself a draft, naming the chapter and the
   rule — nothing derives from a draft chapter.
3. `check_promise_paths.sh`: the same refusal on a promise path, at the
   head end of the range.
4. Say in each script's header that resolution is no longer the whole
   question.

## Acceptance criteria (EARS)

- When a task's `doc_ref` names a section of a draft chapter, the
  front-matter check shall refuse it and name the chapter.
- When a spec's **Proposed changes** names a path in a draft chapter, the
  promise check shall refuse it.
- When the chapter is not a draft, both checks shall behave exactly as
  they do today.
- When a `doc_ref` names no file at all, the system shall keep saying so
  rather than reporting a draft.
- Where a refusal is printed, it shall say that nothing derives from a
  draft chapter, so a reader is not sent looking for a typo.

## Edge cases

- **A task whose `doc_ref` pointed at a chapter that later became a
  draft.** The task is already in the queue and the front-matter check
  sweeps the whole queue, so it starts failing on a file nobody touched.
  That is correct and it is loud: demoting a rule that tasks derive from
  is a decision with consequences, and this is where they surface. The
  implementer states it in the refusal's wording rather than exempting
  the case.
- **A spec already `approved` whose promise names a chapter since made a
  draft.** Same shape, and the promise check runs on a range rather than
  the queue, so it only fires when that spec is in a diff again.
- **`doc_ref: null`.** Untouched — there is no path to judge.
- **A draft chapter that is also the task's own subject**, as when a task
  exists to *remove* the marker. Its `doc_ref` names a draft and is
  refused. That is the rule working: the change that removes the marker
  is authoring, and authoring derives its tasks *after* the removal, so
  no task should be pointing at the chapter while the marker is still on
  it.

## Tests required

- A task whose `doc_ref` names a draft chapter is refused, and the
  message names the chapter.
- The same task against a non-draft chapter passes.
- A `doc_ref` naming no file still reports that, not a draft.
- A spec promising a path in a draft chapter is refused at the door.
- A spec promising a path in a real chapter passes unchanged.
- The existing cases of both checks pass unchanged — this adds a refusal
  and moves none.

## Definition of Done

- [ ] Both checks refuse a draft target and say why.
- [ ] Neither check changes its answer for a chapter that is not a draft.
- [ ] One marker reader across the three checks, or one copy with its
      reason written down.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- none — the criteria this implements are already in
  `product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet`.

## Proposed technical changes

- none — no technical chapter describes either check. Both contracts live
  in their own headers, which the Steps rewrite.

## Outcome

Implemented as specified.

**The reader is shared where a boundary allows and copied where one does
not, which is the judgement this spec left to be made against what the
implementer found.** What was found: none of the three checks sourced
anything at all. Two of them — `check_derived_work.sh` and
`check_promise_paths.sh` — sit in the same directory as `queue_lib.sh`,
so nothing but inertia kept them from sharing; both now source it and
call `ql_doc_is_draft`. The third is a skill, standalone by an explicit
rule: it is the one check available at every adoption stage, and reaching
into `scripts/stage-2-pull-requests/` would break that. It carries four
lines of its own with the boundary named above them. Two copies rather
than three, and the second has a reason instead of a shrug.

**`check_promise_paths.sh` reads the checkout, not a ref.** The spec said
the head end; the script's own condition one already answers existence
with `[ -e "$first" ]` against the working tree, which in CI *is* the
head end. Adding a ref read beside a tree read would have put two notions
of "now" in one loop. The refusal is condition three, after the two that
are about resolution, and says what is actually wrong — the path resolves
perfectly, so a resolution message would send the author hunting a typo
that is not there.

A folder promise is left alone: a trailing slash names no chapter.

**The closing advice is printed per fault kind**, which review found the
first implementation had not done. The refusal named the draft correctly
and then printed the standing trailer under it — "write it as the schema
reads it" — at an author who had written it exactly that way, which is
the typo-hunt this spec's Acceptance criteria forbid, arriving two lines
below the message that avoided it. Resolution faults and draft faults are
now counted apart and each trailer is printed only if its kind fired;
a range faulting both ways gets both.

Step 4 is met in the headers themselves rather than beside the condition:
both scripts opened by asserting resolution *was* the whole question —
`check_promise_paths.sh` in the words "shape, never existence" and "two
conditions answer it", `check_derived_work.sh` in "permanent is
structural — everything under docs/" — and a note further down does not
unsay a contract stated at the top.
