#!/usr/bin/env bash
# harness.sh — the assertion core every fixture layers on: paths,
# counters, the check/finish pair, and the temp-dir cleanup. Case files
# never source this directly unless they need no repository at all —
# they source the fixture for their domain (pipeline_lib.sh,
# release_lib.sh, mirror_lib.sh), which sources this.
#
# No framework and no dependency beyond git and the same POSIX awk/sed
# the scripts themselves are held to.

set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TESTS_DIR/.." && pwd)"

pass=0
fail=0
WORK=""

cleanup() { [ -n "$WORK" ] && rm -rf "$WORK"; }
trap cleanup EXIT

# check <name> <expected-exit> <expected-substring-or-empty> -- <cmd...>
#
# The expectation is passed after `--`: a script whose message names the
# option it is refusing starts its output with a dash, and grep would
# read the expectation as its own flag.
check() {
  local name="$1" want_code="$2" want_text="$3"; shift 4
  local out code
  out=$("$@" 2>&1); code=$?

  if [ "$code" -ne "$want_code" ]; then
    printf 'FAIL  %s\n      expected exit %s, got %s\n' "$name" "$want_code" "$code"
    printf '%s\n' "$out" | sed 's/^/      | /'
    fail=$((fail + 1)); return
  fi
  if [ -n "$want_text" ] && ! printf '%s' "$out" | grep -q -- "$want_text"; then
    printf 'FAIL  %s\n      expected output to contain: %s\n' "$name" "$want_text"
    printf '%s\n' "$out" | sed 's/^/      | /'
    fail=$((fail + 1)); return
  fi
  printf 'ok    %s\n' "$name"
  pass=$((pass + 1))
}

# refute <name> <unwanted-substring> -- <cmd...>
#
# The mirror of check's text half, for the assertions that are about
# something a run must *not* say. Exit code is deliberately not asserted:
# every use so far is a rejection whose faults are being read, and
# pinning the code as well would make the case fail for the wrong reason
# the day a neighbouring fault changes.
refute() {
  local name="$1" unwanted="$2"; shift 3
  local out
  out=$("$@" 2>&1)

  if printf '%s' "$out" | grep -q -- "$unwanted"; then
    printf 'FAIL  %s\n      expected output NOT to contain: %s\n' "$name" "$unwanted"
    printf '%s\n' "$out" | sed 's/^/      | /'
    fail=$((fail + 1)); return
  fi
  printf 'ok    %s\n' "$name"
  pass=$((pass + 1))
}

# bounded <seconds> <cmd...> — the command under a deadline, reported as
# exit 124 when it outlives one.
#
# For the cases whose subject is a *hang*: without a deadline a
# regression does not fail one case, it stops the whole suite, and the
# run that was supposed to name the fault produces no verdict at all.
# `timeout` is GNU coreutils and this suite is held to a stock macOS, so
# the watchdog is a subshell.
bounded() {
  local secs="$1"; shift
  "$@" &
  local pid=$!
  ( sleep "$secs"; kill -9 "$pid" 2>/dev/null ) &
  local watchdog=$!
  wait "$pid"; local code=$?
  kill "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null
  # A killed process reports its signal; the deadline is the only signal
  # these cases can produce, so it is named rather than passed through.
  [ "$code" -ge 128 ] && return 124
  return "$code"
}

# finish — every case file's last line: exit with the case's verdict.
finish() { [ "$fail" -eq 0 ]; exit $?; }
