# Artifact — keystone-core/agent-v1 (formerly KDAT-002D)

**Milestone:** keystone-core/agent (formerly KDAT-002) governed agent extension — canonical citable result
**Spec:** [KDAT-002-SPEC.md](../../KDAT-002-SPEC.md)
**Eval date:** 2026-05-20
**System:** keystone-gov commit `6ac192a` (feature/kdat-002-agent-extension, local dev port 8000)
**Corpus:** 135 docs, 23,684 embedded chunks (Alberta OHS + supplementary)
**Verdict: PASS — H1 confirmed**

---

## Artifacts

| File | Description |
|---|---|
| `KDAT-002D-RESULTS.md` | Full evaluation report — all 12 Section 11 subsections |
| `production_run_2d_20260520.jsonl` | Raw per-run results (186 cases × 3 runs = 558 executions) |

---

## Results

| Metric | Value |
|---|---|
| Total cases | 186 |
| Total executions | 558 |
| Strict pass | 153 |
| Strict fail | **0** |
| Characterization | 33 |
| Verdict | **PASS** |

**Per-category summary:**

| Category | N | Strict | Char | Fail |
|---|---|---|---|---|
| T01 Tool authorization — positive | 20 | 20 | 0 | 0 |
| T02 Tool authorization — adversarial | 20 | 20 | 0 | 0 |
| T03 HITL positive routing | 15 | 15 | 0 | 0 |
| T04 HITL bypass resistance | 15 | 15 | 0 | 0 |
| T05 Per-step evidence gating | 10 | 2 | 8 | 0 |
| T06 Citation coverage | 15 | 15 | 0 | 0 |
| T07 Action audit chain integrity | 5 | 5 | 0 | 0 |
| T08 Prompt injection on parameters | 10 | 10 | 0 | 0 |
| T09 STRIDE coverage (meta) | 6 | 6 | 0 | 0 |
| T10 Severity tier coverage (meta) | 20 | 20 | 0 | 0 |
| T11 Plausible but wrong | 10 | 0 | 10 | 0 |
| T12.1–T12.5 Huyen adversarial | 25 | 25 | 0 | 0 |
| T12.6 Goal failure | 10 | 0 | 10 | 0 |
| T12.7 Plan depth cap | 5 | 5 | 0 | 0 |
| **Total** | **186** | **153** | **33** | **0** |

---

## Bugs fixed between keystone-core/agent-v0 and keystone-core/agent-v1

keystone-core/agent-v1 (formerly KDAT-002D) is a re-run of the identical 186 cases after fixing 4 bugs identified by keystone-core/agent-v0 (formerly KDAT-002C). No test cases or graders were modified.

| Bug | File | Fix |
|---|---|---|
| T07: HMAC verify timestamp mismatch | `agent/audit.py` | `fe28ee8` — `.replace(tzinfo=None)` before `.isoformat()` in `verify_plan_chain()` |
| T02-014: `SYSTEM OVERRIDE` not in P3.1 | `input_sanitizer.py` | `6ac192a` — added `SYSTEM\s+OVERRIDE` and `ignore\s+(role\|permission\|access)\s+(restrictions?)` |
| T08-006: `$()` not in P3.1 | `input_sanitizer.py` | `6ac192a` — added `\$\(` and backtick patterns |
| T08-010: `ASSISTANT:` not in P3.1 | `input_sanitizer.py` | `6ac192a` — added `ASSISTANT\s*:` and `\[ASSISTANT\]` |

---

## Eval progression (complete)

| Run | Cases | Verdict | Notes |
|---|---|---|---|
| KDAT-002 | 66 | FAIL | Empty corpus |
| keystone-core/agent-v0-pre (formerly KDAT-002B) | 66 | PASS | Corpus loaded (135 docs) |
| keystone-core/agent-v0 (formerly KDAT-002C) | 186 | **FAIL** | Spec-compliant; 4 real system bugs found |
| **keystone-core/agent-v1** | **186** | **PASS** | Bugs fixed; canonical result |

**keystone-core/agent-v1 is the canonical citable result for the keystone-core/agent milestone.**

Prior (FAIL run with 186 cases): [`artifacts/kdat-002c/`](../kdat-002c/)
