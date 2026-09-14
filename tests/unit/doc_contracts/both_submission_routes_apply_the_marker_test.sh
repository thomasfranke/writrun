#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The marker is applied by the routes that already exist, never by the
# machinery reading an issue's contents — the form, because a form can,
# and the kit's routing instruction, because it says to
# (docs/product/stage-3-github-issues/intake.md#submitted-and-not-yet-a-report).
#
# **Neither route has a runtime signal.** A form that stops setting the
# label goes on opening issues; an instruction that stops passing it goes
# on being followed. Nothing goes red, and the lister quietly names an
# empty set — which is the state issue #155 was already in when its
# evidence never left the forge. So the two routes are read here, and so
# is the one spelling they have to share with the three places that
# declare, read and remove it.
FORM="$REPO_ROOT/.github/ISSUE_TEMPLATE/writrun-report.yml"
KIT_AGENTS="$REPO_ROOT/.writrun/AGENTS.md"
MIRROR="$REPO_ROOT/.writrun/scripts/stage-3-github-issues/mirror_issues.sh"
INTAKE="$REPO_ROOT/.writrun/scripts/stage-3-github-issues/intake_report.sh"
LISTER="$REPO_ROOT/.writrun/skills/writrun-select-next-task/list_tasks.sh"

# The form's own `labels:` key, at the top level where GitHub reads it —
# not a mention of the word anywhere in the file. The block below the
# key belongs to the fields, and a label named in a field's description
# is prose.
label=$(awk '
  /^labels:/ { print; exit }
' "$FORM" | grep -o 'writrun:[a-z][a-z]*' | head -n1)

if [ "$label" = "writrun:submitted" ]; then
  echo "ok    the report form applies the marker"
  pass=$((pass + 1))
else
  printf 'FAIL  the report form applies the marker\n      %s carries no top-level labels: with writrun:submitted\n' \
    "${FORM#"$REPO_ROOT"/}"
  fail=$((fail + 1))
fi
[ -n "$label" ] || label="writrun:submitted"

# The other route: the kit's instruction, where the flag has to reach
# `gh issue create` itself. A sentence about the marker with no flag on
# the command is an agent opening an unmarked issue.
if grep -q -- "gh issue create --label ${label}" "$KIT_AGENTS"; then
  echo "ok    the kit's routing instruction passes the marker to gh issue create"
  pass=$((pass + 1))
else
  printf 'FAIL  the kit routing instruction passes the marker\n      .writrun/AGENTS.md does not pass --label %s to gh issue create\n' \
    "$label"
  fail=$((fail + 1))
fi

# One spelling, four more places. A label the form applies and the
# machinery misspells is the same silence read from the other end.
spelled() {   # spelled <name> <file>
  if grep -qF -- "$label" "$2"; then
    echo "ok    $1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      %s never spells %s\n' "$1" "${2#"$REPO_ROOT"/}" "$label"
    fail=$((fail + 1))
  fi
}
spelled "the label is declared before anything applies it" "$MIRROR"
spelled "the intake removes it when it mints the report" "$INTAKE"
spelled "and the lister asks the forge for it" "$LISTER"

finish
