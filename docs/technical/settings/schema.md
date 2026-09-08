# The settings file

**What `writrun/settings.json` is, the keys it holds, and the shape contract it is checked against.** One chapter of [`settings/`](README.md).

## Settings

**The file's rendered view is
[`session_card.sh`](../distribution/session-card.md#session_cardsh--the-settings-rendered)** —
every value below, with the documented defaults marked as defaults, on
one card. Read the card for the values; read this chapter for why each
key exists. `read_setting.sh` is the one reader
([contract](schema.md#the-shape-is-a-checked-contract)); its `--origin` flag
prints `declared` or `default` beside the value, which is what lets a
renderer tell a project's choice from a default nobody made.

`writrun/settings.json` holds the choices
[Adoption](../../product/adoption.md#three-stages) leaves open — values only, no
prose — read by both the machinery and the agents. It sits at the root
of the project's own home ([Two homes](../../product/adoption.md#two-homes))
because it is the first file a reader or a tool goes looking for: the
one address ends the hunt, and everything under `writrun/` is the
project's, which `writ update` never touches. Two old addresses stay
honoured by the reader: a file still at `.writrun/settings.json` — the
kit's home, where it lived before the split — is read as-is, and a file
at `.writrun/conventions/settings.json` is read flat, under the
contract frozen at that earlier move. `check_settings.sh` is what names
each move — a bridge outlives the migration it covered, because an
adopter may still be carrying one.

**The choices are sectioned by stage** — the same rule that put the stage
on folder names ([Adoption](../../product/adoption.md#three-stages)): one
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
    "commit_scopes": "about product technical tasks specs skills ci tests agents readme setup queue conventions",
    "commit_types": "docs feat fix refactor chore",
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
| `commit_scopes` | `stage_2` | lower-case words, hyphens allowed, space-separated | the workflows, and agents |
| `commit_types` | `stage_2` | lower-case words, space-separated | the workflows, and agents |
| `pr_title_style` | `stage_2` | `conventional` / `bracketed` | agents only |

**The commit vocabulary is a value, so it lives here.** `commit_types`
and `commit_scopes` are the two lists a title and a subject are checked
against — the project's own words, written where the machinery and the
reader find one statement
([Two homes](../../product/adoption.md#two-homes)). The convention
prose explains what a type or a scope *is* and how the project uses
them; it never spells the lists a second time, which is this file's
"values, never reasoning" rule read in the other direction. A scope
list is the one key whose value grows with the project — adding a word
is editing one line here, and every check sees it at once.

**Every key is present, always** — the same reason the front matter carries
`null` fields rather than omitting them: a reader sees the whole
configuration without knowing the defaults. Each key's documented default
is the behaviour from before the key existed, so a project without the
file, or without the key, behaves exactly as it did: `stage` defaults to
`3`, `pr_title_style` to `conventional`, the three conduct flags —
`auto_commit`, `auto_pr`, `auto_push` — to `true`, `agent_coauthor` with
them, and `commit_types` and `commit_scopes` to the lists the
observance check carried embedded before the keys existed — the ones
the example above spells. `provenance_ledger` defaults to `false` by the same rule and lands
on the opposite side of it: no ledger existed before the key, so recording
nothing is the behaviour it preserves.

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
[`about.md`](../../about.md#non-goals--equally-important)): one nesting level,
entered and left on lines of fixed shape, is still sed/awk territory.
Strictness is scoped
to where the risk is: keys a workflow parses are shape-checked; keys only an
agent reads are checked for value alone, since an agent reads JSON the way it
reads prose.

Two things the file may never do: carry a key that switches off anything in
Adoption's **core** list, and carry reasoning — that stays in
`writrun/conventions/*.md`, and nothing is stated in both.

**A setting controls; it never merely describes.** `stage: 1` means the
workflows stop, not that a reader is told they were deleted. The alternative
is the failure [`0041`](../decisions/github-issues/0041-the-issues-mirror-is.md) named when it
rejected a flag: two ways to say one thing, free to disagree.

