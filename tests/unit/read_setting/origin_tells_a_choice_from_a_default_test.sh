#!/usr/bin/env bash
# Without --origin a declared value and a documented default print
# identically, which is right for a caller that only wants a value to act
# on and wrong for one rendering the file for a person.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
settings_file <<'JSON'
{
  "stage": 1,
  "stage_2": {
    "auto_push": false
  }
}
JSON

check "a declared key is marked declared" 0 "false	declared" \
  -- bash "$READ_SETTING" stage_2.auto_push --origin
check "a key the file omits is its default, marked" 0 "true	default" \
  -- bash "$READ_SETTING" stage_2.auto_commit --origin
check "and without the flag the value stands alone" 0 "^false$" \
  -- bash "$READ_SETTING" stage_2.auto_push

setup
check "with no file at all, everything is a default" 0 "3	default" \
  -- bash "$READ_SETTING" stage --origin

# A value carried over by a rename bridge is the adopter's, under the
# name of the day — declared, not defaulted.
setup
settings_file <<'JSON'
{
  "level": "pull-requests"
}
JSON
check "a bridged value stays declared" 0 "2	declared" -- bash "$READ_SETTING" stage --origin

check "an unusable flag is a usage error" 3 "usage" -- bash "$READ_SETTING" stage --deep

finish
