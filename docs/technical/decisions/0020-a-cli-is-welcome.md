# a CLI is welcome, as a separate repository, never as a dependency.

**2026-08-22**

The Distribution section (once titled "skills, not a
CLI") argued against
*replacing* skills with a binary, and those arguments stand — an agent
needs no porcelain. What it left unanswered is human-shaped: adopting a
repo in one command (`init`), updating copied skills (`update`),
verifying the forge settings the approve convenience depends on
(`doctor`), reading the queue without typing script paths (`list`) — and
opening the pull request each flow ends in (`author`, `take`, `finish`,
`amend`): branch name, Conventional-Commit title, template fields filled
from the diff, and the local checks run in their load-bearing order
first, refusing to open on anything non-zero. Two more: `init` installs
a commit-msg hook that validates the Conventional-Commit convention
(validation, never generation — the message belongs to whoever made the
change); and `work [task-id]` runs the selection algorithm and launches
whatever agent command the adopter configured, prompt pointed at
`AGENTS.md` and the task — the CLI launches agents, never is one, and
the gates are unchanged for what it launches. Packaging, never deciding
— and no `approve` command ever: that gate stays on the forge, operated
by a human on purpose. Those belong to a client, `writrun-cli`, in its
own repository: it wraps
the same scripts and files, reimplements no logic, and this repo works
identically without it. The contract it builds on — schemas, the
`docs/`+`work/` split, script arguments and exit codes — is declared in
Distribution; alpha means it moves without notice and a client pins.
Deferred to after the first adoptions: `init` and `doctor` should be
shaped by the friction swoop and TOM actually hit, not guessed. Two
intents are already fixed for them: `init` extracts the adopting repo's
existing conventions (its log, its CONTRIBUTING) into `.writrun/conventions/`
rather than imposing the shipped defaults, and grafts — never overwrites
— an existing `AGENTS.md`, into which WritRun's part enters as one
titled section fenced by `writrun:begin`/`writrun:end` markers; `update`
refreshes only what sits between those markers, preserving the lines
marked "yours" (the gates table, the deriving default); and `doctor`
guards the contract/taste boundary — the markers survived edits, the
declared merge policy matches the forge's settings.
Rejected: the CLI inside this repository — it would version the
methodology and its client together and make the optional look
mandatory.
