# the push is its own act, and gets its own flag — completing 0054.

**2026-08-31**

[0054](0054-the-adopter-governs-the-agent.md) gave the adopter a word on
the agent's git conduct: `auto_commit` for the commit, `auto_pr` for the
pull request. It named the two artifacts a reviewer can see and stopped
there, and the act between them — the push — was left to inference. The
inference even sounded reasonable: a push to the head branch is the only
way an open pull request updates, so it read as `auto_pr`'s, and a
branch's first push read as nobody's.

**The flags name acts, and the act that makes work public had none.** A
commit is private; a pull request is already a conversation. Between them
sits the moment an adopter's work leaves their machine for someone else's
server, and it is the last moment anything can be taken back quietly.
That is the act a cautious adopter means to hold — and it was precisely
the one no key addressed.

The taking flow shows the cost. It pushes the branch and *then* opens the
draft, so under `auto_pr: false` the branch was already on the forge when
the gate was reached: what waited for the word was the pull request
alone, half a step behind the act the gate exists to hold. The adopter
who most wanted this — someone whose repository is private, or whose work
is under embargo — got the weaker half of what they asked for.

So `auto_push`, a third conduct flag in `stage_2` beside the other two,
default `true`, which is the behaviour from before the key existed.
Nothing else about the conduct flags moves: `false` gates the action and
never the work, approval is per action, and all three outrank the agent
platform's own autonomy mode
([0054](0054-the-adopter-governs-the-agent.md),
[0055](0055-conduct-flags-live-in-stage-2.md)).

**Before a pull request exists, the push and the opening are one act,
gated once.** The agent presents the branch, the title and the body
together and puts nothing on the forge before the word; `false` on either
flag holds all of it. Two prompts for one moment is not a stricter gate —
it is the same gate asked twice, and the second question has no answer
the first did not already give. Once the pull request is open the acts
separate again: a further push to its head branch is `auto_push`'s alone,
because `auto_pr` has been answered and what is being gated again is work
becoming visible.

Rejected: folding the push into `auto_pr` by documenting that the flag
covers "the push and the pull request". That is a setting whose name
describes one act and whose rule governs two — the shape
[0052](0052-settings-carry-the-choice.md) restated as *a setting
controls, it never merely describes*. It would also have no answer for a
push on a branch that never becomes a pull request: a docs branch, a
report branch, a spike pushed for a colleague to look at. Those make work
public the same way, and the gate is about that, never about what kind of
work it is.

Rejected: gating the push at the git layer instead — a hook, or a
credential the agent does not hold. Both work, and neither is this
methodology's to install: the conduct flags bind the agent because the
adopter said so in a file the agent reads, which is what makes them
portable across every platform an agent might run on. A hook binds
whoever's machine it is on, which is a different promise.
