# the conduct flags move to `stage_2` — correcting 0054's placement.

**2026-08-31**

[0054](0054-the-adopter-governs-the-agent.md) put `auto_commit` and
`credit_ai` in `stage_1` on the reasoning that *commits exist for every
adopter*, and `auto_pr` in `stage_2` because pull requests begin there.
The premise was already false when it was written, and the docs said so
a day later: **git begins at Stage 2**
([Adoption](../../../product/adoption.md#three-stages)). Stage 1 is the
queue as files — the docs written, the tasks and specs generated from
them, every status moved by hand. Whether those files also live in a
repository is the adopter's business, which the methodology neither
asks nor checks.

So at Stage 1 there is no commit for `auto_commit` to gate and no
message for `credit_ai` to strip. A flag whose governed action does not
exist at its stage is not a conservative default; it is a section
telling a Stage 1 reader that a choice is theirs to make when nothing
in their adoption will ever read it. That is the exact failure the
stage split was introduced to end — a reader knowing what to ignore
without opening anything.

All three conduct flags now sit in `stage_2`, beside `pr_title_style`,
where the actions they govern begin. Nothing about their semantics
moves with them: the defaults stay `true`, `false` still gates the
action and never the work, and they still outrank the agent platform's
own autonomy mode. The address changed; the rule did not.

**The reject message is the whole migration path.** A file carrying
either flag in `stage_1` is refused by `check_settings.sh` naming
`stage_2` as its home — the homeless-key fault the schema already had,
which needed no new rule to cover this. No legacy acceptance is owed:
the two projects this methodology was extracted from have not migrated
onto it yet, so no settings file in the world spells the old home
except this repository's own, corrected in the same change.

Rejected: reading both addresses for a grace period, the bridge
[0053](0053-settings-at-the-root.md) built for the file's move. That
bridge existed because a whole file at the wrong path is invisible to
the reader — the adopter would silently lose every choice at once. One
key found where the schema no longer documents it is a different
failure: the checker sees it, names it, and the fix is one line.

Rejected: keeping the flags in `stage_1` and documenting that they
apply "from Stage 2 onwards". That is two ways to say one thing, free
to disagree — the shape [0041](../github-issues/0041-the-issues-mirror-is.md)
rejected and [0052](0052-settings-carry-the-choice.md) restated as *a
setting controls, it never merely describes*. A key's section is part
of its address, so the section is where the statement belongs.
