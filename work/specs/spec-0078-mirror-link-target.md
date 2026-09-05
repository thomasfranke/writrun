---
id: spec-0078
task_ref: task-0056
status: implemented
created: 2026-09-05T13:56:57Z
---

# spec-0078 — A mirror's link reaches the file, before the merge and after

**References:** [task-0056](../tasks/task-0056-mirror-links-the-file.md)

- **Goal:** the link on the file's name reaches that file — at the head
  commit while the pull request is open, at the base ref once it merges.

## Scope

A mirror's first line names the file it mirrors. The link on that name
shall reach that file — while the pull request is open, and after it
merges.

Two writers compose it the same way today,
`mirror_issues.sh:635` for a task mirror and `:833` for a report one:

```
"Mirrors [\`${fname}\`](${PR_HTML_URL}/files), which is the authority."
```

Both are in scope. Nothing else about the body changes: the table, the
`Introduced by` row and the readiness sentence stay as they are.

**Where the link points, in both windows.** The file is not on the base
branch until the merge, which is why the diff was chosen — but the file
does exist, on the pull request's head commit, from the moment the
mirror is born. So:

| Window | Target |
|---|---|
| Pull request open | `<repo>/blob/<head-sha>/<path>` — the file at the commit the mirror was born from |
| After the merge | `<repo>/blob/<base-ref>/<path>` — the file where it now lives |

The open-window link is a permalink: it resolves the moment the Issue is
created and keeps resolving after the branch is deleted. The merge
rewrites it to the living file, because a mirror outlives its pull
request and a reader arriving a year later wants the file, not a
snapshot of a branch that is gone.

**The base branch is read, not assumed.** `main` is this repository's
answer and not every adopter's, and the script already takes the
repository as an argument rather than hardcoding it.

**The head sha is fetched, not passed.** `mirror_issues.sh` reads five
`PR_*` names from the environment, and a sixth is the miswiring hazard
`technical/distribution/checks.md` exists to name — a name the caller
never sets or the callee never reads, neither loud. The script already
calls `gh api repos/{repo}/pulls/{n}/files`; the same pull's `.head.sha`
comes from the call it is already making.

## Steps

1. Derive the head sha and the base ref from the pull request the run is
   already reading, without adding an environment name.
2. Build the file link from the repository, the ref and the queue file's
   path, in one helper both writers call.
3. Use it at `:635` (task mirror) and `:833` (report mirror).
4. On merge, rewrite the first line of an existing mirror's body so the
   link points at the base ref, reusing the decode-sed-`PATCH` shape
   already at `:439-449`.
5. A mirror created *at* merge — the catch-up path — is born pointing at
   the base ref, never at a head sha.

## Acceptance criteria (EARS)

- When a mirror is created while its pull request is open, the mirror
  shall link the queue file at the pull request's head commit.
- When a mirror is created for a merged pull request, the mirror shall
  link the queue file at the base ref.
- When a pull request carrying a mirrored queue file merges, the
  machinery shall rewrite that mirror's link to the base ref.
- Where the head sha cannot be read, the machinery shall link the file
  at the base ref rather than fail the mirror.

## Edge cases

- **A fork's pull request.** The head commit lives in the fork, and a
  `blob/<sha>` URL on the base repository resolves it anyway once the
  pull request exists — the commit is reachable from the base
  repository's refs. Verify this against a real fork pull request before
  relying on it; if it does not hold, the fork case falls to the
  base-ref fallback.
- **The pull request closes unmerged.** No rewrite runs and the mirror
  retires with the pull request, so the permalink is the last thing it
  ever said — still correct, still resolving.
- **The file is renamed inside the pull request.** Out of scope here and
  the subject of `report-0031`; this spec links whatever path the run is
  already holding for that mirror.
- **The body was edited by hand.** The rewrite matches the first line's
  link, not the whole body, and leaves an unrecognised body alone rather
  than overwriting a maintainer's text.

## Tests required

- A mirror born on an open pull request links the file at the head sha,
  not the pull request's `/files` view.
- The same for a report mirror.
- A merge rewrites an existing mirror's link to the base ref, and
  changes nothing else in the body.
- A mirror created at merge is born on the base ref.
- With the head sha unreadable, the mirror is created and links the base
  ref.

## Definition of Done

- [ ] Both writers use the one helper.
- [ ] The merge rewrite lands and is covered.
- [ ] The base ref is read from the pull request, never hardcoded.
- [ ] No new `PR_*` environment name.
- [ ] `.writrun/` and `template/` byte-identical.
- [ ] Full suite green; `preflight.sh` exits 0.

## Proposed product changes

- none — the mirror's body shape is not stated in `docs/product/`, and
  this spec changes where one link points, not what a mirror is.

## Proposed technical changes

- none — no permanent doc states the link's target. The claim it has to
  keep is the sentence in the mirror itself.

## Outcome

Implemented as specified.

`mirror_issues.sh` reads the head sha and the base ref from one
`gh api repos/{repo}/pulls/{n}` call, `--jq`'d to both fields at once. No
sixth `PR_*` name. The base ref is read, never assumed.

Two helpers, not one: `file_url` decides the ref — the head sha while the
pull request is open, the base ref once it merged — and `mirror_line`
composes the whole sentence, because the sentence is what the two writers
and the merge rewrite have to agree on character for character, and a
helper that returned only the URL would have left three copies of the
prose around it. Both writers call `mirror_line`; `relink_mirror` matches
on its shape and rewrites line 1 alone.

**The fork case holds, verified against a real fork pull request** as the
spec asked. `cli/cli#14363` has head `a6cb3e85…` in `areesh-ali/cli`;
`gh api repos/cli/cli/commits/a6cb3e85…` resolves it from the base
repository, and `https://github.com/cli/cli/blob/a6cb3e85…/docs/primer/foundations/README.md`
returns **HTTP 200**. So the permalink is composed on the base repository
for a fork's pull request too, and the base-ref fallback is reserved for
the case the spec's last criterion names — a pull request whose own
record could not be read.

**A third fallback the spec did not enumerate.** Where the pull request
cannot be read at all, *neither* ref is known, so "link the base ref"
has nothing to link. The chain ends at the diff — which is exactly where
the sentence pointed before this change — rather than composing a URL
with an empty ref. A mirror that points somewhere beats one that fails to
be written.

**The host is taken from `PR_HTML_URL`**, not written as a literal: the
forge that served the pull request serves its blobs, and an adopter on an
Enterprise host has neither hardcoded.

**`adopt_mirror` now leaves the body it wrote in `ADOPTED_BODY`.** Two
writers touch one body in one pass, and without this the relink would
have PATCHed the adoption's ownership line straight back off.

**This does not reverse
[0067](../../docs/technical/decisions/pull-requests/0067-a-body-link-points-at.md),**
which rejected a head-sha permalink — for a *pull request body*, composed
by `take_task.sh` at take time on an empty branch, where there is no
commit to point at and no later writer to move the link off a superseded
revision. A mirror is born from a commit that exists and is rewritten at
merge, so both objections that entry names are answered rather than
ignored. Said in `file_url`'s header, where the next reader meets it; no
decisions entry, per this spec's Proposed technical changes.
