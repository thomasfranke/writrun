---
id: report-0034
status: tracked
task_ref: [task-0056]
doc_ref: null
created: 2026-09-05T13:37:49Z
triaged: 2026-09-05T13:37:51Z
---

# A mirror's link reaches the pull request's diff, not the file it names

**References:** [task-0056](../tasks/task-0056-mirror-links-the-file.md)

Issue #208, the mirror of `task-0054`, opens with:

> Mirrors [`work/tasks/task-0054-six-review-findings.md`](https://github.com/thomasfranke/writrun/pull/207/changes), which is the authority.

The text names a file and the link goes to the pull request's changed-files
view. A reader who follows it lands on the whole diff of nine queue files
and has to find the one the sentence named. On a change minting one task
the two are close enough to pass unnoticed; on this one they are not.

Both writers spell it the same way — `mirror_issues.sh:635` for a task
and `:833` for a report:

```
"Mirrors [\`${fname}\`](${PR_HTML_URL}/files), which is the authority."
```

The reason is stated ten lines above the first, at `:624-629`: an open
pull request only *proposes* the task, so the queue does not hold it
yet. That is true of `main` — the file is not there until the merge —
and it is not true of the file, which exists on the pull request's head
commit from the moment the mirror is born. The link avoids a `main` that
would 404 by pointing at something that is not the file at all.

The sentence is also the mirror's whole claim to being a projection: it
names the authority so a reader can go read it. Reaching a diff instead
weakens exactly the sentence that says where truth lives.
