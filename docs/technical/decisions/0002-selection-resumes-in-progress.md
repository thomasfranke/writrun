# selection resumes `in-progress` before picking `pending`.

**2026-08-21**

Prevents abandoned half-done work from becoming invisible: without this, an
interrupted agent session leaves a task that no future selection pass will
ever surface. Ownership is defined per adopter; single-agent setups may
treat "this session" as the only owner.
