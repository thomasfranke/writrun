# This project adopts WritRun

**What is written, runs.** Docs are the executable source; code is the
derived artefact. Full reference — flows drawn, rules, schemas, decisions:
<https://github.com/thomasfranke/writrun> — pin the tag this kit was
copied from; `.writrun/VERSION` records it.

## The flows, in one line each

Happy path (drawn in full in WritRun's `docs/product/pipeline.md`):

1. **Authoring** — a human writes a rule in `docs/`, declares it finished
   (a gate); the agent derives tasks + draft specs and opens the PR.
2. **Approval** — the maintainer's review is the gate; CI records
   `draft → approved` onto the branch; merge makes the task ready.
3. **Taking a task** — agent takes the next by the algorithm; a human
   picks any eligible one. `blocked`, open dependencies, or a draft spec
   exclude a task for everyone.
4. **Finishing** — work done → delta check → Outcome + statuses → state
   check → PR. The two checks sit on either side of the status change,
   in that order, always.
5. **Review and merge** — CI re-runs the checks (methodology, not code);
   the maintainer squash-merges; the Issue mirror follows.

Special flows: a spec that must change after approval goes back through
`draft` and is re-approved (the doc always wins over a stale spec); work
discovered mid-flight enters as a `queue/` PR adding only task + spec;
`blocked` needs a `blocked_reason` and a human to lift it; a PR closed
unmerged releases everything — nothing was ever reserved.

## The structure it runs on

| | |
|---|---|
| `docs/` | Permanent truth, shaped by this project's stakeholders. Everything in it is read to derive tasks and specs — see [`docs/writrun-instructions.md`](docs/writrun-instructions.md). |
| `work/tasks/`, `work/specs/` | The queue and its elaborations — machine-managed, statuses in front-matter. |
| `.writrun/` | WritRun's home — see its [README](.writrun/README.md) for what is WritRun-owned vs. this project's. |
| `.github/workflows/writrun-*.yml` | The four workflows: `check` (the guarantee, read-only), `approve` (records approvals), and the **optional** mirror pair `issues` + `progress`. No GitHub Issues wanted? Delete those two — the queue in `work/` is the authority either way, and nothing else reads the mirror. |
| `AGENTS.md` | Agent entry point; the WritRun section sits between `writrun:begin`/`end` markers, gates table included. |

## Skills

All in `.writrun/skills/`, invoked per `AGENTS.md`:

| | |
|---|---|
| `writrun-select-next-task` | The deterministic "what's next" — plus `list_tasks.sh` for humans browsing the queue. |
| `writrun-create-task-and-spec` | Scaffolds schema-correct tasks and specs (`new.sh`); covers when a spec is warranted. |
| `writrun-check-spec-deltas` | The merge contract: the diff touched every doc the spec promised, and nothing else permanent. |
| `writrun-check-task-state` | The lifecycle gates: no forbidden status transition in the diff. |

## Templates

Generated bodies resolve in layers — the project's wins:
`.writrun/conventions/templates/` (yours) → `.writrun/templates/`
(shipped) → the generator's built-in. The PR body template lives in
`.writrun/templates/pull_request_template.md`; agents fill it when
opening any PR. Conventions (commits, branches, PR titles, task/spec
style): `.writrun/conventions/` — yours from the moment of adoption.

## Adopting (you just copied `template/` here)

1. `.writrun/` and the workflows work as copied. Rewrite
   `.writrun/conventions/` to this project's taste.
2. **`AGENTS.md`**: no previous one? Fill the skeleton's TODOs. Already
   had one? **Graft, don't overwrite** — move the marked section into
   yours; the four human gates must be named there.
3. **`docs/`**: read `docs/writrun-instructions.md`. An About file is
   required (yours may already exist); the `product/`/`technical/`
   skeletons are a suggestion — keep yours if you have docs, any shape
   counts as permanent input.
4. `work/` starts empty on purpose — the queue fills through the
   pipeline.
5. Configure the forge per the **Repository setup** section of WritRun's
   README.

Then delete this section — keeping the rest of this file as the
project's WritRun reference card is the idea.

The kit is MIT-0: copying it carries no attribution requirement and no
notice to keep.
