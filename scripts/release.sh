#!/usr/bin/env bash
# release.sh — cut a release. Home-repository automation, never shipped
# to adopters (which is why it lives here and not in .writrun/scripts/).
#
#   release.sh [minor|major|epoch]     default: minor
#
# minor bumps the 3rd digit, major the middle one, epoch the 1st
# (historic milestones only). The next number is computed from the
# latest tag — the very first release is v0.0.01, and the third field
# stays two digits — then: stamp
# .writrun/VERSION, sync the template, run the suite, and only after
# that commit, tag, push, and publish the GitHub Release with notes
# generated from the conventional commits.
#
# Every guard aborts before anything is mutated. A failed suite — or a
# template the sync had to change beyond the version stamp — aborts
# before the commit, leaving only the stamp (and any sync output) dirty
# in the tree (`git checkout .writrun template` undoes it).
set -euo pipefail

[ "$#" -le 1 ] || { echo "release: pick one of minor|major|epoch" >&2; exit 1; }
bump="${1:-minor}"
case "$bump" in
  minor|major|epoch) ;;
  *) echo "release: pick one of minor|major|epoch" >&2; exit 1 ;;
esac

[ -z "$(git status --porcelain)" ] || { echo "release: working tree not clean" >&2; exit 1; }
[ "$(git branch --show-current)" = "main" ] || { echo "release: tags are cut from main" >&2; exit 1; }

# The cut ends at the forge (`gh release create`), which runs after the
# push — so an unusable gh must abort here, before anything is mutated,
# not fail there, after the tag is already public.
command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 \
  || { echo "release: gh must be installed and authenticated — the cut ends at the forge" >&2; exit 1; }

last="$(git tag --list 'v*' --sort=-v:refname | head -n 1)"
if [ -z "$last" ]; then
  next="v0.0.01"
else
  next="$(echo "$last" | awk -F. -v b="$bump" '{
    sub(/^v/, "")
    if (b == "epoch")      { $1++; $2 = 0; $3 = 0 }
    else if (b == "major") { $2++; $3 = 0 }
    else                   { $3++ }
    printf "v%d.%d.%02d", $1, $2, $3 }')"
fi
echo "release: ${last:-none} -> $next ($bump)"

printf '%s\n' "$next" > .writrun/VERSION
"${MAKE:-make}" template-sync

# The sync must have produced nothing but the stamp. A release records;
# it does not fix: the commit below stages only the two VERSION files,
# so any other sync output would be left behind and the tag would carry
# a template disagreeing with its own root — while looking green,
# because the suite runs against the synced working tree. Drift reaching
# main means a mirror-test failure was merged past; it gets its own
# reviewed change, not a ride on a release.
drift=$(git status --porcelain \
  | awk '$2 != ".writrun/VERSION" && $2 != "template/.writrun/VERSION"')
if [ -n "$drift" ]; then
  echo "release: the template sync changed more than the version stamp:" >&2
  printf '%s\n' "$drift" >&2
  echo "release: merge that sync through the normal flow, then release" >&2
  exit 1
fi

"${MAKE:-make}" tests

git add .writrun/VERSION template/.writrun/VERSION
git diff --cached --quiet || git commit -m "chore(release): $next"
git tag -a "$next" -m "$next"
git push origin main --follow-tags
gh release create "$next" --generate-notes
