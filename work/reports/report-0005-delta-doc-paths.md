---
id: report-0005
status: fixed
task_ref: []
doc_ref: null
created: 2026-09-02T06:02:14Z
triaged: 2026-09-02T07:12:37Z
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

**Triage:** the first of the three — spec-0044's list is amended, and
the amendment rides this change. The docs/-relative rule is already
stated where a spec's schema is defined
(`technical/README.md#spec-schema`), and `spec-0043` follows it while
carrying more machinery than this spec does, so nothing here is a rule
that went unwritten: the five entries were a drafting error against a
rule that exists. Teaching the check to pass through repository-root
paths was rejected — the sections exist to close the loop on permanent
docs, and a check that accepted `tests/` would be accepting a promise
the loop has no use for.

What triage does **not** settle is that nothing catches this where it is
born. The error was invisible through drafting and through approval, and
would have surfaced under a finished branch at the completion gate —
the same shape of failure task-0028 was created for, and outside the
pair its companion gate knows. That is a second observation about a
different subject, so it is
[report-0006](report-0006-unresolvable-promise.md), not a second end on
this file.
