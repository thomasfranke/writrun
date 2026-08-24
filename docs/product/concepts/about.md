# About

An About file is the one document every audience reads first: the person
deciding whether to approve a spec, the contributor picking up a task, the
agent starting a session with no memory of the last one. It answers **what
this project is** — never what it does (that's [a product doc](product-doc.md))
and never how it's built (that's [a technical doc](technical-doc.md)).

This repository's own [`docs/about.md`](../../about.md) is a working
instance of everything below, not a separate thing to also read.

## What it holds

- **The gap it fills** — the problem the project exists to solve, in enough
  words to tell it apart from adjacent alternatives, not a feature list.
- **Personas** — who reads the rest of the documentation, and what each of
  them is trying to answer when they open it.
- **Non-goals** — what the project refuses to become. Stated with the same
  weight as a feature, because it is a decision, not an absence of one.
- **Principles** — the handful of structural commitments every other
  document assumes without re-arguing them.
- **Vocabulary** — the nouns the rest of the documentation is written in,
  defined once, here, and never redefined downstream.
- **Where to find what** — a map to the permanent docs and to the queue in
  `work/`, never a summary of their contents.

## What it never holds

- **A checkable rule.** The moment a sentence can be judged "the repo
  complies, yes or no," it is a product rule and belongs in a `product/`
  chapter, not in About.
- **Implementation detail.** Schemas, algorithms, file formats belong to
  `technical/` — About may say a technical doc exists; it never explains
  what's in one.
- **A restatement of `product/` or `technical/`.** If either changes, About
  should not need to change with it — that dependency, if it exists, is a
  sign something is written in the wrong file.

## Why it stays short

About is read by every audience, every session — the cost of a bloated or
stale About file is paid by every reader, every time, not once. A project
whose About file has grown a table of contents has stopped being an About
file: something in it belongs in `product/` or `technical/` and should move
there in the same change that catches the growth.
