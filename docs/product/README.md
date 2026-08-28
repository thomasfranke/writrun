# Product documentation

**What the methodology prescribes, rule by rule, in non-technical language.**
This is the source of truth an adopting project's structure is checked
against — if a repo claims to follow the methodology, each chapter here is a
checklist item it either satisfies or doesn't.

The reader here is anyone deciding whether and how to adopt: a maintainer, a
tech lead, a stakeholder. No file formats, no algorithms, no schemas — that
machinery lives in [`technical/`](../technical/README.md) and is linked from
here, never restated.

## Chapters

Read in order, like a book — the five `concepts/*.md` chapters come first
because every later chapter is written in the nouns they establish, and none
of those nouns are redefined downstream:

| # | Chapter | Answers |
|---|---|---|
| 1 | [`concepts/about.md`](concepts/about.md) | What an About file is, what it may and may not contain. |
| 2 | [`concepts/product-doc.md`](concepts/product-doc.md) | What a product doc is, who reads it, when it changes. |
| 3 | [`concepts/technical-doc.md`](concepts/technical-doc.md) | What a technical doc is, and the link-don't-restate rule. |
| 4 | [`concepts/task.md`](concepts/task.md) | What a task is: the request, its two invariants (identity ≠ order, no technical detail). |
| 5 | [`concepts/spec.md`](concepts/spec.md) | What a spec is: the elaboration, its lifecycle, the approval gate, the doc-delta contract. |
| 6 | [`pipeline/`](pipeline/README.md) | The docs → task → spec → code flow and where humans gate it. True at every level. |
| 7 | [`flow/`](flow/README.md) | What branches, pull requests and CI add — level `flow`. |
| 8 | [`github-issues/`](github-issues/README.md) | What the GitHub Issues mirror adds — level `github-issues`. |
| 9 | [`adoption.md`](adoption.md) | What a project must have, at minimum, to claim adoption. |

Every chapter above traces to a concrete case, not an invented example: the
five concepts and the pipeline generalize swoop's mature, fully-designed
pipeline; adoption's worked example is TOM's real, partial adoption.

## Rules for this folder

- Written for a non-technical reader. If a sentence needs a schema to make
  sense, it belongs in `technical/`.
- Each rule is checkable: an agent (or a reviewer) reading it can answer
  "does this repo comply — yes or no" without interpretation.
- Changes here are behaviour changes, and arrive by one of the two routes
  [Pipeline](pipeline/authoring.md#two-ways-a-permanent-doc-changes) names. **Loop
  closure** — the change ships with the task that implements it, and the
  spec's **Proposed product changes** section must list it. **Authoring** —
  the rule is written before anything implements it, no task precedes it,
  and the change names the tasks and specs it derives.
- Either way, a human writes or reviews it before it merges. That gate is
  not about which route the change took.
