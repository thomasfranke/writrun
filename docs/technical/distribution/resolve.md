# Resolving an answer

**`resolve_doc.sh` — which home answers an address, and how a file defers.** One chapter of [`distribution/`](README.md).

## `resolve_doc.sh` — one address, two homes

Every text WritRun answers on a project's behalf — `gates.md`, each file
under `conventions/` — is addressed in the project's home and read from
whichever home actually answers
([Two homes](../../product/adoption.md#two-homes)):

```bash
bash .writrun/scripts/stage-1-tasks-and-specs/resolve_doc.sh writrun/conventions/commits.md --origin
```

It prints the file in force, and with `--origin` a tab and `declared` or
`default` — the same output shape and the same two words
[`read_setting.sh`](../settings/schema.md#the-shape-is-a-checked-contract)
uses for a value, because the question is the same one: did the project
decide this, or did nobody. Callers name the project's address and never
branch on the answer; a caller that reads `.writrun/defaults/` directly
reads past every project that overrode the file.

**The address maps to the default by name, never by a table.**
`writrun/<rel>` resolves to `.writrun/defaults/<rel>`, so a new default
is a new file and nothing else — no registry to update, and no stub that
has to name where it points. That is what lets a stub be permanent in a
home no update touches: it carries the marker and prose, and the
address is computed from the filename it already has.

**Deferring is positional, and absence defers too.** A first line of
exactly `/// writrun:default` defers; anything else is the project's
answer, whole. The rule is the draft chapter's, for the same reason that
one is positional: a file that *documents* the marker names it in its
prose, and a reader searching the whole file would read the
documentation as a stub
([authoring](../../product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet)).
A missing file resolves to the default as well — a project that deleted
a stub, or adopted before stubs existed, is answered rather than left
with nothing, the same posture the settings reader takes for a missing
key.

**An address nothing answers is loud, and that is the one failure.**
Exit 4 when neither the project's file nor a default exists, or when a
file defers to a default the kit does not ship. Printing nothing would
let a caller pass by having read no rule at all — the silence
[`kit.md`](kit.md#the-kit) names for a data file left outside the
mirror. Exit 3 rejects a usage error, including an address in the kit's
own home: a caller handing over `.writrun/defaults/gates.md` has
confused the two homes, and guessing which it meant would hide that from
it.

**Nothing under `.writrun/defaults/` is edited by hand.** It is the
kit's home, replaced entire by an update
([kit](kit.md#the-adopters-home-leaves-the-mirror-whole-kitwritrun-is-a-seed-not-a-copy)) —
which is exactly what makes a correction to a default reach every
project that defers, and what a text seeded once into the untouchable
home could never do.
