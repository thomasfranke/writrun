# a promise that resolves is still refused when the chapter it names is not a rule — extending 0065.

**2026-09-06**

[0065](0065-a-promise-is-judged-by-shape.md) named the test in
`check_promise_paths.sh` **shape, never existence**, and gave it two
conditions: a first segment that names a repository-root entry `docs/`
has no counterpart for, and a path ending in neither `.md` nor `/`. Both
ask one question — can any diff ever touch this path — and existence was
not merely unused there, it was unavailable: at spec entry the promised
doc is precisely what has not been written yet, so asking "is the file
there" would refuse the ordinary case and pass the broken one.

`spec-0083` adds a third condition that reads the file, and its first
line. A chapter carrying the draft marker is not a rule, and nothing
derives from one
([authoring](../../../product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet)),
so a promise to change it is a promise about a chapter no task was
allowed to be born from. That question cannot be answered by shape,
because the offending path has no shape defect at all.

**So resolution stopped being the whole question, and the two questions
must not be run together.** Conditions one and two ask whether a diff
could ever reach the path. Condition three asks whether anything may
derive from what the path reaches. A promise can pass the first and fail
the second, and when it does the path is written exactly as the schema
reads it.

**This is why the refusal's closing advice is per fault kind.** The
first implementation of the third condition printed a correct message —
"that chapter declares itself a draft" — and then, two lines below it,
the standing trailer telling the author to write the path as the schema
reads it. Reviewing #225 caught it. That advice is not merely unhelpful
for a draft fault, it is false: it sends an author who wrote the path
correctly hunting a typo that is not there, which is the exact failure
0065 built this check to spare them, reappearing under the message that
avoided it. The kinds are counted apart, each trailer prints only if its
kind fired, and a range faulting both ways gets both. The fault helper
takes its kind as a first argument with no unkinded form, so a fault
added later cannot reach the exit with no advice behind it.

**This extends 0065; it does not supersede it.** Both shape conditions
stand unchanged, as does the reasoning that they are read off the
repository rather than a list, and the collision rule that lets the
documentation reading win. What 0065 says about the class of late
amendment, and about what stays with the completion gate, is untouched.
What is corrected is only the claim that existence was never available —
true of the question 0065 had in front of it, and no longer true of the
check as a whole. The log is append-only: 0065 keeps its file, its
number, and its text ([README](../README.md)).

**Where the marker is read from, and why it is not a ref.**
`spec-0083` said the head end of the range. Condition one already
answers existence with `test -e` against the working tree, which in CI
*is* the head end, so reading a ref beside it would put two notions of
"now" in one loop. The checkout answers both.

**What this does not change.** A folder promise, written with a trailing
slash, names no chapter and is left alone. A promise the base branch
already carried is still not re-judged — the boundary 0065 drew holds
for all three conditions, because the fix this check offers is one edit
and history no longer has it. And the completion gate still stands
behind this one for everything 0065 left to it.
