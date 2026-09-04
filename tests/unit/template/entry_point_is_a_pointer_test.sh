#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The kit's claim on an adopting project's AGENTS.md is the four-line
# pointer and nothing else (adoption.md#the-entry-point-is-the-projects).
# The failures this guard exists for: the entry point regrowing the
# writrun:begin markers the ownership split retired, the pointer
# dropping the file it names, and the CLAUDE.md shim growing beyond the
# one import line Claude Code needs.

ENTRY="$REPO_ROOT/template/AGENTS.md"
FLOW="$REPO_ROOT/template/.writrun/AGENTS.md"
GATES="$REPO_ROOT/template/.writrun/gates.md"
SHIM="$REPO_ROOT/template/CLAUDE.md"

if grep -q 'writrun:begin\|writrun:end' "$ENTRY" 2>/dev/null; then
  echo "FAIL  the entry point carries no graft marker"
  fail=$((fail + 1))
else
  echo "ok    the entry point carries no graft marker"; pass=$((pass + 1))
fi

if grep -q '\.writrun/AGENTS\.md' "$ENTRY" 2>/dev/null; then
  echo "ok    the entry point names the flow file the pointer promises"; pass=$((pass + 1))
else
  echo "FAIL  the entry point names the flow file the pointer promises"
  fail=$((fail + 1))
fi

# The pointer is a link, never an import: an @-reference would chain-load
# the whole flow into every Claude session through the shim.
if grep -qE '(^|[^`[:alnum:]])@\.?writrun/AGENTS\.md' "$ENTRY" 2>/dev/null; then
  echo "FAIL  the pointer is a link, not an @-import"
  fail=$((fail + 1))
else
  echo "ok    the pointer is a link, not an @-import"; pass=$((pass + 1))
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

# The shim is exactly the import line — anything more belongs in
# AGENTS.md, where every agent reads it.
if [ "$(cat "$SHIM" 2>/dev/null)" = "@AGENTS.md" ]; then
  echo "ok    the CLAUDE.md shim is exactly the import line"; pass=$((pass + 1))
else
  echo "FAIL  the CLAUDE.md shim is exactly the import line"
  echo "      got: '$(cat "$SHIM" 2>/dev/null | head -3)'"
  fail=$((fail + 1))
fi

finish
