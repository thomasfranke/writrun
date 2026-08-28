# a multi-spec completion is checked against the union of its promises.

**2026-08-22**

Completing a task flips every spec it references to
`implemented` in the same change (`check_state.sh` rule C), and running
`check_deltas.sh` once per spec against the whole diff then reports each
sibling spec's promised docs as UNDECLARED — failing a legitimate change
against an invariant nobody stated. The script therefore takes a
comma-separated list of ids: MISSING stays per spec, each contract
honoured in full and the report naming which spec's promise went unmet;
UNDECLARED is judged against the union; CI passes every spec the change
implements in one call. One spec per PR remains the recommended shape
(CONTRIBUTING), not a rule — a task may equally complete across several
pull requests, one spec each, and a merge that implements without
completing lands the task on `main` as `in-progress`: the one way that
status reaches `main`, surfaced by the lister as work to resume.
Rejected: forbidding multi-spec changes outright — the methodology
nowhere claims sibling specs are independently shippable, and a check
verifies a stated contract rather than inventing a stricter one.
