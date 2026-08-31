# Decisions

**The dated why behind each piece of machinery — and what was
rejected.** Append-only history: an entry is never edited, the next one
is added. The living reference — schemas, the selection algorithm,
distribution, the public contract — is [README.md](../README.md); this
folder is where its shape came from.

One decision per file, numbered in the order it was taken. **The number
is identity**: it never changes, the file is never renamed, and a
superseded decision keeps its file and its number — the entry that
replaces it says so and gets the next number.

Entries sit in the folder of the adoption level they concern, so a
project at one level is not asked to read the machinery of another.
`release/` is this repository's own operation and belongs to no level:
the cut is never shipped to an adopter. **The table below is the chronology**, which folders do not
carry; it is the only part of this folder that is rewritten, and only by
appending a row.

| # | Date | Level | Decision |
|---|---|---|---|
| [0001](tasks-and-specs/0001-blocked-is-a-status.md) | 2026-08-21 | `tasks-and-specs` | `blocked` is a status, not a folder or a tag. |
| [0002](tasks-and-specs/0002-selection-resumes-in-progress.md) | 2026-08-21 | `tasks-and-specs` | selection resumes `in-progress` before picking `pending`. |
| [0003](tasks-and-specs/0003-skills-install-into-writrun.md) | 2026-08-21 | `tasks-and-specs` | skills install into `.writrun/skills/`, not a top-level `skills/`. |
| [0004](tasks-and-specs/0004-writrun-create-task-and.md) | 2026-08-21 | `tasks-and-specs` | `writrun-create-task-and-spec` gains a generator script (`new.sh`). |
| [0005](tasks-and-specs/0005-script-backed-skills-target.md) | 2026-08-21 | `tasks-and-specs` | script-backed skills target POSIX `awk`/`sed`, never gawk extensions. |
| [0006](tasks-and-specs/0006-writrun-check-spec-deltas.md) | 2026-08-21 | `tasks-and-specs` | `writrun-check-spec-deltas` normalises promised paths to repository-root before comparing. |
| [0007](tasks-and-specs/0007-a-permanent-doc-changes.md) | 2026-08-22 | `tasks-and-specs` | a permanent doc changes in two named directions, not one. |
| [0008](tasks-and-specs/0008-ready-for-development-is.md) | 2026-08-22 | `tasks-and-specs` | "ready for development" is derived, never stored. |
| [0009](tasks-and-specs/0009-nothing-in-this-methodology.md) | 2026-08-22 | `tasks-and-specs` | nothing in this methodology reserves a task. |
| [0010](pull-requests/0010-ci-splits-into-a.md) | 2026-08-22 | `pull-requests` | CI splits into a mandatory read-only check and a best-effort write. |
| [0011](github-issues/0011-the-github-issues-mirror.md) | 2026-08-22 | `github-issues` | the GitHub Issues mirror runs one direction only, and follows the pull request. |
| [0012](tasks-and-specs/0012-the-script-backed-skills.md) | 2026-08-22 | `tasks-and-specs` | the script-backed skills carry a test suite. |
| [0013](tasks-and-specs/0013-new-sh-reads-git.md) | 2026-08-22 | `tasks-and-specs` | `new.sh` reads git history, not only the filesystem, when assigning an id. |
| [0014](pull-requests/0014-the-merge-stays-a.md) | 2026-08-22 | `pull-requests` | the merge stays a separate manual act; approval does not auto-merge. |
| [0015](pull-requests/0015-a-spec-that-enters.md) | 2026-08-22 | `pull-requests` | a spec that enters the tree already `approved` is judged against the forge's review record. |
| [0016](tasks-and-specs/0016-a-multi-spec-completion.md) | 2026-08-22 | `tasks-and-specs` | a multi-spec completion is checked against the union of its promises. |
| [0017](tasks-and-specs/0017-the-queue-lives-in.md) | 2026-08-22 | `tasks-and-specs` | the queue lives in `work/`, not `docs/`. |
| [0018](tasks-and-specs/0018-an-approved-spec-s.md) | 2026-08-22 | `tasks-and-specs` | an approved spec's content changes only through draft. |
| [0019](tasks-and-specs/0019-the-task-s-doc.md) | 2026-08-22 | `tasks-and-specs` | the task's doc reference is `doc_ref`: any path under `docs/`. |
| [0020](tasks-and-specs/0020-a-cli-is-welcome.md) | 2026-08-22 | `tasks-and-specs` | a CLI is welcome, as a separate repository, never as a dependency. |
| [0021](tasks-and-specs/0021-the-adoption-kit-is.md) | 2026-08-22 | `tasks-and-specs` | the adoption kit is `template/`: a full copy, guarded by a test. |
| [0022](pull-requests/0022-derivation-is-reviewable-before.md) | 2026-08-22 | `pull-requests` | derivation is reviewable before it is public. |
| [0023](github-issues/0023-mirrors-defer-to-authority.md) | 2026-08-22 | `github-issues` | mirrors defer to authority, and tell a draft from a review. |
| [0024](tasks-and-specs/0024-generated-shapes-resolve-in.md) | 2026-08-22 | `tasks-and-specs` | generated shapes resolve in layers: the project's, then `.writrun/`, then the script. |
| [0025](tasks-and-specs/0025-the-selection-algorithm-s.md) | 2026-08-22 | `tasks-and-specs` | the selection algorithm's filters and its sort bind different parties. |
| [0026](tasks-and-specs/0026-the-queue-is-printable.md) | 2026-08-22 | `tasks-and-specs` | the queue is printable, not just selectable. |
| [0027](tasks-and-specs/0027-the-diagrams-paint-their.md) | 2026-08-22 | `tasks-and-specs` | the diagrams paint their own background. |
| [0028](tasks-and-specs/0028-acceptance-criteria-are-not.md) | 2026-08-22 | `tasks-and-specs` | acceptance criteria are not judged by a model, and CI does not run the adopter's tests. |
| [0029](tasks-and-specs/0029-writrun-check-task-state.md) | 2026-08-22 | `tasks-and-specs` | `writrun-check-task-state` runs after the completion statuses are set, not before. |
| [0030](release/0030-the-version-number-is.md) | 2026-08-23 | release | the version number is computed, never typed. |
| [0031](github-issues/0031-the-mirror-workflows-logic.md) | 2026-08-23 | `github-issues` | the mirror workflows' logic moved out of the YAML too. |
| [0032](tasks-and-specs/0032-a-status-transition-is.md) | 2026-08-23 | `tasks-and-specs` | a status transition is read from the front matter at the range's two ends, never grepped out of the diff. |
| [0033](pull-requests/0033-an-approving-review-vouches.md) | 2026-08-23 | `pull-requests` | an approving review vouches for the pull request, not for a commit. |
| [0034](tasks-and-specs/0034-the-flows-live-in.md) | 2026-08-23 | `tasks-and-specs` | the flows live in the permanent docs; the README summarizes. |
| [0035](tasks-and-specs/0035-canonical-front-matter-is.md) | 2026-08-23 | `tasks-and-specs` | canonical front matter is enforced, not assumed. |
| [0036](tasks-and-specs/0036-the-template-sync-is.md) | 2026-08-23 | `tasks-and-specs` | the template sync is a script, not a Makefile recipe. |
| [0037](tasks-and-specs/0037-decisions-are-history-split.md) | 2026-08-23 | `tasks-and-specs` | decisions are history, split from the living reference. |
| [0038](tasks-and-specs/0038-contract-front-matter-is.md) | 2026-08-23 | `tasks-and-specs` | contract front matter is generated; extension front matter is the template's. |
| [0039](release/0039-a-release-verifies-the.md) | 2026-08-23 | release | a release verifies the sync produced nothing but the stamp. |
| [0040](release/0040-main-gets-a-release.md) | 2026-08-23 | release | main gets a release pipeline of its own; the cut stays local. |
| [0041](github-issues/0041-the-issues-mirror-is.md) | 2026-08-23 | `github-issues` | the Issues mirror is severable, and the kit says so. |
| [0042](release/0042-an-unusable-gh-aborts.md) | 2026-08-24 | release | an unusable gh aborts the release before anything is mutated. |
| [0043](pull-requests/0043-the-merge-is-this.md) | 2026-08-28 | `pull-requests` | the merge is this repository's assenting act, because its maintainer cannot review his own pull requests. |
| [0044](github-issues/0044-a-proposed-task-and.md) | 2026-08-28 | `github-issues` | a proposed task and a queued one stop sharing a label. |
| [0045](tasks-and-specs/0045-one-decision-per-file.md) | 2026-08-28 | `tasks-and-specs` | one decision per file, numbered — reversing part of 0037. |
| [0046](pull-requests/0046-the-task-tag-leads.md) | 2026-08-28 | `pull-requests` | the task tag leads the title, one bracket per task. |
| [0047](tasks-and-specs/0047-a-task-carries-four-dates.md) | 2026-08-28 | `tasks-and-specs` | a task carries four dates, and who writes each is the contract. |
| [0048](github-issues/0048-a-label-names-a-place.md) | 2026-08-28 | `github-issues` | a label names a place in the pipeline, so a closed mirror has none. |
| [0049](tasks-and-specs/0049-dates-are-utc-timestamps.md) | 2026-08-28 | `tasks-and-specs` | every queue date is a UTC timestamp, spelled with Z. |
| [0050](tasks-and-specs/0050-the-subject-slug-is-chosen.md) | 2026-08-28 | `tasks-and-specs` | the filename's subject slug is chosen, not sliced off the title. |
| [0051](pull-requests/0051-an-id-is-unique-across-open-prs.md) | 2026-08-28 | `pull-requests` | an id is unique across open pull requests, not just across a branch. |
| [0052](tasks-and-specs/0052-settings-carry-the-choice.md) | 2026-08-28 | `tasks-and-specs` | adoption is levelled, and settings.json carries which level. |
| [0053](tasks-and-specs/0053-settings-at-the-root.md) | 2026-08-30 | `tasks-and-specs` | settings move to WritRun's root and section by stage — reversing part of 0052. |
| [0054](tasks-and-specs/0054-the-adopter-governs-the-agent.md) | 2026-08-30 | `tasks-and-specs` | the adopter's settings govern the agent's git conduct. |
| [0055](tasks-and-specs/0055-conduct-flags-live-in-stage-2.md) | 2026-08-31 | `tasks-and-specs` | the conduct flags move to `stage_2` — correcting 0054's placement. |
| [0056](pull-requests/0056-protection-is-recommended.md) | 2026-08-31 | `pull-requests` | protecting the authority branch is recommended, never a gate — superseding 0043's unprotected premise. |
| [0057](pull-requests/0057-the-credit-flag-names-its-artifact.md) | 2026-08-31 | `pull-requests` | the credit flag names its artifact and is renamed `agent_coauthor` — narrowing 0054's `credit_ai`. |
| [0058](tasks-and-specs/0058-the-ledger-lives-in-the-queue.md) | 2026-08-31 | `tasks-and-specs` | the provenance ledger lives in the queue; the agent's transcript is a source, never the store. |
| [0059](pull-requests/0059-the-pause-is-derived.md) | 2026-08-31 | `pull-requests` | an amendment in flight suspends the task; the pause is derived, the forge carries the relation. |
| [0060](github-issues/0060-the-merged-close-has-one-owner.md) | 2026-08-31 | `github-issues` | the merged close has one owner, and the label is the queue's to project — completing 0048. |
