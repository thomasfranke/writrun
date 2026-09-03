#!/usr/bin/env bash
. "$(dirname "$0")/../../release_lib.sh"

# The first cut creates the file: a title, then the section for the tag
# being cut, with each subject under its own conventional type. A subject
# that is not conventional is filed under "other" rather than dropped —
# a release that lost a line of its own history would be worse than one
# that files it oddly. The forge's `(#NN)` survives as written: it is the
# only hop an entry has back to the pull request that carried it.
release_setup
git commit -q --allow-empty -m "feat(ci): debounce the mirror updates (#42)"
git commit -q --allow-empty -m "fix(skills): rule K reads the diff"
git commit -q --allow-empty -m "docs(product): the merge is the assenting act"
git commit -q --allow-empty -m "WIP nonsense that never passed a title check"
out=$(bash "$RELEASE_SH" 2>&1); code=$?
if [ "$code" -eq 0 ] &&
   [ -f CHANGELOG.md ] &&
   grep -q '^# Changelog' CHANGELOG.md &&
   grep -q "^## v0.0.01 — $(date -u +%Y-%m-%d)$" CHANGELOG.md &&
   grep -q '^- feat(ci): debounce the mirror updates (#42)$' CHANGELOG.md &&
   grep -q '^- fix(skills): rule K reads the diff$' CHANGELOG.md &&
   grep -q '^- WIP nonsense that never passed a title check$' CHANGELOG.md &&
   [ "$(grep -c '^### ' CHANGELOG.md)" = "4" ] &&
   [ "$(grep -n '^### docs$' CHANGELOG.md | cut -d: -f1)" -lt "$(grep -n '^### feat$' CHANGELOG.md | cut -d: -f1)" ] &&
   [ "$(grep -n '^### other$' CHANGELOG.md | cut -d: -f1)" -gt "$(grep -n '^### fix$' CHANGELOG.md | cut -d: -f1)" ] &&
   git show --stat --format= HEAD | grep -q 'CHANGELOG.md'; then
  echo "ok    the first cut writes the changelog, grouped, nothing dropped"; pass=$((pass + 1))
else
  echo "FAIL  the first cut writes the changelog, grouped, nothing dropped"
  printf '%s\n' "$out" | sed 's/^/      | /'
  [ -f CHANGELOG.md ] && sed 's/^/      > /' CHANGELOG.md
  fail=$((fail + 1))
fi

finish
