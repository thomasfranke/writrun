#!/usr/bin/env bash
# commit_subject.sh — prints the subject of a commit the machinery makes,
# in the style the settings file declares.
#
# Usage: commit_subject.sh <merge|forge>
#   Run from the repository root; the paths are relative to it.
#
#   commit_subject.sh merge    what `writrun approve` records after a merge
#   commit_subject.sh forge    what `writrun progress` records from an event
#
# **The machinery obeys the declaration it asks agents to keep.** With
# `pr_title_style: bracketed` stated, a literal `chore(queue): ...` in a
# workflow writes the other style onto `main` permanently — nothing
# squashes these, so they are the one place a disobedient subject cannot
# be fixed later. Two workflows write them, which is why the subject is
# composed here and not in either: one place, two callers, no drift
# (docs/technical/README.md#pr_title_style).
#
# It is not checked anywhere, and could not usefully be: `writrun check`
# reads pull request titles at the door, and these commits pass no door.
# What replaces the check is having one writer.
#
# The scope is `queue`, in both styles — these commits record what
# happened to `work/`, and nothing else (.writrun/conventions/commits.md).
#
# Exit codes: 0 always, except 3 for a usage error.
#
# Portable bash 3.2, POSIX awk/sed. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail

EVENT="${1:-}"
case "$EVENT" in
  merge|forge) ;;
  *) echo "usage: commit_subject.sh <merge|forge>" >&2; exit 3 ;;
esac

# The reader is the sibling next to this file, resolved from this
# script's own location: the settings file is found relative to the
# working directory, but the script that reads it is found relative to
# the kit, and a workflow is not the only caller.
HERE="$(cd "$(dirname "$0")" && pwd)"
STYLE=$(bash "$HERE/read_setting.sh" stage_2.pr_title_style)

# The sentence is one text per event; only its dress changes. Written
# twice rather than case-converted, because a summary is prose and the
# two styles capitalise it differently — deriving one from the other
# would make the machinery guess at English.
case "$EVENT:$STYLE" in
  merge:bracketed) printf '[Chore][Queue] Record what the merge decided\n' ;;
  merge:*)         printf 'chore(queue): record what the merge decided\n' ;;
  forge:bracketed) printf '[Chore][Queue] Record what the forge just did\n' ;;
  forge:*)         printf 'chore(queue): record what the forge just did\n' ;;
esac
