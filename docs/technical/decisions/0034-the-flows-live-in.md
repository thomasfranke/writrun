# the flows live in the permanent docs; the README summarizes.

**2026-08-23**

The five flows and their special cases — validated by
the maintainer, and declared the source of truth for the mechanics —
lived in the README, which is not under `docs/`: the one surface the
machinery guards. Nothing there is checkable — `check_deltas` cannot
demand it, the derived-work gate does not read it, queue impact never
crosses it. The flows moved verbatim into
`docs/product/pipeline.md#flows-and-statuses`; the README keeps a
one-line-per-flow sketch and links. Rejected: keeping both in full —
restatement is drift by construction, and the mirror regression above
is what that costs; and `technical/` as the home — the flows name
actors and gates, stakeholder-facing behaviour, while the machinery
each node invokes stays linked from here.
