---
id: spec-0080
task_ref: task-0057
status: implemented
created: 2026-09-05T13:48:56Z
---

# spec-0080 — A collision the mirror answers is named

**References:** [task-0057](../tasks/task-0057-id-claims-unseen.md)

- **Goal:** a run that reopens a report's mirror on evidence that the id
  came back says so, with the evidence, in the run's own output.

## Scope

In: the existing-mirror path of `mirror_issues.sh`'s report loop —
`report_row_of`, the adoption message, and the `state=open` write that
reopens a closed mirror. Output only: no write this pass makes today is
added, removed or reordered.

Out: the exit code. `mirror_issues.sh` is the best-effort write half of
the split
[decision 0010](../../docs/technical/decisions/pull-requests/0010-ci-splits-into-a.md)
made, and a mirror that refused to project would leave a report with no
mirror at all — the one state the reconciliation may not leave behind. A
collision named and projected is strictly better than a collision
neither named nor projected.

Out: the task loop's reopen. The same two lines run there and mean
something else: a task's mirror is retired by the orphan sweep when its
pull request closes unmerged, and
`adopted_closed_mirror_reopened_test.sh` pins the merge that takes it
back as the ordinary path. Warning on the task side would fire on the
normal case, which is the fastest way to teach a reader to ignore the
warning.

Out: any general logging change — a verbosity flag, a level, a shared
warning helper. This is two messages in one loop.

Out: detecting the collision anywhere but here.
[spec-0081](spec-0081-mirror-holds-id.md) stops the mint from producing
the id in the first place; this is what is left for the id that arrives
anyway — hand-written, or minted before that fix lands.

**A reopen is not by itself evidence.** Two of them are legitimate. The
orphan sweep retires a report's mirror when its pull request closes
unmerged, and reopening that pull request restores it
(`closed_unmerged_retires_a_report_mirror_test.sh`,
`reopened_pr_restores_mirror_test.sh`). A report recorded `open`, moved
to a terminal status and moved back inside one pull request's life does
the same. So a rule of "warn on every reopen" would be noise, and noise
is what fault 4 already is in the other direction.

**What separates a returning id from a returning report is the title.**
On both legitimate paths the mirror is a projection of the same file, so
its title still names the same finding. When the id has come back the
mirror's title describes a different one — in the adopter's case, an
Issue about `take_task.sh` reopened for a report about something else,
and reattributed to a pull request that never mentioned it. **The title
is therefore the discriminator, and it is also the thing a maintainer
needs to see**, because a mismatch is what makes the Issue in front of
them wrong.

The title is already fetched: `mirror_issues.sh:363-365` lists every
`writrun:report` Issue with its title base64-encoded, and
`report_row_of` decodes it, matches on it, and then drops it. Carrying
it out of the helper is one field and no forge call.

**Silence is the fault, and the run is where it is heard.** The mirror
pass's output is what a maintainer reads when an Issue moves and they
want to know why. Today a returning id produces two ordinary lines —
`report-0001: adopted stale mirror #18 — #17 is no longer open.` and
`report-0001 → status:proposed` — neither of which mentions that the
mirror was closed, that it was closed because somebody triaged it, or
that it is about something else. Every fact needed to say so is in
scope at that point in the loop.

## Steps

1. `report_row_of` returns the mirror's title as a fifth field,
   base64-encoded like the body it already carries. The caller's
   `cut -f1..f4` reads are unchanged; the new field is appended, never
   inserted.
2. The adoption message says the state it adopted the mirror in. A
   closed mirror adopted is a fact the current line omits, and it is
   half the evidence.
3. Before the `state=open` write, compare the mirror's title with the
   title this diff carries for the report — the same `rtitle` the create
   path would use — after stripping the `[REPORT-NNNN]` tag the mirror
   carries and the file does not. Where they differ, print a warning
   naming: the mirror's number, that it was closed, the pull request
   that introduced it, both titles, and the rule — an id is never
   reused. Where they match, print nothing new: that is a restore.
4. Warn only where the mirror was adopted in this pass. A mirror this
   pull request already owns is one it created, and its title moving is
   this pull request editing its own report.
5. Where the diff carries no title for the report — a status-only edit,
   whose patch holds no heading — compare nothing and print nothing. An
   absent title is not a differing one, and the loop already treats
   "the diff says nothing" as "do nothing".
6. Say the discriminator in the comment above that branch: a reopen is
   ordinary, a reopen onto a different title is a returning id, and the
   pass names it rather than refusing it.
7. `make template-sync` — `.writrun/` is mirrored into `template/`.

## Acceptance criteria (EARS)

- When the pass reopens a report mirror it adopted from another pull
  request, and the mirror's title does not match the title the diff
  carries, the system shall report the mismatch, naming the mirror, the
  pull request that introduced it, and both titles.
- When the pass adopts a report mirror that is closed, the system shall
  say the mirror was closed.
- When a reopened mirror's title matches the title the diff carries, the
  system shall print nothing beyond what it prints today.
