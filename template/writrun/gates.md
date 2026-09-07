# Human gates — per principle 7

This file is the project's, like `settings.json`: `writ update` never
touches it, and every project states its own answers here. Fill the
TODOs — naming an agent as the operator of a gate is a valid answer;
leaving a gate unnamed is not.

| Transition | Who |
|---|---|
| Writing or changing anything under `docs/` | <!-- TODO — default: human writes or reviews before merge --> |
| An authored rule is finished, so derivation may start | <!-- TODO — default: the human declares it --> |
| Spec `draft → approved` | <!-- TODO — default: human only, recorded via the approved PR --> |
| Task with empty `spec_ref` and insufficient brief | <!-- TODO — default: stop and ask for a spec --> |
| Derived work, before the PR opens | <!-- TODO — default: present it in the session --> |
| Changing repository/forge settings (Actions permissions, rulesets, merge methods) | <!-- TODO — default: the owner assents in session, per set of changes --> |
| A report becomes a task (`tracked`) | <!-- TODO — default: the agent derives, the human assents through that change's own merge --> |
| Everything else | Agent, autonomously. |

**The forge row is not optional the way its answer is.** Repository
settings live outside the repository — no diff, no review, no merge gate
sees them — so an agent applying one is acting where nothing can catch
it afterwards. Whoever the project names, the agent presents current →
target values first and applies only on an explicit yes.
