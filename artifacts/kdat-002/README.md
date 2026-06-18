# Artifact — KDAT-002

**Milestone:** keystone-core/agent (formerly KDAT-002) (governed agent extension)
**Spec:** [KDAT-002-SPEC.md](../../KDAT-002-SPEC.md) v1.2 (commit 4b12094)
**Eval date:** 2026-05-20
**Verdict: PASS** (keystone-core/agent-v0-pre (formerly KDAT-002B), corpus-loaded)

---

## Artifacts in this directory

| File | Description |
|---|---|
| `KDAT-002-RESULTS-2b.md` | Full evaluation report — keystone-core/agent-v0-pre (corpus-loaded, verdict PASS) |
| `production_run_2026-05-20_2b.jsonl` | Raw per-run results — keystone-core/agent-v0-pre (58 strict / 0 fail / 8 char) |
| `KDAT-002-RESULTS.md` | Full evaluation report — KDAT-002 (corpus-empty, verdict FAIL) |
| `production_run_2026-05-20.jsonl` | Raw per-run results — KDAT-002 (45 strict / 13 fail / 8 char) |

---

## keystone-core/agent-v0-pre summary (corpus-loaded, verdict PASS)

| Metric | Value |
|---|---|
| Total cases | 66 |
| Total executions | 198 |
| Strict pass | 58 |
| Strict fail | 0 |
| Characterization | 8 |
| Verdict | **PASS** |
| Corpus | 135 docs, 23,684 chunks, all embedded |

**H1 confirmed:** Governance primitives (RBAC, evidence thresholding, fail-closed gates, hash-chained audit logging) extend to tool-using agents without redesign.

| Category | N | Strict pass | Verdict |
|---|---|---|---|
| T01 Tool authorization (positive) | 8 | 8 | Pass |
| T02 Tool authorization (adversarial) | 8 | 8 | Pass |
| T03 HITL positive | 5 | 5 | Pass |
| T04 HITL bypass resistance | 4 | 4 | Pass |
| T05 Evidence gating | 3 | 1 + 2 char | Pass |
| T06 Citation coverage | 3 | 3 | Pass |
| T07 Audit integrity | 3 | 3 | Pass |
| T08 Prompt injection | 5 | 5 | Pass |
| T09 STRIDE coverage | 6 | 6 | Pass |
| T10 Severity tier coverage | 7 | 7 | Pass |
| T11 Plausible but wrong | 3 | 3 char | Characterization |
| T12.1–T12.5 Huyen adversarial | 7 | 7 | Pass |
| T12.6 Goal failure | 1 | 1 char | Characterization |
| T12.7 Step constraint | 1 | 1 | Pass |

---

## KDAT-002 summary (corpus-empty, verdict FAIL — preserved)

Identical case set run same day before corpus ingestion. All 13 failures were corpus-dependent (`evidence_score 0.0000 < threshold 0.5000`). Preserved per keystone-core/agent-spec Section 9.5 re-run policy.

---

## Infrastructure bugs found and fixed in M8

1. keystone_app password mismatch (`initdb/01-roles.sql`) — fixed
2. `feedback_signals` table missing from initdb (`initdb/19-feedback-signals.sql`) — fixed
3. Agent tables missing from initdb (`initdb/27-agent-schema.sql`) — fixed
4. Audit chain timestamp tz-naive/tz-aware mismatch (`agent/audit.py` commit `fe28ee8`) — fixed
5. Ingest NUL-byte crash (`ingest_corpus.py` line 455, `chunk_str.replace('\x00', '')`) — fixed
