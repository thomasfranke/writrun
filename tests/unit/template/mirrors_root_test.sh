#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The template is a deliberate full copy — one folder an adopter pastes.
# A copy is a second source of truth, so this case is the guard: every
# mirrored path must stay byte-identical to the root. A failure is fixed
# with `make template-sync`, never by editing template/ by hand.
ok=1
while IFS= read -r p; do
  [ -n "$p" ] || continue
  if ! diff -r -q "$REPO_ROOT/$p" "$REPO_ROOT/template/$p" >/dev/null 2>&1; then
    [ "$ok" = "1" ] && echo "FAIL  template drifted from the root — run 'make template-sync'"
    diff -r -q "$REPO_ROOT/$p" "$REPO_ROOT/template/$p" 2>&1 | sed 's/^/      | /'
    ok=0
  fi
done < "$REPO_ROOT/tests/template_mirrors.txt"

if [ "$ok" = "1" ]; then
  echo "ok    template mirrors the root byte for byte"; pass=$((pass + 1))
else
  fail=$((fail + 1))
fi

finish
