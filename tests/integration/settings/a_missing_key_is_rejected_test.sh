#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Every documented key is present, always — the same reason front matter
# carries null fields rather than omitting them: a reader sees the whole
# configuration without having to know the defaults.
setup
settings_file <<'JSON'
{
  "level": "github-issues"
}
JSON
check "a file missing a documented key is rejected" 1 \
  "'pr_title_style' is missing" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "pr_title_style": "conventional"
}
JSON
check "and it is rejected the other way round too" 1 "'level' is missing" \
  -- bash "$CHECK_SETTINGS"

finish
