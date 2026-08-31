#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The address is a key's identity, so a documented key in the wrong
# section is not merely misplaced — the reader looking in its documented
# home finds nothing and falls back to the default, silently. That is the
# failure this names.
setup

settings_file <<'JSON'
{
  "stage": 3,
  "pr_title_style": "bracketed",
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "credit_ai": true,
    "auto_pr": true
  }
}
JSON
check "a key left at the top level is homeless" 1 \
  "its home is stage_2" \
  -- bash "$CHECK_SETTINGS"
check "and it is reported missing from the home it belongs in" 1 \
  "'stage_2.pr_title_style' is missing" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "auto_pr": true
  },
  "stage_2": {
    "auto_commit": true,
    "credit_ai": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a key in the wrong section is homeless the same way" 1 \
  "'auto_pr' sits at line" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage_1": {
    "stage": 3,
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "credit_ai": true,
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so is the top-level key pushed into a section" 1 \
  "its home is the top level" \
  -- bash "$CHECK_SETTINGS"

# The conduct flags' own old home. Git begins at Stage 2, so a flag left
# in `stage_1` is a file written against the pre-restage rule — and the
# fault is what tells the adopter where it went, which is the whole
# migration path this move offers.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a conduct flag left in stage_1 is rejected" 1 \
  "'auto_commit' sits at line" \
  -- bash "$CHECK_SETTINGS"
check "and the fault names stage_2 as its home" 1 \
  "its home is stage_2" \
  -- bash "$CHECK_SETTINGS"
check "the other flag is named the same way" 1 \
  "'stage_2.credit_ai' is missing" \
  -- bash "$CHECK_SETTINGS"

# A declaration is no different: three keys, three homes, same rule.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "decisions_style": "per-subsystem",
    "auto_commit": true,
    "credit_ai": true,
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a declaration outside stage_1 is homeless" 1 \
  "'decisions_style' sits at line" \
  -- bash "$CHECK_SETTINGS"
check "and its home is named" 1 "its home is stage_1" \
  -- bash "$CHECK_SETTINGS"

# A file with no `stage_1` section at all is never rejected *for the
# absence of the section* — the checker has no required-section rule.
# What it names is each documented key the section was holding, by
# address, which is what an adopter can act on.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_2": {
    "auto_commit": true,
    "credit_ai": true,
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "no stage_1 section faults its keys, by address" 1 \
  "'stage_1.spec_required' is missing" \
  -- bash "$CHECK_SETTINGS"
refute "and never the section itself" "section is missing" \
  -- bash "$CHECK_SETTINGS"

finish
