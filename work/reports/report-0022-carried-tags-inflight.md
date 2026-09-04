---
id: report-0022
status: tracked
task_ref: [task-0047]
doc_ref: null
created: 2026-09-04T15:25:58Z
triaged: 2026-09-04T16:20:11Z
---

# The in-flight half moves only the branch's task, not the title's other tags

**References:** [task-0047](../tasks/task-0047-carried-tags-inflight.md)

Adopter `writrun-cli` opened pull request #20 titled
`[TASK-0003][TASK-0005][Feat] …`, which `conventions/prs.md` names as
supported — one bracket per task, `[TASK-0012][TASK-0014]` its own example.
The draft opened and only `task-0003` moved; `task-0005` stayed `ready` while
its work was in flight. The two jobs of `writrun-progress.yml` disagreed in
the same run:

    status on main           moved work/tasks/task-0003-update-command.md: ready -> in-progress
    mirror follows the file  task-3 → status:in-progress (re-derived from the queue)
                             task-5 → status:ready       (re-derived from the queue)

`apply_pr_event.sh:43-47` resolves one id, by regex over `PR_HEAD_REF`, and
never reads `PR_TITLE`. `template/.github/workflows/writrun-progress.yml:78`
passes `PR_HEAD_REF` alone to the `record` job; lines 146-147 pass both to
`reflect`. The merge half (`record_task_status.sh`) and the mirror projection
(`project_pr_tasks.sh`) each read every tag through `ql_carried_of`, so a
multi-task pull request lands correctly at merge and goes unrecorded for the
whole time it is in flight. The mirror is faithful to the file it re-derives
from: Issue #7 downstream carries `status:ready` while #20 is open on that
task. `take_task.sh:226` composes one tag into the title, so the second is
added by hand after the take.
