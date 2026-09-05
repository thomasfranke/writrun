#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The re-read saving is declared, never assumed — and the declarations
# are wiring, which the suite cannot observe by running a script. The
# approve label step names its mints behind `--minted` only where the
# mint succeeded; where it failed it passes no flag, so a mirror the
# mint created before failing is still healed by the unconditional
# re-read. `project_pr_tasks.sh` mints nothing and says so with the
# empty flag. The contract fails open where nothing asserts it, which
# is why this case may live in this repository alone.
setup

APPROVE="$WORKFLOWS/writrun-approve.yml"
PROJECT="$REPO_ROOT/.writrun/scripts/stage-3-github-issues/project_pr_tasks.sh"

wired() {   # wired <name> <file> <pattern> <count>
  local n
  n=$(grep -cF -- "$3" "$2")
  if [ "$n" -eq "$4" ]; then
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected %s lines containing: %s (got %s)\n' \
      "$1" "$4" "$3" "$n"
    fail=$((fail + 1))
  fi
}

# The gate reads the mint's own outcome, through env like every other
# value this workflow hands to a shell.
wired "the flag is gated on the mint's outcome" \
  "$APPROVE" 'MINT_OUTCOME: ${{ steps.mint.outcome }}' 1
wired "and only success passes it" \
  "$APPROVE" '"$MINT_OUTCOME" = "success"' 1

# One argv, two contracts: the succeeded mint names its mints, the
# failed one says nothing and buys the re-read back.
wired "a mint that succeeded names its mints" \
  "$APPROVE" '--minted $MINTED_TASKS $MINTED_REPORTS' 1
# And the flag is *appended* under that gate, never built into the argv
# the step always passes — which is what "a failed mint passes no flag"
# means when there is one invocation. Read the step's shell, comments
# aside: `--minted` reaches the argv between the gate and its `fi`, and
# nowhere else.
if awk '
    /^[[:space:]]*#/ { next }
    /\$MINT_OUTCOME" = "success"/ { gate = 1; next }
    gate && /^[[:space:]]*fi[[:space:]]*$/ { gate = 0; next }
    /--minted/ { if (gate) inside++; else outside++ }
    END { exit(inside == 1 && outside == 0 ? 0 : 1) }
  ' "$APPROVE"; then
  printf 'ok    a mint that failed passes no flag\n'; pass=$((pass + 1))
else
  printf 'FAIL  a mint that failed passes no flag\n'; fail=$((fail + 1))
fi

# The pull-request path mints nothing and declares exactly that.
wired "project_pr_tasks declares its empty flag" \
  "$PROJECT" '$carried --minted' 1

finish
