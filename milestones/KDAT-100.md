# KDAT-100 — Governed Learning Loop End-to-End (keystone-experiments v0.1.0-moat-proven)

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

Complete governed learning loop proven end-to-end in standalone `keystone-experiments` repo. Full cycle demonstrated: query → feedback → auto-task → custodian review → new version approved → re-query returns improved answer → full audit chain reconstructable. 46/46 automated tests passing. Standalone fixture corpus: 12 documents, 19 versions, 113 chunks, 113 embeddings. Tagged `v0.1.0-moat-proven`.

---

## What this milestone proves

- **End-to-end cycle**: query produces answer → field feedback flagged as `not_helpful` → review task auto-created → custodian reviews and publishes new version → same query returns improved answer citing new version
- **Audit chain**: complete linkage from query → feedback → review task → publication decision → new version, reconstructable from `GET /audit/chain/{feedback_signal_id}`
- **Version tracking**: temporal resolver correctly returns version active on a given date; partial unique index prevents multiple active versions
- **ACL enforcement**: 100% — role-restricted documents not surfaced regardless of query reformulation
- **Off-topic refusal**: 100% — non-corpus queries refused
- **Answer quality**: 96.9% — high factual consistency on fixture corpus
- **Separation of duties**: enforced in both version approval and review task resolution
- **46/46 tests passing**: version resolution, ACL, off-topic refusal, audit chain integrity, full closed-loop cycle
- **Fixture corpus**: 12 documents across fire_ops, hazmat, medical, training domains; 19 versions; 113 chunks

---

## What this milestone does NOT prove

- That the learning loop scales to production corpus sizes
- That the fixture corpus represents all real-world procedure types
- That the 46-test suite covers all edge cases

---

## Public-safe claims

"Governed learning loop proven end-to-end: query → feedback → auto-task → custodian review → improved version published → re-query returns improved answer → full audit chain reconstructable. 46/46 tests. 96.9% answer quality, 100% refusal, 100% ACL. Tagged v0.1.0-moat-proven. No known commercial RAG system demonstrates this combination of governed feedback-to-improvement with version tracking, separation of duties, and full audit chain."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Repo tag | keystone-experiments `v0.1.0-moat-proven` | 46/46 tests |
| Experiment summary | `experiment-summary.json` | 96.9% answer quality, 100% refusal, 100% ACL |
| Full closed-loop test | `test_full_closed_loop` | query → feedback → review → publish → re-query |
| Fixture corpus | 12 docs, 19 versions, 113 chunks | fire_ops, hazmat, medical, training |
| Commit | keystone-experiments `8acf190` | Final passing test run |

---

## Source basis

Date: 2026-03-29

| Commit | Repo | Purpose |
|--------|------|---------|
| `8acf190` | keystone-experiments | Governed learning loop: 46/46 tests, v0.1.0-moat-proven |

---

## Note

This is the moat milestone. No competitor has demonstrated a governed feedback-to-improvement cycle with version tracking, separation of duties, and audit chain linking within an on-premises RAG system.
