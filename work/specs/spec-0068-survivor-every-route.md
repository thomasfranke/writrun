---
id: spec-0068
task_ref: task-0049
status: draft
created: 2026-09-04T19:27:27Z
---

# spec-0068 — The survivor question reaches every route a task is carried by

**References:** [task-0049](../tasks/task-0049-survivor-every-route.md)

- **Goal:** a task an open pull request still works is never landed,
  whichever route that pull request carries it by.

## Scope

In: the close-without-merge arm of `apply_pr_event.sh` — what it asks
the forge for, and what it filters the answer by.

Out: `ql_carried_of`. It answers correctly for both of its arguments
already, and gains a second caller here rather than a change. That is
the whole point: this arm is a reader that disagreed with the helper,
not a question the helper cannot answer.

Out: whether a `[TASK-NNNN]` tag that does not lead the title should
count. The helper reads leading tags only, both readers agree on that
today, and the contract lives in
[decision 0046](../../docs/technical/decisions/pull-requests/0046-the-task-tag-leads.md)
and in `ql_carried_of`'s own comment —
`titles.md#pr_title_style` states what the tag is for, not where it may
sit. Moving the rule by way of a bug fix would change it while claiming
to keep it.

Out: the two sibling readers of this same listing.
`take_task.sh` and `check_amendment_reference.sh` each list the open
pull requests with an interpolated `\t` and read rows positionally, so
the hazard fixed here — a title's own characters read as fields —
stands in both after this ships: a title carrying a literal tab or a
newline still shifts their rows. One shared listing reader in
`queue_lib.sh` is the shape that ends the class for all three, and it
is a change to two working scripts this defect does not touch — it
needs a report of its own rather than a ride on this fix, and this
paragraph is that report's anchor.

