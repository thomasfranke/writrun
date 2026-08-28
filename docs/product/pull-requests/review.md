# Flow 5 — Review and merge

Everything after the pull request opens. The maintainer's assent — the
review, or the merge itself, whichever act the project named — is the
decision; CI records around it, the same shape as flow 2.

CI re-runs both checks on the PR. **They verify the methodology, not the
code** — that the diff touched every doc the spec promised and no other,
and that no status moved through a gate it should not have. Whether the
code works is the adopting project's own pipeline's answer; WritRun does
not duplicate it or stand in for it.

Each task the PR carries has its mirror follow it: `status:in-progress`
while the PR is still a draft, `status:in-review` once it is marked ready,
closed once a merge carries the task to `completed`. **`in-review` is a label of its own
rather than part of `in-progress`** because the two ask opposite things of
the maintainer — one means leave the worker alone, the other means the
maintainer is the blocker.

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#0d1117','primaryColor':'#161b22','primaryTextColor':'#e6edf3','primaryBorderColor':'#8b949e','lineColor':'#ffffff','secondaryColor':'#161b22','tertiaryColor':'#161b22','fontSize':'14px'}}}%%
flowchart LR
    P["PR opened<br/>(flow 4)"]
    G["CI<br/>writrun check<br/>re-runs both checks"]
    G2["CI<br/>writrun progress<br/>mirror: status:in-review"]
    H["MAINTAINER<br/>Review · squash-merge"]
    I["CI<br/>writrun progress<br/>mirror closed"]
    P --> G --> H --> I
    P --> G2
```


## The pull request dies

The unhappy half of review: closed without merging. Nothing was reserved,
so nothing needs releasing — the queue on `main` never changed.

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#0d1117','primaryColor':'#161b22','primaryTextColor':'#e6edf3','primaryBorderColor':'#8b949e','lineColor':'#ffffff','secondaryColor':'#161b22','tertiaryColor':'#161b22','fontSize':'14px'}}}%%
flowchart LR
    A["MAINTAINER<br/>closes the PR unmerged"]
    B["CI<br/>writrun issues<br/>authoring mirrors closed<br/>not planned · reopen restores"]
    C["CI<br/>writrun progress<br/>implementation task<br/>mirror: → status:ready"]
    D["Queue unchanged on main<br/>the task is anyone's again"]
    A --> B --> D
    A --> C --> D
```

A change belongs to flow 1, to flows 3–5, or to one special flow — never
more than one. One that closes the loop on one rule while introducing
another is two changes.

