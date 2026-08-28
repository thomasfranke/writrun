# generated shapes resolve in layers: the project's, then `.writrun/`, then the script.

**2026-08-22**

The body a generator writes is the kind
of default that evolves with the methodology, and a default copied once
never updates — so it lives in a refreshable layer: `new.sh` takes
`.writrun/conventions/templates/{task,spec}.md` when the project defined one
(authority, visible, the adopter's), falls back to the shipped default
in `.writrun/templates/` (machinery's layer, `writ update`'s future
target, never hand-edited), and finally to its own built-in skeleton so
the script works in a bare repository. Front-matter is never templated
— it is contract — and a spec template must keep the two
Proposed-changes headings and Outcome or generation refuses: a shape
that drops them would blind the delta check silently. A dot-folder does
not contradict "authority does not hide": the WritRun-owned parts of
`.writrun/` hold defaults, not authority — the project's layer wins,
always — and `.writrun/conventions/` is that project layer, the
adopter's from the moment of adoption (a root `conventions/` was tried
first and rejected: dropped into a foreign repo it reads as a second,
unprovenanced set of commit and PR conventions beside the project's
own; under `.writrun/` the origin and the purpose are unmissable).
What cannot consolidate is what the platform dictates — workflows in
`.github/`, `AGENTS.md` at the root — and each such file declares in
its own header that WritRun shipped it. The PR template escaped that
list because agents consume its *content* while only GitHub consumes
the workflows': it lives solely in `.writrun/templates/`, and GitHub's
pre-fill (which reads `.github/`, `docs/`, or the root, and nowhere
else) is deliberately forgone — the flows' PRs are written by agents,
and a human opening one by hand is guided by the derived-work check's
own failure message. Rejected: a `.github/` projection kept
byte-identical by a test — it worked, but two copies of one file inside
one repository is the disease this project exists to treat, and the
pre-fill was not worth the carrier.
