# canonical front matter is enforced, not assumed.

**2026-08-23**

The
line-based readers are the portability choice, and they were an
assumption: YAML allows the same meaning in forms `sed -n 's/^status:
*//p'` cannot see — a block list under `spec_ref:` reads as *no
specs*, which would hand out a task whose approval gate was never
passed; a quoted `doc_ref` matches no path comparison; a folded
`blocked_reason` reads as nothing. Silent every time, and silent
wrongness is this repository's named worst case. Rather than teach
every reader more YAML, the canonical form became a checked contract:
`check_front_matter.sh` validates shape (one `key: value` per line,
bare values, inline lists), schema (every field exactly once, closed
status and priority vocabularies, `blocked`/`blocked_reason` paired
both ways, `YYYY-MM-DD` dates, `doc_ref` relative to `docs/`), and
identity (`id` agrees with the filename) — run by `writrun check`
before the lifecycle rules, which is what makes those rules'
line-based reads legitimate. Unknown keys in canonical shape pass: an
adopter may extend the schema, not reshape it. Rejected: a YAML
parser dependency (the portability non-goal), teaching each reader
the alternate forms (half a parser in awk, and the ceiling only
moves), and stating the rule as prose (a contract nobody executes is
the assumption again, wearing a heading).
