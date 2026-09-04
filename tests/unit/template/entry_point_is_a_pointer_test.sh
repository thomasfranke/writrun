#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The kit's claim on an adopting project's AGENTS.md is the four-line
# pointer and nothing else (adoption.md#the-entry-point-is-the-projects).
# The failures this guard exists for: the entry point regrowing the
# writrun:begin markers the ownership split retired, the pointer
# dropping the file it names, the pointer becoming an import, the
# claimed section regrowing the flow or the gates table that moved out,
# and the CLAUDE.md shim growing beyond the one import line Claude Code
# needs.

ENTRY="$REPO_ROOT/template/AGENTS.md"
FLOW="$REPO_ROOT/template/.writrun/AGENTS.md"
GATES="$REPO_ROOT/template/.writrun/gates.md"
SHIM="$REPO_ROOT/template/CLAUDE.md"

# writrun_section <entry-file> — the lines WritRun claims: from the
# `## WritRun` heading to the next top-level heading, or the end.
writrun_section() {
  awk '/^## WritRun/ { inside = 1; next } inside && /^## / { inside = 0 } inside' "$1"
}

# pointer_faults <entry-file> — every way an entry point breaks the
# claim, named. Empty output is the pass. Built to report by name rather
# than to return a verdict, so the same reading serves the kit's real
# file and the scratch files that prove the guard bites.
pointer_faults() {
  local entry="$1" section
  [ -f "$entry" ] || { printf '!no-entry-point '; return; }

  grep -qE 'writrun:(begin|end)' "$entry" && printf 'graft-marker '
  grep -q '\.writrun/AGENTS\.md' "$entry" || printf 'names-no-flow-file '

  # The pointer is a link, never an import: an @-reference chain-loads
  # the whole flow into every Claude session through the shim. Every
  # spelling of the path is the same import — `@.writrun/…` and
  # `@./.writrun/…` reach the file alike, so the match is on any
  # @-token ending in the flow file rather than on one written form.
  grep -qE '(^|[^`[:alnum:]])@[[:alnum:]._/-]*writrun/AGENTS\.md' "$entry" \
    && printf 'pointer-is-an-import '

  section=$(writrun_section "$entry")
  [ -n "$section" ] || { printf '!no-writrun-section '; return; }

  # "The pointer and nothing else" is a size, and nothing checked it: a
  # marker-free file passes every other reading here while carrying the
  # whole flow back. Flow prose returns as sub-headings, the gates that
  # moved to gates.md return as a table, and either way the section
  # outgrows what four lines can hold.
  printf '%s\n' "$section" | grep -qE '^#{3,} ' && printf 'section-has-subheadings '
  printf '%s\n' "$section" | grep -qE '^\|' && printf 'section-has-a-table '
  [ "$(printf '%s\n' "$section" | grep -c '[^[:space:]]')" -le 6 ] \
    || printf 'section-outgrew-the-pointer '
}

out=$(pointer_faults "$ENTRY")
if [ -z "$out" ]; then
  echo "ok    the entry point is the pointer and nothing else"; pass=$((pass + 1))
else
  echo "FAIL  the entry point is the pointer and nothing else"
  echo "      faults: $out"
  fail=$((fail + 1))
fi

if [ -f "$FLOW" ] && grep -q 'gates\.md' "$FLOW"; then
  echo "ok    the flow file ships and reaches the project's answers via gates.md"; pass=$((pass + 1))
else
  echo "FAIL  the flow file ships and reaches the project's answers via gates.md"
  fail=$((fail + 1))
fi

if [ -f "$GATES" ] && grep -q 'TODO' "$GATES"; then
  echo "ok    the gates file ships as the TODO skeleton, not somebody's answers"; pass=$((pass + 1))
else
  echo "FAIL  the gates file ships as the TODO skeleton, not somebody's answers"
  fail=$((fail + 1))
fi

# Every gate the flow routes through gates.md has a row in the shipped
# skeleton: a gate the kit never asks about is one the adopter answers
# by accident. report-0019's `tracked` row shipped missing, and the
# flow's own rule makes an unnamed gate a stall.
missing=""
for gate in 'docs/' 'approved' 'spec_ref' 'Derived work' 'settings' 'tracked'; do
  grep -qF "$gate" "$GATES" || missing="$missing$gate "
