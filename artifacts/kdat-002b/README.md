# Artifact — KDAT-002B

**Milestone:** KDAT-002 governed agent extension — corpus-loaded re-eval
**Spec:** [KDAT-002-SPEC.md](../../KDAT-002-SPEC.md) v1.2 (commit 4b12094)
**Eval date:** 2026-05-20
**System:** keystone-api:v0.6.1 (Docker Compose, keystone-demo stack)
**Corpus:** 135 docs, 23,684 embedded chunks (Alberta OHS + supplementary)
**Verdict: PASS — H1 confirmed**

---

## Artifacts

| File | Description |
|---|---|
| `KDAT-002-RESULTS-2b.md` | Full evaluation report per KDAT-002-SPEC Section 11 format |
| `production_run_2026-05-20_2b.jsonl` | Raw per-run results (66 cases × 3 runs = 198 executions) |

Prior run (same cases, corpus-empty, verdict FAIL): [`artifacts/kdat-002/`](../kdat-002/)

---

## Results

| Metric | Value |
|---|---|
| Total cases | 66 |
| Total executions | 198 |
| Strict pass | 58 |
| Strict fail | **0** |
| Characterization | 8 |
| Verdict | **PASS** |

**All adversarial categories 100% strict pass:**

| Category | N | Pass |
|---|---|---|
| T01 Tool authorization (positive) | 8 | 8/8 |
| T02 Tool authorization (adversarial) | 8 | 8/8 |
| T03 HITL positive | 5 | 5/5 |
| T04 HITL bypass resistance | 4 | 4/4 |
| T05 Evidence gating | 3 | 1 + 2 char |
| T06 Citation coverage | 3 | 3/3 |
| T07 Audit chain integrity | 3 | 3/3 |
| T08 Prompt injection on parameters | 5 | 5/5 |
| T09 STRIDE coverage (all 6 categories) | 6 | 6/6 |
| T10 Severity tier coverage (all 4 tiers) | 7 | 7/7 |
| T11 Plausible but wrong | 3 | 3 char |
| T12.1–T12.5 Huyen adversarial | 7 | 7/7 |
| T12.6 Goal failure | 1 | 1 char |
| T12.7 Step constraint | 1 | 1/1 |

---

## Infrastructure bugs found and fixed in M8

Five latent bugs discovered during the M8 deploy and eval execution:

1. **keystone_app password mismatch** — `initdb/01-roles.sql` created role with wrong password vs `DATABASE_URL`. Blocked every fresh install. Fixed.
2. **`feedback_signals` table missing from initdb** — Table existed in original hand-seeded DB but was never in any `initdb/` script. FK violation on startup. Fixed (`initdb/19-feedback-signals.sql`).
3. **Agent tables missing from initdb** — Five agent tables only in SQLAlchemy models, never in `initdb/`. `agent/health` returned `tables_missing: True` on fresh install. Fixed (`initdb/27-agent-schema.sql`).
4. **Audit chain timestamp tz-naive/tz-aware mismatch** — `write_audit_entry()` stored naive timestamp; `verify_plan_chain()` read back tz-aware from PostgreSQL TIMESTAMPTZ, HMAC always failed. Fixed (`agent/audit.py`, commit `fe28ee8`, keystone-gov).
5. **Ingest NUL-byte crash** — Container's pdfminer produces NUL bytes in some PDFs; psycopg2 raises `ValueError` on insert. Fixed (`ingest_corpus.py` line 455, commit `87c1d55`, keystone-gov).
