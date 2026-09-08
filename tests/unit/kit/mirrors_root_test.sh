#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The kit is a deliberate full copy — one folder an adopter pastes.
# A copy is a second source of truth, so this case is the guard: every
# mirrored path must stay byte-identical to the root. A failure is fixed
# with `make kit-sync`, never by editing kit/ by hand.
#
# Except where the kit differs on purpose. tests/kit_exceptions.txt
# is the single source of that — the same file the sync reads — and the
# comparison drops those paths from both sides before diffing, by path
# and never by name. Since the two homes split the list is empty: the
# adopter's files live in writrun/, outside every mirrored path, and
# kit/writrun/ is a hand-written seed this guard never compares.
EXCEPTIONS="$REPO_ROOT/tests/kit_exceptions.txt"

ok=1
while IFS= read -r p; do
  [ -n "$p" ] || continue

  a=$(mktemp -d); b=$(mktemp -d)
  cp -R "$REPO_ROOT/$p" "$a/side"
  cp -R "$REPO_ROOT/kit/$p" "$b/side" 2>/dev/null || true

  if [ -f "$EXCEPTIONS" ]; then
    while IFS= read -r x; do
      [ -n "$x" ] || continue
      case "$x" in
        "$p"|"$p"/*) rel=${x#"$p"}; rel=${rel#/}
                     rm -rf "$a/side/$rel" "$b/side/$rel" ;;
      esac
    done < "$EXCEPTIONS"
  fi

  if ! diff -r -q "$a/side" "$b/side" >/dev/null 2>&1; then
    [ "$ok" = "1" ] && echo "FAIL  kit drifted from the root — run 'make kit-sync'"
    diff -r -q "$a/side" "$b/side" 2>&1 | sed "s|$a/side|$p|g; s|$b/side|kit/$p|g; s/^/      | /"
    ok=0
  fi
  rm -rf "$a" "$b"
done < "$REPO_ROOT/tests/kit_mirrors.txt"

if [ "$ok" = "1" ]; then
  echo "ok    kit mirrors the root byte for byte, but for the exceptions"; pass=$((pass + 1))
else
  fail=$((fail + 1))
fi

finish
