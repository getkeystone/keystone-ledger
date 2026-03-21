# Keystone AI — KDAT Milestone Ledger

Keystone AI is a controlled procedure retrieval system for industrial safety and regulated operations. KDAT milestones are numbered capability deliverables. This repo is the public record: what was built,what test evidence backs each claim, and what each milestone explicitly does not prove. Every page carries an evidence class and a publication status.
Read those first. This is an evidence ledger, not a brochure.

The ledger tracks milestones through KDAT-051. 42 milestones are currently ready to publish. 41 have delivery commits on the tracked branch. 8 are curated summaries awaiting validation.

---

---

## What KDAT means

**KDAT = Keystone Delivery Acceptance Test**

A KDAT is a numbered Keystone milestone with explicit scope, verification, evidence quality, and publication status. The KDAT sequence is used to track what is historically established, what is proven on the current branch, what is still under review, and what is not yet safe to claim publicly.

KDAT milestones are numbered capability milestones in the Keystone AI development program. Each milestone defines a discrete technical capability that can be demonstrated and verified. Milestones are numbered sequentially (KDAT-001A, KDAT-002, KDAT-003, …) and may have sub-milestones (011A, 011B,
011C).

Keystone AI is a controlled procedure retrieval system for industrial safety and regulated operations.

---

## How to read this repo

Each milestone has a page in [milestones/](milestones/). Every page has:

- **Status** — current lifecycle state
- **Evidence class** — how strong the backing evidence is
- **What this proves** — exactly what was demonstrated
- **What this does NOT prove** — explicit scope limits
- **Public-safe claims** — language safe to use externally
- **Verification** — tests and smoke locks cited

Before citing any milestone, read the full page. Pay particular attention to the evidence class and the "does NOT prove" section.

---

## Evidence classes

Evidence class is the most important signal on any milestone page.

| Class | Meaning |
|-------|---------|
| **Proven on current branch** | Delivery commits exist on the tracked branch, test scripts pass, smoke locks in place |
| **Historical baseline** | Pre-dates the current branch; referenced as prior work foundation |
| **Curated summary** | Derived from a human summary; no branch commits in this log to directly verify |
| **Doc-only reference** | Appears in documentation but no dedicated technical delivery commit |
| **Underdocumented** | Some evidence exists but insufficient to fully characterize the milestone |
| **Unknown** | Insufficient evidence; status not determinable from available data |

Curated summary is NOT the same as proof. Doc-only is NOT the same as delivered
technical capability.

See [docs/evidence-classes.md](docs/evidence-classes.md) for full definitions.

---

## No overclaiming

This repository will not claim:

- Enterprise readiness unless explicitly proven
- High availability or disaster recovery unless a milestone proves it
- Multi-node or distributed deployment unless a milestone proves it
- OIDC, ABAC, or production-hardened identity unless a milestone proves it
- Any capability "in production" unless deployment evidence exists

When evidence quality is weaker, the page says so.

---

## Current snapshot

### LRFD Pilot (feature/pilot-enhancements)

Generated from branch `feature/pilot-enhancements` (2026-03-18).

| Category | Count |
|----------|-------|
| Proven on current branch | 41 |
| Historical baseline | 2 |
| Curated summary | 8 |
| Doc-only reference | 1 |
| Unknown (gap) | 1 |

### Alberta Demo (dev/keystone-next)

Generated from branch `dev/keystone-next` (2026-03-21).

| KDAT | Title | Status |
|------|-------|--------|
| KDAT-070 | Config-Driven Deployment Architecture | Proven |
| KDAT-071 | Generic Procedural Reranker | Proven |
| KDAT-072 | Alberta OHS Corpus Ingestion (57 docs, 2,717 chunks) | Proven |
| KDAT-073 | Public Demo Deployment (demo.getkeystone.ai) | Proven |
| KDAT-074 | Professional UI Theme | Proven |
| KDAT-075 | Security Hardening Pass 1 (7 critical/high fixes) | Proven |
| KDAT-076 | Prompt Injection Mitigation (10/10 blocked) | Proven |
| KDAT-077 | Retrieval Quality Eval Harness (19/20, 95%) | Proven |
| KDAT-078 | Hybrid Weight Optimization | Proven |
| KDAT-079 | Backup and Restore (scripts exist, no drill) | Proven (partial) |
| KDAT-080 | Ingest Metadata Preservation | Proven |

Live demo: [demo.getkeystone.ai](https://demo.getkeystone.ai)

Branch HEAD SHAs at generation time:
- keystone-gov: `c0a9a27`
- keystone-console: `3e4f589`
- keystone-deploy: `bcf7a9f` (includes KDAT-038–051)
- dev/keystone-next: `2fab85a5898def8eab55ab5b100f209b30657b1d`

---

## Navigation

- [All milestones](milestones/README.md)
- [Claims matrix](docs/claims-matrix.md)
- [Roadmap](docs/roadmap.md)
- [By status](index/by-status.md)
- [By evidence class](index/by-evidence-class.md)
- [By capability](index/by-capability.md)
- [Timeline](index/timeline.md)
- [Publication policy](docs/publication-policy.md)
- [Evidence class definitions](docs/evidence-classes.md)
