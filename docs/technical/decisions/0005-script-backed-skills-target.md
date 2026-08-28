# script-backed skills target POSIX `awk`/`sed`, never gawk extensions.

**2026-08-21**

`check_deltas.sh` originally used `match($0, re, arr)`, the
gawk-only 3-arg form, which fails on macOS's stock `/usr/bin/awk` (BWK
awk) — the default environment for a large share of adopters. Rewritten as
a portable `awk` + `sed` pipeline, and made a standing rule for both
scripts: no construct that needs gawk, tested against `/usr/bin/awk` and
not merely whatever is on `$PATH`. Rejected: declaring gawk a dependency —
a methodology whose non-goal is "not tied to one language, framework, or
agent platform" should not require a package install to verify a doc
change.
