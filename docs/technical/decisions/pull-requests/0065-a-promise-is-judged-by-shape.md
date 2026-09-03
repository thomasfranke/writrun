# a promise is judged by its shape, never by whether the file exists.

**2026-09-02**

A path in either **Proposed changes** section is read relative to
`docs/`, and `check_deltas.sh` prefixes every bullet with it before
comparing. A spec that writes a repository-root path instead promises a
file no diff can ever reach: `tests/harness.sh` is read as
`docs/tests/harness.sh`. The promise is not unkept, it is *unkeepable* —
and nothing said so until the completion gate ran against a finished
branch. It happened twice. `spec-0041` was refused on #83, costing an
amendment under an open pull request with the task suspended.
`spec-0044` carried five such paths to `approved` and was caught only
because a person read
[report-0005](../../../../work/reports/report-0005-delta-doc-paths.md).

`check_promise_paths.sh` moves the refusal to where the spec enters, on
the reasoning [0059](0059-the-pause-is-derived.md) already used for the
companion rule — "the whole class of late amendment this case belongs
to, moved to the point where amending costs nothing". A path that cannot
resolve is that same class, one step earlier: the fix is one edit, and
nothing has been assented to yet.

**The test is shape, and existence was never available to it.** At spec
entry the promised doc is precisely what has not been written — a spec
legitimately promises the chapter its own change creates, so "is the
file there" would refuse the ordinary case and pass the broken one. Two
conditions answer the question that *is* askable, whether the path is a
documentation path at all:

- **Root-relative.** The first segment names an entry at the repository
  root for which `docs/` holds no counterpart. `tests/`, `template/`,
  `.github/`, `.writrun/` and a leading `docs/` are all caught by it.
- **Not a document.** The path ends in neither `.md` nor `/`, the
  trailing slash being the folder form `check_deltas.sh` already reads.

**Both are read off the repository, never from a list.** A table of
known root names would be a second copy of the tree, wrong the first
time anyone adds a folder, and it would judge an adopter whose docs are
shaped differently by this repository's shape. Reading the tree costs a
`test -e` per promised path and is right by construction.

Where the two readings collide — a project holding both `docs/tests/`
and `tests/` — the documentation reading wins, because refusal requires
that `docs/<first-segment>` *not* exist. That is the safe direction: the
promise is keepable, so refusing it would be a false negative on a
correct spec, and the opposite error surfaces at the completion gate
that still stands behind this one.

**What this deliberately leaves to the completion gate.** Whether the
promised doc was actually touched, whether the change touched a doc it
never promised, and whether a spec that reached the base branch already
carrying an offending path is wrong — all three stay with
`writrun-check-spec-deltas`. This check reads the range's own specs and
history is not re-judged, the same boundary the companions check draws:
a completion pull request that merely flips `approved` to `implemented`
must not be refused with a message insisting the cheap fix is still
available when it is not.

**Rejected: teaching either check to pass repository-root paths
through.** report-0005's triage settled it — the Proposed-changes
sections exist to close the loop on permanent docs, and a promise of
`tests/` is one the loop has no use for. The machinery a change touches
belongs in the spec's Scope and Steps, which is what `spec-0043` does
while carrying more machinery than `spec-0044` did.
