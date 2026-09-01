#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule I. The provenance ledger is the one machine field a branch writes,
# because no forge event carries a token count — only the session that
# spent them knows. What keeps that from widening into "a branch may edit
# front matter" is the shape of the permission: appending is a different
# act from editing, and the check can tell them apart.
#
# An entry records work that happened. Rewriting one rewrites the past —
# and the reason this field exists at all is that the field beside it
# (`taken_by`) keeps erasing itself
# (docs/product/concepts/provenance.md#why-the-field-naming-the-worker-is-not-this-record).

FIRST='provenance:
  - {by: agent, model: claude-opus-5, login: octocat, input: 562, output: 175853, cache_read: 37266324, cache_write: 366590}'

setup
task_file task-001 ready "" null null rule "$FIRST"
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature

# Appending: the entry the base held is still there, unchanged, and a
# second session's entry follows it.
task_file task-001 ready "" null null rule "$FIRST
  - {by: agent, model: claude-fable-5, login: octocat, input: 12, output: 900, cache_read: 40, cache_write: 8}"
commit_all
check "a second session appends its entry" 0 "no forbidden lifecycle transition" \
  -- bash "$CHECK_STATE" main...HEAD
check "and the result is canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# A person's entry appends the same way — using an agent is not
# obligatory, and neither is recording one.
task_file task-001 ready "" null null rule "$FIRST
  - {by: human, login: octocat}"
commit_all
check "so does a person's" 0 "no forbidden lifecycle transition" \
  -- bash "$CHECK_STATE" main...HEAD

# Editing: the counts of an entry already written are corrected in place.
setup
task_file task-001 ready "" null null rule "$FIRST"
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 ready "" null null rule 'provenance:
  - {by: agent, model: claude-opus-5, login: octocat, input: 562, output: 175853, cache_read: 1, cache_write: 366590}'
commit_all
check "an entry corrected in place is refused" 1 \
  "edits a provenance entry it found" \
  -- bash "$CHECK_STATE" main...HEAD

# Removing: the entry is gone and the ledger looks shorter than the past
# it records.
task_file task-001 ready "" null null rule "provenance: []"
commit_all
check "and so is an entry removed" 1 "edits a provenance entry it found" \
  -- bash "$CHECK_STATE" main...HEAD

# Reordering: every entry is still present, so a check comparing sets
# would pass. Order is what makes the list a chronology.
task_file task-001 ready "" null null rule 'provenance:
  - {by: human, login: octocat}
  - {by: agent, model: claude-opus-5, login: octocat, input: 562, output: 175853, cache_read: 37266324, cache_write: 366590}'
commit_all
check "an entry pushed down the list is refused too" 1 \
  "edits a provenance entry it found" \
  -- bash "$CHECK_STATE" main...HEAD

# A task the branch creates has no past to rewrite.
setup
task_file task-002 backlog "" null null rule "$FIRST"
commit_all
check "a task born with an entry is not an edit" 0 \
  "no forbidden lifecycle transition" \
  -- bash "$CHECK_STATE" main...HEAD

finish
