# File schemas

**The front matter and body shape of every file the machinery reads** —
task, spec, report — and the canonical form all three are held to. Read
the chapter for the file you are touching before touching anything under
`work/`; the technical router is [`../README.md`](../README.md).

| Chapter | Holds |
|---|---|
| [`task.md`](task.md) | the task schema, each field's rules, `blocked` vs. `depends_on` |
| [`spec.md`](spec.md) | the spec schema and the Proposed-changes contract |
| [`report.md`](report.md) | the report schema and the routes its status records |
| [`front-matter.md`](front-matter.md) | the canonical form, and where the shape is enforced |

## The skill is the operational pointer

[`writrun-create-task-and-spec`](../../../.writrun/skills/writrun-create-task-and-spec/SKILL.md)
generates every shape above — `new.sh task|spec|report`, with the flags
and refusals that make an id, a slug and an `origin` a fact rather than a
memory. The skill carries the commands and how to fill what they leave
blank; the schema is this folder's, stated once, and
`writrun-check-front-matter` is what holds a hand-written file to it.
