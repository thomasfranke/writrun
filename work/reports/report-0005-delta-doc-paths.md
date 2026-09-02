---
id: report-0005
status: open
task_ref: []
doc_ref: null
created: 2026-09-02T06:02:14Z
triaged: null
---

# spec-0044 promises paths the delta check cannot see

`spec-0044` (approved, task-0033 not yet taken) lists five entries
under **Proposed technical changes**:

```
- `.writrun/skills/writrun-check-task-state/check_state.sh` — rule K
- `.writrun/skills/writrun-check-task-state/SKILL.md` — document it
- `.github/workflows/writrun-check.yml` — `HEAD_REF` via env
- `tests/unit/check_state/` — the cases above
- `template/` — the mirrored copies of the three files
```

`check_deltas.sh` normalises every bullet in both Proposed-changes
sections by prefixing `docs/` (`extract_paths`, the
`sed 's|^|docs/|'` at line ~72), because the spec schema states those
paths relative to `docs/`. The five entries above therefore resolve to
`docs/.writrun/...`, `docs/.github/...`, `docs/tests/...` and
`docs/template/` — paths no implementing diff will ever touch. When
task-0033 is completed, each will report `MISSING` and the gate exits 1;
the same happens in CI through `check_promised_deltas.sh`.

The precedent runs the other way: `spec-0043`, implemented and merged,
lists only `technical/README.md#report-schema` in Proposed technical
changes and carries all machinery work (generator, gates, mirror,
template sync) in its Scope and Steps sections.

Not investigated further: whether the answer is amending spec-0044's
list, teaching the check to pass through repository-root paths, or
stating the docs/-relative rule more loudly where specs are written, is
triage's to decide. The spec is `approved`, so its body is not editable
in place while it stays so.
