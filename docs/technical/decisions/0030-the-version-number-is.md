# the version number is computed, never typed.

**2026-08-23**

`make
release` derives the next tag from the last one and walks the whole
path — stamp `.writrun/VERSION`, sync the template, run the suite,
commit, tag, push, publish the GitHub Release with generated notes — so
a bad tag (dirty tree, wrong branch, unsynced mirror, red suite) is
unrepresentable rather than forbidden. The bump vocabulary is WritRun's
own, not SemVer's: `minor` moves the third digit, `major` the middle
one, and `epoch` — a name with prior art in Debian and RPM — the first,
reserved for historic milestones. The stamp travels with the kit and is
the anchor `writ update` will diff from. The release path is tested at
two depths: an integration suite drives `scripts/release.sh` against a
local bare origin with `make` and `gh` stubbed, and one e2e case runs
the real `make release` in a throwaway copy of this whole repository —
real sync, real suite nested inside (an env guard stops the
recursion), real push to a bare origin, only the forge faked.
Rejected: standard SemVer
naming (patch/minor/major — the day-to-day release deserved the humble
word, and the first digit needed something above `major`), a version
argument typed by hand (derivable numbers drift when typed), a
maintained CHANGELOG file (release notes are generated from the
conventional commits), and shipping the automation to adopters in the
kit — **an adopting project's versioning is not WritRun's business**,
out of scope entirely: each repository versions however it likes, and
`.writrun/VERSION` in an adopter already means the kit's own tag, not
the project's version. The maintainer's own repositories sharing this
same scheme is a personal-tooling concern, solved outside WritRun: the
plan is a small standalone repository (the core — guards, bump, tag,
push, forge release — calling an optional per-repo `release-prepare`
hook), extracted from this script once a second consumer exists;
WritRun's home repo will then consume it like any other project.
