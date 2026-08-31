# Commits

**Squash-only means the PR title is the commit that lands**, so the shape
of a commit subject is the shape [prs.md](prs.md) describes, and which of
the two it is comes from [`settings.json`](../settings.json)'s
`stage_2.pr_title_style`. This file covers the vocabulary each style uses.

Under `conventional` — [Conventional
Commits](https://www.conventionalcommits.org/), `type(scope): imperative
summary`:

- **Types**: `docs`, `feat`, `fix`, `refactor`, `chore`.
- **Scopes** (optional — omit when a change genuinely spans the
  repository): `about`, `product`, `technical`, `tasks`, `specs`,
  `skills`, `ci`, `tests`, `agents`, `readme`, `setup`, `queue`.
- Example: `docs(product): add the coverage-rule concept chapter`.

Under `bracketed` — the same two vocabularies, capitalised inside
brackets, then a sentence: `[Docs][Product] Add the coverage-rule concept
chapter`.

Either way the `[TASK-NNNN]` tags come first and sit **outside** whichever
grammar follows, so the one parser that exists never has to know both at
once: from Stage 2, `writrun check` strips the tags and reads what is
left against the declared style — the type against the list above, the
scope against it too when one is present, and nothing at all about the
summary that follows. Anything downstream of that is read by eye and by
`git log --grep`, neither of which is a strict parser; the release notes
the forge generates come from pull requests and parse nothing here.

**Editing the two vocabularies above is editing what the check
accepts.** They are this project's, like every other line in this
folder, and `check_observance.sh` carries the machine half of the same
statement — change one and change the other, or a type this file offers
is a type the door refuses.

- Trivial work is a commit, never a task (principle 6).

**Two workflows commit, and their subjects obey the declaration like
everyone else's.** `writrun approve` records what a merge decided — the
specs it approved, and the `queued`/`merged` dates it earned — and
`writrun progress` records what a pull request event moved. Both take
their subject from
[`commit_subject.sh`](../scripts/stage-2-pull-requests/commit_subject.sh),
which composes it from `pr_title_style` under the scope `queue`; neither
carries a literal, because nothing squashes these and a subject in the
other style would sit on `main` for good. Each is one commit because each
records one event.

**A branch's own subjects are a convention kept by hand.** Squash-only
means only the pull request title reaches `main`, so `writrun check` reads
that title and nothing else — a subject on a branch is a courtesy to
whoever reads the branch, and a gate that failed a pull request over text
the merge discards would be enforcing where nothing is left behind.

## Who presses commit — `stage_2.auto_commit`

`true`, the default, lets an agent commit on its own as its flow requires.
`false` gates the action and never the work: the agent still composes the
**whole** message — subject, body, trailers — presents it, and commits only
after an explicit yes. Approval is per commit; several in one working
session are several asks, never one session-wide grant.

**The flag outranks the agent platform's own autonomy mode.** An agent
running auto-accept, autonomous, or any mode in which its harness would not
ask, still stops here: the platform's mode governs what the *harness* asks,
this flag governs what the *adopter* allowed. A setting that only bound an
agent already asking would control nothing.

Neither this flag nor `auto_pr` touches the machinery's own commit above,
nor any workflow-driven write — those are not an agent's actions.

## Whether the agent signs — `stage_2.agent_coauthor`

`true`, the default, obliges an agent to append a `Co-Authored-By:`
trailer **naming the model** to every commit it writes:

```
Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
```

`false` means the message carries the change alone — no co-author
trailer, no session URL, no tool mention; it reads as any other in the
history. An instruction from the agent's own platform to append credit
yields to this file, either way, with the same precedence `auto_commit`
states.

**`true` states a shape, not a permission**, and that is what changed
when the key stopped being called `credit_ai`. The old wording left the
agent whatever credit its *platform* appended — a source, not an
artifact, so there was nothing for a check to look for and nothing an
agent on a silent platform owed. Naming the trailer makes the obligation
the agent's: on a platform that appends no credit of its own, the agent
**writes** the trailer rather than having nothing to keep.

**The model is named specifically, not as a category** — `Claude Opus 5`,
never `AI` or `an agent`. A record that survives the next model's arrival
is the whole reason the trailer is worth reading a quarter later, and a
category name answers nothing.

The flag speaks only to what an agent writes. Authorship and committer
identity stay git configuration, nobody else's commits are touched, and
nothing rewrites history — it binds from the commit after the flip.
