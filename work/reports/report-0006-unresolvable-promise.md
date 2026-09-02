---
id: report-0006
status: open
task_ref: []
doc_ref: technical/README.md#spec-schema
created: 2026-09-02T07:13:08Z
triaged: null
---

# A promise the delta check cannot resolve is caught only at the completion gate

**References:** [technical/README.md#spec-schema](../../docs/technical/README.md#spec-schema)

A path in either **Proposed changes** section is read relative to
`docs/` — `check_deltas.sh` prefixes every bullet with `docs/`
(`extract_paths`), and `technical/README.md#spec-schema` states the
convention. A spec that writes a repository-root path instead therefore
promises something no diff can touch, and nothing says so until the
completion gate runs under a finished branch.

Two instances so far, both found late and both costing an amendment:

- `spec-0041` promised the decision file without `decisions/README.md`;
  refused on #83, fixed by an amendment under an open pull request with
  the task suspended. That instance is what
  [task-0028](../tasks/task-0028-promise-companions.md) was written
  against.
- `spec-0044` promised five repository-root paths — `check_state.sh`,
  its `SKILL.md`, the workflow, `tests/unit/check_state/` and
  `template/` — every one of which normalises to a `docs/…` path that
  does not exist ([report-0005](report-0005-delta-doc-paths.md)). Caught
  before the task was taken, by reading the report rather than by any
  check.

`check_promise_companions.sh`, task-0028's outcome, runs where a spec is
written and is the one gate that looks at a promise list early — but it
judges one named pair (a decisions entry and its index) and says nothing
about whether a promised path resolves at all. Both instances above are
the same shape: a promise defect invisible through drafting and through
approval, surfacing at the most expensive moment.

Not investigated: whether the answer belongs in that gate, in `new.sh`,
or in a check of its own; nor whether "resolves" should mean the file
exists today, since a spec legitimately promises a doc its own change
creates.
