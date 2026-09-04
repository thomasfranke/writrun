# Observance

**How obedience to the declared settings is checked** — where disobedience leaves a trace, and only there. One chapter of [`settings/`](README.md).

## Observance is checked where it leaves a trace

A conduct flag binds the agent, but only some disobedience is visible
afterwards — and what is visible is checked, not trusted. From Stage
2, `writrun check` fails a pull request whose title ignores the
declared `pr_title_style`, and one that disagrees with `agent_coauthor`
**in either direction** — commits or a body carrying credit while the flag
is `false`, or an agent's commit lacking the model-naming
`Co-Authored-By:` trailer while it is `true`. The second direction is only
checkable because the flag now names an artifact rather than deferring to
whatever a platform appends, and it reads commits alone: a trailer has a
fixed shape and a place, a body's credit line has neither, so the body's
obligation at `true` stays instruction-bound. What leaves no trace at all
(`auto_commit`, `auto_pr` — whether the agent *asked*) is not checked: no
diff can show a question that wasn't asked, and no check infers one.

`check_observance.sh` is where both live. The title check strips the
`[TASK-NNNN]` tags — not the settable part — and reads what is left
against the declared style: the type against the vocabulary
`conventions/commits.md` carries, the scope against it too when one is
present, and nothing about the summary. Case inside a bracketed label
is not judged, because the convention writes both `[Fix]` and `[DOCS]`.
The credit check reads the pull request's own commits and body — never
`main`'s past, since nothing rewrites history — and skips the
machinery's recording commits **by committer identity**, not by subject.
The subject is now the machinery's own, and constant whatever the title
style says — but reading it would still be the wrong
test: a subject is text, and what makes those commits exempt is who
wrote them, which only the identity says.

**The `true` direction's unit is the pull request, and it has to be.**
Judging per commit would need a signal that does not exist: an agent
commits under whoever ran it, with the same name and the same email as
any other work of theirs, and the check is handed a title, a body and a
range. So the declaration is read where one exists — at `true` the flag
obliges a credit line in the body, and that line is the pull request
saying an agent worked it. When it is there, every commit that is not the
machinery's owes the trailer; when nothing declares agent work, no commit
is judged and the run says so.

That keeps the rule that matters: a human's pull request is asked for
nothing, because using an agent is not obligatory and a check demanding
the trailer everywhere would read absence as disobedience. It costs the
converse — a person's commit on a declared-agent branch is asked for the
trailer too, which is the trade
[0057](../decisions/pull-requests/0057-the-credit-flag-names-its-artifact.md)
records. What the direction catches is partial compliance; what it cannot
catch is an agent that credits itself nowhere, and no check infers that
either.

**A category is not a model.** `Co-Authored-By: AI` satisfies any trailer
regex and answers nothing a quarter later, which is the whole reason the
trailer is worth reading — so a small vocabulary of category words, bare
family names among them, is refused. It is a tripwire and not a proof: a
name written to evade it evades it, exactly as the core-rule stems in
`check_settings.sh` do.

The ledger itself is not checked here. It is a queue field an agent
writes, not a trace left in the forge, and `provenance_ledger` gates
whether it exists at all — a project declaring `false` has nothing for a
check to read, which is a legal state and not a fault.

