---
id: spec-0042
task_ref: task-0030
status: implemented
created: 2026-09-01T13:19:03Z
---

# spec-0042 — The commit subject stops reading pr_title_style

**References:** [task-0030](../tasks/task-0030-commit-subject-constant.md)

- **Goal:** `pr_title_style` governs the pull request title and nothing
  else; the commit subject is Conventional Commits in every project,
  whatever the key declares.

## Scope

The machinery half of
[0063](../../docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md).
Two files compose or describe a commit subject, two convention files
teach the rule, one test asserts the behaviour being reversed.

Out of scope: the title check. `check_observance.sh` reads `$PR_TITLE`
against the declared style and keeps doing exactly that — the title is
the half the key still governs, and its logic is untouched. Also out of
scope: anything under `docs/`, whose rule landed with the authoring
change; this diff touches no permanent doc.

## Steps

1. `commit_subject.sh` — drop the `read_setting.sh` call and the `STYLE`
   variable. The `case` collapses from `EVENT:STYLE` to `EVENT`, four
   literals to two: `chore(queue): record what the merge decided` and
   `chore(queue): record what the forge just did`. Rewrite the header
   comment, which currently exists to explain an obedience the script no
   longer owes; what replaces it is why the subject is a constant and
   why the file still exists (one writer, two callers).
2. `check_observance.sh` — the comment at the credit exemption says the
   recording subject is "composed from `pr_title_style`
   (commit_subject.sh)". Correct it to a constant. **No logic change**:
   the exemption is by committer identity, which is the very point that
   comment makes, and it stays right.
3. `.writrun/conventions/commits.md` — the opening paragraph is the
   claim 0063 repeals; rewrite it so the commit grammar is stated as a
   constant carrying the two vocabularies, not as a consequence of the
   title style. Delete the `bracketed` paragraph. The `[TASK-NNNN]`
   paragraph keeps the tag on the title and drops it from the subject.
   The `commit_subject.sh` paragraph loses the setting and keeps the
   one-writer argument.
4. `.writrun/conventions/prs.md` — the `conventional` bullet describes
   itself as "the Conventional Commit the squash will produce"; that
   promise is gone. Both styles get a description that is about who
   reads the queue, and the bullet list gains a line saying what lands
   on `main` and who types it.
5. Rename
   `tests/integration/stage-2/commit_subject/the_machinery_obeys_the_style_test.sh`
   to `the_subject_is_constant_test.sh` and invert its premise: the two
   subjects are the same under both declared styles.
6. Sweep the suite for any other assertion of a bracketed recording
   subject.

## Acceptance criteria (EARS)

- When `writrun approve` records a merge, the system shall write the
  subject `chore(queue): record what the merge decided`, whatever
  `stage_2.pr_title_style` declares.
- When `writrun progress` records a forge event, the system shall write
  the subject `chore(queue): record what the forge just did`, whatever
  `stage_2.pr_title_style` declares.
- When `commit_subject.sh` runs, the system shall not read
  `stage_2.pr_title_style`.
- When a pull request title is checked, the system shall judge it
  against the declared `stage_2.pr_title_style` exactly as it did
  before.

## Edge cases

- **No settings file, or no `pr_title_style` key.** The script stops
  reading settings entirely, so both cases print the same subject
  instead of falling back to a default. This removes a failure mode
  rather than adding one.
- **The usage error survives.** An absent or unknown event argument
  still exits 3; collapsing the `case` must not collapse that.
- **`main`'s existing recording commits stay bracketed.** Nothing
  rewrites history, and the credit check reads a pull request's own
  commits, never `main`'s past — the mixed history is expected and
  harmless.
- **A Stage 1 project writes no recording commits at all**, so the
  script is unreachable there; it is not made conditional.

## Tests required

- The renamed integration test: both subjects identical under
  `bracketed` and under `conventional`, and unchanged with the key
  absent from the settings file.
- The usage-error case (exit 3, no event and a bad event) kept as-is.
- The existing observance suite must stay green untouched — evidence
  the title check was not disturbed.

## Definition of Done

- [ ] `commit_subject.sh` reads no setting and prints two literals.
- [ ] `commits.md` states the commit grammar as a constant; the
      `bracketed` commit paragraph is gone.
- [ ] `prs.md` no longer promises that the title becomes the subject.
- [ ] The `check_observance.sh` comment is accurate; its logic is
      byte-identical.
- [ ] The renamed test asserts constancy and the suite is green.

## Proposed product changes

- none — the rule landed with the authoring change; this diff touches no
  permanent doc.

## Proposed technical changes

- none — same reason.

## Outcome

Built as scoped. `commit_subject.sh` reads no setting: `read_setting.sh`
and the `STYLE` variable are gone, the `case` is over the event alone,
and it prints two literals — `chore(queue): record what the merge
decided` and `chore(queue): record what the forge just did`. The usage
error survives the collapse; the `case` now carries all three arms, and
an absent or unknown event still exits 3.

**The header comment was rewritten to a different question.** It existed
to explain an obedience the script no longer owes; what replaced it is
why the subject is a constant — `main`'s readers are the same in every
project — and why the file still exists once nothing is composed in it:
one writer, two callers, and nothing squashes these, so a subject that
drifted between the two workflows would sit there for good.

**The title check was not touched.** `check_observance.sh` still reads
`$PR_TITLE` against the declared style, byte for byte; only comments
changed in it, and the observance suite passes untouched — which is the
evidence the spec asked for.

**Divergences.**

- **Four comments corrected, not one.** The spec named the credit
  exemption's comment in `check_observance.sh`. Three more carried the
  repealed premise: that file's header, which said the squash puts the
  title into the authority branch's history, and the commit steps of
  both recording workflows, which described the subject as composed in
  the declared style. A comment stating the rule this change repeals is
  worse than no comment, and correcting one while leaving three would
  have left the next reader with a contradiction and no way to tell
  which half was current. No logic moved in any of them.
- **Two paragraphs in the convention files beyond the ones listed.**
  `prs.md`'s tag paragraph argued the tag leads because the squash puts
  the title into `main` — the same repealed premise; it now argues from
  where a title is actually read, a list of open pull requests, which is
  the half of the left-edge argument [0063](../../docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md)
  keeps. `commits.md`'s closing paragraph said only the pull request
  title reaches `main`; it now says the squash discards a branch's
  subjects and what reaches `main` is one subject, seeded by the title
  and typed in the merge box. Neither changes what the file asks anyone
  to do.
- **The `template/` mirror moved with the kit.** `make template-sync`,
  mechanical — six files under `template/`. The release end-to-end test
  is what names it: a sync that changes more than the version stamp
  fails the cut, so the mirror travels in the change rather than behind
  it.
- **Two test cases beyond the required list.** A `refute` that the
  bracketed dress appears nowhere under a `bracketed` declaration — the
  assertion the old case made in reverse — and a settings file holding
  text that is not JSON, which still prints the subject. The second is
  the observable form of "reads no setting": under the old script that
  line went through `read_setting.sh`, and here nothing opens the file
  at all.
