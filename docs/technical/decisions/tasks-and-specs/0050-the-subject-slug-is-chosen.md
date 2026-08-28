# the filename's subject slug is chosen, not sliced off the title.

**2026-08-28**

[0044](../github-issues/0044-a-proposed-task-and.md)'s sibling change gave queue files a
subject slug and left the generator deriving it: lowercase the title,
split on non-alphanumerics, keep the first three words. The first file it
produced under that rule was `task-0009-stamp-queued-and.md` — three
words, grammatical, ending on a conjunction that identifies nothing.

The slug's whole job is to answer "which of these is which" in a
directory listing. That is a judgement about the *queue* — what
distinguishes this task from the ones beside it — and a slice of one
sentence cannot make it. A title is written to read well as a sentence;
its first three words are chosen for grammar, not for contrast against
files the title's author was not looking at.

So the slug becomes an argument. Whoever creates the file chooses two or
three words; the generator derives them only when none is given, because
a mechanical name beats a missing file. This is the same split the
generator already runs on: it guarantees the *shape* — contract front
matter, canonical form — while the body and the project's extension
fields are the author's to fill. The filename joins the second list.

Rejected: a stop-word list, which would have turned
`stamp-queued-and` into `stamp-queued-merged` and left every other bad
slug intact — the problem is not conjunctions, it is that no algorithm
reading one title knows what the listing needs. Also rejected: renaming
files whose slug reads poorly, which identity forbids and which would
buy nothing: `task-0009` is already found by its id, and a listing is
improved for the next reader by the next file, not by rewriting history.
