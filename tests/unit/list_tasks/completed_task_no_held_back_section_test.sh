#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 done spec-001 2026-08-22
spec_file spec-001 task-001 implemented
out=$(bash "$LIST_TASKS" 2>&1)
if printf '%s' "$out" | grep -q "Held back"; then
  echo "FAIL  a completed task produces no Held back section"; fail=$((fail + 1))
else
  echo "ok    a completed task produces no Held back section"; pass=$((pass + 1))
fi

finish
