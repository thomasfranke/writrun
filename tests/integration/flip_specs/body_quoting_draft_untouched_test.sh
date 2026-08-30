#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A spec documenting the methodology can quote `status: draft` in its
# body; only the front-matter block is the record.
setup
task_file task-001 pending spec-001
spec_file spec-001 task-001 draft
printf 'status: draft\n' >> work/specs/spec-001.md
commit_all
bash "$CI_SCRIPTS/stage-2-pull-requests/flip_approved_specs.sh" main...HEAD >/dev/null
fm_status=$(sed -n '1,/^---$/d; p' work/specs/spec-001.md >/dev/null; sed -n '2,/^---$/p' work/specs/spec-001.md | sed -n 's/^status: *//p')
body_drafts=$(grep -c '^status: draft$' work/specs/spec-001.md)
if [ "$fm_status" = "approved" ] && [ "$body_drafts" = "1" ]; then
  echo "ok    the flip touches front-matter only, never a quoted body line"; pass=$((pass + 1))
else
  echo "FAIL  the flip touches front-matter only, never a quoted body line"
  grep -n 'status:' work/specs/spec-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
