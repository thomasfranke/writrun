#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A red main that a script can fix is the bot's to fix: a drifted
# kit ends synced, committed, and pushed; no drift commits nothing;
# a push that fails is loud (docs/technical/README.md#distribution).
HEAL="$REPO_ROOT/.github/scripts/readiness_heal.sh"

setup
# A bare remote standing in for origin/main.
git checkout -q main
mkdir -p kit/kit
printf 'kit v1\n' > kit/kit/file.txt
git add -A >/dev/null; git commit -qm "kit baseline"
remote=$(mktemp -d); git clone -q --bare . "$remote"
git remote add origin "$remote"

check "no drift heals nothing" 0 "no drift — nothing to heal" \
  -- bash "$HEAL" main

printf 'kit v2\n' > kit/kit/file.txt
check "a drifted kit is committed and pushed" 0 "healed — kit sync committed to main" \
  -- bash "$HEAL" main
if git --git-dir="$remote" log -1 --format=%s main | grep -q "chore(setup): sync the kit"; then
  echo "ok    the heal reached the remote"; pass=$((pass+1))
else
  echo "FAIL  the heal reached the remote"; fail=$((fail+1))
fi

# A file the sync CREATES is drift too — git diff alone cannot see it.
printf 'brand new\n' > kit/kit/new_file.txt
check "a created file under the kit is healed" 0 "healed — kit sync committed to main" \
  -- bash "$HEAL" main
if git --git-dir="$remote" show main:kit/kit/new_file.txt >/dev/null 2>&1; then
  echo "ok    and the new file reached the remote"; pass=$((pass+1))
else
  echo "FAIL  and the new file reached the remote"; fail=$((fail+1))
fi

git remote remove origin
printf 'kit v3\n' > kit/kit/file.txt
check "a heal that cannot push is loud, not shrugged at" 1 "" \
  -- bash "$HEAL" main
rm -rf "$remote"

finish
