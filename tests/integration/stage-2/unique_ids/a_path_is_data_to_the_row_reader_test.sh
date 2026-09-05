#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# This check's rows are assembled here rather than read off a forge, and
# they still go through the shared reader: the collapse `IFS="$TAB" read`
# performs is a property of `read`, not of where the row came from, and a
# private parse beside the shared one is the drift `queue_lib.sh` exists
# to prevent.
#
# What that move has to keep true is that the third field is *data*. It
# is a path, a person names it, and the reader assembles its result
# through an assignment — so a path carrying a `$` or a space must arrive
# whole and unexpanded, and the collision must name it as written.
setup
stub_forge
task_file task-0007 ready ""
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
cp 'work/tasks/task-0007.md' 'work/tasks/task-0007-a $HOME b.md'
commit_all
check "a path holding a \$ and a space is named as written" 1 \
  'task-0007-a $HOME b.md' \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
