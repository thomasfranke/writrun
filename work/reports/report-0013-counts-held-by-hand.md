---
id: report-0013
status: open
task_ref: []
doc_ref: technical/distribution.md
created: 2026-09-03T04:38:01Z
triaged: null
---

# The kit's counting sentences are held by hand

**References:** [technical/distribution.md](../../docs/technical/distribution.md)

Three files count the skills in prose: `.writrun/README.md` and its
mirrored copy under `template/` both say "the five `writrun-*` skills",
and `template/WRITRUN.md` says "The five skills in `.writrun/skills/`".
Nothing reads any of them. That is half of what report-0012 found — the
three files said *four* while five shipped — and the half that
task-0039's two structural tests do not close: they compare what the kit
ships against the names its prose uses, and a number has no shipped
counterpart to compare against.

The drift is one commit away. A sixth skill named in `template/AGENTS.md`
turns both tests green and leaves all three sentences stale, which is the
exact shape of the original finding.

Observed while reviewing task-0039, whose `distribution.md` paragraph
first claimed the tests "bite the moment the kit gains something its
guide has not learned about". That sentence was corrected in the same
change to say which half it holds; this is the half left open.
