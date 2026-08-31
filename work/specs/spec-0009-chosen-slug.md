---
id: spec-0009
task_ref: task-0012
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0009 — Take the subject slug as an argument

**References:** [task-0012](../tasks/task-0012-chosen-slug.md)

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

Done as specified. `new.sh task` and `new.sh spec` both take `--slug` and
use it verbatim; `check_slug` refuses anything outside the filename
contract, and separately refuses leading digits followed by a hyphen with
a message that says what breaks. The derivation is untouched — it is no
longer trying to be good, only to be present.

Seven cases across two files in the `new` suite: the chosen slug on both
subcommands, the derivation still running when the flag is absent, the two
edge cases the spec named (a slug another id already carries, a long one),
every refusal shape, and one assertion that the queue is empty after all
of them.

Three divergences:

- **`--slug` is shown unbracketed in SKILL.md.** Step 5 asks the skill to
  say that choosing is the default. Saying it while the synopsis shows
  `[--slug ...]` alongside every genuinely optional flag would have been
  contradicted by the shape an agent actually copies, so the flag is
  written as though required and the paragraph under it explains that it
  is not. The failure that motivated the rule is named there by filename —
  `task-0009-stamp-queued-and.md`, which breaks mid-phrase — because "what
  a good slug is" is not derivable from the rule alone.

- **The slug is validated before the forge is consulted.** The steps put
  no order on it. Validating first means a refusal makes no network call
  and mints no id, which matters because an id minted for a file never
  written is one the next run mints again — harmless, but it would put a
  forge round trip behind a typo.

- **`new.sh spec` now refuses an unknown flag.** It previously read
  exactly two positionals and ignored anything after them, so
  `new.sh spec task-0001 "Title" --slugg x` created the file with a
  derived slug and said nothing. Parsing flags there at all is what this
  change adds, and a parser that silently drops what it does not
  understand is the failure mode the flag exists to remove. `new.sh task`
  already behaved this way; the two subcommands now agree.
