# Human gates — per principle 7

This file is the project's, like `settings.json`: `writ update` never
touches it, and every project states its own answers here. This is the
WritRun repository's. Reasoning:
[`gates.md`](../docs/product/stage-1-tasks-and-specs/gates.md#what-a-projects-own-table-has-to-carry).

| Transition | Who |
|---|---|
| Anything under `docs/` | Human writes, or reviews before merge; agents may draft. |
| An authored rule declared finished | **Human declares it** — never inferred. |
| Spec `draft → approved` | **Human only**; here the assent is the maintainer's merge. |
| Task with empty `spec_ref` | Brief insufficient → **stop and ask for a spec**. |
| Derived work, before the PR opens | **Present it in the session.** |
| Repository/forge settings | **Owner assents in session**, per set. |
| A report becomes a task (`tracked`) | **Agent derives, human assents** — that change's own merge. |
| Everything else | Agent, autonomously — triage to `fixed`/`declined` included. |

**The forge row is not optional the way its answer is.** Repository
settings live outside the repository — no diff, no review, no merge gate
sees them — so an agent applying one is acting where nothing can catch
it afterwards. Whoever the project names, the agent presents current →
target values first and applies only on an explicit yes.
