---
id: task-0023
status: backlog
blocked_reason: null
taken_by: null
spec_ref: []
doc_ref: technical/README.md#auto_commit-and-auto_pr
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T13:02:49Z
queued: null
completed: null
merged: null
---

# The settings gain a push flag, an order, and obedient commits

**References:** [technical/README.md#auto_commit-and-auto_pr](../../docs/technical/README.md#auto_commit-and-auto_pr)

An adopter can say who presses commit and who opens the pull request,
and cannot say who pushes. `auto_commit` names the commit, `auto_pr`
names the pull request, and the act between them belongs to neither —
the word `push` appears nowhere in the conventions. What covers it
today is inference: a push to the head branch is the only way an open
pull request updates, so it reads as `auto_pr`'s; a branch's first push
reads as nobody's.

The gap has a visible edge. Taking a task pushes the branch and then
opens the draft, and the flag holds the draft — so under `auto_pr:
false` the branch is already on the forge when the gate is reached, and
what waits for the word is only the pull request. The gate sits half a
step behind the act it exists to hold, which is the work becoming
visible to anyone but its author.

And while both settings files are open: their keys sit in the order
they were minted, which is a history the file itself cannot show —
`spec_required` ahead of `decisions_style`, `credit_ai` wedged between
the two `auto_` flags. Alphabetical inside each section is an order a
reader checks at a glance and a writer never has to ask about, and it
turns adding a key from a placement decision into no decision at all.

The machinery's own commits disobey a declaration too. With
`pr_title_style: bracketed` stated, `main` carries `chore(queue):
record what the merge decided` and `chore(queue): record what the forge
just did` — the other style, and permanent, since no squash ever
rewrites them. `commits.md` already orders them kept in step ("edit it
to match whatever this file says"), and the same sentence miscounts the
writers: it names one workflow where two commit, so an adopter who
obeys it fixes half and is told there is no other half.

The branch's own subjects, meanwhile, sit outside every check — the
title is read, nothing else, because squash-only means the title is
what lands. The convention still opens by saying a commit subject takes
the declared shape, so the rule claims ground nothing holds, and a
subject in the wrong style rode a branch recently with no gate seeing
it. Say which it is: a convention the branch keeps by hand because it
never lands, or something a check reads.

And the kit ships this repository's own file, because `.writrun` is a
byte mirror. A project that copies `template/` starts at `stage: 3`
with every workflow armed and the Issues mirror opening issues on its
first pull request — while the kit's own guide tells the adopter to
declare a stage, and adoption starts at Stage 1. It should ship the
cautious file instead: Stage 1, and `auto_commit`, `auto_push` and
`auto_pr` all `false`, so a new adopter grants autonomy deliberately
instead of discovering it. That means the settings file leaves the
mirror and the sync learns its first exception — the open question
spec-0033's Outcome already parked.

The same mirror hides the file inside its own home. `.writrun/README.md`
says who owns `skills/`, `scripts/`, `templates/`, `VERSION` and
`conventions/`, never `settings.json`, under a rule that says never to
hand-edit a WritRun-owned folder: the one file the adopter is meant to
edit is the one the table forgot. The kit's `AGENTS.md` never mentions
the settings at all, and its `docs/technical/README.md` still tells the
adopter to state the decisions shape in the doc — the value that now
lives in `settings.json`, which `conventions/README.md` says must never
be stated in both.

Give the push a conduct flag of its own, let `auto_pr` keep the pull
request's own fields and stop reaching for the branch, and make the
taking flow present the push and the draft as the one act they are —
so an adopter who gates the forge is asked once, before anything of
theirs is public. Put the keys in alphabetical order in both files.
And let every subject the machinery writes follow the declared style,
from a place that names all of them, so flipping the declaration is one
edit and not a hunt. Ship the kit a settings file of its own, cautious
by default, and say in `.writrun`'s own README that the file is the
adopter's.
