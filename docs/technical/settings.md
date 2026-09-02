# Settings

**The choices an adopting project declares, and how obedience to them is
checked.** The keys, the conduct flags, the declarations, and the shape
contract the file is held to. One chapter of [`README.md`](README.md),
the technical router; read it before committing, pushing, opening a pull
request, or deciding whether a task needs a spec.

## Settings

`.writrun/settings.json` holds the choices
[Adoption](../product/adoption.md#three-stages) leaves open — values only, no
prose — read by both the machinery and the agents. It sits at the root of
WritRun's own home because it is the first file a reader or a tool goes
looking for: the one address ends the hunt. The file is the project's from
adoption onward and `writ update` never touches it — the same exemption
`conventions/` carries, stated for this file by name now that it no longer
lives there. A file left at the old address, `.writrun/conventions/settings.json`,
is still honoured flat by the reader under the contract frozen at the
move, and `check_settings.sh` is what names the move — the bridge
outlives the migration it covered, because an adopter may still be
carrying one.

**The choices are sectioned by stage** — the same rule that put the stage
on folder names ([Adoption](../product/adoption.md#three-stages)): one
top-level `stage`, the single global switch, then one object per stage
holding the keys that stage's readers act on, so a reader knows which
choices their stage may ignore without knowing each key. A section exists
only when it holds a documented key — no empty placeholder objects.

```json
{
  "stage": 3,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false,
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
```

**Keys are alphabetical inside each section.** Mint order is a history the
file cannot show, and a reader checking whether a key is present should
not have to know when it was added. This is the schema's rule and nothing
enforces it: a fault over an adopter's working file would cost more than
the order buys, so the file above is the statement and the eye is the
check.

| Key | Section | Values | Read by |
|---|---|---|---|
| `stage` | top level | `1` / `2` / `3` | the workflows, and agents |
| `decisions_style` | `stage_1` | `per-subsystem` / `chronological` | agents only |
| `product_layout` | `stage_1` | `by-concept` / `by-feature` | agents only |
| `provenance_ledger` | `stage_1` | `true` / `false` | agents only |
| `spec_required` | `stage_1` | `always` / `when-warranted` | agents only |
| `agent_coauthor` | `stage_2` | `true` / `false` | agents only |
| `auto_commit` | `stage_2` | `true` / `false` | agents only |
| `auto_pr` | `stage_2` | `true` / `false` | agents only |
| `auto_push` | `stage_2` | `true` / `false` | agents only |
| `pr_title_style` | `stage_2` | `conventional` / `bracketed` | agents only |

**Every key is present, always** — the same reason the front matter carries
`null` fields rather than omitting them: a reader sees the whole
configuration without knowing the defaults. Each key's documented default
is the behaviour from before the key existed, so a project without the
file, or without the key, behaves exactly as it did: `stage` defaults to
`3`, `pr_title_style` to `conventional`, and the three conduct flags —
`auto_commit`, `auto_pr`, `auto_push` — to `true`, `agent_coauthor` with
them. `provenance_ledger` defaults to `false` by the same rule and lands
on the opposite side of it: no ledger existed before the key, so recording
nothing is the behaviour it preserves.

### `stage`

Ordered and cumulative, so one value rather than three switches. Each stage
stops the machinery the one below it does not need:

- `1` (tasks and specs) — no workflow runs. The four scripts still run as
  ordinary commands, so every guarantee they carry survives; what stops is
  the *enforcement*, which a person then performs deliberately.
- `2` (pull requests) — `writrun check` and `writrun approve` run.
- `3` (GitHub issues) — adds `writrun issues` and `writrun progress`.

**The four human gates are core at every stage.** A gate asks for *a human
decision, recorded*, never for a pull request specifically
([gates](../product/stage-1-tasks-and-specs/gates.md)). At Stage 1 a person performs each
directly and names how in their `AGENTS.md`, which Adoption already requires.
No check can verify that, which is why it is stated here: `stage: 1` is
not permission to drop them.

### `pr_title_style`

Governs every pull request title, including authoring ones, which carry no
task tag — and nothing else:

```
conventional   [TASK-0007] feat(ci): record approval on the merge
               docs(product): the merge is the assenting act

bracketed      [TASK-0007][Feat][CI] Record approval on the merge
               [DOCS] The merge is the assenting act
```

Composed by agents, and from Stage 2 checked at the door —
[observance](#observance-is-checked-where-it-leaves-a-trace): `writrun
check` fails a title that ignores the declared style. Nothing parses
the summary beyond that — not the release notes, which the forge
generates from pull requests.

**The commit subject is not this key's, and is not settable.** It is
Conventional Commits everywhere, whatever the title style: the squash
dialog's subject is the merging maintainer's to type, and the
machinery's own recording commits take theirs from `commit_subject.sh`
under the scope `queue`, now one literal per event rather than one per
event per style. A project choosing `bracketed` chooses it for the queue
its people read, never for `main`
([0063](decisions/pull-requests/0063-title-and-subject-are-two-texts.md)).

**The `[TASK-NNNN]` tag is in both and is not settable.** It is how
the machinery and `list_tasks.sh` learn which tasks a pull request
carries, and a branch name holds one id: a title without it reduces a
multi-task pull request to reporting one task, silently.

### The conduct flags

The adopter's word on the agent's own git actions, one flag per act:
`auto_commit` holds the commit, `auto_push` holds the push, `auto_pr`
holds the pull request. `true` — the default, and the behaviour from
before the keys existed — lets the agent take that action on its own as
its flow requires. `false` gates the action, never the work: the agent
still composes the whole thing — the full commit message, or the branch
and the pull request's complete title and body — presents it, and acts
only on an explicit yes. Approval is per action, never a session-wide
grant.

**`auto_push` exists because the push is the act that makes work
public.** A commit is private and a pull request is already a
conversation; between them sits the moment an adopter's work lands on
someone else's server, and until this key that moment was covered by
inference alone — read as `auto_pr`'s when a pull request was open, as
nobody's on a branch's first push. The inference covered the wrong half.
Taking a task pushes the branch and *then* opens the draft, so an
adopter who set `auto_pr: false` had their branch on the forge before
the gate they asked for was reached: what waited for the word was only
the pull request, half a step behind the act the gate exists to hold.

**Before a pull request exists, the push and the pull request are one
act, gated once.** The agent presents the branch, the title and the body
together, and `false` on either flag holds all of it — two prompts for
one moment is not a stricter gate, it is a worse one. Once the pull
request is open, a further push to its head branch is `auto_push`'s
alone: `auto_pr` has been answered, and what is being gated again is
work becoming visible.

**The flags outrank the agent platform's own autonomy mode.** An agent
running auto-accept, autonomous, or any mode in which its harness would
not ask, still stops: the platform's mode governs what the *harness*
asks, these flags govern what the *adopter* allowed — a setting that only
bound an agent already asking would control nothing, and a setting
controls (below). All three sit in `stage_2` because that is where the
actions they govern begin: git starts at Stage 2
([Adoption](../product/adoption.md#three-stages)), so below it there is
neither a commit, a push nor a pull request for a conduct flag to gate —
Stage 1 needs nothing but files. No flag touches the commits the
machinery makes nor any workflow-driven write — those are not the
agent's actions.

### `agent_coauthor`

The adopter's word on whether an agent appears as a co-author of what it
writes. `true` — the default — obliges the agent to append a
`Co-Authored-By:` trailer **naming the model** to every commit it makes,
and a credit line to every pull request body it writes. `false` means both
carry the change alone: no co-author trailer, no session URL, no tool
mention; the message reads as any other in the history.

**`true` states a shape, not a permission.** The key formerly said the
agent kept "whatever credit its platform appends", which named no artifact
and so could not be checked at all in that direction — a promise with no
shape is a promise nothing holds. Naming the trailer makes both directions
checkable ([observance](#observance-is-checked-where-it-leaves-a-trace)),
and it is what lets the commit history answer, on its own, which model
worked a change. The obligation follows from that: on a platform that
appends no credit of its own, the agent **writes** the trailer rather than
having nothing to keep.

The model is named specifically, not as a category — `Co-Authored-By:
Claude Opus 5`, never "an AI" — because the record has to survive the next
model's arrival to be worth reading a quarter later.

An instruction from the agent's own platform, in either direction, yields
to this file, with the same precedence the conduct flags above state. The
flag speaks only to what the agent writes: authorship identity stays git
configuration, other authors' commits are untouched, and nothing rewrites
history — it binds from the write after the flip. It is deliberately not
an `auto_` flag: those gate whether the agent may act, this states what
the act leaves written. It is also not commit signing, which is git
configuration and unrelated.

This is one half of what [Provenance](../product/concepts/provenance.md)
records. `provenance_ledger` is the other, and the two are independent:
turning either off never silently turns off the other.

### The declarations

Unlike the conduct flags, these gate no action — each answers, once, a
question every agent session otherwise re-asks. `spec_required` is the
project's word on when a task needs a spec: `always`, or
`when-warranted` (the default — the creation skill's own judgement
guidance applies). `decisions_style` names where dated decisions live:
`per-subsystem` (the methodology's default, and this repository's own
shape — an entry sits in the folder of the adoption level it concerns,
and the index carries the chronology the folders do not) or
`chronological` (one log across the whole project). `product_layout`
names how the product half is organized: `by-concept` (chapters about
ideas — this repository's shape) or `by-feature` (one doc per feature
— TOM's shape). `provenance_ledger` is the project's word on whether its
tasks carry a [provenance ledger](../product/concepts/provenance.md):
`false` (the default) means they carry none and every check is satisfied
by their carrying none — a project that works without agents, or that
wants no accounting, states so here and is asked for nothing. Each is a
declared variant from
[Adoption's open list](../product/adoption.md#mandatory-core-vs-documented-variant),
stated here so it is never reverse-engineered from the file tree.

### Observance is checked where it leaves a trace

A conduct flag binds the agent, but only some disobedience is visible
afterwards — and what is visible is checked, not trusted. From Stage
2, `writrun check` fails a pull request whose title ignores the
declared `pr_title_style`, and one that disagrees with `agent_coauthor`
**in either direction** — commits or a body carrying credit while the flag
is `false`, or an agent's commit lacking the model-naming
`Co-Authored-By:` trailer while it is `true`. The second direction is only
checkable because the flag now names an artifact rather than deferring to
whatever a platform appends, and it reads commits alone: a trailer has a
fixed shape and a place, a body's credit line has neither, so the body's
obligation at `true` stays instruction-bound. What leaves no trace at all
(`auto_commit`, `auto_pr` — whether the agent *asked*) is not checked: no
diff can show a question that wasn't asked, and no check infers one.

`check_observance.sh` is where both live. The title check strips the
`[TASK-NNNN]` tags — not the settable part — and reads what is left
against the declared style: the type against the vocabulary
`conventions/commits.md` carries, the scope against it too when one is
present, and nothing about the summary. Case inside a bracketed label
is not judged, because the convention writes both `[Fix]` and `[DOCS]`.
The credit check reads the pull request's own commits and body — never
`main`'s past, since nothing rewrites history — and skips the
machinery's recording commits **by committer identity**, not by subject.
The subject is now the machinery's own, and constant whatever the title
style says — but reading it would still be the wrong
test: a subject is text, and what makes those commits exempt is who
wrote them, which only the identity says.

**The `true` direction's unit is the pull request, and it has to be.**
Judging per commit would need a signal that does not exist: an agent
commits under whoever ran it, with the same name and the same email as
any other work of theirs, and the check is handed a title, a body and a
range. So the declaration is read where one exists — at `true` the flag
obliges a credit line in the body, and that line is the pull request
saying an agent worked it. When it is there, every commit that is not the
machinery's owes the trailer; when nothing declares agent work, no commit
is judged and the run says so.

That keeps the rule that matters: a human's pull request is asked for
nothing, because using an agent is not obligatory and a check demanding
the trailer everywhere would read absence as disobedience. It costs the
converse — a person's commit on a declared-agent branch is asked for the
trailer too, which is the trade
[0057](decisions/pull-requests/0057-the-credit-flag-names-its-artifact.md)
records. What the direction catches is partial compliance; what it cannot
catch is an agent that credits itself nowhere, and no check infers that
either.

**A category is not a model.** `Co-Authored-By: AI` satisfies any trailer
regex and answers nothing a quarter later, which is the whole reason the
trailer is worth reading — so a small vocabulary of category words, bare
family names among them, is refused. It is a tripwire and not a proof: a
name written to evade it evades it, exactly as the core-rule stems in
`check_settings.sh` do.

The ledger itself is not checked here. It is a queue field an agent
writes, not a trace left in the forge, and `provenance_ledger` gates
whether it exists at all — a project declaring `false` has nothing for a
check to read, which is a legal state and not a fault.

### The shape is a checked contract

JSON permits arbitrary nesting, arrays and free-form whitespace; a
line-based reader sees none of it and would misread in silence. So the
file is restricted to what such a reader can see — a two-level object and
nothing deeper. At the top level: scalar pairs (`"stage": 3`) and stage
sections, each opened by a two-space-indented `"stage_N": {` line of its
own and closed by a two-space `}` line of its own. Inside a section:
scalar pairs at four spaces. Every pair is one `"key": value` line,
values `true`, `false`, an unquoted integer, or a double-quoted string —
and `check_settings.sh` enforces all of it, including that every
documented key sits in its documented home. The subset is ordinary JSON
that any editor or `jq` reads.

`read_setting.sh` addresses a sectioned key through its section —
`read_setting.sh stage_2.pr_title_style` — and a top-level key bare:
`read_setting.sh stage`. The address, not the name, is a key's identity.

What the restriction buys is that no script needs `jq`, which would be this
project's first runtime dependency (see the non-goal in
[`about.md`](../about.md#non-goals--equally-important)): one nesting level,
entered and left on lines of fixed shape, is still sed/awk territory.
Strictness is scoped
to where the risk is: keys a workflow parses are shape-checked; keys only an
agent reads are checked for value alone, since an agent reads JSON the way it
reads prose.

Two things the file may never do: carry a key that switches off anything in
Adoption's **core** list, and carry reasoning — that stays in
`.writrun/conventions/*.md`, and nothing is stated in both.

**A setting controls; it never merely describes.** `stage: 1` means the
workflows stop, not that a reader is told they were deleted. The alternative
is the failure [`0041`](decisions/0041-the-issues-mirror-is.md) named when it
rejected a flag: two ways to say one thing, free to disagree.

