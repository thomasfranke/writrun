---
id: spec-0040
task_ref: task-0023
status: draft
created: 2026-08-31T18:49:37Z
---

# spec-0040 — A push flag of its own, keys in order, and a kit that ships cautious

**References:** [task-0023](../tasks/task-0023-push-gate.md)

- **Goal:** the adopter can gate the act that makes work public, the
  settings files carry an order a reader checks at a glance, every
  subject the machinery writes obeys the declared style from one place,
  and a project that copies the kit starts closed rather than fully
  armed.

## Scope

Five threads, one subject: the settings file and the things that were
supposed to obey it.

**The push has no flag.** `auto_commit` names the commit and `auto_pr`
names the pull request; the act between them — the one that makes a
branch visible to anyone but its author — is covered by inference alone,
and the word `push` appears nowhere in `conventions/`. The gap has a
visible edge in the taking flow, which pushes the branch and *then*
opens the draft: under `auto_pr: false` the branch is already on the
forge when the gate is reached, so what waits for the word is only the
pull request, half a step behind the act the gate exists to hold.

**The keys sit in mint order**, which is a history the file cannot show.

**The machinery disobeys the declaration it is told to keep.** With
`pr_title_style: bracketed` stated, `main` carries `chore(queue): record
what the merge decided` and `chore(queue): record what the forge just
did` — the other style, permanently, since no squash rewrites them. The
scope `queue` is not in the vocabulary either. And `commits.md` names
one workflow where two commit, so an adopter who obeys it fixes half and
is told there is no other half.

**The kit ships this repository's settings**, because `.writrun` is a
byte mirror: a project that copies `template/` starts at `stage: 3` with
every workflow armed and the Issues mirror opening issues on its first
pull request — while the kit's own guide tells the adopter to declare a
stage, and adoption starts at Stage 1. This is the open question
[spec-0033](spec-0033-declaration-keys.md)'s Outcome parked: honouring it
means teaching the sync its first exception.

**And the mirror hides the file inside its own home.**
`.writrun/README.md` names every folder's owner except `settings.json` —
the one file the adopter is meant to edit is the one the table forgot,
under a rule that says never to hand-edit a WritRun-owned folder. The
kit's `AGENTS.md` never mentions the settings, and its
`docs/technical/README.md` still tells the adopter to state the decisions
shape in the doc — the value that now lives in `settings.json`, which
`conventions/README.md` says must never be stated in both.

In: `auto_push`; the taking flow's one act; alphabetical keys in both
settings files; one place for the machinery's subjects; the kit's own
cautious settings file and the sync exception that lets it exist; the
ownership row, the kit's `AGENTS.md`, the kit's stale decisions
instruction; their tests.

Out: **a check on branch commit subjects.** The task asks which it is,
and it is a convention kept by hand: squash-only means only the title
lands, so a subject that never reaches `main` is not something a gate
should fail a pull request over, and the machinery's own recording
commits would need an exemption from a check whose whole subject is
commits nobody reads afterwards. `commits.md` says so plainly instead of
claiming ground nothing holds. Out: **a check on key order.** The order
is a reader's convenience and a writer's relief from a decision; a fault
that failed an adopter's working file over it would cost more than it
buys, so the schema states it and nothing enforces it. Out: the
`credit_ai` → `agent_coauthor` rename and the ledger, which are
task-0025's and task-0026's; this change writes whichever name the file
carries when it lands, and alphabetical order resolves the wedge either
way. Out: the kit `AGENTS.md`'s stale `pending` vocabulary — a real
defect, unrelated to the settings, and a report of its own.

## Steps

1. **`auto_push`**, a third conduct flag in `stage_2`, default `true` —
   the behaviour from before the key existed, like the other two.
   `read_setting.sh`'s `default_for`, `check_settings.sh`'s `HOMES`, its
   boolean vocabulary arm and its printed summary. Documented with the
   other two.
2. **`technical/README.md`: `### auto_commit and auto_pr` becomes `###
   The conduct flags`**, covering three. `auto_push` gates the push;
   `auto_pr` stops reaching for the branch and keeps the pull request's
   own fields. `#settings`' table gains the row, and the every-key-present
   paragraph gains the new default. task-0023's `doc_ref` and its
   References line move to the new anchor in the same change — both, or
   the two disagree.
3. **The taking flow asks once.** `conventions/prs.md`,
   `product/stage-2-pull-requests/taking.md` and both `AGENTS.md` files
   present the push and the draft as the one act they are: the agent
   composes the branch, the title and the body, presents them together,
   and pushes only on the word — so an adopter who gates the forge is
   asked before anything of theirs is public, not after.
4. **Alphabetical inside each section**, in `.writrun/settings.json` and
   in the kit's, stated as the schema's rule in `#settings`.
5. **One place for the machinery's subjects.**
   `.writrun/scripts/stage-2-pull-requests/commit_subject.sh
   <merge|forge>` prints the subject in the declared style, reading
   `pr_title_style` through `read_setting.sh`; `writrun-approve.yml` and
   `writrun-progress.yml` both call it instead of carrying a literal.
   `queue` joins the scope vocabulary in `commits.md` and the machine
   half in `check_observance.sh`, because that is what these commits are
   about and the two lists are kept in step by that file's own rule.
