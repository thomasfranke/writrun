---
id: spec-0062
task_ref: task-0044
status: implemented
created: 2026-09-04T14:51:09Z
---

# spec-0062 — A pull request body's references are navigable

**References:** [task-0044](../tasks/task-0044-pr-body-shape.md)

- **Goal:** every task, spec and report a pull request body names is a
  bullet carrying its id, its title and a link that opens the file — and
  where the machinery composes the body, it composes the bullets too.

## Scope

In: the shipped pull request template, `conventions/prs.md`, the body
`take_task.sh` composes (both the template path and the no-template
fallback), the template mirror, and the contract chapter that describes
what the script writes.

Out: the `## How to test` section
([spec-0063](spec-0063-how-to-test.md)); any check that fetches a URL —
[0067](../../docs/technical/decisions/pull-requests/0067-a-body-link-points-at.md)
states why none is added; the Issues mirror's body, which renders itself.

## Steps

1. `.writrun/templates/pull_request_template.md`:
   - `## Spec` shows the bullet shape —
     `- [spec-NNNN](https://github.com/owner/repo/blob/main/work/specs/spec-NNNN-slug.md) — What it states`.
   - `## Derived work` loses the table and shows the same bullets, the
     spec nested under the task it derives from. The heading is a
     contract marker and is not touched.
   - A `## Report` section is added, for the reporting pull request the
     template never had a section for: the report, and the task and spec
     the `tracked` route mints.
   - The instruction comment names three kinds of pull request instead
     of two, and states the link rule in one line with a link to
     [`body.md`](../../docs/product/stage-2-pull-requests/body.md).
2. `.writrun/conventions/prs.md`: the **Body** bullet states the shape —
   id, title, link; absolute, on `main` — and links the chapter for the
   reasoning. Nothing is stated in both.
3. `take_task.sh`, `repo_blob_url()`: derive
   `https://github.com/<owner>/<repo>/blob/main/` from `git remote get-url
   origin`, accepting both the `git@github.com:owner/repo.git` and
   `https://github.com/owner/repo(.git)` forms. A remote that is missing,
   unreadable or not on `github.com` yields the empty string — the blob
   path shape is GitHub's, and guessing another forge's would write a
   dead link that reads as live.
4. `take_task.sh`, the `## Spec` composition: one bullet per entry of
   `spec_ref`, in that order, each `- [<id>](<url>) — <title>`. The title
   is the spec file's first `# ` heading with its own `spec-NNNN — `
   prefix stripped. With no URL the bullet is `- <id> — <title>`; with no
   spec at all the line stays the sentence it is today. Composition never
   fails a take: every missing part degrades to the part above it.
5. The no-template fallback body in the same script carries the same
   sections as the template it stands in for.
6. `docs/technical/distribution/take-task.md`: the composition sentence
   says what the body now carries, and that a body composed without a
   usable remote carries ids and titles without links.
7. `make template-sync`.

## Acceptance criteria (EARS)

- When `take_task.sh` composes a body for a task whose `spec_ref` is not
  empty, the `## Spec` section shall carry one bullet per spec, each
  naming the id, the spec's title, and an absolute URL to that spec's
  file on `main`.
- When the origin remote is absent, unreadable, or not on `github.com`,
  the bullets shall carry id and title without a link and the take shall
  proceed to its normal exit.
- When a spec's heading carries the `spec-NNNN — ` prefix, the composed
  bullet shall carry the title without it.
- When the shipped template is filled by hand, its `## Spec`,
  `## Derived work` and `## Report` sections shall each show the bullet
  shape, and the text of the `## Derived work` heading shall be
  byte-identical to today's.
- When `check_derived_work.sh` reads a `## Derived work` section written
  in the new shape, it shall behave exactly as it does today.

## Edge cases

- A `spec_ref` entry that resolves to no file: the bullet is the bare id.
  The eligibility re-check above already refuses such a take, so this is
  the composition refusing to crash, not a supported state.
- A spec heading that is only `# spec-0062`: the title is empty and the
  bullet is `- [spec-0062](url)`. Nothing is invented.
- A remote URL with a trailing slash, a `.git` suffix, or both.
- An adopter on a self-hosted GitHub: the host is not `github.com`, so no
  link is composed. Under-linking is the safe direction.
