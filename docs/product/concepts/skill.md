# Skill

A skill is **when to run something, and how to read what it says**. It
lives in `.writrun/skills/<name>/SKILL.md`, and a session loads it whole
when its trigger fires.

## Why a skill is held to a tighter standard than a doc

A permanent doc is read once, by the reader who needs it. A skill is
read by **every** session its trigger fires for, whether or not the
sentence that session needed was in there. The cost is paid per session;
the value is not.

That asymmetry is the whole rule below. A skill that restates its
chapter does not become more helpful — it becomes a second copy of the
same rule, billed to every session, drifting from the first the moment
only one of them is updated.

**The same arithmetic holds for any file a session loads
unconditionally**, whatever it is called — a repository's agent entry
point is read before every task, so a sentence only some tasks need is
billed to all of them. The rule below is written for skills because
they are what the methodology ships; it is owed by anything read on the
same terms.

## What belongs in one

- The trigger, in the front-matter `description` — the retrieval key,
  and the one part whose length earns itself.
- The command to run.
- How to read what it prints: each exit code, each section, what each
  asks the reader to do next.
- The judgements the script cannot make.

## What does not

- **A rule a permanent doc owns.** It stands once, in that doc, and the
  skill links there. This is the
  [link-don't-restate rule](technical-doc.md#the-link-dont-restate-rule)
  applied to skills, for the same reason it exists for technical docs.
- **The steps of an algorithm a script implements.** The script is the
  authority. Prose beside it is a second authority, wrong from the first
  change nobody mirrors.
- **Anything a reader can reach by following a link.** A skill is a
  pointer with instructions, never a summary of what it points at.

## Criteria

- When a skill states a rule a permanent doc owns, it shall link to that
  doc instead of restating it.
- When a script implements an algorithm, its skill shall name the script
  and how to read its output, and shall not restate its steps.
- When a skill is loaded, every sentence it carries shall be one the
  session needs to act — the trigger, the command, the output's meaning,
  or a judgement no script makes.
