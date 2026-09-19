---
id: report-0049
status: open
task_ref: []
doc_ref: null
created: 2026-09-19T21:55:29Z
triaged: null
---

# The routing section names one destination, and a defect in the binary has another

Issue #288, opened by @thomasfranke.

### What was observed

`.writrun/AGENTS.md`, *When the defect is WritRun's*, gives a routing agent one address: "open the issue on the repository this kit came from — <https://github.com/thomasfranke/writrun>, the provenance pointer `WRITRUN.md` carries". `WRITRUN.md` carries that same address and nothing else.

A defect in the `writrun` binary has another home — <https://github.com/thomasfranke/writrun-cli> — and no text the kit ships names it. An adopter's agent following the section literally files a `doctor` bug into the methodology's queue.

The same section states the submission's shape in one clause: "the title states the observation, the body carries the evidence and the tag in `.writrun/VERSION`". The form the kit ships, `.github/ISSUE_TEMPLATE/writrun-report.yml`, asks for those three fields and is the *receiving* repository's; the routing agent composing an issue by hand reads the clause alone.

### Evidence

`thomasfranke/writrun-cli#168`, composed by an agent in an adopter project running WritRun v0.0.09 through `writrun-cli v0.0.3`, and now `report-0048` there.

- **It reached the right repository, which no instruction named.** The finding's subject was the binary's `doctor`, and the agent addressed `writrun-cli` on its own judgement.
- **Its first sentence states the consumer's implementation, and states it wrong:** "`doctor`'s stage-2 forge checks read only `/repos/{owner}/{repo}/rulesets`". The checks read `repos/{owner}/{repo}/rules/branches/main`, and `rulesets/{id}` only for a bypass list. The claim was inferred from the output rather than observed. The finding itself stands — neither endpoint reports a classic branch protection rule — but the sentence a maintainer reads first is not a fact.
- **Its evidence went stale in nine minutes.** The issue reports a classic branch protection rule on `thomasfranke/tom` at 21:28Z; a branch ruleset was created there at 21:37Z and the classic rule removed. The issue does not say which repository state it was read against, so a maintainer reproducing it today finds a different repository and no defect.

Neither miss is a reporter being careless: the instruction asks for a title, evidence and a tag, and all three were given.

### Version consumed

`.writrun/VERSION` — v0.0.09.

