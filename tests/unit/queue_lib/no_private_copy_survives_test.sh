#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# No private copy of the shared helpers survives under .writrun/scripts
# — the regression spec-0087 exists to make impossible to reintroduce
# quietly. The clone family bit three times before the fold (the two
# incidents queue_lib.sh's header records, and the bare-ref bug
# spec-0084 had to find in one copy out of three). git_read and the
# range parse are pinned by name; the field reader is pinned by its awk
# body, because the name is worn by an honest stranger too —
# mirror_issues.sh reads fields from delimiter-stripped front-matter
# text, a different question — and a body cannot be renamed past a
# grep the way a name can. A clone with a new name AND a new body is
# what decision 0072 refuses — a grep cannot see what it does not know.

SCRIPTS="$REPO_ROOT/.writrun/scripts"

# survivors — every private definition found, or "clean"; non-zero on a
# find so the check fails loudly with the paths in its output.
survivors() {
  local hits
  hits=$(
    grep -rn '^git_read() {' "$SCRIPTS" 2>/dev/null
    grep -rln 'sub("^" f ": \*", "")' "$SCRIPTS" 2>/dev/null \
      | grep -v '/queue_lib.sh$'
    grep -rln 'merge-base "${left:-HEAD}"' "$SCRIPTS" 2>/dev/null \
      | grep -v '/queue_lib.sh$'
    true
  )
  if [ -n "$hits" ]; then
    printf '%s\n' "$hits"
    return 1
  fi
  echo clean
}

check "no private git_read, range parse or fm_field remains" 0 \
  "clean" -- survivors

finish
