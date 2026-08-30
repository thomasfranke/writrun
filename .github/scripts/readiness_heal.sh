#!/usr/bin/env bash
# readiness_heal.sh — the heal phase of release readiness: when the
# regeneration changed the template, commit it and push; when it changed
# nothing, say so and touch nothing. Red stays reserved for what a
# script cannot fix (docs/technical/README.md#distribution).
#
# Usage: readiness_heal.sh <remote-branch>
#   Run from the repository root after `make template-sync`. Pushes with
#   the rebase-not-force pattern the queue recording uses. This file is
#   this repository's own CI, never shipped in the kit.
#
# Exit codes: 0 healed or nothing to heal; non-zero when git could not
# commit or push — a heal that failed must be seen, not shrugged at.

set -euo pipefail

BRANCH="${1:?usage: readiness_heal.sh <remote-branch>}"

if git diff --quiet -- template; then
  echo "no drift — nothing to heal"
  exit 0
fi

git config user.name  "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add template
git commit -m "chore(template): sync the kit with the root it mirrors" \
  -m "Healed by release readiness; red is for what a script cannot fix."
# Another recording may have landed since checkout. Rebase onto it
# rather than force: the heal is an addition to the branch's history,
# never a replacement of it.
git pull --rebase origin "$BRANCH"
git push origin "HEAD:${BRANCH}"
echo "healed — template sync committed to ${BRANCH}"
