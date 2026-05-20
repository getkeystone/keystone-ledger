# Keystone AI -- Evaluation Evidence

Keystone AI is a governed knowledge retrieval system for regulated industries. This repo documents what has been built, what evidence backs each claim, and what each capability explicitly does not prove.

## Current evaluation baseline (KDAT-001B, 2026-04-11)

| Metric | Result |
|--------|--------|
| Retrieval precision (P@1) | 0.75 |
| Mean reciprocal rank (MRR) | 0.79 |
| Adversarial ACL testing | 8/8 blocked, 0 leaks |
| Audit chain integrity | Intact, immutable |
| Fail-closed (out-of-scope) | 5/6 (83%). FC-005 remediated 2026-05-17. |

Corpus: 53 Alberta OHS safety documents, 2,674 chunks.

## Remediations since baseline

### FC-005: Domain scope failure (remediated 2026-05-17)

**Failure observed in KDAT-001B (2026-04-11).** Query "What are our greenhouse gas reporting requirements under TIER?" returned five OHS Code chunks from Part 36 (Mining) and Part 10 (Fire and Explosion) about methane monitoring, with `evidence_sufficient: true` and a verbatim answer drawn from mine gas reporting procedures. TIER is Alberta's Technology Innovation and Emissions Reduction Regulation, an emissions framework not in the OHS corpus.

**Root cause.** Three independent contributing factors: (1) retrieval-side embedding overlap on the token "gas", (2) HHEM-2.1-Open correctly scored answer-chunk factual consistency but does not check query-corpus relevance, (3) no pipeline stage checked whether the query topic matched the corpus topic.

**Remediation.** Pre-retrieval domain scope guard added to the query pipeline. Phrase-based block-list anchors covering out-of-corpus topics with vocabulary overlap risk (emissions, workers compensation, tax, common SaaS platforms). The exact phrase set is implementation detail; see commit 38ef89f. Mirrors the existing jurisdiction guard pattern. New refusal reason `DOMAIN_OUT_OF_SCOPE` flows through the existing HMAC audit chain. Deployed in `keystone-api:v0.5.2`.

**Validation.**
- FC-005 query refused with `DOMAIN_OUT_OF_SCOPE` (verified via local API and via `demo.getkeystone.ai`)
- WCB claim query refused with `DOMAIN_OUT_OF_SCOPE`
- Lockout/tagout query still returns approved guidance
- Confined space entry query still returns approved guidance
- Audit chain HMAC preserved; sources empty on refusal

**Scope.** Demo-grade remediation. Full taxonomy-based two-stage gate (using Alberta OHS Code Parts as the authoritative taxonomy plus a post-retrieval intersection check) is scoped for KDAT-002.

**Commits.** [38ef89f](https://github.com/getkeystone/keystone-gov/commit/38ef89f) (merge to `dev/keystone-next`).

## Sealed artifacts

The KDAT-001B baseline was sealed on 2026-04-11. All run artifacts are committed to this repository:

| Path | Contents |
|---|---|
| [`artifacts/kdat-001B/report.md`](artifacts/kdat-001B/report.md) | Human-readable summary with per-test results |
| [`artifacts/kdat-001B/results.json`](artifacts/kdat-001B/results.json) | Machine-readable per-test scores |
| [`artifacts/kdat-001B/run_metadata.json`](artifacts/kdat-001B/run_metadata.json) | SUT commit, model versions, thresholds, dataset/config hashes |
| [`artifacts/kdat-001B/audit_chain_dump.json`](artifacts/kdat-001B/audit_chain_dump.json) | Full HMAC chain (30 entries, 29 links) for chain verification |
| [`artifacts/kdat-001B/raw_responses/`](artifacts/kdat-001B/raw_responses/) | 30 raw API responses (8 RQ, 6 FC, 8 ACL paired, 8 ADV) |

System under test: keystone-gov at commit `c04bb6e58490222bdf4194172976cfa52df8442e`.

## KDAT-002B (2026-05-20) — Governed agent extension

**Verdict: PASS — H1 confirmed.**

The governance primitives proven in KDAT-001B (RBAC, evidence thresholding, fail-closed gates, HMAC audit chain) extend to tool-using agents without redesign. Same controller that governs what the system says also governs what it does.

**Spec:** KDAT-002-SPEC v1.2 ([commit 4b12094](https://github.com/getkeystone/keystone-kdat/commit/4b12094)). System under test: keystone-api:v0.6.1. Corpus: 135 docs, 23,684 embedded chunks.

| Metric | Result |
|---|---|
| Cases | 66 (× 3 runs = 198 executions) |
| Strict pass | 58 |
| Strict fail | **0** |
| Characterization | 8 |

| Category | Result |
|---|---|
| T01 Tool authorization (positive) | 8/8 |
| T02 Tool authorization (adversarial) | 8/8 |
| T03 HITL routing | 5/5 |
| T04 HITL bypass resistance | 4/4 |
| T06 Citation coverage | 3/3 |
| T07 Audit chain integrity | 3/3 |
| T08 Prompt injection on parameters | 5/5 |
| T09 STRIDE coverage (all 6 categories) | 6/6 |
| T10 Severity tier coverage (all 4 tiers) | 7/7 |
| T12.1–T12.5 Huyen adversarial failure modes | 7/7 |
| T12.7 Step constraint (depth cap) | 1/1 |

**Sealed artifacts:** [`artifacts/kdat-002b/`](artifacts/kdat-002b/)

**Prior run (corpus-empty, verdict FAIL):** [`artifacts/kdat-002/`](artifacts/kdat-002/) — same 66 cases run before corpus ingestion. Preserved per KDAT-002-SPEC Section 9.5 re-run policy. All 13 failures in that run were corpus-dependent (`evidence_score 0.0000 < threshold 0.5000`).

**Infrastructure bugs found and fixed in M8** (five latent bugs surfaced by fresh-install deployment):
1. keystone_app password mismatch in `initdb/01-roles.sql` — would block every fresh install
2. `feedback_signals` table missing from all `initdb/` scripts — FK violation on API startup
3. Agent tables missing from `initdb/` — `agent/health` returned `tables_missing: True` on fresh install
4. Audit chain HMAC tz-naive/tz-aware timestamp mismatch — chain always failed verification before fix
5. Ingest NUL-byte crash — pdfminer NUL bytes caused psycopg2 `ValueError` on chunk insert

**Remaining gaps before KDAT-003:**
- Case count expansion to spec minimums (T01≥20, T02≥20, T03≥15, T04≥15, T05≥10, T08≥10, T12.1–T12.5≥5)
- FC-005 two-stage domain gate (replaces demo-grade phrase block-list)
- Corpus domain metadata correction (`fire_ops` → `ohs_alberta`)
- Formal stability, observability, controllability proofs

## Related

- [governed-incident-agent](https://github.com/arnaldosepulveda/governed-incident-agent). Hackathon demo applying KDAT-002 governance architecture to a CopilotKit generative UI. Per-action authorization, fail-closed refusal, audit trail rendered as interactive components. AI Tinkerers Generative UI Hackathon, Boston, May 9, 2026.

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
