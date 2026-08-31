---
id: spec-0034
task_ref: task-0021
status: approved
created: 2026-08-31T04:52:11Z
---

# spec-0034 — Observance is checked where it leaves a trace

- **Goal:** the settings an agent is told to obey stop being pure
  trust where disobedience is visible. From Stage 2, `writrun check`
  fails a pull request whose title ignores the declared
  `pr_title_style`, and one whose commits or body carry platform
  credit — a co-author trailer, a session link, a generated-with line
  — while `credit_ai` is `false`. What leaves no trace (`auto_commit`,
  `auto_pr`) stays instruction-bound, and the docs say so rather than
  pretend.

## Scope

In: the check workflow's two new verifications, the conventions
sentences they contradict, tests, template mirrors.

Out: any check on `auto_commit`/`auto_pr` (a question not asked leaves
no diff); rewriting history (the credit check reads the PR's own
commits and body, never `main`'s past); the machinery's own recording
commit (not an agent's action, never checked against conduct flags).

## Steps

1. `writrun check` gains a title verification: with
   `stage_2.pr_title_style: conventional`, the summary after the
   `[TASK-NNNN]` tags must parse as `type(scope): subject` over the
   documented vocabularies; with `bracketed`, as `[Type][Scope]
   Sentence`. Authoring and reporting titles — no tags — are checked
   against the same style's tagless form.
2. `writrun check` gains a credit verification, active only when
   `credit_ai` is `false`: no commit message in the PR and no PR body
   carries `Co-Authored-By:` naming an agent platform, a
   `Claude-Session`/session-URL trailer, or a generated-with line.
3. `.writrun/conventions/commits.md`'s "nothing in this project parses
   a subject" and prs.md's equivalent are updated to name the one
   parser that now exists and what it reads.
4. Tests: one green and one failing case per style; credit case
   flagged under `false`, ignored under `true`; `make template-sync`.
5. Remove the observance catch-up note in
   `technical/README.md#settings`.

## Acceptance criteria (EARS)

- When a pull request's title ignores the declared style, `writrun
  check` shall fail, naming the style and the offending title.
- When `credit_ai` is `false` and a commit or the body carries
  platform credit, `writrun check` shall fail, naming the line.
- When `credit_ai` is `true`, the credit verification shall not run.
- When the machinery's own recording commit appears in a range, it
  shall never be checked against the conduct flags.

## Edge cases

- A PR title quoting credit-like text inside its subject ("remove the
  Co-Authored-By trailer"): the credit check reads trailers and body
  lines, not subjects — a mention is not a trailer.
- A fork PR: both verifications are read-only over the diff and run
  with no secrets, like every check.

## Tests required

The four criteria above as cases in the check suite; template mirrors
byte-identical; full suite green.

## Definition of Done

- [ ] Both verifications live in `writrun check`, tested both ways.
- [ ] Conventions name the parser; catch-up note gone; mirrors synced.

## Proposed product changes

- none — the rule was authored first
  (`technical/README.md#observance-is-checked-where-it-leaves-a-trace`).

## Proposed technical changes

- `technical/README.md#settings` — remove the observance catch-up note
  once both verifications run.

## Outcome

_(fill after execution)_
