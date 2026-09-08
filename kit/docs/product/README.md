# Product documentation

**What the system does, rule by rule, in non-technical language.** The
source of truth implementations are checked against — the reader is a
maintainer, a tech lead, a stakeholder.

This layout — `product/` beside `technical/` — is WritRun's **suggested**
shape, not a requirement: everything under `docs/` counts as permanent
input, shaped however your stakeholders prefer. One rule survives any
shape: product intent and technical design never share a file.

## Chapters

| # | Chapter | Answers |
|---|---|---|
| 1 | <!-- TODO: first checkable chapter --> | |

## Rules for this folder

- Written for a non-technical reader — if a sentence needs a schema, it
  belongs in `technical/`.
- Each rule is checkable: a reader can answer "does this repo comply —
  yes or no" without interpretation.
- Changes arrive by authoring (rule first, work derived from it) or by
  loop closure (shipped with the task, listed in its spec's Proposed
  changes) — and a human writes or reviews either before it merges.
