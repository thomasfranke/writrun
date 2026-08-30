#!/usr/bin/env bash
# level_gate.sh — does this project's adoption level reach far enough for
# the job about to run?
#
# Usage: level_gate.sh <required-level>
#   Run from the repository root. Writes `run=true|false` to $GITHUB_OUTPUT
#   when that variable is set, so the steps after it can be guarded with
#   `if: steps.gate.outputs.run == 'true'`.
#
# The levels are ordered and cumulative, which is why one value gates four
# workflows: `github-issues` without `pull-requests` would ask for a
# projection that pull-request events drive, with no pull requests to drive
# it (product/adoption.md#three-stages).
#
#   tasks-and-specs   no workflow runs
#   pull-requests     writrun check, writrun approve
#   github-issues     adds writrun issues, writrun progress
#
# **The setting is what stops the machinery, not deleting the files.** They
# stay installed and inert — one way to say a thing rather than two free to
# disagree, which is the reversal of 0041 this implements.
#
# It always exits 0. A gate that failed the job would report "did not run"
# as a red check, and a project that chose a lower level did nothing wrong.
# It says why instead, every time, so a silent absence is never mistaken
# for a silent success.
#
# Exit codes: 0 always, except 3 for a usage error.
#
# Portable bash 3.2, POSIX awk/sed. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail

NEED="${1:-}"
case "$NEED" in
  tasks-and-specs|pull-requests|github-issues) ;;
  *) echo "usage: level_gate.sh <tasks-and-specs|pull-requests|github-issues>" >&2; exit 3 ;;
esac

ordinal() {
  case "$1" in
    tasks-and-specs) printf '1' ;;
    pull-requests)   printf '2' ;;
    github-issues)   printf '3' ;;
    *)               printf '0' ;;
  esac
}

HERE=$(bash "$(dirname "$0")/read_setting.sh" level)

if [ "$(ordinal "$HERE")" -eq 0 ]; then
  echo "level '${HERE}' is outside the vocabulary; reading it as the" >&2
  echo "documented default. check_settings.sh is what names that fault." >&2
  HERE=github-issues
fi

report() { [ -n "${GITHUB_OUTPUT:-}" ] && printf 'run=%s\n' "$1" >> "$GITHUB_OUTPUT"; return 0; }

if [ "$(ordinal "$HERE")" -ge "$(ordinal "$NEED")" ]; then
  echo "level is '${HERE}', which reaches '${NEED}' — running."
  report true
  exit 0
fi

echo "level is '${HERE}', which stops below '${NEED}' — not running."
echo "This job is off because .writrun/conventions/settings.json says so,"
echo "not because anything failed. Raise 'level' to turn it on"
echo "(docs/product/adoption.md#three-stages)."
report false
