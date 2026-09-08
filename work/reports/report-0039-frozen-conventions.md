---
id: report-0039
status: authored
task_ref: []
doc_ref: product/adoption.md#two-homes
created: 2026-09-08T16:44:40Z
triaged: 2026-09-08T17:10:00Z
---

# A convention the kit improves reaches no adopter

**References:** [product/adoption.md](../../docs/product/adoption.md#two-homes) · [technical/distribution/kit.md](../../docs/technical/distribution/kit.md)

The seven conventions ship once, into the adopter's home, and the home
an update never touches is the only place they exist. Between v0.0.04
and v0.0.06 they had exactly one content change — `specs.md` and
`tasks.md` each fix the address of the template override, retired when
the adopter's files left the kit's home:

```
-`.writrun/conventions/templates/spec.md` — it wins over the shipped default
+`writrun/conventions/templates/spec.md` — it wins over the shipped default
```

An adopter who took the kit at v0.0.04 holds a `conventions/specs.md`
pointing at the retired address, `writ update` to v0.0.06 cannot
correct it — `writrun/` is the home it never touches, by the two-homes
rule itself — and no future release can either. The fix exists,
released, and reaches nobody.

The folder mixes two kinds of text with different lives. Taste —
title style, branch grammar, prose rules — is genuinely the adopter's
and needs no updates. Restated contract — `prs.md` describing the
`## Derived work` marker and what `auto_push` carries, `specs.md`
naming the override address the generator honours — has to track the
kit it describes, and sits where no release reaches it. Every restated
sentence in the adopter's home is frozen at the version that seeded it.
