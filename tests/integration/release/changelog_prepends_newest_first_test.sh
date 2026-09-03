#!/usr/bin/env bash
. "$(dirname "$0")/../../release_lib.sh"

# A second cut goes above the first and below the title, so the file
# reads newest-first and the title is written once. The older section is
# left exactly as it was — history is appended to, never rewritten.
release_setup
cat > CHANGELOG.md <<'MD'
# Changelog

Written by `make release` at every cut.

## v0.0.01 — 2026-01-01

### feat

- feat(ci): the first thing that ever shipped
MD
git add CHANGELOG.md >/dev/null
git commit -qm "chore(release): v0.0.01"
# The tag names the release commit, as a real cut leaves it — so the
# previous release's own commit is behind the range, not inside it.
git tag -a v0.0.01 -m v0.0.01
git commit -q --allow-empty -m "fix(ci): the second thing"
out=$(bash "$RELEASE_SH" 2>&1); code=$?
new_line=$(grep -n '^## v0.0.02 ' CHANGELOG.md | cut -d: -f1)
old_line=$(grep -n '^## v0.0.01 — 2026-01-01$' CHANGELOG.md | cut -d: -f1)
if [ "$code" -eq 0 ] &&
   [ -n "$new_line" ] && [ -n "$old_line" ] &&
   [ "$new_line" -lt "$old_line" ] &&
   [ "$(grep -c '^# Changelog$' CHANGELOG.md)" = "1" ] &&
   grep -q '^- fix(ci): the second thing$' CHANGELOG.md &&
   grep -q '^- feat(ci): the first thing that ever shipped$' CHANGELOG.md &&
   ! grep -q '^- chore(release): v0.0.01$' CHANGELOG.md; then
  echo "ok    a later cut prepends its section and leaves the older one alone"; pass=$((pass + 1))
else
  echo "FAIL  a later cut prepends its section and leaves the older one alone"
  printf '%s\n' "$out" | sed 's/^/      | /'
  [ -f CHANGELOG.md ] && sed 's/^/      > /' CHANGELOG.md
  fail=$((fail + 1))
fi

finish
