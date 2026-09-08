---
id: task-0065
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0091, spec-0092, spec-0093]
doc_ref: product/adoption.md#two-homes
origin: rule
priority: high
depends_on: []
milestone: null
created: 2026-09-08T16:48:47Z
queued: 2026-09-08T17:00:56Z
completed: 2026-09-08T17:30:11Z
merged: null
provenance:
  - {by: agent, model: claude-opus-5, login: thomasfranke, input: 428, output: 119997, cache_read: 39731854, cache_write: 201160}
---

# The kit's texts become defaults the project overrides

**References:** [product/adoption.md#two-homes](../../docs/product/adoption.md#two-homes) · [spec-0091](../specs/spec-0091-kit-folder-name.md) · [spec-0092](../specs/spec-0092-defaults-house.md) · [spec-0093](../specs/spec-0093-vocabulary-settings.md)

The two-homes rule now reads layered
([adoption](../../docs/product/adoption.md#two-homes)): every text the
kit answers on a project's behalf lives as a default in the kit's own
home, the project's home holds a deferring stub or a whole override,
and the commit vocabulary is a settings value the checks read. Bring
the kit up to the rule — the shipped folder's name included, which the
docs already use.

Why it matters: today a convention the kit improves reaches no adopter
(report-0039 — the v0.0.06 address fix dies in a home no update
touches), and the vocabulary an adopter personalizes is reverted by
every refresh while their own prose goes on declaring it
(report-0040). The layered homes close both: corrections flow to
everyone who defers, and nothing the project wrote is ever touched.
