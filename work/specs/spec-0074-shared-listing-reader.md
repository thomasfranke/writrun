---
id: spec-0074
task_ref: task-0054
status: implemented
created: 2026-09-05T12:57:03Z
---

# spec-0074 — One listing reader ends the tab-collapse class

**References:** [task-0054](../tasks/task-0054-six-review-findings.md)

- **Goal:** one reader parses the open-pull-request listing, three
  callers use it, and a title's own characters can no longer shift a
  row in any of them.

## Scope

In: a shared listing reader in `queue_lib.sh`, and moving
`apply_pr_event.sh`, `check_amendment_reference.sh` and
`check_unique_ids.sh` onto it.

In: the hazard itself. Tab is an IFS whitespace character, so `IFS="$TAB"
read` collapses runs of tabs: one empty field shifts every field after
it. `gh` emits an empty `author.login` verbatim for a deleted account,
which is how the empty field arrives without anybody typing one.

Out: `take_task.sh`. It interpolates the same `\t` at line 536 and
reads it positionally, and spec-0068 named it alongside
`check_amendment_reference.sh` as a sibling. It is a fourth caller and
belongs on the reader, but it is also the act that opens every pull
request in this repository; moving it in the same change would put the
taking act's regression risk on a defect fix. It gets a report of its
own, and this paragraph is that report's anchor.

Out: what a row *means*. `ql_carried_of` and `ql_task_num` keep their
contracts exactly; this changes how the row reaches them.

Out: the `--jq` projection's field order. Callers read different
subsets — `check_unique_ids.sh` reads a kind/number/file triple, the
other two read a pull-request row — so the reader must serve both
without a single field order becoming the new coupling.

**spec-0068 already named the shape.** #200 fixed the collapse in
`apply_pr_event.sh` and put the siblings out of scope by name; its
lines 34-43 say a shared listing reader in `queue_lib.sh` is what ends
the class for all three, and that the fix "needs a report of its own
rather than a ride". This is that report's spec.

**Why a helper rather than three fixes.** Three correct copies of one
parse agree until one of them is edited. `queue_lib.sh` exists because
two private copies of the id-minting scan had already drifted apart
once, and its own header says never to call `ql_forge_scan` from a
command substitution for the same reason: one writer per question.

## Steps

1. Read all three call sites and write down what each row carries and
   which fields each caller uses. The reader's shape is decided by the
   union, not by whichever caller is converted first.
2. Add the reader to `queue_lib.sh`. It must not collapse empty fields:
   the field separator has to be treated as a delimiter, not as
   whitespace. Give it the header the file's other helpers have — what
   it answers, and the failure it exists to prevent.
3. Move `apply_pr_event.sh` onto it, keeping #200's behaviour
   identical. Its cases pass unchanged or the reader is wrong.
4. Move `check_amendment_reference.sh:210` onto it.
5. Move `check_unique_ids.sh:198` onto it.
6. Mirror `.writrun/` into `template/` with `make template-sync`.

## Acceptance criteria (EARS)

- When the forge listing carries a row with an empty field, the shared
  reader shall return that row with every field in its own position.
- When a listed pull request's title carries a literal tab, the reader
  shall not read the fragment after it as a later field.
- When `apply_pr_event.sh`, `check_amendment_reference.sh` or
  `check_unique_ids.sh` reads the open-pull-request listing, it shall
  read it through the shared reader and shall not parse the rows
  itself.
- When the listing is empty or the forge could not be reached, each
  caller shall behave exactly as it does today.

## Edge cases

- **A title carrying a newline.** The row separator, not the field
  separator. The reader must state whether it survives one, and if it
  does not, the projection has to stop putting the title last where a
  newline silently ends the row.
- **A deleted account.** The case that produces the empty field in
  practice; `gh` emits `author.login` as the empty string. It is the
  fixture the tests should use, because it is real.
- **`check_unique_ids.sh`'s rows are not pull requests.** Line 198
  reads a kind/number/file triple assembled locally. It carries the
  identical collapse hazard and belongs on the reader, but a reader
  named for pull requests would read wrong there — name it for the
  parse, not for the source.
- **bash 3.2.** No associative arrays, no `readarray`, no `read -d ''`
  tricks that assume bash 4. The standing rule is in
  `technical/decisions/`.
- **The `template/` twins.** Four files move; all four have twins, and
  the byte-identity case fails loudly if one is missed.

## Tests required

- A unit case per caller, feeding a listing whose author field is empty
  and asserting the fields after it are still in place. Three cases,
  one hazard, because the point is that the class is closed everywhere.
- A unit case feeding a title containing a literal tab and asserting no
  caller reads a field from it.
- The existing `apply_pr_event` integration cases must pass unchanged —
  that is the regression evidence for step 3.
- A unit case asserting no caller of the listing parses it with a bare
  `IFS="$TAB" read`, so a fourth caller added later is caught at the
  suite rather than at a deleted account.

## Definition of Done

- [ ] One reader in `queue_lib.sh`, with a header saying what it
      prevents.
- [ ] All three callers use it; none parses the listing itself.
- [ ] An empty field shifts nothing, in all three.
- [ ] A tab in a title shifts nothing, in all three.
- [ ] `apply_pr_event`'s existing cases pass unchanged.
- [ ] `take_task.sh` is reported, not silently left.
- [ ] `template/` twins identical; `make template-sync` reports nothing
      to do.

## Proposed product changes

- none — no rule changes. The queue's behaviour with a deleted account
  in the listing was always what this restores; the readers were wrong
  about it, and being wrong about a rule is not a version of it.

## Proposed technical changes

- none — no chapter describes the listing readers.
  `distribution/checks.md` states the rules that belong to a gate
  script's *caller*, and this changes how a script reads a forge
  answer, which is the script's own. The reasoning goes in
  `queue_lib.sh`'s header, beside the helper, where its siblings keep
  theirs.

## Outcome

One reader, `ql_row_fields`, in `queue_lib.sh` beside the helpers that
are one copy for the same reason.

`IFS="$TAB" read` cannot split these rows: a tab is IFS *whitespace*, so
a run of tabs folds into one separator, an empty field vanishes and every
field after it shifts left. The empty field is not hypothetical — `gh`
writes `author.login` as the empty string when the author deleted their
account, and `@tsv` emits two adjacent tabs. What the shift produced was
a listing row about a pull request still working a task being read as a
row about something else.

Three callers converted: `apply_pr_event.sh`, `check_amendment_reference.sh`
(three loops) and `check_unique_ids.sh`. The third assembles its own rows
rather than reading a forge, which is why the helper is named for the
parse and not for pull requests — and why converting it was refused as
optional: the collapse is a property of `read`, not of where the row came
from.

The helper returns 1 on a row with too few separators, so a caller skips
a row it cannot answer instead of reading it short — the guard the hand
parse carried, kept, and now in one place. No doc delta, as promised: the
reasoning lives in the helper's own header.