done
if [ -z "$missing" ]; then
  echo "ok    every gate the flow routes through gates.md has a row to fill"; pass=$((pass + 1))
else
  echo "FAIL  every gate the flow routes through gates.md has a row to fill"
  echo "      no row for: $missing"
  fail=$((fail + 1))
fi

# The shim is exactly the import line — anything more belongs in
# AGENTS.md, where every agent reads it.
if [ "$(cat "$SHIM" 2>/dev/null)" = "@AGENTS.md" ]; then
  echo "ok    the CLAUDE.md shim is exactly the import line"; pass=$((pass + 1))
else
  echo "FAIL  the CLAUDE.md shim is exactly the import line"
  echo "      got: '$(cat "$SHIM" 2>/dev/null | head -3)'"
  fail=$((fail + 1))
fi

# The guard bites. A case that cannot fail is not a guard, and the two
# regressions worth naming — the relative @-import and the regrown
# table — both pass a reading that only hunts for markers.
scratch=$(mktemp -d)
pointer='This project tracks its work with WritRun. Before touching `work/`,
`docs/`, or any task, spec, or report, read and follow
[`.writrun/AGENTS.md`](.writrun/AGENTS.md).'

printf '# AGENTS.md\n\n## WritRun\n\n%s\n' "$pointer" > "$scratch/clean.md"
out=$(pointer_faults "$scratch/clean.md")
if [ -z "$out" ]; then
  echo "ok    an entry point that is only the pointer reports no fault"; pass=$((pass + 1))
else
  echo "FAIL  an entry point that is only the pointer reports no fault"
  echo "      faults: $out"
  fail=$((fail + 1))
fi

# `@./.writrun/AGENTS.md` is the spelling the first version of this
# guard read straight past.
printf '# AGENTS.md\n\n## WritRun\n\nRead and follow @./.writrun/AGENTS.md.\n' \
  > "$scratch/import.md"
out=$(pointer_faults "$scratch/import.md")
case "$out" in
  *pointer-is-an-import*)
    echo "ok    a relative @-import is caught, not just the bare spelling"; pass=$((pass + 1)) ;;
  *)
    echo "FAIL  a relative @-import is caught, not just the bare spelling"
    echo "      got: '$out'"
    fail=$((fail + 1)) ;;
esac

printf '# AGENTS.md\n\n## WritRun\n\n%s\n\n| Transition | Who |\n|---|---|\n| Spec approval | Human |\n' \
  "$pointer" > "$scratch/table.md"
out=$(pointer_faults "$scratch/table.md")
case "$out" in
  *section-has-a-table*)
    echo "ok    a gates table regrown under the claim is caught"; pass=$((pass + 1)) ;;
  *)
    echo "FAIL  a gates table regrown under the claim is caught"
    echo "      got: '$out'"
    fail=$((fail + 1)) ;;
esac

printf '# AGENTS.md\n\n## WritRun\n\n%s\n\n### Picking work\n\nUse the selector.\n' \
  "$pointer" > "$scratch/flow.md"
out=$(pointer_faults "$scratch/flow.md")
case "$out" in
  *section-has-subheadings*)
    echo "ok    flow prose regrown under the claim is caught"; pass=$((pass + 1)) ;;
  *)
    echo "FAIL  flow prose regrown under the claim is caught"
    echo "      got: '$out'"
    fail=$((fail + 1)) ;;
esac

# An entry point the test can no longer find is drift, not agreement.
out=$(pointer_faults "$scratch/renamed-away.md")
rm -rf "$scratch"
case "$out" in
  '!no-entry-point'*)
    echo "ok    an entry point the test cannot find is reported, not shrugged at"; pass=$((pass + 1)) ;;
  *)
    echo "FAIL  an entry point the test cannot find is reported, not shrugged at"
    echo "      got: '$out'"
    fail=$((fail + 1)) ;;
esac

finish
