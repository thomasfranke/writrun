---
id: spec-0059
task_ref: task-0043
status: draft
created: 2026-09-04T06:26:04Z
---

# spec-0059 — The routed end through the machinery

**References:** [task-0043](../tasks/task-0043-cross-repo-reports.md)

- **Goal:** `routed` is a report end the machinery accepts everywhere
  the other four are accepted, and closes as acted-on everywhere the
  mirror closes.

## Scope

The status vocabulary and the closes, nothing else: no workflow is
added (that is [spec-0060](spec-0060-report-intake.md)) and no guidance
prose is written (that is
[spec-0061](spec-0061-upstream-guidance.md)). The kit's copies of the
scripts ride the `.writrun` mirror; this spec edits the root and runs
the sync. The task lister is out of scope: it names `open` reports
only, and `routed` is terminal.

## Steps

1. `check_front_matter.sh` — `routed` joins the report status
   vocabulary: a terminal end that pairs with a stamped `triaged`,
   keeps `task_ref` empty, and allows `doc_ref` null (the outcome
   lives in the body as the upstream issue reference, like
   `declined`'s reason).
2. `check_state.sh` — wherever the four ends are read as terminal
   (a triaged report is not re-routed, the `tracked` gate), `routed`
   behaves as `authored`/`fixed`/`declined` do.
3. `mirror_issues.sh` and `rederive_labels.sh` — the close mapping:
   `routed` closes the mirror **completed**, beside `tracked`,
   `authored` and `fixed`; `declined` stays the one not-planned close.
4. `template/work/reports/README.md` — the status table gains the
   `routed` row, matching the root `work/reports/README.md`, which
   gains it in the same pass.
5. `make template-sync` so the mirrored `.writrun` copies carry the
   script changes; the two technical chapters below record the enum
   and the route.

## Acceptance criteria (EARS)

- When a report file carries `status: routed` with a stamped
  `triaged`, `check_front_matter.sh` shall exit 0.
- When a report carries `status: routed` with `triaged: null`, the
  front-matter check shall refuse it, as it refuses any other end
  without its timestamp.
- When a recording lands a report as `routed`, the mirror machinery
  shall close its Issue as completed.
- When `rederive_labels.sh` repairs a `routed` report's mirror, it
  shall land on the same close.
- When a report already ended `routed`, `check_state.sh` shall refuse
  a later move to any other end, as for every terminal end.

## Edge cases

- A `routed` report whose body names no upstream issue: the checks read
  front matter, not prose — the review catches it, and the schema
  chapter says the body carries the reference.
- `doc_ref` on a `routed` report: allowed and rare — the doc that says
  the consumed thing's behaviour, when one exists.
- A pre-existing triaged report is untouched: the vocabulary grows, no
  stored value changes.

## Tests required

- `tests/integration/front_matter/report_statuses_test.sh` — `routed`
  accepted, and the end-pairs-with-triaged rule covers it.
- `tests/integration/stage-3/mirror_issues/triage_closes_the_report_mirror_test.sh`
  — the completed close for `routed`.
- A `check_state` unit beside
  `a_triaged_report_is_not_re_routed_test.sh` covering `routed` as
  terminal.

## Definition of Done

- [ ] Every checker that reads report statuses accepts `routed` and
      treats it as terminal.
- [ ] Both mirror writers close a `routed` report's Issue as completed.
- [ ] Root and kit `work/reports/README.md` show five ends.
- [ ] `make template-sync` run; mirror test green.

## Proposed product changes

- none — the rule was authored ahead of this spec
  (`product/concepts/report.md#routing-upstream`,
  `product/stage-3-github-issues/labels.md`); authoring closes the loop
  in advance.

## Proposed technical changes

- `technical/schemas/report.md#report-schema` — the status enum gains
  `routed`; a paragraph on what names its outcome (the upstream issue,
  in the body) and how it pairs with `triaged`.
- `technical/reporting/entry-point.md#the-report-entry-point` — the
  triage step's outcomes name the fifth route and the authorization it
  waits on.

## Outcome

_(fill after execution)_