- When the pass owns the mirror already, the system shall print nothing
  beyond what it prints today, whatever the titles say.
- When the diff carries no title for the report, the system shall
  compare no titles and print no warning.
- When a mismatch is reported, the system shall still project the
  mirror — reopen it, label it — and shall exit with the status it would
  have exited with.
- When the pass reopens a task's mirror, the system shall print what it
  prints today.

## Edge cases

- **A mirror whose title differs only by its `[REPORT-NNNN]` tag.** The
  tag is the mirror's and never the file's, so it is stripped before the
  comparison. Comparing the raw strings would warn on every reopen.
- **A retitled report.** Someone edits the file's heading and the
  mirror's title is the old one. This warns, and it is a false positive
  by intention: the machinery cannot tell an edited heading from a
  returned id, and the two lines it prints let a reader tell in a
  second. The alternative is missing the case this spec exists for.
- **A mirror somebody retitled by hand on the forge.** Same answer, same
  reason. A title is a stranger's to edit, which the intake's own
  reasoning already notes.
- **A mismatch on a mirror that is open, not closed.** Out of this
  spec's reach: the loop reaches it, but an open mirror is not evidence
  of a triaged finding coming back, and widening the warning to every
  title difference is the general logging change this spec refuses.
- **Whitespace and case.** Compared after trimming, so a reflowed
  heading is not a collision. Not case-folded: two findings whose titles
  differ only in case are still two findings.
- **A mirror this pass adopted because nobody owned it** — the
  intake-born case, with no `Introduced by` line. There is no pull
  request to name, and the warning says so rather than printing an empty
  number.

## Tests required

- New: a closed report mirror, owned by a closed pull request, whose
  title names a different finding from the one the diff carries. The run
  warns, naming both titles and the owning pull request; the mirror is
  still reopened and still labelled. This is report-0031's fourth fault,
  stated as a case.
- New: the same shape with matching titles — a restored orphan. The
  mirror is reopened and nothing extra is printed.
- New: an adopted closed mirror reports the state it was adopted in.
- `reopened_pr_restores_mirror_test.sh`,
  `closed_unmerged_retires_a_report_mirror_test.sh`,
  `stale_mirror_adopted_test.sh`, `unowned_mirror_adopted_test.sh` and
  `own_mirror_untouched_by_adoption_test.sh` pass unchanged — the writes
  do not move, and the messages they assert on are extended, never
  replaced.
- `adopted_closed_mirror_reopened_test.sh` passes unchanged: the task
  path prints what it printed before.
- `a_proposed_report_triaged_later_is_closed_test.sh` passes unchanged —
  a report whose status moves inside one pull request is the pass's own
  mirror, and step 4 excludes it.

## Definition of Done

- [ ] A reopen onto a differing title prints a warning naming the
      mirror, its introducing pull request, and both titles.
- [ ] A reopen onto a matching title prints nothing new.
- [ ] A mirror this pull request owns never warns.
- [ ] The adoption line says whether the mirror it adopted was closed.
- [ ] No write, no forge call and no exit code moves.
- [ ] Nothing outside the report loop's existing-mirror path changes.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] The sequence in
      [report-0031](../reports/report-0031-id-the-mirror-holds.md) — a
      triaged Issue reopened for an unrelated finding — produces a line
      naming the collision, in a run whose other output is unchanged.

## Proposed product changes

- none. What a mirror run prints is not a rule about what a mirror
  means, and `product/stage-3-github-issues/labels.md#criteria` states
  the second: which label a report's mirror carries, and when it closes.
  This change writes no label and closes nothing. Putting the pass's
  console output in that chapter would make a message a rule, and the
  next change to the wording would be a documented behaviour change over
  a sentence nobody consumes.

## Proposed technical changes

- none — no technical chapter describes this pass. Its contract lives in
  `mirror_issues.sh`'s own comments, which step 6 rewrites, and
  `.writrun/` is mirrored into `template/` by `make template-sync` — a
  Step above, not a promise here. No decisions entry either: the
  ownership rules this touches were settled in
  `decisions/github-issues/0011` and `0023`, and this names an outcome
  inside them rather than moving any of them.

## Outcome

Implemented as specified. Output only: no write, no forge call and no
exit code moved.

`report_row_of` appends the mirror's title as a fifth base64 field; the
caller's four `cut` reads are untouched. The adoption line names the
state it found — `adopted stale mirror #18, closed — …` — placed after
the number rather than before "stale", so the substring the two existing
adoption cases assert on is extended and not replaced. Those two are the
task loop's anyway, which this change does not reach.

The comparison strips the mirror's `[REPORT-NNNN]` tag and trims both
sides, and is not case-folded. It runs only where this pass adopted the
mirror and the diff carries a title, so a restore prints nothing new, a
mirror this pull request owns never warns, and a status-only edit
compares nothing.

The warning names the mirror, the state it was in, both titles, the pull
request that introduced it — or that none did — and the rule. Then the
reopen and the label happen exactly as before: a collision named and
projected is strictly better than one neither named nor projected.
