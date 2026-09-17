---
id: task-0071
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0099]
doc_ref: technical/settings/schema.md#the-vocabulary-is-readable
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-17T19:46:08Z
queued: null
completed: null
merged: null
provenance: []
---

# The settings vocabulary is readable where the value is

**References:** [technical/settings/schema.md#the-vocabulary-is-readable](../../docs/technical/settings/schema.md#the-vocabulary-is-readable) · [spec-0099](../specs/spec-0099-vocabulary-readable.md)


`schema.md` now says the allowed values of every documented key are
readable from the kit, by the reader that reads the value — a
`--vocabulary` flag on `read_setting.sh`, printing a closed key's values
one per line and nothing for a free-form key. None of that is built:
the lists live as variables in `check_settings.sh`, and nothing reads
them but the check.

What has to exist: one home for the vocabulary that the checker and the
reader both read, the flag, and a test holding the schema's table to
that home.

It matters because a tool offering a choice before the write has to
hold the choices, and today the only way to hold them is a copy — a
second authority that drifts on the next update — or a grep over the
kit's internals, which is a second parser of the same. A porcelain
building a config screen against v0.0.08 was left picking blind and
learning the vocabulary from the refusal (report-0045, issue #268).
