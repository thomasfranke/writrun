#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# One awk body answers the front-matter question through two doors:
# ql_fm_field_in reads stdin — the shape `git show REV:path |` forces on
# a caller whose blob may legitimately be absent — and ql_fm_field is
# its file form, delegating rather than duplicating (spec-0087). The
# invariants pinned here are the ones the file door always had, asserted
# through the stdin door so a divergence between the two cannot hide.

QUEUE_LIB="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/queue_lib.sh"

# field_in <field> <fixture-file> — the stdin door's answer, <empty>
# when it prints nothing so the assertion can see the blank.
field_in() {
  bash -c '
    set -euo pipefail
    . "$0"
    v=$(ql_fm_field_in "$1" < "$2")
    printf "got=%s\n" "${v:-<empty>}"
  ' "$QUEUE_LIB" "$1" "$2"
}

# both_doors <field> <fixture-file> — the two answers side by side; the
# delegation claim is that they can never differ.
both_doors() {
  bash -c '
    set -euo pipefail
    . "$0"
    a=$(ql_fm_field_in "$1" < "$2")
    b=$(ql_fm_field "$1" "$2")
    printf "in=%s file=%s\n" "${a:-<empty>}" "${b:-<empty>}"
  ' "$QUEUE_LIB" "$1" "$2"
}

setup

cat > spec.md <<'FIX'
---
id: spec-0001
status: draft
---

# A spec whose body quotes front matter

status: implemented
FIX
printf '' > empty.md
printf 'status: loose\nno front matter here\n' > bare.md

check "a field present in the block is read" 0 \
  "got=draft" -- field_in status spec.md
check "a field the block does not carry is empty, exit 0" 0 \
  "got=<empty>" -- field_in completed spec.md
check "a body line spelling the field at column 0 never counts" 0 \
  "got=spec-0001" -- field_in id spec.md
check "empty input is an empty answer, never a failure" 0 \
  "got=<empty>" -- field_in status empty.md
check "a file with no front-matter block yields nothing" 0 \
  "got=<empty>" -- field_in status bare.md
check "the file door gives the stdin door's answer" 0 \
  "in=draft file=draft" -- both_doors status spec.md

finish
