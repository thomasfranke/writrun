---
id: report-0021
status: open
task_ref: []
doc_ref: null
created: 2026-09-04T14:47:24Z
triaged: null
---

# rederive_labels.sh misses mirrors minted seconds earlier in the same job

Issue #161, opened by @thomasfranke.

Observed in `thomasfranke/writrun-cli`, kit at `v0.0.03`. Six task mirrors were created and never received a `status:` label; nothing since has corrected them, and the workflow reported success.

In a single `writrun approve` run, `mirror_issues.sh` minted Issues #3–#16 for task-0001…task-0014 between 05:05:30Z and 05:05:39.36Z. Five milliseconds later the same job invoked `rederive_labels.sh` with all fourteen ids. It labelled task-0001…task-0007, reported `no mirrored Issue.` for task-0009…task-0014, then labelled task-0008:

```
05:05:39.37  bash .writrun/scripts/stage-3-github-issues/rederive_labels.sh ...
05:05:40.84  task-0001 → status:ready (re-derived from the queue)
   ...
05:05:46.95  task-0007 → status:ready (re-derived from the queue)
05:05:47.04  task-0009: no mirrored Issue.
05:05:47.14  task-0010: no mirrored Issue.
05:05:47.24  task-0011: no mirrored Issue.
05:05:47.34  task-0012: no mirrored Issue.
05:05:47.45  task-0013: no mirrored Issue.
05:05:47.55  task-0014: no mirrored Issue.
05:05:48.46  task-0008 → status:ready (re-derived from the queue)
```

`rederive_labels.sh:145` fetches the mirror list once, at startup:

```sh
ISSUES=$(gh api "repos/${REPO}/issues?labels=writrun:task&state=all&per_page=100" \
  --paginate \
  --jq '...')
```

That read landed roughly four seconds after the last create, and the cut in what it saw follows creation order exactly: #10 (task-0008, created 05:05:35.42Z) was in the snapshot; #11 (task-0009, created 05:05:36.17Z) and the five after it were not.

Two details point at the snapshot rather than a per-task lookup or a rate limit. The six failures took about 100 ms each against roughly 1 s for each success, so no write was attempted for them. And task-0008 — last in the argument list, processed nine seconds after the failures — succeeded, because its visibility had been decided at snapshot time rather than at processing time.

The affected mirrors are writrun-cli #11–#16. Their queue files carry `status: ready` and every spec in their `spec_ref` is `approved`, so the files are correct and only the projection is behind. `origin:rule` and `writrun:task` did land on all of them, since `mirror_issues.sh` writes those at creation.

The comment in `writrun-approve.yml` names this outcome — "Minted and never labelled is the one outcome with no second event to correct it" — and the guard written there covers the rebase-merge divergence, where `merge_commit_sha` leaves a task outside the commit range. This run is a different path to the same outcome: the ids were all passed correctly, and the mint and the projection ran in the same job.

Evidence: https://github.com/thomasfranke/writrun-cli/actions/runs/33839172431

