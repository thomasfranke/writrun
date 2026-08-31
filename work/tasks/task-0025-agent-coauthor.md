---
id: task-0025
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0035]
doc_ref: product/concepts/provenance.md#the-commits-carry-the-other-half
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T14:23:13Z
queued: 2026-08-31T15:20:54Z
completed: 2026-08-31T22:38:41Z
merged: 2026-08-31T23:35:01Z
---

# The agent's credit names its model, and the check reads both directions

**References:** [product/concepts/provenance.md#the-commits-carry-the-other-half](../../docs/product/concepts/provenance.md#the-commits-carry-the-other-half) · [spec-0035](../specs/spec-0035-agent-coauthor.md)

The adopter's word on the agent's self-credit is half-held. `false` is
checked — a pull request carrying a co-author trailer, a session link or a
generated-with line while the flag forbids it fails at the door. `true` is
not checked at all, and cannot be: it was defined as keeping *whatever
credit the platform appends*, which names a source instead of an artifact,
so there is no shape for a check to assert. The observance run says as much
out loud, prints that nothing is judged, and returns.

The docs now define `true` as an artifact — a `Co-Authored-By:` trailer
naming the model, and a credit line in the pull request body — and rename
the key `agent_coauthor`, because the flag states what appears in the
commit and every other document in this repository calls the actor *the
agent*. Bring the settings, their checks, the conventions and the adoption
kit up to that, and give the `true` direction the check it can now carry.

What this buys is larger than the flag. Once an agent's commits name the
model that helped write them, the commit history answers *which model
worked this change* by itself — in any repository, on any agent platform,
with no second store to keep. That is half of what the provenance ledger
exists to report, obtained from something git already indexes.

Judging that direction has one boundary the work must respect: using an
agent is not obligatory, so a person's commits carry no trailer and are
never at fault for it.
