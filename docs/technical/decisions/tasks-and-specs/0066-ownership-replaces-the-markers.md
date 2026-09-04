# the CLI's update contract is ownership, not markers.

**2026-09-04**

[0020](0020-a-cli-is-welcome.md) fixed two intents for the deferred
`init` and `doctor`, and one of them no longer describes the kit.
WritRun's part was to enter an existing `AGENTS.md` as a titled section
fenced by `writrun:begin`/`writrun:end`; `update` was to refresh only
what sat between those markers, preserving the lines marked "yours" — the
gates table, the deriving default; and `doctor` was to check that the
markers survived edits. [The entry point is the
project's](../../../product/adoption.md#the-entry-point-is-the-projects)
replaced that mechanism with an ownership split, and this entry records
what the client now builds on. 0020 keeps its number and the rest of its
reasoning: a CLI is still welcome, still a separate repository, still
never a dependency.

**What made the markers necessary was one file holding two owners.** The
graft put kit-owned prose and adopter-owned answers in the same
`AGENTS.md`, so a refresh had to tell them apart — hence a fence to
refresh between, and an exemption list for the lines inside it that were
nonetheless the project's. Every one of those mechanisms is bookkeeping
for a mixture, and the mixture was the choice, not the requirement.

**The split removes the question instead of answering it.** A file under
`.writrun/` is either the kit's, replaced entire, or the adopter's,
never touched: `AGENTS.md` and the scripts are WritRun's, `gates.md` and
`settings.json` are the project's. Nothing is part both, so `update`
never merges anyone's prose — it copies whole files and skips two by
name. The root `AGENTS.md` keeps a four-line pointer and is otherwise
the project's, which is why `init` grafts a pointer rather than a
section, and why an entry point that has grown a marker is now a defect
rather than the design.

**`doctor` loses the check it was given and gains a smaller one.** "The
markers survived edits" has no subject any more. What is worth verifying
is that the two adopter-owned files still exist and still answer their
gates — an unfilled `gates.md` TODO is the failure the old exemption
list was protecting against, stated directly — and the declared merge
policy still matches the forge's settings, which 0020 already named and
which is untouched here.

**Rejected: keeping the markers as an update-time safety net.** A fence
around content nobody merges is a second mechanism describing the same
boundary the directory already draws, and the day the two disagree the
fence wins for the wrong reason. The one surviving `writrun:begin` pair
in the pull-request body template is not this mechanism: it has a live
reader — `writrun check` locates the `## Derived work` heading through
it — and it fences generated content inside a file the adopter owns,
which is the case the graft never was.
