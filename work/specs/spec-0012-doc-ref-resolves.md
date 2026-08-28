---
id: spec-0012
task_ref: task-0015
status: draft
created: 2026-08-28
---

# spec-0012 — Check that a doc_ref resolves

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

(filled when the task completes)
