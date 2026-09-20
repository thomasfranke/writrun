---
id: spec-0103
task_ref: task-0075
status: implemented
created: 2026-09-19T23:29:00Z
---

# spec-0103 — The routing instruction names the owner, and points at the form it ships

**References:** [task-0075](../tasks/task-0075-routing-names-owner.md)

- **Goal:** an adopter's agent routing a defect knows which repository
  owns it — the methodology or the binary — and composes the submission
  from the form the kit already put in its tree.

## Scope

Kit prose, and the one product sentence it implements. No script
changes, no machinery: the route, the authorization ask and both
outcomes are [spec-0061](spec-0061-upstream-guidance.md)'s and stay as
they are. What changes is the destination the prose names. The agent
flow is authored at `.writrun/AGENTS.md`, the mirror's source, and
reaches `kit/.writrun/` by `make kit-sync`.

The contradiction this closes is one the routing section itself lists as
a methodology defect: `kit/WRITRUN.md` already ships the owner rule —
*"routed to the repository that owns the defect"* — and the agent flow
ships a single hardcoded address instead.

## Steps

1. `.writrun/AGENTS.md`, *When the defect is WritRun's* — the section
   states the destination as the repository that **owns** the defect,
   and names both homes with what each owns: the methodology, its kit,
   scripts and rules at <https://github.com/thomasfranke/writrun>; the
   `writ` binary and anything `writrun-cli` installs at
   <https://github.com/thomasfranke/writrun-cli>. The heading widens
   with it — the defect is upstream's, not necessarily WritRun's.
2. The same section's shape clause names the form first —
   `.github/ISSUE_TEMPLATE/writrun-report.yml`, which the kit shipped
   into this repository and which asks for exactly these fields — and
   keeps the three fields after it as the fallback for a repository that
   no longer ships the form. The `gh issue create --label
   writrun:submitted` line and the `routed` / `open` outcomes are
   untouched.
3. `kit/work/reports/README.md` — its "For agents" paragraph opens *"A
   defect in WritRun itself — the kit, its scripts, its rules"*; it
   widens to the owner the same way, one line, still linking the concept
   rather than restating it.
4. `kit/WRITRUN.md` — the finding bullet already carries the owner rule;
   its second clause names only WritRun. It names the binary's home
   beside it, one clause.
5. `make kit-sync` carries `.writrun/AGENTS.md` into `kit/.writrun/`,
   and the mirror test stays green.

## Acceptance criteria (EARS)

- When an agent reads the kit's routing section, it shall find the
  destination stated as the repository that owns the defect, and not as
  the repository the kit came from.
- When the section names where a defect goes, it shall name both homes
  and what each owns.
- When the section states the submission's shape, it shall name the
  report form the kit ships into the adopter's repository before
  restating any field.
- When two shipped documents state the routing destination, they shall
  state the same one.
- When `make kit-sync` runs, `kit/.writrun/AGENTS.md` shall be
  byte-identical to the root's.

## Edge cases

- **The owner is genuinely unclear** — the binary reporting a kit rule
  wrongly. The section's existing doubt rule decides it on the evidence:
  reproduced against a clean kit copy it is the methodology's; reached
  only through the binary it is the binary's.
- **An adopter with no `writrun-cli`** — the kit copied by hand. The
  binary's home is named but never asked for; no step of the route
  depends on the CLI existing.
- **A third consumer later** — the section states the owner rule first
  and the two addresses as its instances, so a third home is a line
  rather than a rewrite.
- **The adopter deleted the report form** — it is theirs to delete. The
  fields stay beside the pointer for exactly that, so a missing file
  costs the composing agent nothing.

## Tests required

- The kit mirror unit test over `tests/kit_mirrors.txt` and
  `check_doc_shapes.sh` stay green over the edited prose. No script
  changes, so no new unit test — the prose is covered by review, as
  `kit.md` records.

## Definition of Done

- [ ] No shipped file names the kit's origin as the destination for
      every defect.
- [ ] The routing section names both homes and what each owns.
- [ ] The submission's shape names the shipped form, with the fields as
      its fallback.
- [ ] `make kit-sync` leaves no diff and `check_doc_shapes.sh` exits 0.

## Proposed product changes

- `product/concepts/report.md#routing-upstream` — the sentence that
  *instructs* says "the upstream repository"; it says the repository
  that owns the defect, which the section's own cost sentence already
  says, and names what an adopter consumes as more than the methodology.

## Proposed technical changes

- none — kit prose and one product sentence.
  `technical/distribution/kit.md` describes what ships and what mirrors,
  and neither changes.

## Outcome

Built as the five steps and the product bullet planned, with three
divergences worth the record.

**The two homes landed as a table, and the heading moved with them.**
Step 1 said "names both homes with what each owns"; prose carrying two
addresses and two ownership tests in one paragraph read as a list
pretending not to be one, so it is a two-row table: the methodology —
the kit, its scripts, its rules, its shipped prose — at `writrun`, and
the `writ` binary — anything `writrun-cli` installs or prints — at
`writrun-cli`. The heading is now *When the defect is upstream's*.
"WritRun's" named one of the two owners, so it could not head a section
about both. No document links that anchor, so nothing broke.

**The doubt sentence at the section's end was widened too, and the
steps did not say so.** It asked whether the defect is "WritRun's or
this project's use of it" — the narrower question, left standing it
would have contradicted the heading above it. It now asks whether the
defect is upstream's. The owner-between-the-two doubt is answered
separately, beside the table, as the spec's first edge case required:
reached only through the binary it is the binary's; reproduced against
a clean kit copy with no `writ` in the path it is the methodology's.

**The product change is two edits, not one sentence.** The bullet
promised the instructing sentence; the paragraph above it also named
what an adopter consumes as "the methodology itself", which would have
left the rule saying one thing in its second paragraph and another in
its first. Both now say the owner, and a closing clause assigns the
naming of the homes to the kit — the rule is the owner, never a fixed
address — so a third consumer is a kit edit and not a rule change.

Step 2 landed as planned: the routing section names
`.github/ISSUE_TEMPLATE/writrun-report.yml` first, as the form the kit
shipped into the adopter's own repository, and keeps the three fields
after it for a project that no longer ships the file. Steps 3 and 4
landed as planned in `kit/work/reports/README.md` and `kit/WRITRUN.md`.
`make kit-sync` carried `.writrun/AGENTS.md` into `kit/.writrun/`.

The report's third finding — the evidence discipline a routed
submission owes — is not here, as the task said it would not be.
`check_doc_shapes.sh` exits 0 over the edited prose and the suite is
green.
