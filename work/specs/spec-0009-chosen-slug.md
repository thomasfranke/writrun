---
id: spec-0009
task_ref: task-0012
status: approved
created: 2026-08-28T00:00:00Z
---

# spec-0009 — Take the subject slug as an argument

## Scope

`new.sh` accepts the filename's subject slug instead of only deriving
it, on both subcommands.

In scope: `new.sh` (a `--slug` flag, validation of what it accepts, and
the existing derivation kept as the fallback) and the
`writrun-create-task-and-spec` SKILL.md, which is what an agent reads
before creating anything. Out of scope: renaming any existing file, and
the derivation algorithm itself — it stays exactly as it is, because it
is no longer trying to be good, only to be present.

## Steps

1. `new.sh task` and `new.sh spec`: accept `--slug <words>`, and use it
   verbatim as the filename's subject when given.
2. Validate it as the shape the filename contract allows: lowercase
   alphanumerics and single hyphens, no leading or trailing hyphen. A
   slug that would produce a filename the canonical check then rejects
   must be refused where it is typed, not written and discovered later.
3. Refuse a slug that starts with digits followed by a hyphen — it would
   read as part of the id and break every prefix resolver.
4. Keep the title-derived slug when `--slug` is absent, unchanged.
5. SKILL.md: state that choosing the slug is the default and the
   derivation is the fallback, with the failure that motivated it named
   so the next agent understands what a good slug is for.

## Acceptance criteria

- When `new.sh` is given `--slug`, the system shall name the file with
  exactly those words after the id.
- When `new.sh` is given no `--slug`, the system shall derive one from
  the title as it does today.
- When a slug holds anything but lowercase alphanumerics and single
  interior hyphens, the system shall refuse and write no file.
- When a slug would read as a continuation of the id (leading digits),
  the system shall refuse and write no file.
- When a slug is refused, the system shall exit 3 and leave the queue
  untouched.

## Edge cases

- `--slug` given an empty string: refused, not treated as absent.
- A slug identical to one an existing file already carries under a
  different id — allowed, since identity is the id.
- A very long slug: allowed. The convention asks for two or three words;
  the check enforces shape, not taste.

## Tests required

One case per acceptance criterion, in the `new` suite.

## Definition of Done

- `make tests` green, including the new cases.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — the authoring change stated the rule in the conventions first.

## Proposed technical changes

none — the same authoring change covered `technical/README.md`.

## Outcome

(filled when the task completes)
