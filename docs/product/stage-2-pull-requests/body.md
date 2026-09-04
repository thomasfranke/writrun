# The pull request body

What a pull request declares, and how a reader gets from a declaration to
the file it names. The shape ships as
[`templates/pull_request_template.md`](../../../.writrun/templates/pull_request_template.md)
and the conventions it obeys are
[`conventions/prs.md`](../../../.writrun/conventions/prs.md); this chapter
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
