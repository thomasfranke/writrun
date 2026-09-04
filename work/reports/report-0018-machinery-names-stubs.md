---
id: report-0018
status: fixed
task_ref: []
doc_ref: null
created: 2026-09-04T05:00:24Z
triaged: 2026-09-04T15:26:20Z
---

# Skills and scripts name the chapter stubs, not the folded homes

With `docs/technical/` foldered, the five old chapter files stand as
stubs so every existing reference keeps resolving. The machinery still
names those stubs rather than the folded homes: the five `SKILL.md`
files and several scripts (`new.sh`, `check_front_matter.sh`,
`check_deltas.sh`, `brief.sh`, `list_tasks.sh`, `read_setting.sh`,
`scripts/release.sh`) link `technical/schemas.md`,
`technical/selection.md` and siblings by URL or in error text, and the
kit's mirrored copies under `template/` carry the same addresses. Every
link lands — on a stub, one hop short of the content.

**Triage:** trivial — a mechanical rewrite of every reference to its
folded home, no behaviour changed. Fixed in the change that carries this
line; the git history names the outcome.
