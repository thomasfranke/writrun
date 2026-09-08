---
id: report-0040
status: authored
task_ref: []
doc_ref: technical/settings/schema.md#settings
created: 2026-09-08T16:44:41Z
triaged: 2026-09-08T17:10:00Z
---

# The adopter's vocabulary is written inside a kit file

**References:** [technical/settings/observance.md](../../docs/technical/settings/observance.md) · [template/WRITRUN.md](../../template/WRITRUN.md)

The commit vocabulary — the types and scopes a title is checked
against — lives at two addresses in the shipped kit, one in each home.
`writrun/conventions/commits.md` spells the two lists as the adopter's
prose, and the guide invites editing them ("`writrun/` is yours: make
the conventions your own", `WRITRUN.md:109`). But
`check_observance.sh:73-74` carries its own copy:

```sh
TYPES="docs feat fix refactor chore"
SCOPES="about product technical tasks specs skills ci tests agents readme setup queue conventions"
```

and the copy is what the check reads. `observance.md` says the title's
type is read "against the vocabulary `conventions/commits.md` carries" —
the code never opens that file.

So an adopter who follows the guide and adds a scope to `commits.md`
has changed nothing the check sees: titles their own conventions
declare valid are refused. Editing the script instead lasts exactly
one update — `.writrun/` is replaced whole, and the refresh reverts
the vocabulary to the kit's while `commits.md` goes on declaring the
adopter's. After any update the two addresses disagree, and the one
that reverted is the one the check reads.
