# the vocabulary is read where the value is — one home in the kit for the checker and the reader, and a free-form key answers empty.

**2026-09-17**

The settings vocabulary lived as bash variables inside
`check_settings.sh`, and nothing read them but that check. A porcelain
could therefore write a value and be judged — the right shape, and the
one that keeps the kit the single authority — but it could not **offer**
the choices before the write. To show them it would have to hold them,
and a copy outside the kit is a second authority that drifts on the next
update. So a config screen either shipped that copy or let the reader
pick blind and learn the vocabulary from a refusal: *"pr_title_style 'x'
is outside its vocabulary: conventional bracketed"*, a good sentence
arriving one step too late (report-0045).

The lists now sit in `ql_vocabulary`, keyed by the key's documented
address, and both sides read them there: `check_settings.sh` refuses
what the home does not name, `read_setting.sh --vocabulary` prints what
it does.

- **In `queue_lib.sh`, not beside the checker.** A helper two scripts
  share has one copy and that copy is the lib
  ([0072](../pull-requests/0072-a-shared-helper-has-one-copy.md)). The
  checker keeping the list and the reader asking the checker for it
  would make a gate into a data file for its own callers, which is the
  shape `take_task.sh` and `session_card.sh` had already grown against
  the commit vocabulary before it became a setting.
- **On the reader, not as a mode of the checker.** The chapter's
  sentence is already *the reader reads, the checker judges*: a flag on
  `read_setting.sh` keeps a caller asking one script two questions about
  one key, and keeps the judging script out of the path of a screen that
  has nothing yet to judge.
- **Empty means free-form, never unknown.** `commit_types` and
  `commit_scopes` are shapes — lower-case words, space-separated — and a
  shape is not a list. They answer nothing, exactly as an address the
  schema does not document answers nothing, so a caller has one grammar
  to read: values, or none. The alternative was a second vocabulary
  about vocabularies, spelling *free-form* in a word some porcelain
  would then have to recognise.
- **The table is held to the home by the suite.** `schema.md`'s Values
  column is where a person reads the vocabulary and `ql_vocabulary` is
  where the machinery does; a case parses the first and compares it to
  the second, key by key, so a value added to one alone fails a test
  rather than a reader.

Rejected: a `--list` mode on `check_settings.sh`, which would put the
offer behind the judge; shipping the vocabulary as a data file under
`.writrun/`, which is a third form of the same fact and no easier to
read than a function; and answering a free-form key with a shape word,
which trades one silent copy for one silent parser.
