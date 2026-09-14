---
id: spec-0094
task_ref: task-0066
status: approved
created: 2026-09-13T23:42:51Z
---

# spec-0094 — Anything under docs/ is a document the queue can name and promise

**References:** [task-0066](../tasks/task-0066-documents-not-markdown.md)

- **Goal:** A path under `docs/` is a document the queue can name and a
  spec can promise, whatever its file extension — while every refusal
  decision 0065 was written for stays standing.

## Scope

Two gates read an extension as the answer to "is this documentation", and
both stop doing so.

- `check_front_matter.sh`'s `check_doc_ref` — the `*.md|*.md#*` case that
  decides which `doc_ref` values are legal.
- `check_promise_paths.sh`'s condition two — the `*/|*.md` case that
  decides which **Proposed changes** entries resolve.

Both live inside `.writrun/`, which `tests/kit_mirrors.txt` carries
whole, so the kit copies follow from `make kit-sync` and are not edited
by hand.

**Out of scope, and deliberately.** `check_deltas.sh` needs no change:
it already reads `docs/*` whole and matches promised paths verbatim, and
that is exactly why the two halves currently contradict each other.
`check_doc_shapes.sh` needs none either — it enumerates `*.md` by
construction, and a non-Markdown file has no front matter to hold to a
schema. Neither the draft marker nor anchor verification is widened;
both are addressed as edge cases below rather than as work.

## Steps

1. Widen `check_doc_ref` to accept any `doc_ref` under `docs/`, with an
   optional `#anchor`, keeping the existing resolution check — the file
   must be there — and the existing `docs/`-prefix refusal.
2. Replace condition two in `check_promise_paths.sh`. A trailing `/`
   stays the folder promise. Everything else is read as a file path and
   accepted on shape, so the condition stops testing the extension.
3. Add the refusal the widening makes newly available: a promise with no
   trailing slash whose path names an existing **directory** under
   `docs/` is a folder promise missing its slash, and saying so at spec
   entry costs one edit where the completion gate would otherwise report
   a promise that can never be matched.
4. Leave condition one untouched — the root-relative test is what stops
   `tests/harness.sh`, and it is the whole of what decision 0065 was
   defending.
5. Run `make kit-sync` so the kit's copies of both scripts match.
6. State the criterion in the two schema chapters that annotate the
   field, and record the decision beside the one it refines.

## Acceptance criteria (EARS)

- When a task's or report's `doc_ref` names a path relative to `docs/`
  that resolves to a file which exists, the checker shall accept it
  whatever that file's extension.
- When a `doc_ref` resolves to no file, the checker shall refuse it,
  naming the path it tried — unchanged from today.
- When a `doc_ref` begins with `docs/`, the checker shall refuse it —
  unchanged from today.
- When a spec promises a path whose first segment names a
  repository-root entry for which `docs/` holds no counterpart, the
  check shall refuse it — unchanged from today.
- When a spec promises a path with no trailing slash that names an
  existing directory under `docs/`, the check shall refuse it and say a
  folder promise is written with a trailing slash.
- When a spec promises a path under `docs/` that is neither of those, the
  check shall accept it whatever its extension.
- When a promised path is not a Markdown file, the draft-chapter
  condition shall not be applied to it.
- When a completing diff touches a non-Markdown file under `docs/` that
  its spec promised by exact path, `check_deltas.sh` shall report it
  declared — with no change to that script.

## Edge cases

- **A non-Markdown document can never declare itself a draft.**
  `ql_doc_is_draft` and `doc_declares_draft` read `/// writrun:draft` as
  the first line, which a JSON or binary file cannot carry. The result is
  that such a document is never a draft, which is the strict answer and
  needs no code: an absent declaration has always meant "not a draft".
  Widening the marker to other comment syntaxes is a separate question
  and is not asked here.
- **An anchor on a non-Markdown path.** Anchors are already unverified
  by contract — `check_doc_ref` states that matching one would mean
  parsing Markdown, which no reader in this methodology does. Accepting
  `#layout` on a drawing therefore costs nothing and changes no
  behaviour.
- **A promise of a file that does not exist yet** stays legal and must:
  decision 0065 established that a spec legitimately promises the
  document its own change creates, so existence is not a test at spec
  entry. Step 3's directory refusal does not break this — it fires only
  when the path *does* exist and is a directory.
- **A name collision between `docs/x/` and `x/`** keeps resolving to the
  documentation reading, as 0065 decided; step 4 leaves that code alone.

## Tests required

- `tests/integration/front_matter/` — a `doc_ref` naming a non-Markdown
  file that exists is accepted; one naming a non-Markdown file that does
  not exist is still refused.
- `tests/integration/stage-2/promise_paths/` — a non-Markdown promise
  resolves; a slash-less promise of an existing directory is refused with
  the folder-promise message.
- `a_path_that_is_not_a_document_is_refused_test.sh` **is rewritten, not
  deleted.** It currently asserts the behaviour this spec removes, and
  what survives is its real subject: a repository-root path is still not
  a document. Deleting it would drop coverage of condition one along with
  the assertion that changed.
- `the_five_paths_of_spec_0044_are_refused_test.sh` is re-read against
  the new rule: those five are root-relative, so they must still be
  refused, and if any of them passed for the extension reason rather than
  the root reason, that is the regression this check catches.
- The kit mirror unit test must pass without a new exception.

## Definition of Done

- [ ] Both gates accept a non-Markdown path under `docs/`, and every
      refusal listed above still fires.
- [ ] `make kit-sync` leaves the kit copies byte-identical, with no entry
      added to `tests/kit_exceptions.txt`.
- [ ] The rewritten and new tests pass, and the suite's count is read
      from the runner rather than carried by hand.
- [ ] The two schema chapters state what the field accepts, and no longer
      leave `check_front_matter.sh` as the only place the answer exists.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- none — no product rule changes. The rule this restores is already
  stated: `kit/docs/product/README.md` tells every adopter that
  "everything under `docs/` counts as permanent input", and the machinery
  is what disagreed with it.

## Proposed technical changes

- `technical/schemas/task.md#task-schema` — state what `doc_ref` accepts:
  any path under `docs/` that resolves, with an optional anchor, and not
  a file format. The annotation already says "any path under `docs/`";
  the prose has to stop being the only place that is true.
- `technical/schemas/report.md` — the same field under the same contract,
  which that chapter defers to the task's for; the deferral is kept and
  the sentence made accurate.
- `technical/decisions/pull-requests/0075-a-document-is-not-a-file-format.md`
  — the record: what 0065's `.md` test was standing in for, why the
  root-relative half is untouched, and what replaced the extension half.
  It sits beside 0065 because it refines that decision; the `doc_ref`
  half is cross-referenced there rather than given a second record.
- `technical/decisions/README.md` — the index gains the new record's
  line. A record that is not indexed is one the router cannot reach, so
  the two never change apart.

## Outcome

_(fill after execution)_
