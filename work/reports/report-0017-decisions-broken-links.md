---
id: report-0017
status: fixed
task_ref: []
doc_ref: null
created: 2026-09-04T04:59:32Z
triaged: 2026-09-04T04:59:56Z
---

# Four decision links resolve to nothing

A link sweep over `docs/technical/` (run while foldering the reference)
found four relative links in `decisions/` resolving to no file, all
predating the foldering:

- `tasks-and-specs/0052-settings-carry-the-choice.md` links `0010`,
  `0041` and `0046` as siblings, but they live in `pull-requests/`
  (0010, 0046) and `github-issues/` (0041) — the per-subsystem split
  placed them there.
- `pull-requests/0063-title-and-subject-are-two-texts.md` reaches for
  `conventions/commits.md` one directory level short
  (`../../../` where the file sits four levels below the root).

Fixed in the same change: the three cross-subsystem paths now route
through `../<subsystem>/`, and 0063 gained its missing level. No
record's meaning was touched — paths only.
