# Flow 4 — Finishing a task

The work itself, then the loop. A task derived from an authored rule exists
to bring the **code up to a doc that already states it** — there is nothing
to update, and its spec promises no product change. A task that originated
elsewhere, in the code or the machinery, carries its doc change with it.

The agent drives the queue mechanics throughout — status, Outcome, the local
checks — because it is what holds the algorithm. **Only the work itself is
delegable.**

The two checks sit on either side of the status change, and that order is
load-bearing. `writrun-check-spec-deltas` verifies the doc contract and can run as
soon as the work is done. `writrun-check-task-state` has nothing to read until the
statuses move — every rule it has is about a transition, so running it first
passes without checking anything.

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#0d1117','primaryColor':'#161b22','primaryTextColor':'#e6edf3','primaryBorderColor':'#8b949e','lineColor':'#ffffff','secondaryColor':'#161b22','tertiaryColor':'#161b22','fontSize':'14px'}}}%%
flowchart LR
    C["AGENT or HUMAN<br/>Task carried out<br/>the code now matches the doc"]
    D["AGENT<br/>writrun-check-spec-deltas<br/>the doc contract, exit 0"]
    E["AGENT<br/>Outcome filled<br/>spec: → implemented<br/>task: → completed"]
    F["AGENT<br/>writrun-check-task-state<br/>the transitions E just made<br/>exit 0 · open PR"]
    C --> D --> E --> F
```

