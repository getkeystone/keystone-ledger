# KDAT Ledger Update: 2026-03-26 Session

## Updates to Existing KDATs

### KDAT-087 (completed)
- **Was:** Retrieval Tuning Baseline (50%)
- **Now:** Retrieval Tuning Baseline -- COMPLETED at 80% answer quality, 86% FCS
- **Evidence:** eval_results_1774525517.json (final run), 4 progressive eval rounds

### KDAT-001B (completed)
- **Was:** Eval Harness (outstanding, must produce quantitative evidence)
- **Now:** Eval Harness COMPLETED -- 30 queries, 9 categories, 80% answer quality, 86% FCS mean
- **Evidence:** eval harness at scripts/eval_harness.py; 4 result JSON files
- **Note:** Fixed scoring bug where hedge_detected gated answer_quality. 5 remaining failures documented (1 corpus gap, 1 hedge, 3 intermittent).

## New KDATs

### KDAT-089: KDAT-001B Eval Harness Baseline
**Status:** Proven
**Evidence:** eval_results_1774516425.json through eval_results_1774525517.json (4 runs). scripts/eval_harness.py.
**Description:** Structured 30-query evaluation harness producing JSON evidence artifacts. 9 categories: safety procedures, hazard assessment, training, emergency response, PPE, confined space, off-topic refusal, system prompt probing, edge cases. Progression: 64% -> 72% -> 80% answer quality. FCS mean: 58% -> 86%.

### KDAT-090: SOC 2 Type II Controls Matrix
**Status:** Proven
**Evidence:** keystone-docs commit eb06a33 (docs/soc2-controls-matrix.md). keystone-soc2-controls-matrix.docx (prospect handout).
**Description:** 25 controls mapped across 9 SOC 2 TSC categories. 6 additional architectural controls specific to governed RAG. Customer responsibilities section. No aspirational claims -- every control maps to running code.

### KDAT-091: COR Audit Readiness API
**Status:** Proven
**Evidence:** keystone-gov commits b53213e, 41a1e88, 2cb12f5, 38148ed. compliance_runs table. POST /compliance/run returns results in <15s.
**Description:** Retrieval-only compliance assessment: 14 COR elements, ~50 queries, hybrid FTS+vector scoring per query. No LLM generation. Evidence threshold 0.75 (cosine similarity). Results stored in compliance_runs (INSERT-only for keystone_app). Deployed to dev and demo.

### KDAT-092: COR Compliance Console UI
**Status:** Proven
**Evidence:** keystone-console commits 0cc1e8d, 68dfd70. Live at dev.example.internal/compliance and demo.getkeystone.ai/compliance.
**Description:** Full compliance dashboard: checklist selector, "Run Assessment" button, element cards (E01-E14) with green/amber/red scoring (>=80/50-79/<50), expandable per-query evidence details, assessment history table. Authority-only navigation gate.

### KDAT-093: Evidence Threshold Calibration
**Status:** Proven
**Evidence:** Three compliance runs at thresholds 0.30, 0.65, 0.75 stored in compliance_runs. Score capping commit 2cb12f5.
**Description:** Systematic threshold tuning for compliance scoring. 0.30 passes everything (no signal). 0.65 still passes everything (OHS corpus is semantically aligned with COR queries). 0.75 produces meaningful distribution: 47% overall, 2 green elements, 3 amber, 9 red. Score capping added (ts_rank_cd can exceed 1.0).

## Docker Images

| Tag | Used By | Date |
|-----|---------|------|
| keystone-api:v0.3.2 | keystone-lrfd | 2026-03-20 |
| keystone-api:v0.4.1 | (superseded) | 2026-03-23 |
| keystone-api:v0.4.2 | keystone-demo | 2026-03-26 |

## Total: 62 KDATs (was 57)
