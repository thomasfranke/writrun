# the task's doc reference is `doc_ref`: any path under `docs/`.

**2026-08-22**

The field was born `product_ref` with "null if purely
technical" — which left every task derived from a technical doc with no
reference at all: invisible to reverse traceability and to the
queue-impact guard that crosses edited docs against the queue. With
`docs/` free-form (the stakeholders', not the methodology's, to shape),
"product" in the name meant nothing anyway. `doc_ref` points at the doc
that authorized the task, wherever it lives under `docs/`; null is
reserved for tasks that originate in code or machinery, not in a doc.
The spec's two Proposed-changes sections keep their audience names — the
checks verify their union and never distinguish them, so they cost
nothing and keep principle 2 visible at the spec level.
