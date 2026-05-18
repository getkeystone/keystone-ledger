# Keystone Applied Intelligence — Evaluation Evidence

Keystone Applied Intelligence is a governed knowledge retrieval system for regulated industries. This repo documents what has been built, what evidence backs each claim, and what each capability explicitly does not prove.

## Current evaluation baseline (KDAT-001B, 2026-04-11)

| Metric | Result |
|--------|--------|
| Retrieval precision (P@1) | 0.75 |
| Mean reciprocal rank (MRR) | 0.79 |
| Adversarial ACL testing | 8/8 blocked, 0 leaks |
| Audit chain integrity | Intact, immutable |
| Fail-closed (out-of-scope) | 5/6 (83%) — FC-005 remediated 2026-05-17 |

Corpus: 53 Alberta OHS safety documents, 2,674 chunks.

## Remediations since baseline

### FC-005: Domain scope failure (remediated 2026-05-17)

**Failure observed in KDAT-001B (2026-04-11).** Query "What are our greenhouse gas reporting requirements under TIER?" returned five OHS Code chunks from Part 36 (Mining) and Part 10 (Fire and Explosion) about methane monitoring, with `evidence_sufficient: true` and a verbatim answer drawn from mine gas reporting procedures. TIER is Alberta's Technology Innovation and Emissions Reduction Regulation — an emissions framework not in the OHS corpus.

**Root cause.** Three independent contributing factors: (1) retrieval-side embedding overlap on the token "gas", (2) HHEM-2.1-Open correctly scored answer-chunk factual consistency but does not check query-corpus relevance, (3) no pipeline stage checked whether the query topic matched the corpus topic.

**Remediation.** Pre-retrieval domain scope guard added to the query pipeline. Phrase-based block-list anchors (greenhouse gas, emissions reporting, carbon pricing, WCB claim, workers compensation, T2 corporate, income tax filing, Microsoft 365, Office 365). Mirrors the existing jurisdiction guard pattern. New refusal reason `DOMAIN_OUT_OF_SCOPE` flows through the existing HMAC audit chain. Deployed in `keystone-api:v0.5.2`.

**Validation.**
- FC-005 query refused with `DOMAIN_OUT_OF_SCOPE` (verified via local API and via `demo.getkeystone.ai`)
- WCB claim query refused with `DOMAIN_OUT_OF_SCOPE`
- Lockout/tagout query still returns approved guidance
- Confined space entry query still returns approved guidance
- Audit chain HMAC preserved; sources empty on refusal

**Scope.** Demo-grade remediation. Full taxonomy-based two-stage gate (using Alberta OHS Code Parts as the authoritative taxonomy plus a post-retrieval intersection check) is scoped for KDAT-002.

**Commits.** [38ef89f](https://github.com/getkeystone/keystone-gov/commit/38ef89f) (merge to `dev/keystone-next`).

## In development

Governed agent extension (KDAT-002): tool authorization by role, action audit trails, HITL approval gates, multi-step reasoning with per-step evidence. Same governance primitives applied to tool-using agents.

Planned remediations for KDAT-002:
- FC-005: two-stage gate with OHS Code Parts as the taxonomy (replaces the demo-grade phrase block-list)
- Sealed re-evaluation of FC-001 through FC-006 with the gate enabled
- Adversarial set expansion (out-of-corpus, in-corpus wrong-Part with shared vocab, border queries spanning multiple Parts, false-refusal probes)

## Related

- [governed-incident-agent](https://github.com/arnaldosepulveda/governed-incident-agent) —
  Hackathon demo applying KDAT-002 governance architecture to a CopilotKit generative UI. Per-action authorization, fail-closed refusal, audit trail rendered as interactive components. AI Tinkerers Generative UI Hackathon, Boston, May 9, 2026.

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
| Org profile | [github.com/getkeystone](https://github.com/getkeystone) |
| Contact | [arnaldo@getkeystone.ai](mailto:arnaldo@getkeystone.ai) |
