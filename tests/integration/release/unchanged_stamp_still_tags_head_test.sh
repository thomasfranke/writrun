#!/usr/bin/env bash
. "$(dirname "$0")/../../release_lib.sh"

# When the stamp already holds the next number (a release re-cut after a
# failed push), the stamp has nothing to add — and the cut still commits,
# because the changelog section for this tag is new. The tag lands on
# HEAD either way, which is what this case exists to hold.
release_setup
printf 'v0.0.01\n' > .writrun/VERSION
printf 'v0.0.01\n' > template/.writrun/VERSION
git add -A >/dev/null
git commit -qm "pre-stamped"
before=$(git rev-list --count HEAD)
out=$(bash "$RELEASE_SH" 2>&1); code=$?
if [ "$code" -eq 0 ] &&
   [ "$(git rev-list --count HEAD)" = "$((before + 1))" ] &&
   [ "$(git describe --tags)" = "v0.0.01" ] &&
   git show --stat --format= HEAD | grep -q 'CHANGELOG.md' &&
   [ "$(git show HEAD:.writrun/VERSION)" = "v0.0.01" ]; then
  echo "ok    an unchanged stamp still commits, for the changelog, and tags HEAD"; pass=$((pass + 1))
else
  echo "FAIL  an unchanged stamp still commits, for the changelog, and tags HEAD"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
