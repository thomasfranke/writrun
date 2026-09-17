#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A bullet under either heading that does not open with a backticked
# path used to be no promise at all: this gate found nothing to judge
# and passed, and the completion gate later judged every touched doc
# undeclared against nothing (report-0044, decision 0078). Now it is
# refused by name, where the fix is one edit.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft
sed -i.bak 's|^- none — no behaviour change$|- [`product/chapter.md`](../../docs/product/chapter.md) — the link form.|' \
  work/specs/spec-0038.md && rm -f work/specs/spec-0038.md.bak
commit_all

check "a link-form bullet is refused, naming the section" 1 \
  "spec-0038's Proposed product changes carries a bullet the gates cannot read" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "the refusal says what form the gates read" 1 "Open the" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
refute "a refused spec is not reported as nothing to judge" "nothing to judge" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# The bold-then-backtick form is the other plausible one, in the other
# section — refused the same way, even beside a promise that reads.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft product/chapter.md
sed -i.bak 's|^- none — no technical chapter changes$|- **README** `technical/README.md` — bold first.|' \
  work/specs/spec-0038.md && rm -f work/specs/spec-0038.md.bak
commit_all

check "a bullet whose backtick is not first is refused" 1 \
  "Proposed technical changes carries a bullet" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# A bullet the base already carried is history, exactly as a path already
# promised there: the fix is no longer one edit, so it is not offered.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft
sed -i.bak 's|^- none — no behaviour change$|- [`product/chapter.md`](../../docs/product/chapter.md) — the link form.|' \
  work/specs/spec-0038.md && rm -f work/specs/spec-0038.md.bak
commit_all
printf '\nA note.\n' >> work/specs/spec-0038.md
commit_all

check "a bullet already at the base is not re-refused" 0 "1 spec(s) read" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" HEAD~1...HEAD

finish
