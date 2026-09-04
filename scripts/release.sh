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
# .writrun/VERSION, sync the template, run the suite, write the
# CHANGELOG.md section for the number being cut, and only after that
# commit, tag, push, and publish the GitHub Release with notes generated
# from the conventional commits.
#
# The changelog is the same history the forge publishes, kept where a
# pinned copy can read it (docs/technical/distribution/README.md).
# It is generated here and never edited by hand: one writer is what keeps
# it from becoming a second history that agrees with the tags until
# somebody forgets.
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

# --- the changelog ---------------------------------------------------------
#
# Written after the drift guard, which aborts on any dirty path that is
# not one of the two stamps — a changelog written before it would abort
# the release it belongs to. Composed from `git log` and never from the
# forge: asking GitHub for the text would put the cut's own content
# behind a network call, and behind a tag that does not exist yet at the
# moment the file has to be staged.
#
# The subjects are trusted to be conventional because
# check_observance.sh judged them at the pull request. One that is not is
# still printed, under "other" — a release that silently dropped a line
# of its own history would be worse than one that files it oddly.

changelog_section() {   # changelog_section <tag> <range...>
  local tag="$1"; shift
  local subjects type matched other
  # One vocabulary, spelled once — the loop reads it, and the "other"
  # filter is built from it. Two copies drift. A type only one of them
  # knows matches neither group, and its subjects leave the file
  # entirely: the one thing this block promises never happens.
  local types="docs feat fix refactor chore"
  local known="${types// /|}"
  subjects=$(git log --format='%s' "$@")

  printf '## %s — %s\n\n' "$tag" "$(date -u +%Y-%m-%d)"

  if [ -z "$subjects" ]; then
    printf 'No commit landed between this tag and the one before it.\n'
    return 0
  fi

  for type in $types; do
    matched=$(printf '%s\n' "$subjects" | grep -E "^${type}(\([^)]*\))?: " || true)
    [ -n "$matched" ] || continue
    printf '### %s\n\n' "$type"
    printf '%s\n' "$matched" | sed 's/^/- /'
    printf '\n'
  done

  other=$(printf '%s\n' "$subjects" \
    | grep -Ev "^(${known})(\([^)]*\))?: " || true)
  if [ -n "$other" ]; then
    printf '### other\n\n'
    printf '%s\n' "$other" | sed 's/^/- /'
    printf '\n'
  fi
}

if [ -z "$last" ]; then
  section=$(changelog_section "$next")
else
  section=$(changelog_section "$next" "${last}..HEAD")
fi

if [ -f CHANGELOG.md ]; then
  # The new section goes above the newest one and below whatever title
  # the file opens with, so the file reads newest-first and the title is
  # written once. A file carrying no section yet has nothing to go above,
  # so the section is appended under whatever prose is there.
  #
  # `|| true` because that empty case is not a failure. grep exits 1 on no
  # match, and under `set -e` the cut would abort without a word, after
  # the suite has already run.
  first=$(grep -n '^## ' CHANGELOG.md | head -n 1 | cut -d: -f1 || true)
  tmp=$(mktemp "${TMPDIR:-/tmp}/writrun-changelog.XXXXXX")
  if [ -n "$first" ]; then
    head -n "$((first - 1))" CHANGELOG.md > "$tmp"
    printf '%s\n\n' "$section" >> "$tmp"
    tail -n "+$first" CHANGELOG.md >> "$tmp"
  else
    cat CHANGELOG.md > "$tmp"
    printf '\n%s\n' "$section" >> "$tmp"
  fi
  # Written back through the existing file, never moved over it: mktemp
  # opens 0600 and an `mv` carries that mode onto the destination, so
  # every cut after the first would leave a changelog nobody but its
  # author can read. Git records only the exec bit, so the damage is
  # invisible until somebody reads the working tree.
  cat "$tmp" > CHANGELOG.md
  rm -f "$tmp"
else
  {
    printf '# Changelog\n\n'
    printf 'Written by `make release` at every cut, from the commit subjects\n'
    printf 'the range carries. Never edited by hand — the subject is where a\n'
    printf 'wrong line is fixed, on the next tag.\n\n'
    printf '%s\n' "$section"
  } > CHANGELOG.md
fi

# The changelog joins the stamps, so one commit carries the number and
# what earned it. It always changes, which is why a re-cut that finds the
# stamp already correct still commits — the tag lands on HEAD either way.
git add .writrun/VERSION template/.writrun/VERSION CHANGELOG.md
git diff --cached --quiet || git commit -m "chore(release): $next"
git tag -a "$next" -m "$next"
git push origin main --follow-tags
gh release create "$next" --generate-notes
