# Front matter

**The canonical form every queue file is held to**, and where the shape is enforced. One chapter of [`schemas/`](README.md).

## Front matter is canonical

The front matter above is a fixed shape, not general YAML. Every reader
in the machinery is line-based on purpose — plain `bash`/`awk`/`sed`, no
YAML parser, no runtime dependency — and YAML permits the same meaning
in forms a line-based reader cannot see: a block list under `spec_ref:`
reads as an empty list, a quoted value never matches a path comparison,
a folded scalar reads as nothing. Silently, in every case.

So the canonical form is a checked contract, not an assumption: one
field per line as `key: value`, values bare (no quotes, no `>`/`|`
block scalars), every schema field present exactly once even when
`null`, lists inline (`[]` or `[spec-0001, spec-0002]`), `id` agreeing
with the filename — exactly for a spec, as the `task-NNNN` prefix of
`task-NNNN-<subject>.md` for a task — statuses and priority drawn only from their
documented vocabularies, `blocked`/`blocked_reason` paired both ways,
every date an RFC 3339 UTC timestamp
(`2026-08-21T09:14:00Z`), and `doc_ref` written relative to `docs/`.
Unknown keys in canonical shape are allowed — an adopter may extend the
schema, not reshape it. Extensions enter through the project template's
own front-matter block: `new.sh` appends those fields to the generated
contract block, refuses a template that redefines a contract field or
writes a non-canonical line, and the agent fills their values the same
way it fills the body — the template's placeholder text is the
project's instruction for what belongs in each
(`writrun-create-task-and-spec`'s SKILL.md says so explicitly).

**Body shapes resolve in layers, and the project's wins.** The generated
body comes from the project's own `.writrun/conventions/templates/task.md`
(or `spec.md`) where it defined one; otherwise from the shipped default in
`.writrun/templates/`; otherwise from the generator's built-in skeleton.
A file written by hand honours the same order. The *contract* front matter
is never templated — the generator writes it, and refuses a template that
redefines a contract field — and a spec template must keep the two
Proposed-changes headings and Outcome or it is refused too.

`.writrun/skills/writrun-check-front-matter/check_front_matter.sh` enforces all of it —
`writrun check` runs it before the lifecycle rules, so a file the
line-based readers would misread never merges — and `new.sh` only ever
generates this form, so the contract costs nothing on the happy path.

**The shape is held wherever it is shown, not only where it is stored.**
A schema enforced at the machinery's door leaves every example a chapter
prints unheld, and an example is documentation that lies with a straight
face: a reader copies it and the first check refuses what it taught. This
repository's own concept chapters printed a task with no `origin` and a
bare `created` date, and the adoption kit shipped that for weeks with
nothing noticing. `check_doc_shapes.sh` reads every fenced `yaml` block
under `docs/`, `template/`, `.writrun/` and the root's three documents,
and hands the whole ones to the same checker. **The language tag is the
declaration of intent**: a block that is deliberately not canonical — a
shape that is history, or one shown to say what the checker refuses — is
fenced as ```text, which is the only escape and is always visible in a
diff.

Its second half holds the *words*.
`.writrun/scripts/stage-2-pull-requests/retired_vocabulary.txt` carries
one line per word this project stopped having, and the backticked form is
refused wherever the documents instruct — `docs/technical/decisions/` is
exempt, because a record has to be able to name what it retired, and
ordinary English is untouched because it carries no backticks. A
vocabulary the check cannot find is *said*, never assumed empty: a half
that answers "clean" for having read nothing is the same blindness a
block silently skipped is. Retiring a
word without adding its line is how the next one ships; the file is the
single source, and it is the price of the guard. **This paragraph cannot
spell its own example**, and that is the rule working: the token form is
what the check refuses outside a record, so a section that defines the
rule names the word as a word or not at all.

