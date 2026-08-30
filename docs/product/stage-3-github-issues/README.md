# The Issues mirror

**Task is WritRun's noun; a GitHub Issue is only where a task is mirrored**
for people who read the queue in a browser. The file under `work/tasks/` is
the authority, always — an edit made in the mirror is not written back. In a
repository that also uses Issues for bug reports and feature requests, the
`writrun:task` label is what separates mirrors from everything else: every
workflow filters on it and touches nothing without it. A mirror is titled
`[TASK-NNNN] <task title>` — the same tag a PR title carries, so one
search for the tag finds the task everywhere it appears.
