#!/usr/bin/env bash
# The brief is one output in one order: header, task, every spec in
# spec_ref order, then the doc_ref section. Reading it in another order
# would put a spec's scope before the request it elaborates.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready "spec-001, spec-002"
spec_file spec-001 task-001 approved
spec_file spec-002 task-001 approved
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#scope|' work/tasks/task-001.md
rm -f work/tasks/*.bak

bash "$BRIEF" task-001 > out.txt 2>&1
code=$?
h=$(grep -n '^task-001' out.txt | head -n1 | cut -d: -f1)
t=$(grep -n '^== work/tasks/task-001.md ==$' out.txt | cut -d: -f1)
s1=$(grep -n '^== work/specs/spec-001.md ==$' out.txt | cut -d: -f1)
s2=$(grep -n '^== work/specs/spec-002.md ==$' out.txt | cut -d: -f1)
d=$(grep -n '^== docs/product/chapter.md#scope ==$' out.txt | cut -d: -f1)

if [ "$code" -eq 0 ] && [ -n "$h$t$s1$s2$d" ] \
   && [ "$h" -lt "$t" ] && [ "$t" -lt "$s1" ] && [ "$s1" -lt "$s2" ] && [ "$s2" -lt "$d" ]; then
  echo "ok    header, task, each spec in order, then the doc section"; pass=$((pass + 1))
else
  echo "FAIL  header, task, each spec in order, then the doc section"
  sed 's/^/      | /' out.txt; fail=$((fail + 1))
fi

check "the header carries each spec's status" 0 "spec-001 approved" -- bash "$BRIEF" task-001
check "the task's own body is printed" 0 "Test task task-001" -- bash "$BRIEF" task-001
check "the doc section is printed, not the whole file" 0 "baseline" -- bash "$BRIEF" task-001

finish
