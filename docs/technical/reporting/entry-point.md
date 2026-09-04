# The entry point

**How something observed enters the system**, deterministic end to end. One chapter of [`reporting/`](README.md).

## The report entry point

The cheapest way work enters the system, and the one a client wraps
first: **a report is one free-form sentence** — "checkout returns
500", "the generator reuses ids" — plus whatever evidence is at hand.
No form and no prose requirement — but the report is **kept**,
not consumed: it becomes a file that records the observation and,
later, the route triage sent it down ([report schema](../schemas/report.md#report-schema)).
Everything else structured about it is still produced *from* it,
downstream. The product-side flow, gates and triage table live in
[authoring — reporting](../../product/stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight);
this section is the operation's contract, for agents today and the CLI
tomorrow.

The operation, deterministic end to end:

1. **Record** — the observation becomes a file: `new.sh report`,
   `status: open`, evidence in the body as text and links. This runs
   **before** triage and before the dedup search, because capture is
   the step that has to cost nothing — a duplicate report is cheaper
   than a finding nobody wrote down. It rides whatever change is
   already open: a report is neither a rule nor work, so the
   one-kind-per-change rule does not reach it.
2. **Dedup** — at triage, the non-completed tasks are read; a report
   matching one ends `tracked` against that task and the operation
   stops there. New evidence it carried enriches the existing task's
   body through a normal queue change. A client implements this as a
   search over `work/tasks/` front matter and titles, never as a
   question to the reporter.
3. **Triage** answers two questions in order — *is this worth acting on
   at all?*, then, for what survives, *is what "correct" means already
   written?* Five outcomes, and each writes the report's terminal
   status: not a defect, or not worth acting on → `declined`, with the
   reason in the body; a defect against documented behaviour → a task,
   `tracked`; a rule nobody wrote → route to authoring, `authored`; a
   trivial fix → a commit, `fixed`; a defect another repository owns →
   an issue opened there, `routed`, the body naming it. The first
   question is new: while reports evaporated there was nothing to
   close, so one question sufficed and the table never had to name a
   "no". All are the agent's to answer, `declined` included — triage is
   not a human gate
   ([gates](../../product/stage-1-tasks-and-specs/gates.md)) — with one
   asymmetry: `routed` opens an issue on someone else's repository,
   which is an outward-facing act, so it waits on the user's explicit
   authorization, asked per report and never assumed from a session's
   flow. A refused or unanswerable ask leaves the report `open`
   ([routing upstream](../../product/concepts/report.md#routing-upstream)).
4. **Generation**, on the defect path: `new.sh task` with
   `--origin report`, `--doc-ref` when a doc states the violated
   behaviour (null when the broken thing was never documented),
   priority from impact; a spec via `new.sh spec` when the fix is more
   than the body can brief. **Evidence — the error, the log excerpt,
   the reproduction — lives in the task body, as text and links**: the
   mirror is one-way, so anything attached only to an Issue never
   reaches the file that is the authority. The generated queue is
   **presented to the human before any PR opens** (the
   derivation-review gate). The new task's id is written onto the
   report's `task_ref`, which is the only link between the two — the
   task schema carries nothing pointing back.
5. **Recording**, at Stage 2+: branch `report/short-name` — no task id
   in the name, because the PR records work rather than working it —
   and a PR that only adds queue files. The merge authorizes the task;
   the approval gate takes over. **This branch is for a change that is
   only a report**; a report file added alongside other work needs no
   branch of its own, which is step 1's exemption seen from the forge
   side.

One inversion a client must know: **an outage ships the fix first.**
When documented behaviour is down, the patch goes out through an
ordinary PR at whatever size the outage demands, and the report runs
immediately behind it, triaging what remains — the patch itself gets
no retroactive task
([the reporting rules](../../product/stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight)).
This is the one case where step 1 follows the work instead of leading
it: "capture costs nothing" is the reason recording comes first, and no
reason of that shape outranks a live outage. The report still gets
written — `tracked` when work remains, `fixed` when the patch was all of
it — because an outage nobody recorded is the finding most worth having.

What a client (`writ report`) builds on is exactly the public contract
below: the task, spec and report schemas (`origin: report`
included), the generator's arguments and refusals, the `report/` branch
prefix, and the `## Derived work` marker in the PR body. The triage judgement
itself is the one step that is not mechanical — a client either asks
an agent to make it or asks the person, and the contract stays the
same either way.


