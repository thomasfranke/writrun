# `new.sh` reads git history, not only the filesystem, when assigning an id.

**2026-08-22**

An id must never be reused, including after its file
was deleted — and a deleted file is invisible to a directory scan, so
filesystem-only assignment hands the next task an id the history still
refers to. It therefore also asks `git log --diff-filter=A` for every id
the directory ever held. Outside a git repository the filesystem is the
whole answer, which is correct there: nothing was deleted from a history
that does not exist. Rejected: a counter file — a second source of truth
for something the history already records exactly.