6. **`commits.md` counts its writers and stops claiming the branch.**
   Two workflows commit, not one; and only the pull request title is
   checked — a branch subject is a courtesy the squash discards.
7. **The kit's own settings file.** `tests/template_exceptions.txt`
   lists `.writrun/settings.json`; `sync_template.sh` preserves every
   listed path across the copy rather than overwriting it, and names
   what it kept; the byte-mirror unit test excludes the same list, from
   the same file, so the exception has one source. The kit's file ships
   `stage: 1`, `auto_commit`, `auto_pr` and `auto_push` all `false`, and
   every other key at its documented default — `pr_title_style:
   conventional`, which is the condition spec-0033 recorded and could
   not honour.
8. **`.writrun/README.md` gains the `settings.json` row** — the
   project's, from adoption; `writ update` never touches it — and the
   "never hand-edit" rule gains its one exception by name.
9. **The kit's `AGENTS.md` names the settings file** as the adopter's
   first edit, and its `docs/technical/README.md` drops "stated here"
   from the decisions section, pointing at `settings.json` instead.
10. `make template-sync`; suite.

## Acceptance criteria (EARS)

- When `stage_2.auto_push` is absent from the settings file,
  `read_setting.sh` shall print `true`.
- When `stage_2.auto_push` holds a value outside `true`/`false`,
  `check_settings.sh` shall fault, naming the vocabulary.
- When an agent takes a task under `auto_push: false`, it shall present
  the branch, the pull request title and the body together and push
  nothing before an explicit yes.
- When the machinery commits, its subject shall be in the style
  `pr_title_style` declares.
- When `pr_title_style` is `bracketed`, `commit_subject.sh merge` shall
  print a bracketed subject; when it is `conventional`, a conventional
  one.
- When `sync_template.sh` runs, it shall leave every path in the
  exceptions list as the kit carries it, and say which paths it kept.
- When the kit's settings file is read, it shall answer `1` for `stage`
  and `false` for all three conduct flags.
- When the byte-mirror test runs, it shall hold every mirrored path
  identical except those the exceptions list names.

## Edge cases

- **An adopter who deletes the settings file** keeps `auto_push: true`,
  like the other two flags — the behaviour from before the key existed.
- **A settings file at the legacy address** (`conventions/settings.json`,
  decision 0053) is read flat; `auto_push` resolves there the same way
  the other conduct flags do.
- **The `credit_ai` rename lands first, or second.** This change writes
  whichever name the file carries; under alphabetical order
  `agent_coauthor` and `credit_ai` both sort clear of the `auto_` block,
  so neither ordering has to be redone.
- **A first push that is also the pull request's.** `auto_push` and
  `auto_pr` are one question at that moment, and the flow asks once —
  two prompts for one act is the failure this replaces, not an
  improvement on it.
- **A push that is not a task's** — a docs or report branch — is the
  same act and the same flag. The gate is about work becoming public,
  not about what kind of work it is.
- **`sync_template.sh` run when the kit's file is missing.** A preserved
  path that does not exist in `template/` is copied from the root like
  any other, so a fresh clone of the exception is the root's file until
  someone writes the kit's — reported, never silent.
- **`commit_subject.sh` where no settings file exists.** It reads the
  documented default, `conventional`, which is what the workflows write
  today.

## Tests required

`read_setting.sh` answers `true` for an absent `auto_push` and the
stated value for a present one; `check_settings.sh` accepts both
booleans and faults on a third value, and names `stage_2` as its home.
`commit_subject.sh` prints both styles for both events, and the
documented default when the file is absent. `sync_template.sh` leaves a
listed exception untouched and reports it; the byte-mirror test reads
the same exceptions list. The kit's settings file answers `1` and three
`false`s. A case reading both settings files' keys in order.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] No literal commit subject remains in either workflow.
- [ ] `.writrun/settings.json` and the kit's differ only where the
      exceptions list allows, and both are alphabetical within each
      section.
- [ ] Template synced; suite green.

## Proposed product changes

- `product/stage-2-pull-requests/taking.md#criteria` — the push and the
  draft are one act, gated once, before the work is public.

## Proposed technical changes

- `technical/README.md#settings` — the `auto_push` row, its documented
  default, and alphabetical order inside each section as the schema's
  rule.
- `technical/README.md#the-conduct-flags` — the section formerly
  `#auto_commit-and-auto_pr`, covering three flags and saying which act
  each one holds.
- `technical/README.md#distribution` — the kit's settings file leaves
  the byte mirror, and the exceptions list is the single source of that.
- `technical/decisions/tasks-and-specs/0061-the-push-is-its-own-act.md`
  — the dated why: the flags name acts, and the act that makes work
  public had none.
- `technical/decisions/README.md` — the chronology row for 0061.

## Outcome

_(fill after execution)_
