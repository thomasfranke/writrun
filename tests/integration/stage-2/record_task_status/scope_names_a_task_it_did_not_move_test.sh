#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `tasks` and `scope` answer different questions, and the mirror wants the
# second. A task the merge creates already resting where it belongs — an
# empty `spec_ref`, or specs the same merge approved — writes no `moved`
# line, and its mirror still owes a label. Deriving that set a second time
# from the range would be a second chance to disagree with the recording;
# it is reported instead.
setup
git checkout -q main
printf 'seed\n' > seed.txt
commit_all
task_file task-001 backlog spec-001
spec_file spec-001 task-001 draft
task_file task-002 ready ""
commit_all
spec_file spec-001 task-001 approved
commit_all

OUT=$(mktemp "${TMPDIR:-/tmp}/writrun-out.XXXXXX")
GITHUB_OUTPUT="$OUT" bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" \
  HEAD~2...HEAD >/dev/null

moved=$(sed -n 's/^tasks=//p' "$OUT")
scoped=$(sed -n 's/^scope=//p' "$OUT")

case " $moved " in
  *" task-001 "*) echo "ok    the moved task is reported in tasks"; pass=$((pass+1)) ;;
  *) echo "FAIL  the moved task is reported in tasks"; echo "      | tasks=$moved"; fail=$((fail+1)) ;;
esac

case " $moved " in
  *" task-002 "*) echo "FAIL  a task that did not move is not in tasks"; echo "      | tasks=$moved"; fail=$((fail+1)) ;;
  *) echo "ok    a task that did not move is not in tasks"; pass=$((pass+1)) ;;
esac

for want in task-001 task-002; do
  case " $scoped " in
    *" $want "*) echo "ok    $want is named in scope"; pass=$((pass+1)) ;;
    *) echo "FAIL  $want is named in scope"; echo "      | scope=$scoped"; fail=$((fail+1)) ;;
  esac
done

rm -f "$OUT"
finish
