# The intake

**How a labelled issue becomes a report file**, mechanically. One chapter of [`reporting/`](README.md). The rule it implements — arrival creates nothing, the label is the assent, the body is data — is [`intake.md`](../../product/stage-3-github-issues/intake.md)'s; this chapter is the machinery's contract.

## The workflow

`writrun-intake.yml` is the fifth kit workflow, wholly Stage 3 like
`writrun-issues.yml`, and shaped like it: the YAML wires one event onto
one script and holds no logic of its own, because the suite's
integration tier executes scripts, not YAML. The event is
`issues: [labeled]` — the only forge moment the product rule names — and
the stage gate is the same first job every workflow runs
([stage_gate.sh](../distribution/checks.md)). The two refusals live in
the script, not in a YAML `if:`: a label that is not `writrun:report`,
and a title already carrying a `[REPORT-` or `[TASK-` tag, which says
the issue is already some file's mirror and its writer is another
workflow. The YAML does carry one `if:` on the label name — a
pre-filter, not a relocated refusal: every labelled event on every
issue fires the workflow, and without the filter ordinary triage
labels would start two runners and a full-history clone to run one
string comparison the script then makes anyway.

## The script's contract

`.writrun/scripts/stage-3-github-issues/intake_report.sh <owner/repo>
<issue-number>`, run from a full-history checkout of the authority
branch. The issue's fields arrive through env — `ISSUE_TITLE`,
`ISSUE_BODY`, `ISSUE_AUTHOR`, `ISSUE_CREATED_AT`, `LABEL_NAME`,
`BASE_REF` — never as interpolated text, for the reason below. On the
minting path it:

1. mints the next report id over the same three views the generator
   reads — the directory, the git history, and every open pull
   request's file list ([report schema](../schemas/report.md#report-schema));
   the forge view is all-or-nothing, and the output says which view
   answered;
2. writes `work/reports/report-NNNN-<slug>.md` — `status: open`, the
   issue's title as the report's title, `created` from the issue when
   its timestamp is canonical and from the clock when it is not, a
   provenance line naming the issue number and author, and the issue's
   text as the body;
3. commits with `commit_subject.sh intake` and lands it with the same
   rebase-not-force pattern every queue recording uses — a conflicting
   rebase aborts back to the recording commit rather than dying
   half-applied with conflict markers in the queue;
4. retitles the issue `[REPORT-NNNN] <title>`, labels it `status:open`,
   and comments the file's path — from that moment the issue is the
   report's mirror, and nothing downstream can tell it from one born in
   a diff.

Nothing ever writes back from the issue to the file: the mirror is
one-way from birth, as everywhere else.

## The id race, and the concurrency answer

Two `writrun:report` labels applied close together would each read the
same queue and mint the same id. The workflow's concurrency group is
**per issue**, not global: the forge does not serialize a shared group
— it keeps one pending run and *cancels* the rest, and a cancelled
intake is an issue that silently never becomes a report. So concurrent
intakes are allowed to race, and the script itself settles the race:
after every `git pull --rebase` it re-reads the tree, and an id another
file now claims — a racing intake's, or a report/ branch merged in the
window — is dropped and minted again, bounded at three attempts. The
rebase alone could not see this: a report landing under a different
filename replays cleanly, and the intake pushes straight to the
authority branch with no pull-request gate to refuse the duplicate.

A second delivery of the *same* label event is a no-op keyed on the
queue, not on the title: before minting, the script looks for a report
already carrying the `Issue #N` line it writes into every report it
mints, and finding one it re-dresses the mirror for that file instead.
The title tag alone could not be the guard — the retitle is the last
write, so a run that died after the push left the report recorded and
the issue untagged, and a title is a stranger's to edit besides.

## The body is data

The issue's text is a stranger's. It travels from the event payload
into the workflow's env block, from env into the script as a variable,
and from the variable into the file through `printf '%s'` — at no point
is it interpolated into shell, YAML, or a template. `$(...)`,
backticks, and a front-matter block of its own all arrive verbatim in
the report's body, where every reader treats them as what the reporter
claimed to have seen. This is `writrun-issues.yml`'s posture applied
one event over ([the report entry point](entry-point.md#the-report-entry-point)).
