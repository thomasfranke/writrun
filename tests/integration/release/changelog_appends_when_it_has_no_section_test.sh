#!/usr/bin/env bash
. "$(dirname "$0")/../../release_lib.sh"

# A changelog that exists but carries no section yet — a title and the
# prose under it — has nothing to prepend above, so the section lands at
# the end. The alternative is not a misplaced section: the search for the
# first heading finds nothing, and a cut that treated that as a failure
# would die without a word, with the suite already run and the stamp
# already dirty.
release_setup
cat > CHANGELOG.md <<'MD'
# Changelog

Written by `make release` at every cut.
MD
git add CHANGELOG.md >/dev/null
git commit -qm "docs(technical): the changelog opens"
git tag -a v0.0.01 -m v0.0.01
git commit -q --allow-empty -m "fix(ci): the thing this tag carries"
out=$(bash "$RELEASE_SH" 2>&1); code=$?
title_line=$(grep -n '^# Changelog$' CHANGELOG.md | cut -d: -f1)
new_line=$(grep -n '^## v0.0.02 ' CHANGELOG.md | cut -d: -f1)
if [ "$code" -eq 0 ] &&
   [ -n "$title_line" ] && [ -n "$new_line" ] &&
   [ "$new_line" -gt "$title_line" ] &&
   grep -q '^Written by `make release` at every cut\.$' CHANGELOG.md &&
   grep -q '^- fix(ci): the thing this tag carries$' CHANGELOG.md &&
   git show --stat --format= HEAD | grep -q 'CHANGELOG.md'; then
  echo "ok    a file with no section yet gains one under the prose it opens with"; pass=$((pass + 1))
else
  echo "FAIL  a file with no section yet gains one under the prose it opens with"
  printf '%s\n' "$out" | sed 's/^/      | /'
  [ -f CHANGELOG.md ] && sed 's/^/      > /' CHANGELOG.md
  fail=$((fail + 1))
fi

finish
