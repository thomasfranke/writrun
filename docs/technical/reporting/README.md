# Reporting

**How something observed enters the system**, and where triage can send
it. Read it when recording a finding rather than working one; the
technical router is [`../README.md`](../README.md).

| Chapter | Holds |
|---|---|
| [`entry-point.md`](entry-point.md) | the operation's contract, deterministic end to end |

## The skill is the operational pointer

[`writrun-create-task-and-spec`](../../../.writrun/skills/writrun-create-task-and-spec/SKILL.md)
is where the commands live — `new.sh report`, its two refused flags, and
`new.sh task --from-report`, which closes the link triage opened. The
statuses those commands write, and the rule that keeps the `tracked`
route on a branch of its own, are
[`concepts/report.md`](../../product/concepts/report.md)'s; the skill links
there rather than restating them, so the route has one statement and not
three.
