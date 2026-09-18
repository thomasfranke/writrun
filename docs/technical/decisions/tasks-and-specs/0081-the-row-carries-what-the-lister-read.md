# the row carries what the lister read to place it — one token in the human row, never a second output.

**2026-09-17**

`list_tasks.sh` resolves, for every task it considers, the specs in its
`spec_ref` and each of those specs' status. It has to: `ready` *is*
"every `spec_ref` approved or implemented", and steps 2–4 of the
algorithm read exactly that. Then it dropped both at the printf, so a
reader built on the lister could say a task's id, its priority and the
section it sat under, and could not say what authorized it — the one
fact the placement was derived from (report-0047).

The alternative from the reader's side was a filesystem read of its
own: `spec_ref` off the task, `status` off each spec, per row, of
something the kit had already read. That is a second authority over the
same files, and it drifts on the next update — the objection
`read_setting.sh` answers for settings, one level down.

**One output, not two.** The report offered a fourth and fifth field, a
`--format`, or a machine-readable mode beside the human one. The row
wins: the human line and the porcelain's read are then the same line and
cannot disagree, and no second grammar has to be kept true. The price is
a wider row for people, paid once.

**One token, no space.** It sits between the id and free text — a title
carries spaces and goes last — so a field a reader has to count to find
is one they will miscount. `spec-0002:approved`, comma-joined in
`spec_ref` order, is the whole grammar. `no-spec` is a word rather than
an empty column for the same reason an empty section is not printed
empty elsewhere here: absence and oversight look identical.

**A spec the queue lacks is named `missing`**, the status the placement
judged it by, so the row cannot say less than the decision behind it.

The fields before the token stay each section's own — priority for an
available task, the author for one in flight — because the token is a
column added to four rows, not a new row shape. Two packers build a
held-back record and both were changed; a case asserts the field's
position on every row, which is the failure mode a record one field
short produces: the next field slides into the token's slot and prints
where a reader expects a spec.

Rejected: a machine-readable mode, which is a second output free to
disagree with the first; and printing only the count of approved specs,
which answers "is it ready" — a question the section already answered —
instead of "which spec, and in what state".
