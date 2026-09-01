---
id: task-0021
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0026, spec-0027, spec-0029, spec-0030, spec-0033, spec-0034]
doc_ref: product/adoption.md#three-stages
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T02:47:35Z
queued: 2026-08-31T04:04:03Z
completed: 2026-08-31T04:56:25Z
merged: 2026-08-31T11:30:53Z
provenance: []
---

# Catch the machinery up with the restaged docs

**References:** [product/adoption.md#three-stages](../../docs/product/adoption.md#three-stages) · [spec-0026](../specs/spec-0026-conduct-flags-home.md) · [spec-0027](../specs/spec-0027-statuses-pointers.md) · [spec-0029](../specs/spec-0029-ruleset-bot-bypass.md) · [spec-0030](../specs/spec-0030-kit-forge-setup.md) · [spec-0033](../specs/spec-0033-declaration-keys.md) · [spec-0034](../specs/spec-0034-observance-checks.md)

The docs restaged the methodology and the machinery has not caught up.
Git begins at Stage 2 now — Stage 1 is autogen of tasks and specs from
the docs, as files, statuses by hand — yet the settings file still
keeps the agent's commit conduct in a Stage 1 section, and the status
machinery's comments still point at the Stage 1 chapter for a
projection that moved to Stage 2's. Protection of the authority branch
became a recommendation bounded by the forge, with the owner-assent
gate on settings, and the workflow comments still explain themselves
by an unprotected main.

Bring every piece up to the rules the docs now state, and carry the
same guidance into the adoption kit, so an adopter's agent finds the
machinery agreeing with the docs it reads. The queue's own new
vocabulary — clickable references, the origin field, the reporting
rename — is its own task:
[task-0022](task-0022-queue-vocabulary.md).
