# the adopter's files leave the kit — ownership is per home, not per file.

**2026-09-07**

[0053](0053-settings-at-the-root.md) put `settings.json` at the root of
`.writrun/` — one known address ends the hunt — and left `gates.md` and
`conventions/` beside it, each row of a README table saying which files
an update may touch. [Two homes](../../../product/adoption.md#two-homes)
replaced that per-file split with a per-folder one, and this entry
records the move: the adopter's files — `settings.json`, `gates.md`,
`conventions/` — now live in `writrun/`, the project's home, and
`.writrun/` is the kit's whole, replaced entire on update.

The reasons, in order of weight:

- **A README table is trust; a folder boundary is structure.** Per-file
  ownership asked every reader — and the future `writ update` — to
  consult a list before touching anything under `.writrun/`. Per-home
  ownership needs no list: the path is the answer.
- **The mirror loses its exceptions.** `settings.json` and `gates.md`
  were the two files `tests/template_exceptions.txt` stashed and
  restored around every sync, because the kit ships them cautious while
  this repository's carry its own answers. Outside the mirrored path,
  the seed (`template/writrun/`) is written deliberately and the
  machinery stands ready but unexercised.
- **Removal becomes three deletions.** With no adopter file inside it,
  `.writrun/` deletes whole; `writrun/` stays untouched — the rule's
  removal contract falls out of the layout instead of being enforced
  against it.

0053's other half stands: the keys stay sectioned by stage, and the
one-address rule still holds — the address just crossed the fence. The
reader honours both old homes as migration bridges: a file still at
`.writrun/settings.json` is read as-is, one at the pre-0053 address
`.writrun/conventions/settings.json` is read flat under the contract
frozen there, and `check_settings.sh` names each move.
