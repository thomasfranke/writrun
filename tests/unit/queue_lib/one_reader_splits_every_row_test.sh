#!/usr/bin/env bash
# The point of the shared reader is that the class is closed, and a class
# is only closed while the next caller joins it. `IFS="$TAB" read` is
# what three of these scripts used to do, it is what the fourth still
# does, and it is what somebody adding a fifth would copy from whichever
# neighbour they read first. So it is caught here rather than at a
# deleted account.
#
# take_task.sh is the named exception, not an oversight. It is a fourth
# caller and it belongs on the reader, and moving the act that opens
# every pull request in this repository is regression risk that does not
# ride a defect fix — it has a report of its own. The exception is listed
# by name so that retiring it means editing this line.
. "$(dirname "$0")/../../harness.sh"

SCRIPTS="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests"
EXEMPT="take_task.sh"

offenders=""
for f in "$SCRIPTS"/*.sh; do
  base=$(basename "$f")
  case " $EXEMPT " in *" $base "*) continue ;; esac
  # Comment lines are dropped first: the headers that explain this
  # hazard spell it out, and a reading that counted prose would report
  # every script that documents the fault as committing it.
  #
  # Both spellings of the same mistake are caught: the TAB a script
  # computed once, and the one interpolated at the read.
  # The stripped text is captured before it is searched, never piped
  # into `grep -q`: a quiet grep closes the pipe on its first match, and
  # GNU sed reports the broken pipe as a failure while BSD sed does not.
  # Under `set -o pipefail` that made this case pass on macOS and fail on
  # Linux CI, on the strength of which script matched first.
  stripped=$(sed 's/^[[:space:]]*#.*$//' "$f")
  if printf '%s\n' "$stripped" \
     | grep -qE 'IFS="?\$\{?(TAB|QL_TAB)\}?"? +read|IFS="\$\(printf .\\t.\)" +read'; then
    offenders="${offenders}${base} "
  fi
done

if [ -z "$offenders" ]; then
  echo "ok    no listing caller splits a row with a bare IFS=TAB read"
  pass=$((pass + 1))
else
  printf 'FAIL  these parse tab rows with read instead of ql_row_fields: %s\n' "${offenders% }"
  fail=$((fail + 1))
fi

# And the exemption is real: a name left here after the script stopped
# offending would quietly exempt whatever takes its place.
exempt_text=$(sed 's/^[[:space:]]*#.*$//' "$SCRIPTS/take_task.sh")
if printf '%s\n' "$exempt_text" \
   | grep -qE 'IFS="\$\(printf .\\t.\)" +read'; then
  echo "ok    the one exemption still names a script that needs it"
  pass=$((pass + 1))
else
  echo "FAIL  take_task.sh no longer parses rows itself — drop it from EXEMPT"
  fail=$((fail + 1))
fi

finish
