---
id: spec-0012
task_ref: task-0015
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0012 — Check that a doc_ref resolves

**References:** [task-0015](../tasks/task-0015-doc-ref-resolves.md)

## Scope

`check_front_matter.sh` gains one rule: a non-null `doc_ref` names a file
that exists.

In scope: the path check and its cases. Out of scope: the **anchor** — a
heading can be renamed without moving the file, and matching anchors means
parsing markdown, which this project's line-based readers deliberately do
not do. Naming that limit is part of the change: the check proves the file,
not the section.

## Steps

1. In `check_task`, after the existing `doc_ref` shape rules, resolve the
   path part against `docs/` and fail when it is not a file.
2. The spec's `task_ref` already resolves by construction (`new.sh` refuses
   otherwise); leave it.
3. Message names the missing path, since the fix is repointing and that
   needs the old value visible.

## Acceptance criteria

- When `doc_ref` names a file that exists, the system shall accept it.
- When `doc_ref` names a file that does not exist, the system shall report
  it malformed and name the path.
- When `doc_ref` is `null`, the system shall accept it.
- When `doc_ref` carries an anchor, the system shall check only the path
  and shall not fail on an anchor it cannot verify.

## Edge cases

- A path that exists but is a directory, not a file.
- A `doc_ref` written with a `docs/` prefix — already rejected by the
  existing rule, and must keep failing for that reason, not this one.
- Running from a directory other than the repository root: the check
  resolves relative to `docs/`, so a wrong cwd must not turn every
  `doc_ref` into a failure. Prefer the same base the rest of the script
  uses.

## Tests required

One case per acceptance criterion, in the `front_matter` suite.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — no behaviour change to the methodology.

## Proposed technical changes

none — the schema already says `doc_ref` points at a doc; this makes the
statement checkable.

## Outcome

Done as specified. `check_task` resolves the path part of a non-null
`doc_ref` against `docs/` and fails when it is not a file, naming both the
value as written and the path it resolved to — the fix is repointing, and
that needs the old value visible. The anchor is left unverified, and the
script says why where the rule lives rather than only here.

Nine assertions across two case files in the `front_matter` suite: the
four criteria, plus the two edge cases the spec named and one it did not
(an anchor on a path that is missing). **The repository's own 30 queue
files pass**, which is the part worth recording — the rule was written
against a queue that had just been rearranged by the level split, and
every `doc_ref` in it survived, including the one repointed by hand when
`product/pipeline.md` was split into chapters.

Two divergences:

- **`docs` became a third positional argument** rather than a constant.
  The edge case asks that a wrong cwd not turn every `doc_ref` into a
  failure, and says to prefer the base the rest of the script uses. That
  base is the working directory, since `work/tasks` and `work/specs` are
  already relative to it — so the answer is consistency, not cleverness:
  a cwd wrong enough to hide `docs/` has already hidden the queue, and the
  script then checks nothing rather than failing everything. Making it an
  argument states that base instead of burying it.

- **A directory named `chapter` is caught by the older rule, not this
  one.** The spec's first edge case expects a directory to be rejected as
  "not a file". It is — but only when it is named like one
  (`folder.md`); a plain directory name has no `.md` suffix and the shape
  rule rejects it first, with its own message. Both cases are covered and
  both messages are asserted, because which rule speaks is what a reader
  fixing the file will act on.
