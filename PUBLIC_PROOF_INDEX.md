# Public Proof Index

The externally-citable subset. Every row is `OK` in the claims matrix and
backed by a sealed artifact or a public link. Regenerated from claims marked
Ready to publish / OK — nothing `CHECK`, `UNSOURCED`, `BROKEN`, or `STALE`
appears here. If it is not in this table, do not cite it publicly.

Generated: 2026-07-15. Public repos only (keystone-ledger, keystone-verify).

## Retrieval — `keystone-core/retrieval-v1` (sealed 2026-04-11)

| Claim | Evidence | Public link |
|---|---|---|
| P@1 = 0.75, MRR = 0.79 | retrieval-v1 sealed run | github.com/getkeystone/keystone-ledger |
| 8/8 adversarial ACL probes blocked, 0 leaks | retrieval-v1 | keystone-ledger |
| Fail-closed 5/6 (83%); FC-005 domain-scope guard merged (demo-grade), re-verification not yet sealed | retrieval-v1 + README §FC-005 | keystone-ledger#fc-005-domain-scope-failure-remediated-2026-05-17 |
| 53 documents, 2,674 chunks; audit receipts logged (chain re-verification pending) | retrieval-v1 | keystone-ledger |

## Agent evaluation

| Claim | Evidence | Public link |
|---|---|---|
| 186 cases, 12 categories, 558 executions, 0 failures | `keystone-core/agent-v1` | keystone-ledger |
| 153 strict pass, 33 characterization | agent-v1 | keystone-ledger |
| Sealed failing run: 66 cases surfaced 4 real bugs | `keystone-core/agent-v0` (kept beside agent-v1) | keystone-ledger |
| Engage 100/100 (core 70/70, arch 25/25, edge 5/5); v0 96/100 (3 bugs + 1 non-determinism) | `keystone-engage/agent-v1`, `agent-v0` | keystone-ledger |

## Architecture (only claims currently OK)

| Claim | Evidence | Public link |
|---|---|---|
| Hash-chained HMAC audit ledger | code + agent-v0 (the caught HMAC bug is the proof it verifies) | keystone-ledger |
| ACL as query predicate, 4 roles × 5 classifications | code + keystone-core/retrieval-v1 (8/8 ACL probes blocked, 0 leaks) | keystone-ledger |
| 7 planes, 2 sites, no external model-API dependency (roles, not names) | operational | (page copy; no repo) |

## Methodology / framework

| Claim | Evidence | Public link |
|---|---|---|
| Endpoint-agnostic eval harness; sealed-artifact methodology | keystone-verify | github.com/getkeystone/keystone-verify |
| HHEM-2.1-Open factual-consistency gate (Vectara) | Vectara attribution | vectara.com |

## Excluded pending evidence (do NOT cite until resolved)
- 5-phase coordinator, 9-state task machine — `CHECK` (asserted from code; no sealed case).
- NATS JetStream bus, MCP tool exposure — `UNSOURCED` (deployed ≠ evaluated).
- OTel traces in Tempo, per-entry cost attributes — `CHECK`.
- keystone-counsel/retrieval-v1 (Counsel 30/30, threshold 0.58) — `UNSOURCED` (no sealed artifact in the ledger; removed 2026-07-15).
- Audit chain "intact" on retrieval-v1 — `CHECK` (the sealed dump has empty hashes; cite "audit receipts logged" until re-sealed).
- FC-005 — cite the ledger §FC-005 anchor with "demo-grade, re-verification not yet sealed"; never the `38ef89f` commit permalink, never "remediated".

Maintenance: regenerate whenever a claims-matrix row flips to/from `OK`.
