# contract front matter is generated; extension front matter is the template's.

**2026-08-23**

The canonical-form decision promised that
an adopter "may extend the schema, not reshape it" — and the generator
kept no such promise: adding a project field (owner, estimate) to
every new task meant hand-editing each generated file or editing
`new.sh`, which `writ update` will overwrite. Now a project template
may open with a front-matter block of its own: `new.sh` appends those
**extension fields** to the contract block it generates, placeholders
and all, with the same placeholders (`{{id}}`, `{{title}}`,
`{{task_ref}}`) substituted — and refuses, before writing anything, a
template that redefines a contract field or writes a line the
canonical check would reject at the merge: a shape that would blind or
fail a check is stopped where it is born, the same pattern as the spec
template's contract headings. The skill instructs the agent to treat
each extension's placeholder text as the project's brief and fill it
like the body. The earlier "front matter is never templated" narrows,
deliberately, to the contract fields — the reason it existed (a
reshaped contract blinds the machinery silently) applies only to them.
Rejected: templating the whole block (that reason, still standing),
and leaving extensions hand-edit-only (a promise the tooling didn't
keep).
