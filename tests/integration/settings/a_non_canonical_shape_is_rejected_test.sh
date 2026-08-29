#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# JSON permits nesting, arrays and free-form whitespace; the reader sees
# none of it and would misread in silence. So the shape is a checked
# contract, and these are the shapes it exists to catch.
setup

settings_file <<'JSON'
{
  "level": "github-issues",
  "pr_title_style": "conventional",
  "mirror": {
    "labels": true
  }
}
JSON
check "a nested object is rejected" 1 "not one canonical" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "level": "github-issues",
  "pr_title_style": "conventional",
  "prefixes": ["task", "spec"]
}
JSON
check "an array is rejected" 1 "not one canonical" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "level": "github-issues", "pr_title_style": "conventional"
}
JSON
check "two keys on one line are rejected" 1 "not one canonical" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "level": "github-issues",
  "level": "pull-requests",
  "pr_title_style": "conventional"
}
JSON
check "a duplicated key is rejected" 1 "'level' appears more than once" \
  -- bash "$CHECK_SETTINGS"

# Edge case: a trailing comma is invalid JSON, and a reader that shrugged
# at it would be reading something no other tool calls a settings file.
settings_file <<'JSON'
{
  "level": "github-issues",
  "pr_title_style": "conventional",
}
JSON
check "a trailing comma on the last pair is rejected" 1 \
  "ends with a comma" \
  -- bash "$CHECK_SETTINGS"

finish