- A body composed under `auto_pr: false` prints the same bullets it would
  have opened with — the printed act is the act.

## Tests required

- `tests/unit/take_task/`: a composed body carries id, title and an
  absolute `blob/main` URL for each spec, in `spec_ref` order.
- `tests/unit/take_task/`: the ssh and https remote forms yield the same
  URL; a non-GitHub remote yields bullets with no link and exit 0.
- `tests/unit/take_task/the_flags_hold_the_whole_act_test.sh`: the
  assertion on the old `Implements spec-…` sentence follows the new shape.
- `tests/unit/template/`: the mirror stays byte-identical.

## Definition of Done

- [ ] The template ships the three declarations in the bullet shape, the
      `## Derived work` heading untouched.
- [ ] `take_task.sh` composes the spec bullets, and degrades to id and
      title where it cannot compose a URL.
- [ ] `conventions/prs.md` states the shape and links the chapter.
- [ ] `take-task.md` describes what the script now writes.
- [ ] `make template-sync` leaves no diff.
- [ ] The suite is green.

## Proposed product changes

- none — the rule was authored ahead of this spec
  (`product/stage-2-pull-requests/body.md`); authoring closes the loop in
  advance.

## Proposed technical changes

- `technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command`
  — the composition sentence names the bullets, the `main` blob URL, and
  the unlinked fallback.

## Outcome

Built as planned, steps 1–7. The template's three declarations ship in
the bullet shape — `## Derived work` as bullets with the spec nested
under its task, `## Spec` as one bullet per spec, and a new `## Report`
for the reporting pull request the template never had a section for. The
`## Derived work` heading text is byte-identical to what it was; it is a
contract marker `writrun check` finds by name, and the change is what
sits under it. `conventions/prs.md` states the shape and the two link
rules and links `body.md` for the reasoning. `take_task.sh` composes the
bullets from `spec_ref`, in that order, each carrying the spec's own
first heading with its `spec-NNNN — ` prefix stripped, and an absolute
`blob/main` URL derived from the origin remote in both the ssh and https
forms. `take-task.md` says what the script writes and what it writes
instead when it cannot compose a URL. `make template-sync` leaves no
diff.

**Degradation is the design, not a fallback.** No URL leaves id and
title; no spec file leaves the bare id; no `spec_ref` at all leaves the
sentence that was there before. The act is the branch reaching the forge
with a draft on it, and a take that refused over a heading it could not
parse would trade the whole act for a bullet.

**One interface the spec did not name: `WRITRUN_ORIGIN_URL`.** The suite
cannot present a github.com remote to the script, because the act
fetches `origin main` two hundred lines before it composes anything, so
that fetch would have to reach github.com. `url.<base>.insteadOf` does
not help — `git remote get-url` applies the rewrite too, so the case
under test disappears into the local path. The remote is therefore read
through an overridable name, which nothing but the suite sets; the shape
is `WRITRUN_MIRROR_REFRESH_WAIT`'s in `rederive_labels.sh`, and the
reason is the same one: a seam the suite needs and production never
touches. Without it the URL forms in Tests required could not be tested
at all.

**The marker the composition replaces changed with the template.** The
script matched `Implements spec-NNNN.`; it now matches the placeholder
bullet the `## Spec` section ships, and the awk that drops the other
kinds' sections drops two ranges rather than one, since `## Report` sits
between `## Spec` and `## How to verify`.

`conventions/prs.md` gained two bullets rather than the one step 2
names — the reference shape, and the two questions
([spec-0063](spec-0063-how-to-test.md)'s step 2, which lands in the same
file and the same change). Splitting them was clearer than one bullet
saying both.

Tests: `the_body_names_what_it_implements_test.sh` covers the linked
shape, `spec_ref` order, the two remote forms and the `.git`/trailing
slash pair, the non-GitHub and local-remote fallbacks, that a take with
no composable URL still opens the draft, and the no-spec sentence.
`the_flags_hold_the_whole_act_test.sh`'s assertion on the old
`Implements spec-…` sentence follows the bullet. The template mirror
case is unchanged and green, and `check_derived_work.sh`'s own tier
passes against the new shape — it reads the heading, and the heading did
not move.
