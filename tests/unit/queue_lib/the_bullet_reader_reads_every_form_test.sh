#!/usr/bin/env bash
# One bullet reader for both gates (decision 0078). What it reads, what
# it names, and what it leaves alone — each form here is one an author
# has actually written, and the link form is the one that sat on a
# silent pass in writrun-cli (report-0044).
#
# Sources the harness directly: the reader reads stdin, no repository.
. "$(dirname "$0")/../../harness.sh"

QUEUE_LIB="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/queue_lib.sh"

SPEC='# spec-0001 — test

## Scope

- `not/a/promise.md` — a bullet outside the sections is not one.

## Proposed product changes

- `product/one.md#anchor` — the form the gates read.
- none — nothing else here.
- [`product/two.md`](../../docs/product/two.md) — the link form.
- `product/three.md` — a wrapped entry whose second line
  is indented and so is not a bullet.

## Proposed technical changes

- **bold** `technical/four.md` — the backtick is not first.
- `technical/five.md`
  — a note on its own continuation line.

## Outcome

- `not/a/promise/either.md`
'

reads() {   # reads <function> — the function over the spec above
  bash -c 'set -euo pipefail; . "$0"; "$1"' "$QUEUE_LIB" "$1" <<<"$SPEC"
}

exact() {   # exact <name> <want> -- <cmd...> — the whole of stdout
  local name="$1" want="$2"; shift 3
  local out
  out=$("$@")
  if [ "$out" = "$want" ]; then
    printf 'ok    %s\n' "$name"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected:\n%s\n      got:\n%s\n' \
      "$name" "$(printf '%s\n' "$want" | sed 's/^/        /')" \
      "$(printf '%s\n' "$out" | sed 's/^/        /')"
    fail=$((fail + 1))
  fi
}

TAB=$(printf '\t')

exact "the paths are the backticked bullets, anchor stripped, sorted, and only those" \
  "$(printf 'product/one.md\nproduct/three.md\ntechnical/five.md')" \
  -- reads ql_promised_paths

exact "the unreadable bullets are named with their section, and none is not one" \
  "$(printf 'product%s- [`product/two.md`](../../docs/product/two.md) — the link form.\ntechnical%s- **bold** `technical/four.md` — the backtick is not first.' "$TAB" "$TAB")" \
  -- reads ql_unreadable_promises

# A spec whose sections say none and nothing else — the skeleton — reads
# as no path and no unreadable bullet, which is "nothing to judge".
NONE='## Proposed product changes

- none — no behaviour change

## Proposed technical changes

- none — no technical chapter changes
'
exact "a skeleton of none reads as nothing at all" "" \
  -- bash -c 'set -euo pipefail; . "$0"; ql_promised_paths; ql_unreadable_promises' "$QUEUE_LIB" <<<"$NONE"

finish
