# `writrun-check-spec-deltas` normalises promised paths to repository-root before comparing.

**2026-08-21**

A spec writes its Proposed-changes
paths relative to `docs/` (`product/tasks-and-specs/README.md`), while `git diff
--name-only` reports relative to the repository root
(`docs/product/tasks-and-specs/README.md`). The two never matched, so every run reported
every promised path MISSING *and* every touched doc UNDECLARED at the same
time — the check had never passed and could not have. The script now
prefixes `docs/` when extracting. Two related changes in the same pass: a
failing `git diff` exits 3 instead of being swallowed into an empty file
list that looks like a real "nothing was touched" result, and UNDECLARED
no longer overwrites a MISSING exit code, since a forgotten doc update is
the drift this check exists to catch. Rejected: writing Proposed-changes
paths relative to the repository root instead — the `docs/`-relative form
is what `doc_ref` already uses, and diverging the two would be a
second thing to remember.
