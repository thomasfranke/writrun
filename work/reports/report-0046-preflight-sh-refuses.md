---
id: report-0046
status: open
task_ref: []
doc_ref: null
created: 2026-09-17T19:32:08Z
triaged: null
---

# preflight.sh refuses the only range shape that reaches the working tree, so finish's later gates never see the completion edits

Issue #269, opened by @thomasfranke.

Observed in [`writrun-cli`](https://github.com/thomasfranke/writrun-cli), against the kit tagged `v0.0.08` in `.writrun/VERSION`.

The kit reads a **bare** range — `origin/main`, with no `..` — as "this ref against the working tree". `ql_range_ends` leaves its head end empty for that shape and for no other, and `check_deltas.sh`'s header describes the behaviour deliberately:

> The bare shape hands back an empty HEADREF: its diff compares the ref to the *working tree*.

`preflight.sh` cannot be given one. It decides what its arguments are by shape, at `:44-52`:

```bash
*..*)  [ -z "$RANGE" ] || own_failure "two diff ranges given ('$RANGE' and '$arg')"
       RANGE="$arg" ;;
*)     [ -z "$IDS_ARG" ] || own_failure "two task lists given ('$IDS_ARG' and '$arg')"
       IDS_ARG="$arg" ;;
```

So `origin/main` arrives as a **second task list** and the run dies with `PREFLIGHT: two task lists given ('task-0001' and 'origin/main')`.

**And no other shape reaches the tree.** `origin/main..` and `origin/main...` are both accepted as ranges, and both resolve their head end to `HEAD` — `${QL_HEADREF:-HEAD}` for the two-dot form, `${right:-HEAD}` for the three-dot one. The one shape that reaches the working tree is the one shape `preflight.sh` will not take as a range.

### Why it matters downstream

`writrun finish` writes the spec's `implemented` and the task's `completed` date into the working tree and commits nothing. It then hands `preflight.sh` a range, and stages 2 and 3 read it — so the two gates that exist to judge those edits run without them, and the run ends:

```
PREFLIGHT OK — range origin/main...HEAD; deltas checked: none — no spec reached 'implemented' in this range
```

A pass, printed under the word PREFLIGHT, over the very change those stages exist to judge — at the last moment before the forge is asked for anything. Every completion this client has cut has been vouched for that way, and the sentence was quoted from a live run while implementing the half that *was* reachable.

That client reached its step 1, which calls `check_deltas.sh` directly and can be given the bare range: a promised document written and staged but not committed is now judged rather than refused as missing. Step 4 is behind this issue, and the client's own document now says so rather than claiming otherwise.

### What would settle it

Any of these, and the shape is upstream's to choose:

- accept a bare ref as the range when one argument is already a task list — the ambiguity only exists when both are given and one of them is a ref;
- take the range through a named flag rather than by shape, so a bare ref is unambiguous;
- or have `preflight.sh` reduce a two-ended range itself for the stages that should read the tree, which keeps its argument grammar exactly as it is.

The first is the smallest; the last needs no caller to change at all.