Out: `flip_task_status.sh`'s edge table, and the missing `ready →
in-review` edge that makes this defect outlive the event that caused
it. That absence is what makes the window expensive, not what opens it;
report-0023 carries it, and closing the cause here does not need it.

Out: the fork exposure of report-0028. A fork already chose both of the
strings this arm reads — `headRefName` on a fork's pull request is the
fork's to name, exactly as its title is — so a survivor claimed by tag
is one more spelling of a claim that was always available, not a new
one. And a survivor can only *hold a task in flight*; the take that put
it there was the other reader's.

**Two readers of one question, and the fix is to stop having two.**
`apply_pr_event.sh` derives the tasks it must write from
`ql_carried_from_env`, so the head branch and every leading title tag
both count. Then it asks the forge which of those tasks somebody else
still works, and answers that question with a regex over head branch
names alone —

```
$2 ~ ("^task/0*" n "-")
```

— so a survivor that carries the task by tag is invisible to the very
run that was reading tags a dozen lines above. Three ways to close it
were weighed:

- *Grep the title for the tag in the same awk* — rejected. It is a
  second implementation of the tag grammar: the leading-only rule, the
  case folding, the zero stripping, the dedupe. spec-0066 refused
  exactly this for exactly this reason, and a second parser inside the
  script that just stopped having one would be a worse copy than the
  one that was deleted.
- *Ask the forge per task, with a search that names the tag* — rejected.
  It reinstates one call per carried task, which spec-0066's build
  removed on the reasoning that no two of those answers could differ.
  The listing is not the defect.
- *List `title` beside `headRefName` and filter both through
  `ql_carried_of`* — chosen. The question and the reader then compute
  the carried set the same way, by construction, and the filter becomes
  a membership test instead of a pattern.

**The wire shape has to change with it, and that is not incidental.**
The listing comes back today as `number headRefName login isDraft`,
space-joined by `--jq` and read positionally by awk. A title has spaces
in it, and may have a newline, so appending it to that shape gives one
pull request an unpredictable number of fields and possibly two rows.
The rows become tab-separated instead — `@tsv`, which escapes both — and
are read as fields rather than split on whitespace.

**One listing stays one listing.** The carried set of each open pull
request is computed once per row, before the loop over the closing pull
request's tasks, not once per row per task. A close carrying six tags
must still cost the forge one call and the helper one pass.

## Steps

1. Ask the forge for the title: `--json
   number,headRefName,author,isDraft,title`, emitted with `@tsv` rather
   than the interpolated string, so a title's own spaces cannot be read
   as fields.
2. Build the survivor index once, before the loop over carried tasks:
   one line per open pull request holding its number, author login,
   draftness, and the carried set `ql_carried_of "$head" "$title"`
   answers for it. Two rows never reach the helper. The closing pull
   request's own, wherever the listing's lag still shows it — the event
   is better evidence than the cache, and a closed pull request must
   answer for nothing (see Edge cases). And any row that cannot carry a
   task — a head branch not under `task/` and a title not opening with
   `[` — dropped by one cheap test first: `ql_carried_of` forks
   subshells, and a 200-row listing would otherwise buy every unmerged
   close several hundred forks for rows that answer nothing.
3. Replace the head-branch regex with membership in that set —
   field-wise equality, never a substring of the row. The loop's own
   `sed 's/^task-0*//'` goes with it: both sides are already normalized
   to `task-N` by `ql_task_num`, and a second normalization is a second
   rule.
4. Keep the single listing and its `--limit`. This change alters what
   the answer is filtered by, never how often it is asked.
5. Update the script header's close-without-merge paragraph to say
   which routes the question reaches and that it reaches them through
   the same helper as the reader, and name this second caller in
   `ql_carried_of`'s own comment, which today names only the amendment
   check.
6. `make template-sync` — `.writrun/` is mirrored into `template/`.

## Acceptance criteria (EARS)

- When a pull request closes unmerged, the system shall decide each
  carried task's survivor from the carried set `ql_carried_of` answers
  for each open pull request, covering the head branch and every
  leading `[TASK-NNNN]` tag of the title.
- When an open pull request carries a closing task by a title tag
  alone, the system shall treat it as a survivor and re-record that
  task's in-flight state and `taken_by` from it instead of landing it.
- When several open pull requests carry one closing task, by either
  route or by both, the system shall re-record from the
  highest-numbered of them.
- When no open pull request carries a task by either route, the system
  shall land it and clear `taken_by`, as it does today.
- When the listing still shows the closing pull request itself, the
  system shall not count it the survivor of any task, by any route.
- When a pull request carries several tasks, the system shall ask the
  forge exactly once for the run, with `--limit` above the forge's
  default page.
- When an open pull request's title contains spaces or a newline, the
  system shall read that row's fields unambiguously and shall not take
  title text for another field.
- When the forge cannot answer, the system shall land every carried
  task, as it does today.

## Edge cases

- **An open pull request that carries no task at all** — a `docs/` or
  `report/` branch with an untagged title. Its carried set is empty, and
  an empty set must answer for no task. This is the case a substring
  match gets wrong, which is why the membership test is field-wise.
- **A row whose login or number spells a task id.** Matched against the
  carried field alone, never against the line.
- **Zero-padded spellings on either side** — a survivor on
  `task/019-fix`, a tag written `[TASK-0019]`, a closing task file
  `task-0019`. All three normalize through `ql_task_num`, which is the
  reason the loop's own stripping is removed rather than kept beside it.
- **A head branch named `task/0021` with no trailing dash.** The old
  regex required the dash; the helper does not. So the survivor query
  now judges a head branch by the same rule that decides which tasks the
  closing pull request itself carries — a widening, deliberate, and in
  the direction of agreement.
- **A tag that does not lead the title**, as in `Fix [TASK-0022]`. Not
  carried, by this reader and by the reader upstream alike. The reach is
  exactly the reader's, and no wider.
- **The closing pull request in its own `open` listing**, on a race
  against the forge's own state. Left alone, this fix would widen an
  existing strand: today the closing pull request can name itself
  survivor of the one task its head branch spells, and membership over
  branch and title would let it claim every tag-carried task too — each
  re-recorded in-flight from a closed pull request's own author, with
  no later event from that pull request to heal it. So the row is
  skipped by number in step 2, which closes the branch-route strand the
  script's header already names along with the one this would have
  opened: the event in hand proves that pull request closed, whatever
  the listing's lag says.
- **More than 200 open pull requests.** The limit and its cut are
  untouched; the index is built over whatever the listing returned.
- **`gh` absent, or `GH_TOKEN` empty.** The listing is skipped, the
  index is empty, every carried task lands. Untouched.

## Tests required

- `a_survivor_answers_for_one_task_test.sh` is re-aimed, and this is a
  deliberate change of scenario rather than a test caught wrong. Said
  precisely: the stub's one listing row carries no title field at all
  today, so in the fixture as it stands task-0022 has no survivor by
  any route and the landing the test asserts is correct. What the
  re-aim does is give the fixture the shape report-0027's defect needs
  — a title on the survivor's row — and then assert the fix over it.
  Three things change together:
  - The stub's rows become `@tsv`-shaped and gain the title, since the
    script now asks for that field.
  - The survivor's title carries `[TASK-0022]`, and task-0022 must be
    re-recorded from it: `in-review`, `taken_by` naming the survivor's
    author. The assertion inverts.
  - The landing half moves onto a third carried task that no open pull
    request names by either route, so the case still proves both
    outcomes from one listing.
  Its two harness assertions are preserved as they stand: exactly one
  `gh pr list` call for the whole run, and `--limit` present in that
  call.
- A case where two open pull requests carry one closing task, the
  lower-numbered by branch and the higher by tag alone: the higher one
  wins and `taken_by` names its author. Run the reverse ordering too, so
  the answer is not an artifact of which route the listing happened to
  put first.
- A case where the listing includes a pull request carrying no task:
  every carried task's answer is unaffected by that row.
- A case where the listing still includes the closing pull request's own
  row, title tags and all: no task is re-recorded from it, and its
  tasks land wherever no other row carries them.
- A case where a survivor's title carries its tags ahead of a
  `[Feat][Ci]` suffix and a summary with spaces: the row is read as
  fields, and the survivor is found.
- `no_forge_answer_lands_the_task_test.sh` and every non-close case must
  pass unchanged — this arm's other outcomes do not move.

## Definition of Done

- [ ] The listing asks for `title`, and its rows are read as fields.
- [ ] The survivor filter is membership in `ql_carried_of`'s answer, and
      no branch-name pattern remains in `apply_pr_event.sh`.
- [ ] The closing pull request's own row answers for nothing.
- [ ] One `gh pr list` per run, `--limit` still given.
- [ ] `a_survivor_answers_for_one_task_test.sh` asserts the tag-carried
      survivor, and its landing half sits on a task nobody carries.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] The sequence in
      [report-0027](../reports/report-0027-survivor-branch-only.md) —
      #A on `task/0021-a` closed unmerged while #B on `task/0021-b`
      stays open, both titled `[TASK-0021][TASK-0022]` — leaves task-22
      `in-review` with `taken_by` naming #B's author.

## Proposed product changes

- none — the rule already stands.
  `product/stage-2-pull-requests/statuses.md#criteria` says the
  machinery re-derives from the newest surviving pull request when
  another open one *still works* the task, and names no route by which
  it works it. spec-0066 already widened the carried criterion beside
  it to every task a pull request carries. This spec makes the query
  keep both; writing "by either route" beside them is the second copy
  that disagrees later.

## Proposed technical changes

- none — no technical chapter describes this query. It is documented in
  `apply_pr_event.sh`'s own header, which is machinery this change
  updates rather than a permanent doc, and
  `technical/settings/titles.md#pr_title_style` already states that the
  tag is how the machinery learns which tasks a pull request carries.
  This makes one more reader keep that statement.

## Outcome

_(fill after execution)_
