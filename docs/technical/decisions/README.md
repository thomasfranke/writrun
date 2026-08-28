# Decisions

**The dated why behind each piece of machinery — and what was
rejected.** Append-only history: an entry is never edited, the next one
is added. The living reference — schemas, the selection algorithm,
distribution, the public contract — is [README.md](../README.md); this
folder is where its shape came from.

One decision per file, numbered in the order it was taken. **The number
is identity**: it never changes, the file is never renamed, and a
superseded decision keeps its file and its number — the entry that
replaces it says so and gets the next number. The table below is the
chronological log; it is the only part of this folder that is rewritten,
and only ever by appending a row.

| # | Date | Decision |
|---|---|---|
| [0001](0001-blocked-is-a-status.md) | 2026-08-21 | `blocked` is a status, not a folder or a tag. |
| [0002](0002-selection-resumes-in-progress.md) | 2026-08-21 | selection resumes `in-progress` before picking `pending`. |
| [0003](0003-skills-install-into-writrun.md) | 2026-08-21 | skills install into `.writrun/skills/`, not a top-level `skills/`. |
| [0004](0004-writrun-create-task-and.md) | 2026-08-21 | `writrun-create-task-and-spec` gains a generator script (`new.sh`). |
| [0005](0005-script-backed-skills-target.md) | 2026-08-21 | script-backed skills target POSIX `awk`/`sed`, never gawk extensions. |
| [0006](0006-writrun-check-spec-deltas.md) | 2026-08-21 | `writrun-check-spec-deltas` normalises promised paths to repository-root before comparing. |
| [0007](0007-a-permanent-doc-changes.md) | 2026-08-22 | a permanent doc changes in two named directions, not one. |
| [0008](0008-ready-for-development-is.md) | 2026-08-22 | "ready for development" is derived, never stored. |
| [0009](0009-nothing-in-this-methodology.md) | 2026-08-22 | nothing in this methodology reserves a task. |
| [0010](0010-ci-splits-into-a.md) | 2026-08-22 | CI splits into a mandatory read-only check and a best-effort write. |
| [0011](0011-the-github-issues-mirror.md) | 2026-08-22 | the GitHub Issues mirror runs one direction only, and follows the pull request. |
| [0012](0012-the-script-backed-skills.md) | 2026-08-22 | the script-backed skills carry a test suite. |
| [0013](0013-new-sh-reads-git.md) | 2026-08-22 | `new.sh` reads git history, not only the filesystem, when assigning an id. |
| [0014](0014-the-merge-stays-a.md) | 2026-08-22 | the merge stays a separate manual act; approval does not auto-merge. |
| [0015](0015-a-spec-that-enters.md) | 2026-08-22 | a spec that enters the tree already `approved` is judged against the forge's review record. |
| [0016](0016-a-multi-spec-completion.md) | 2026-08-22 | a multi-spec completion is checked against the union of its promises. |
| [0017](0017-the-queue-lives-in.md) | 2026-08-22 | the queue lives in `work/`, not `docs/`. |
| [0018](0018-an-approved-spec-s.md) | 2026-08-22 | an approved spec's content changes only through draft. |
| [0019](0019-the-task-s-doc.md) | 2026-08-22 | the task's doc reference is `doc_ref`: any path under `docs/`. |
| [0020](0020-a-cli-is-welcome.md) | 2026-08-22 | a CLI is welcome, as a separate repository, never as a dependency. |
| [0021](0021-the-adoption-kit-is.md) | 2026-08-22 | the adoption kit is `template/`: a full copy, guarded by a test. |
| [0022](0022-derivation-is-reviewable-before.md) | 2026-08-22 | derivation is reviewable before it is public. |
| [0023](0023-mirrors-defer-to-authority.md) | 2026-08-22 | mirrors defer to authority, and tell a draft from a review. |
| [0024](0024-generated-shapes-resolve-in.md) | 2026-08-22 | generated shapes resolve in layers: the project's, then `.writrun/`, then the script. |
| [0025](0025-the-selection-algorithm-s.md) | 2026-08-22 | the selection algorithm's filters and its sort bind different parties. |
| [0026](0026-the-queue-is-printable.md) | 2026-08-22 | the queue is printable, not just selectable. |
| [0027](0027-the-diagrams-paint-their.md) | 2026-08-22 | the diagrams paint their own background. |
| [0028](0028-acceptance-criteria-are-not.md) | 2026-08-22 | acceptance criteria are not judged by a model, and CI does not run the adopter's tests. |
| [0029](0029-writrun-check-task-state.md) | 2026-08-22 | `writrun-check-task-state` runs after the completion statuses are set, not before. |
| [0030](0030-the-version-number-is.md) | 2026-08-23 | the version number is computed, never typed. |
| [0031](0031-the-mirror-workflows-logic.md) | 2026-08-23 | the mirror workflows' logic moved out of the YAML too. |
| [0032](0032-a-status-transition-is.md) | 2026-08-23 | a status transition is read from the front matter at the range's two ends, never grepped out of the diff. |
| [0033](0033-an-approving-review-vouches.md) | 2026-08-23 | an approving review vouches for the pull request, not for a commit. |
| [0034](0034-the-flows-live-in.md) | 2026-08-23 | the flows live in the permanent docs; the README summarizes. |
| [0035](0035-canonical-front-matter-is.md) | 2026-08-23 | canonical front matter is enforced, not assumed. |
| [0036](0036-the-template-sync-is.md) | 2026-08-23 | the template sync is a script, not a Makefile recipe. |
| [0037](0037-decisions-are-history-split.md) | 2026-08-23 | decisions are history, split from the living reference. |
| [0038](0038-contract-front-matter-is.md) | 2026-08-23 | contract front matter is generated; extension front matter is the template's. |
| [0039](0039-a-release-verifies-the.md) | 2026-08-23 | a release verifies the sync produced nothing but the stamp. |
| [0040](0040-main-gets-a-release.md) | 2026-08-23 | main gets a release pipeline of its own; the cut stays local. |
| [0041](0041-the-issues-mirror-is.md) | 2026-08-23 | the Issues mirror is severable, and the kit says so. |
| [0042](0042-an-unusable-gh-aborts.md) | 2026-08-24 | an unusable gh aborts the release before anything is mutated. |
| [0043](0043-the-merge-is-this.md) | 2026-08-28 | the merge is this repository's assenting act, because its maintainer cannot review his own pull requests. |
| [0044](0044-a-proposed-task-and.md) | 2026-08-28 | a proposed task and a queued one stop sharing a label. |
| [0045](0045-one-decision-per-file.md) | 2026-08-28 | one decision per file, numbered — reversing part of 0037. |
| [0046](0046-the-task-tag-leads.md) | 2026-08-28 | the task tag leads the title, one bracket per task. |
| [0047](0047-a-task-carries-four-dates.md) | 2026-08-28 | a task carries four dates, and who writes each is the contract. |
| [0048](0048-a-label-names-a-place.md) | 2026-08-28 | a label names a place in the pipeline, so a closed mirror has none. |
| [0049](0049-dates-are-utc-timestamps.md) | 2026-08-28 | every queue date is a UTC timestamp, spelled with Z. |
