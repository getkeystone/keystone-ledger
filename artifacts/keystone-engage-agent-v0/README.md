# Artifact: keystone-engage/agent-v0

**Eval entry:** keystone-engage/agent-v0
**Milestone:** Keystone Engage, governed conversational agent, failing run preserved
**Eval date:** 2026-07-06
**System:** keystone-engage commit `553d2ef`
**Corpus:** 6 documents, 35 chunks (HNSW via pgvector)
**Model:** qwen2.5:7b-instruct (chat), nomic-embed-text (embedding), served via Ollama
**Verdict: FAIL (96/100), preserved alongside agent-v1**

---

## Artifacts

| File | Description |
|---|---|
| `report.md` | Full evaluation report with per-failure root cause |
| `results.json` | Per-case results (100 cases) |
| `run_metadata.json` | SUT commit, model versions, thresholds, corpus |

---

## Results

| Metric | Value |
|---|---|
| Total cases | 100 |
| Passed | 96 |
| Failed | **4** |
| Pass rate | 96% |
| Verdict | **FAIL** |

**By bucket:**

| Bucket | Total | Passed | Rate |
|---|---|---|---|
| core-regression | 71 | 69 | 97.2% |
| architecture | 25 | 24 | 96.0% |
| edge-case | 4 | 3 | 75.0% |

---

## Failures

Four failing cases surfaced three real system bugs and one instance of LLM non-determinism within tolerance. All fixed or reclassified in agent-v1 (`b178584`).

| Case | Category | Type | Root cause |
|---|---|---|---|
| ENG-066 | tool-authorization | Real bug | Empty-string caller_id treated as a valid identity instead of public scope |
| ENG-070 | audit-chain | Real bug | Escalation regex missing regulatory-complaint patterns; complaints fell through to RAG |
| ENG-078 | behavioral-content | Real bug | Distress signal without account keywords hit the fail-closed path instead of an empathy acknowledgment |
| ENG-075 | behavioral-content | Non-determinism | Model used valid synonyms for "hardship"; brittle assertion, reclassified edge-case |

Each real bug is a contact-center-heritage gap: a scope-enforcement hole (ENG-066), a routing-table omission (ENG-070), and missing IVR distress screening (ENG-078).

---

## What this run proves

The eval methodology catches real bugs. Four failures across three categories surfaced three distinct, fixable system issues plus one tolerated non-determinism. Publishing the failing run is contact-center quality-management heritage: bad calls are analyzed, not buried.

## Eval progression

| Run | Cases | Verdict | Notes |
|---|---|---|---|
| **agent-v0** | **100** | **FAIL** (96/100) | This run |
| [agent-v1](../keystone-engage-agent-v1/) | 100 | PASS (100/100) | Bugs fixed; canonical result |
