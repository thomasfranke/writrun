---
id: task-0039
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0055]
doc_ref: product/concepts/report.md
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-03T03:31:19Z
queued: 2026-09-03T03:45:19Z
completed: null
merged: null
provenance: []
---

# The adoption kit carries the report concept

**References:** [product/concepts/report.md](../../docs/product/concepts/report.md) · [spec-0055](../specs/spec-0055-kit-carries-reports.md)

The adoption kit teaches a methodology without reports. An adopter who
copies `template/` gets `new.sh report`, `.writrun/templates/report.md`
and a front-matter checker that reads `work/reports/` — and not one line
of prose telling them any of it exists. `AGENTS.md`, the file they graft
into their own, never says the word.

Close that: the kit ships `work/reports/` with its README, its `work/`
map names the folder, its `AGENTS.md` carries the reporting flow — the
four routes, that recording rides any change, that the `tracked` route
never does — and `WRITRUN.md` is rewritten end to end.

The rewrite is part of this and not a task of its own. `WRITRUN.md` is
the file that answers "what is this?" for somebody meeting the
methodology inside somebody else's repository, and it currently answers
in the vocabulary of somebody who already knows. It opens by saying the
project uses WritRun as its flow, then says what that is, then how it
works — and it is the same file the report's finding lands in, so
patching it now and rewriting it later would be one edit thrown away. The
mirrored `.writrun/README.md` gets its counts right in the same pass:
five skills, and a `templates/` folder that also holds a report shape.

Why it matters beyond tidiness: reports are the cheapest entry the
methodology has, and the one an adopter loses silently. A finding nobody
writes down goes back to being lost in a conversation, which is the state
the concept exists to end — and the kit is where an adopter learns what
they have.

Shipping the folder is the maintainer's call, made when this was
triaged. `product/adoption.md` keeps saying a reports folder is not part
of the adoption minimum, and that stays true: what ships is a
convenience, and its absence is still never read as a gap.
