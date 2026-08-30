# Human gates

Four checkpoints are named, not implied. An adopting project states, in
its own `AGENTS.md`, who operates each one — but every adopting project
must name all four somewhere, even if the answer for one of them is "an
agent, autonomously":

- **Changing a permanent doc** — About, any product chapter, any technical
  section, authored or closing the loop. A human writes it or reviews it
  before the change stands. An agent may draft the change; a permanent doc
  never merges on agent approval alone.
- **An authored rule declared finished.** A human writes a rule over many
  edits and no event marks the last one, so derivation never starts on an
  inference: the human declares the doc done, and only then is the derived
  work generated. Today the declaration is simply telling the agent — or
  marking the authoring change ready for review; tooling may give it a
  command later. The forgotten handoff is caught mechanically, not
  remembered: a change to a permanent doc that neither derives tasks nor
  declares "none" does not merge.
- **A spec's `draft → approved` transition.** By default, human-only. An
  agent never self-approves a spec it drafted, or anyone else's, unless the
  adopting project has explicitly written down that it delegates this gate.
  The project also names **which act carries the assent** — an approving
  review, or the merge — since a repository whose maintainer authors its
  own pull requests has no review available to give (flow 2).
  `approved → implemented` is not gated the same way — it happens
  mechanically when the task completes and the Outcome section is filled.
- **A task whose brief is insufficient.** When `spec_ref` is empty and the
  task's own body plus `doc_ref` don't add up to a brief an agent could
  implement without guessing, the agent stops and asks whether to draft a
  spec first — it does not improvise scope to keep moving.

What a gate requires is a **human decision, recorded** — not a human
keystroke on a particular field. A project may record assent however it
likes, including by having its tooling write the transition once a person
has approved the change that carries it. What stays forbidden is the thing
the gate exists to prevent: a spec reaching `approved`, or a permanent doc
reaching `main`, with no person having assented to it at all.

Everything else in the pipeline — creating tasks, drafting specs,
implementing an approved spec, filling a spec's Outcome — is agent work,
autonomously, by default. Implementing is also the one step equally a
person's to take (flow 4); the gates do not change with who takes it.

## Criteria

- When a task's `spec_ref` is empty and its body plus `doc_ref` do not
  amount to a sufficient brief, the agent shall stop and ask whether to
  draft a spec, rather than guessing at scope.
- When a spec transitions from `draft` to `approved`, a human shall have
  assented to that transition, whether or not a person writes the field.
- When a project names the act that carries a maintainer's assent, it
  shall name one its forge makes available to the people who hold the
  gate, and shall state it in its `AGENTS.md`.
- When a permanent doc (About, a product chapter, a technical section) is
  changed, the change shall not be treated as final until a human has
  written or reviewed it.
