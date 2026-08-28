# the queue is printable, not just selectable.

**2026-08-22**

The sort was
declared advisory for a person, and a suggestion nobody can see is not a
suggestion. `list_tasks.sh` prints the eligible set, what must be resumed
first, what is held back with the reason for each, and what is already in
flight — so a developer chooses from the queue instead of asking an agent
to choose for them. Completed tasks are omitted from "held back" rather
than listed as obstacles: that list would otherwise grow with the project
until it buried the part needing attention. Rejected: having the skill's
prose ask the agent to enumerate the queue by hand — the filters are
exactly the mechanical, self-grading-prone step the other scripts exist
for.
