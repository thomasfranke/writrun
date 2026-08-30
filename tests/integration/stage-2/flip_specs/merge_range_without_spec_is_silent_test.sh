#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Most merges carry no spec at all. The workflow commits only when the
# flip printed something, so silence here is what stops it pushing an
# empty commit to the base branch on every merge in the repository.
setup
printf '# Product\n\n## Scope\n\nchanged\n' > docs/product/chapter.md
commit_all
git checkout -q main
git merge -q --squash feature
git commit -qm "squash: edit a chapter"
merge=$(git rev-parse HEAD)
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/flip_approved_specs.sh" "${merge}~1...${merge}")
if [ -z "$out" ]; then
  echo "ok    a merge carrying no spec flips nothing"; pass=$((pass + 1))
else
  echo "FAIL  a merge carrying no spec flips nothing"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
