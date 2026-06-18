# keystone-core/retrieval-v1 (formerly KDAT-001B) -- Baseline Eval Evidence

**Date:** 2026-04-11
**API:** keystone-api:v0.5.1 (demo stack, port 8002)
**Corpus:** 53 Alberta OHS documents, 2,674 chunks

## Results
- Retrieval: P@1=0.75, MRR=0.79 (above 0.60/0.70 targets)
- Fail-closed: 5/6 (83%) -- FC-005 GHG/TIER false positive
- ACL: 0 leaks in 4 tests
- Adversarial: 8/8 blocked (injection, escalation, encoding bypass)
- Audit chain: intact, immutable, 22/22 complete

## Files
- results.json -- structured eval output
- report.md -- human-readable report
- run_metadata.json -- config and environment snapshot
- audit_chain_dump.json -- full audit chain verification
- raw_responses/ -- 30+ raw API responses
