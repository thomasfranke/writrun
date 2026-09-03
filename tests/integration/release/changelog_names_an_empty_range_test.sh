#!/usr/bin/env bash
. "$(dirname "$0")/../../release_lib.sh"

# A tag cut with nothing behind it still gets a section: an empty heading
# would read as a section somebody forgot to fill, and the file is the
# record that this number exists.
release_setup
git tag -a v0.0.01 -m v0.0.01
out=$(bash "$RELEASE_SH" 2>&1); code=$?
if [ "$code" -eq 0 ] &&
   grep -q '^## v0.0.02 ' CHANGELOG.md &&
   grep -q 'No commit landed between this tag and the one before it\.' CHANGELOG.md &&
   [ "$(grep -c '^### ' CHANGELOG.md)" = "0" ]; then
  echo "ok    an empty range is named, never left as a bare heading"; pass=$((pass + 1))
else
  echo "FAIL  an empty range is named, never left as a bare heading"
  printf '%s\n' "$out" | sed 's/^/      | /'
  [ -f CHANGELOG.md ] && sed 's/^/      > /' CHANGELOG.md
  fail=$((fail + 1))
fi

finish
