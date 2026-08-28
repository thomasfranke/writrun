# `blocked` is a status, not a folder or a tag.

**2026-08-21**

Consistent
with "status lives in front-matter" and "identity is never order". Paired
with mandatory `blocked_reason` so a blocked task always states its own
unblock condition. Rejected: a separate `blocked/` folder (breaks the
no-file-moves rule) and overloading `depends_on` with non-task blockers
(destroys its machine-checkability).
