# Keystone AI — Evaluation Evidence

Keystone AI is a governed knowledge retrieval system for regulated industries. This repo documents what has been built, what evidence backs each claim, and what each capability explicitly does not prove.

## Current evaluation baseline (KDAT-001B, 2026-04-11)

| Metric | Result |
|--------|--------|
| Retrieval precision (P@1) | 0.75 |
| Mean reciprocal rank (MRR) | 0.79 |
| Adversarial ACL testing | 8/8 blocked, 0 leaks |
| Audit chain integrity | Intact, immutable |
| Fail-closed (out-of-scope) | 5/6 (83%) |

Corpus: 53 Alberta OHS safety documents, 2,674 chunks.

## What is not claimed

- Enterprise HA or disaster recovery
- Multi-node or distributed deployment
- OIDC/SAML production identity integration
- Third-party penetration testing
- WCAG accessibility compliance

When evidence quality is weaker, the milestone page says so.

## Evidence classes

Each milestone page carries an evidence class indicating how strong the backing evidence is.

| Class | Meaning |
|-------|---------|
| Proven on current branch | Delivery commits exist, test scripts pass |
| Historical baseline | Pre-dates current branch; referenced as prior work |
| Curated summary | Derived from human summary; no branch commits to directly verify |

See [docs/evidence-classes.md](docs/evidence-classes.md) for full definitions.

## Milestone index

Milestones are numbered capability deliverables (KDAT-001 through KDAT-101). Each milestone page in [milestones/](milestones/) documents scope, verification, what was proven, and what was not proven.

- [All milestones](milestones/README.md)
- [By status](index/by-status.md)
- [By evidence class](index/by-evidence-class.md)
- [By capability](index/by-capability.md)

## Links

| | |
|---|---|
| Live demo | [demo.getkeystone.ai](https://demo.getkeystone.ai) |
| Website | [getkeystone.ai](https://getkeystone.ai) |
