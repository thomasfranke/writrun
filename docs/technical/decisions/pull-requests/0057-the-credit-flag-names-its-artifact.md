# the credit flag names its artifact, and is renamed `agent_coauthor` — narrowing 0054's `credit_ai`.

**2026-08-31**

[0054](../tasks-and-specs/0054-the-adopter-governs-the-agent.md) gave the
adopter a word on the agent's self-credit and defined `true` as keeping
*whatever credit the platform appends* — a co-author trailer, a session
link, a generated-with line. That definition names a source rather than an
artifact, and the consequence showed up in the checker: `check_observance.sh`
can fail a pull request carrying credit at `false`, and at `true` prints
*"the adopter allows platform credit, so nothing is judged here"* and
returns. Half the flag was unheld, and not by oversight — an open set has
no shape to assert. A promise with no shape is a promise nothing holds.

So `true` now names the artifact: a `Co-Authored-By:` trailer on the
agent's commits, naming the model, and a credit line in the pull request
body. Both directions become checkable, and the obligation follows from the
shape — an agent on a platform that appends nothing must **write** the
trailer, where before it had nothing to keep. `true` stops being passive.

The model is named specifically rather than as a category, because the
record has to survive the next model's arrival. That is also what makes the
commit history answer *which model worked this change* on its own, in any
repository, without a second store — half of what
[Provenance](../../../product/concepts/provenance.md) needs, obtained from
an artifact git already indexes.

**The name moves with the meaning.** `credit_ai` was the only setting
naming the actor something the documentation never calls it: every chapter
says *the agent*, and the sole lowercase `ai` in `docs/` was the key
itself. Once the flag states what appears in the commit, `agent_coauthor`
says it outright — `agent_coauthor: true` reads as *the agent appears as
co-author*, and no reader opens this file to learn what the flag does. At
`v0.0.01`, with no adopter but this repository, the rename costs a
`check_settings.sh` fault naming the new home.

Rejected: a `coauthor` / `none` / `platform` vocabulary. It is the honest
shape if credit ever takes a second form, and nothing here forecloses it —
but a third value would have to describe an artifact too, or it reintroduces
exactly the unheld state this entry closes. A boolean that means one
checkable thing is worth more today than an enum whose extra value would
have to be invented first.

Rejected: `agent_signs_commits` and every "sign" spelling. Commit signing
is a real and unrelated mechanism, and a settings key that reads as GPG
configuration would be misread by precisely the reader who knows git best.

Rejected: folding it into the `auto_` family. Those flags gate whether the
agent may act; this one states what the act leaves written. Sharing their
prefix would file it under a question it does not answer.

Rejected: checking the `true` direction against every commit. A human's
commits carry no trailer, using an agent is not obligatory, and a check
that read that absence as disobedience would fault honest work. The
direction is judged only on an agent's own commits, by the same committer
identity the recording-commit skip already resolves.
