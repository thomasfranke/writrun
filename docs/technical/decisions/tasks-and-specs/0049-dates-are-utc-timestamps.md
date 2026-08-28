# every queue date is a UTC timestamp, spelled with Z.

**2026-08-28**

Queue dates were `YYYY-MM-DD`. That cannot order two entries made the
same day, which in an active queue is most of them — this repository
created nine tasks and seven specs on one date, and their files record
no sequence at all. The selection algorithm sorts by `created` as its
second key, so on a busy day it was really sorting by id and pretending
otherwise.

Dates become RFC 3339 UTC timestamps: `2026-08-21T09:14:00Z`. **Always
`Z`, never an offset**, and that is the load-bearing half. Every reader
here is line-based `awk`/`sed`, and with one spelling a lexicographic
sort of these strings *is* a chronological sort. Allowing `+02:00`
alongside `Z` would keep `sort` looking correct while being wrong for
exactly the entries that crossed a timezone — the silent-wrong-answer
failure this schema's canonical form exists to prevent.

Migrating the files already in the queue widens precision that was never
recorded, so the hour is normalized to `T00:00:00Z` and is not a claim:
the date part is what those files ever knew. Recovering real times from
`git log` was rejected — the commit that introduced a file dates the
*commit*, not the moment the field meant, and a plausible-looking wrong
timestamp is worse than an obviously normalized one.

Rejected: keeping bare dates and breaking ties by id, which is what was
happening unstated — an ordering rule nobody wrote down and nobody could
have predicted from the docs. Also rejected: local times, which make two
machines disagree about the order of the same two files.
