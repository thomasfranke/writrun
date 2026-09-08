#!/usr/bin/env bash
# Sources the harness directly: the sync needs a directory tree, not a
# git repository.
. "$(dirname "$0")/../../harness.sh"

SYNC="$REPO_ROOT/scripts/sync_template.sh"

# The kit differs from the root in one file on purpose, and the mirror
# list names the *directory* it lives in — so the exception is inside a
# tree the sync removes wholesale before copying. Declining to overwrite
# would not save it; it is stashed and restored, and named in the output.
WORK=$(mktemp -d); cd "$WORK" || exit 1
mkdir -p a-dir/nested template/a-dir/nested
printf 'the root\n'    > a-dir/nested/settings.json
printf 'the root\n'    > a-dir/other.txt
printf 'the kit own\n' > template/a-dir/nested/settings.json
printf 'a-dir\n'                     > mirrors.txt
printf 'a-dir/nested/settings.json\n' > exceptions.txt

check "the sync names what it kept" 0 "kept    a-dir/nested/settings.json" \
  -- bash "$SYNC" mirrors.txt exceptions.txt

if [ "$(cat template/a-dir/nested/settings.json)" = "the kit own" ]; then
  echo "ok    the exception survives a directory mirror"; pass=$((pass + 1))
else
  echo "FAIL  the exception survives a directory mirror"
  echo "      | template holds: $(cat template/a-dir/nested/settings.json)"
  fail=$((fail + 1))
fi

if [ "$(cat template/a-dir/other.txt)" = "the root" ]; then
  echo "ok    and everything beside it still mirrors"; pass=$((pass + 1))
else
  echo "FAIL  and everything beside it still mirrors"; fail=$((fail + 1))
fi

# Twice is the real test: the first run could have been the copy landing
# before anything was deleted.
bash "$SYNC" mirrors.txt exceptions.txt >/dev/null 2>&1
if [ "$(cat template/a-dir/nested/settings.json)" = "the kit own" ]; then
  echo "ok    and survives a second sync"; pass=$((pass + 1))
else
  echo "FAIL  and survives a second sync"; fail=$((fail + 1))
fi

# An exception the kit does not carry yet arrives from the root like any
# other path — reported as adopted, never guessed at.
rm -f template/a-dir/nested/settings.json
check "an exception the kit lacks is adopted, and said so" 0 \
  "adopted a-dir/nested/settings.json" \
  -- bash "$SYNC" mirrors.txt exceptions.txt

finish
