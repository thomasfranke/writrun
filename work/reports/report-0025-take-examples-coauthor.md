---
id: report-0025
status: fixed
task_ref: []
doc_ref: technical/settings/conduct.md#agent_coauthor
created: 2026-09-04T17:11:36Z
triaged: 2026-09-04T18:02:11Z
---

# The take examples omit the flag the first commit's trailer needs

**References:** [technical/settings/conduct.md#agent_coauthor](../../docs/technical/settings/conduct.md#agent_coauthor)

task-0045 gives the taking act a first commit, and `--coauthor` is what
writes the `Co-Authored-By:` trailer on it. Neither take example passes
the flag — this repository's `AGENTS.md:66` nor the kit's
`.writrun/AGENTS.md:40`:

```bash
bash .writrun/scripts/stage-2-pull-requests/take_task.sh 0034 \
  --title "[Type][Scope] What this change does"
```

An agent following either at `stage_2.agent_coauthor: true` gets an
untrailered first commit and the script's two-line reminder, which is
the design working. What follows is the part worth recording.

The body `take_task.sh` composes carries no credit line, so at that
moment `check_observance.sh` says "nothing in the pull request body
declares agent work — no commit judged" and passes. The trailer becomes
owed later: the agent implements, writes trailered commits, and fills
the body with the credit line the conventions ask for at `true`. From
that point the pull request declares agent work and the take's own
commit is an untrailered authored commit in the range — which is
`check_observance.sh:284`'s partial compliance, "three commits
trailered of five".

So the failure does not land where the flag was omitted. It lands at
the completion gate of a pull request whose first commit was made
hours earlier, by a command the entry point told the agent to run.

Fixed in task-0045's change, after review. Both examples now pass
`--coauthor`, with the sentence that says who owes it. The route was
reconsidered because the omission does not merely inconvenience: from the
merge of that change onward, every agent take that follows the documented
entry point produces a pull request its own completion gate rejects, and
neither file sits under `docs/`, so the deltas gate that refuses
unpromised permanent-doc edits does not reach them.
