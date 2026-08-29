#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The gate is only a gate if it is wired. A script that answers correctly
# while a job runs anyway is the failure this case exists to catch, and it
# is the one thing about the level that the suite cannot observe by
# running a script: the wiring lives in YAML, so it is read as text.
setup

gated() {   # gated <workflow> <required-level>
  local f="$WORKFLOWS/$1" name="$1"
  if ! grep -q "level_gate.sh $2$" "$f"; then
    printf 'FAIL  %s gates on %s\n' "$name" "$2"; fail=$((fail + 1)); return
  fi
  printf 'ok    %s gates on %s\n' "$name" "$2"; pass=$((pass + 1))

  # Every job except the gate itself waits on it. Job keys are the lines
  # indented exactly two spaces and ending in a colon, under `jobs:`.
  local jobs ungated
  jobs=$(awk '/^jobs:$/ { inj = 1; next } inj && /^  [a-z][a-z0-9_-]*:$/ {
      sub(/:$/, ""); sub(/^  /, ""); print }' "$f")
  ungated=""
  for j in $jobs; do
    [ "$j" = "gate" ] && continue
    awk -v job="  $j:" '
      $0 == job { inj = 1; next }
      inj && /^  [a-z]/ { exit }
      inj && /needs: gate/ { found = 1 }
      END { exit(found ? 0 : 1) }
    ' "$f" || ungated="$ungated $j"
  done
  if [ -n "$ungated" ]; then
    printf 'FAIL  every %s job waits on the gate\n      ungated:%s\n' \
      "$name" "$ungated"
    fail=$((fail + 1))
  else
    printf 'ok    every %s job waits on the gate\n' "$name"; pass=$((pass + 1))
  fi
}

gated writrun-check.yml pull-requests
gated writrun-approve.yml pull-requests
gated writrun-issues.yml github-issues
gated writrun-progress.yml github-issues

finish
