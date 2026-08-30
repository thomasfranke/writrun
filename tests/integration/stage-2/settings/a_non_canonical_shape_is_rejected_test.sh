#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# JSON permits arbitrary nesting, arrays and free-form whitespace; the
# reader sees two levels and nothing deeper, and would misread the rest in
# silence. So the shape is a checked contract, and these are the shapes it
# exists to catch.
setup

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional",
    "mirror": {
      "labels": true
    }
  }
}
JSON
check "a third nesting level is rejected" 1 "opens a third nesting level" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "mirror": {
    "labels": true
  },
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so is a section that is not a stage" 1 \
  "only a '\"stage_N\"' section may" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "prefixes": ["task", "spec"],
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "an array is rejected" 1 "not one canonical" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3, "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "two keys on one line are rejected" 1 "not one canonical" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
  "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a pair at the wrong indent inside a section is rejected" 1 \
  "at four spaces inside 'stage_1'" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage": 2,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a duplicated key is rejected" 1 "'stage' appears more than once" \
  -- bash "$CHECK_SETTINGS"

# A section exists only when it holds a documented key: an empty
# placeholder is a line the reader must skip and the check must
# special-case, bought for nothing.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  },
  "stage_3": {
  }
}
JSON
check "an empty placeholder section is rejected" 1 "holds nothing" \
  -- bash "$CHECK_SETTINGS"

# Edge case: a trailing comma is invalid JSON, and a reader that shrugged
# at it would be reading something no other tool calls a settings file.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  },
}
JSON
check "a trailing comma on the last entry is rejected" 1 \
  "ends with a comma" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true,
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so is one on a section's last pair" 1 \
  "last pair of 'stage_1' and ends with a comma" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a missing comma between entries is rejected too" 1 \
  "ends without a comma" \
  -- bash "$CHECK_SETTINGS"

finish
