# The pull request body

What a pull request declares, and how a reader gets from a declaration to
the file it names. The shape ships as
[`templates/pull_request_template.md`](../../../.writrun/templates/pull_request_template.md)
and the conventions it obeys are
[`conventions/prs.md`](../../../writrun/conventions/prs.md); this chapter
is the rule behind both.

## Every reference is a bullet, and every bullet opens

A body that names `spec-0059, spec-0060, spec-0061` has told the reviewer
three numbers. It has not told them what the three specs say, and it has
not offered a way to find out that costs less than a search.

So every task, spec and report a body names is a bullet carrying three
things — the id, the title, and a link that opens the file:

```markdown
- [spec-0059](https://github.com/owner/repo/blob/main/work/specs/spec-0059-routed-status.md) — The routed end runs
```

The id is what the machinery reads and what a person types into a search.
The title is what makes a list of three ids reviewable without opening
any of them. The link is what makes opening one cost a click. None of the
three stands for the other two.

This is the rule the queue already keeps one layer down — a task's body
links its `doc_ref` and every spec it elaborates, a spec's body links its
task ([`schemas/task.md`](../../technical/schemas/task.md)) — reaching the
one place where the reference was still a bare number.

**The three declarations.** An implementing pull request lists its specs,
an authoring one lists the tasks and specs it derives, and a reporting
one lists the report and the pair the route mints. The heading
`## Derived work` is a contract marker `writrun check` finds by name; what
sits under it is bullets.

## A body link is absolute

A pull request body is a page, not a file in the tree. A relative path
there has nothing to be relative *to*: the forge leaves it uncorrected and
the browser resolves it under the pull request's own address, which
reaches nothing. The link is written as a full URL, or it is not a link.

That is the one place this rule differs from the queue's, where relative
paths are correct and stay correct through a rename.

## The link points at the authority branch

`main`, never the branch the pull request is merging. A squash-merging
project deletes the head branch at merge, so a link to it dies at the
exact moment the pull request stops being a conversation and becomes a
record. A link to `main` outlives every branch that ever carried the file.

For work an authoring pull request *creates*, the `main` link resolves at
merge and not before — and that is the honest address. The merge is the
assenting act ([approval](approval.md)); a link that starts working when
the work becomes real is describing the queue correctly. Until then the
file is in the pull request's own diff, one tab away from the body that
names it.

## The body says how to test

Two questions are asked of a finished pull request, and one of them had
nowhere to be answered.

- **`## How to verify`** — the methodology's answer: the completion
  gates' result, and anything a reviewer should re-read by hand.
- **`## How to test`** — the reviewer's answer: what to run to watch the
  change work, and what to expect back. Commands, not assurances.

A change that ships nothing runnable says so in a line. An empty section
and a forgotten one look identical, which is the reasoning that already
makes an authoring change declare "none" rather than leave Derived work
blank ([authoring](../stage-1-tasks-and-specs/authoring.md#declaring-derived-work)).

## A section the body carries is a section it answered

The sentence above was written about two headings and is true of every
one of them, and for ten days the criteria below said it about only one.
That is how two pull requests reached `ready` here — #261 and #262 —
with `## What`, `## Why` and `## How to test` holding nothing but the
comments the template seeded, and every completion gate green over them.

So the rule binds **whatever headings the body carries**, and it is
deliberately not a list of them. The template ships three
kind-specific sections and instructs a change to keep the one that
applies and delete the others; a project may shape the rest to suit its
reviewers. A fixed list of required headings would be a second copy of
the template — wrong the first time anyone edits theirs, and judging an
adopter by this repository's habits. What the body carries is read off
the body, the way a promise's first segment is read off the tree
([0065](../../technical/decisions/pull-requests/0065-a-promise-is-judged-by-shape.md)).

**Unanswered has a signature, which is what makes this checkable at
all.** A section nobody filled still holds the instructional comment the
template put there, verbatim; failing that, it is a heading with nothing
under it but the next heading. Both are readable without understanding a
word of the prose — the distinction WritRun draws everywhere between a
guard and a review.

**The moment is `ready`, never the taking.** Taking a task opens the
draft before the work starts, and a body that had to be complete then
would be a body written before its own change. A draft answers nothing
and owes nothing; marking it ready is the claim that a reviewer can now
read it.

## Criteria

- When a pull request body names a task, a spec or a report, it shall
  carry that id's title beside it and a link that opens the file, so that
  a reviewer reads the list without a search and opens any entry with a
  click.
- When a body links a file in the repository, the link shall be a full
  URL, so that it resolves from a page that is not itself in the tree.
- When a body links a file in the repository, the link shall address the
  authority branch, so that it survives the deletion of the head branch
  at merge.
- When a pull request is marked ready for review, its body shall state
  what a reviewer runs to test the change, or state that there is nothing
  to run.
- When a pull request is marked ready for review, every section its body
  carries shall be answered — the template's instructional comment
  replaced by the answer, and no heading left standing over nothing.
- When a body omits a section the template ships, nothing shall require
  it: what the rule reads is the headings that are there, never a list of
  the headings that could be.
