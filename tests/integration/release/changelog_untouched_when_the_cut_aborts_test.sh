#!/usr/bin/env bash
. "$(dirname "$0")/../../release_lib.sh"

# Every guard aborts before the changelog is written, and the two that
# can fire after the stamp are read here: the sync that changed more than
# the stamp, and the red suite. The file the cut would have written is
# the record of a release that happened — an aborted cut leaves it
# exactly as it found it.
release_setup
printf '# Changelog\n\n## v0.0.01 — 2026-01-01\n\n### feat\n\n- feat(ci): shipped\n' > CHANGELOG.md
git add CHANGELOG.md >/dev/null
git commit -qm "chore: changelog"
# Tagged, so the cut under test is a second one and the number it would
# write is v0.0.02 — a string the seeded file cannot already hold.
git tag -a v0.0.01 -m v0.0.01
before=$(git log -1 --format=%H)
# The whole file, hashed: the assertion is every byte, not one string a
# rewrite could leave standing.
before_file=$(git hash-object CHANGELOG.md)
printf '#!/usr/bin/env bash\necho "make $*" >> "%s/calls.log"\ntouch "%s/repo/template/stray.md"\n' "$WORK" "$WORK" > "$WORK/stub-bin/make"
chmod +x "$WORK/stub-bin/make"
out=$(bash "$RELEASE_SH" 2>&1); code=$?
drift_ok=false
if [ "$code" -ne 0 ] &&
   printf '%s' "$out" | grep -q 'changed more than the version stamp' &&
   [ "$(git hash-object CHANGELOG.md)" = "$before_file" ] &&
   [ "$(git log -1 --format=%H)" = "$before" ]; then
  drift_ok=true
fi

rm -f "$WORK/repo/template/stray.md"
git checkout -q -- .writrun/VERSION template/.writrun/VERSION 2>/dev/null || true
printf '#!/usr/bin/env bash\necho "make $*" >> "%s/calls.log"\n[ "$1" = "tests" ] && exit 1\nexit 0\n' "$WORK" > "$WORK/stub-bin/make"
chmod +x "$WORK/stub-bin/make"
out2=$(bash "$RELEASE_SH" 2>&1); code2=$?
suite_ok=false
if [ "$code2" -ne 0 ] &&
   [ "$(git hash-object CHANGELOG.md)" = "$before_file" ] &&
   [ "$(git log -1 --format=%H)" = "$before" ] &&
   [ "$(git tag --list)" = "v0.0.01" ]; then
  suite_ok=true
fi

if [ "$drift_ok" = true ] && [ "$suite_ok" = true ]; then
  echo "ok    an aborted cut leaves the changelog exactly as it found it"; pass=$((pass + 1))
else
  echo "FAIL  an aborted cut leaves the changelog exactly as it found it (drift=$drift_ok suite=$suite_ok)"
  printf '%s\n' "$out" | sed 's/^/      | /'
  printf '%s\n' "$out2" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
