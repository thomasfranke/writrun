#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `origin` is a fact about how the task came to exist, and the schema
# draws it between doc_ref and priority — the generator writes it there,
# character for character, so a reader of the file and a reader of the
# schema see the same shape.
setup
bash "$NEW_SH" task "Reported gap" --origin report --slug reported >/dev/null 2>&1
f=work/tasks/task-0001-reported.md
if grep -q '^origin: report$' "$f" &&
   [ "$(grep -n '^doc_ref:' "$f" | cut -d: -f1)" = "$(( $(grep -n '^origin:' "$f" | cut -d: -f1) - 1 ))" ] &&
   [ "$(grep -n '^priority:' "$f" | cut -d: -f1)" = "$(( $(grep -n '^origin:' "$f" | cut -d: -f1) + 1 ))" ]; then
  echo "ok    origin lands between doc_ref and priority"; pass=$((pass + 1))
else
  echo "FAIL  origin lands between doc_ref and priority"
  sed -n '1,16p' "$f" 2>/dev/null | sed 's/^/      | /'
  fail=$((fail + 1))
fi

bash "$NEW_SH" task "Derived rule" --origin rule --slug derived >/dev/null 2>&1
if grep -q '^origin: rule$' work/tasks/task-0002-derived.md; then
  echo "ok    the other value is written just as literally"; pass=$((pass + 1))
else
  echo "FAIL  the other value is written just as literally"; fail=$((fail + 1))
fi

check "and the canonical check accepts both" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
