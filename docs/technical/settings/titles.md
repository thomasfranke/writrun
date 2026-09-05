# Titles

**The declared pull-request title style**, and the two parts of a title that are not settable. One chapter of [`settings/`](README.md).

## `pr_title_style`

Governs every pull request title, including authoring ones, which carry no
task tag — and nothing else:

```
conventional   [TASK-0007] feat(ci): record approval on the merge
               docs(product): the merge is the assenting act

bracketed      [TASK-0007][Feat][CI] Record approval on the merge
               [DOCS] The merge is the assenting act
```

Composed by agents, and from Stage 2 checked at the door —
[observance](observance.md#observance-is-checked-where-it-leaves-a-trace): `writrun
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
([0063](../decisions/pull-requests/0063-title-and-subject-are-two-texts.md)).

**The `[TASK-NNNN]` tag is in both and is not settable.** It is how
the machinery and `list_tasks.sh` learn which tasks a pull request
carries, and a branch name holds one id: a title without it reduces a
multi-task pull request to reporting one task, silently.

What the pair may claim is bounded: at most eight distinct tasks per
pull request, counted after dedup, and above that the machinery refuses
the whole set. The ceiling is a constant beside the parser, not a
setting — the only honest default for a key would be the unbounded
behaviour from before it existed, which is the defect the bound removes
([0068](../decisions/pull-requests/0068-what-a-pull-request-claims-is-bounded.md)).

