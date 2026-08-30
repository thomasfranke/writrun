# settings move to WritRun's root and section by stage — reversing part of 0052.

**2026-08-30**

[0052](0052-settings-carry-the-choice.md) put the settings file in
`.writrun/conventions/` and made it flat. Both choices served their reasons
and both aged badly within two days of the stage split landing.

**The address.** `conventions/` was chosen because that folder is the
project's from adoption onward and `writ update` never touches it — a real
property, but one the file can carry by name; the folder was never the
point. Meanwhile the address argument 0052 itself made — "one known path
ends the hunt" — argues against the corner it picked: the file every
reader and every tool goes looking for first belongs at the root of
WritRun's home, `.writrun/settings.json`, not behind a folder whose name
says "prose about commit style". The update exemption moves onto the file
by name; nothing else changes about who owns it.

**The shape.** Flat was chosen so `sed` could read the file. Then the
stage split put the stage on the name of every folder, chapter and suite
that belongs to one — and left the settings, the one file whose whole job
is stage-scoped choices, as an undivided list a Stage 1 reader must
already understand to ignore half of. The file now carries one top-level
`stage` and one section per stage (`"stage_1"`, `"stage_2"`), each key in
the section whose readers act on it; a section exists only when it holds
a documented key.

**Still no `jq` — 0052's real constraint survives the reversal.** What
0052 rejected was "nested JSON with `jq`": the dependency, not the
indentation. One nesting level, entered by a `"stage_N": {` line of fixed
shape and left by a `}` line of fixed shape, is a two-state line reader —
still sed/awk territory, and `check_settings.sh` still enforces the canon
so the reader never meets anything else. The reader addresses a sectioned
key through its section (`stage_2.pr_title_style`); the address, not the
name, is identity.

**The bridge follows the `level` precedent.** A file left at the old
address keeps working, read flat under the old contract, frozen; the
check faults it by naming the move. An adopter who never updates loses
nothing; one who updates is told exactly once what to do.

Rejected: stage-prefixed flat keys (`stage2_pr_title_style`), which keep
the reader trivial but put the structure in a naming convention the check
cannot see the edges of. Rejected: one file per stage, which multiplies
the addresses exactly where one address was the argument. Rejected: an
empty `"stage_3": {}` for symmetry — a section with nothing to say is a
line the reader must skip and the check must special-case, bought for
nothing.
