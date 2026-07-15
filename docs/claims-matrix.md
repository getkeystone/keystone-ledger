# Claims Matrix

Every claim on a public surface, mapped to the artifact that proves it.

**This is the mechanical form of governance red line 4: never publish a number with no sealed artifact behind it.** Any control that depends on the operator remembering is not a control. This table is that control.

**Use:** before any publish, every claim in the artifact must appear here with a green status. If it is not in the table, it does not ship. Run `scripts/verify-claims-matrix.sh` as the pre-publish gate; it exits non-zero on any non-`OK` claim row.

Last updated: July 15, 2026.

> **Promoted 2026-07-15.** This file supersedes the 2026-03-16 `lrfd-backend-bootstrap` version (KDAT-001..051 only), which did not cover the platform-extension claims now on the public surface. The prior version is retained in git history. Evidence-hygiene corrections applied on promotion are marked `[corrected 2026-07-15]`.

---

## Status legend

`OK` verified, traceable, current · `STALE` was true, has drifted · `BROKEN` the proof does not resolve · `UNSOURCED` no artifact · `CHECK` needs verification before next publish

---

## Retrieval claims

| Claim | Artifact | Surfaces | Status |
|---|---|---|---|
| P@1 = 0.75 | keystone-core/retrieval-v1 | site, platform page, resume, blurb, Post #1 | OK |
| MRR = 0.79 | keystone-core/retrieval-v1 | same | OK |
| 8 of 8 adversarial ACL probes blocked, 0 leaks | keystone-core/retrieval-v1 | same | OK |
| Fail-closed 5/6 (83%) | keystone-core/retrieval-v1 | site, platform page | OK |
| 53 documents, 2,674 chunks | keystone-core/retrieval-v1 | site, platform page, resume | OK |
| Audit chain intact | keystone-core/retrieval-v1 | platform page | **CHECK** — [corrected 2026-07-15] the sealed `kdat-001B/audit_chain_dump.json` has empty `entry_hash`/`previous_hash` on all 30 entries. Public wording downgraded to "audit receipts logged" until a dump with populated hashes is re-sealed. |

## Agent claims

| Claim | Artifact | Surfaces | Status |
|---|---|---|---|
| 186 cases, 12 categories, 558 executions, 0 failures | keystone-core/agent-v1 | site, platform page, resume, blurb | OK |
| 153 strict pass, 33 characterization | keystone-core/agent-v1 | ledger only | OK |
| 66 cases surfaced 4 real bugs | keystone-core/agent-v0 | platform page, resume, Post #1 | OK |
| Engage 100/100 (core 70/70, arch 25/25, edge 5/5) | keystone-engage/agent-v1 | platform page, resume | OK |
| Engage agent-v0 96/100, 3 bugs + 1 non-determinism | keystone-engage/agent-v0 | platform page | OK |
| Counsel 30/30, 32 chunks, 4 categories, threshold 0.58 | keystone-counsel/retrieval-v1 | platform page | **UNSOURCED** — [corrected 2026-07-15] no `keystone-counsel/retrieval-v1` directory exists in `keystone-ledger/artifacts/`; the counsel `evals/` dir is empty and 0.58 lives only in `.env` (code default is 0.50). Removed from PUBLIC_PROOF_INDEX and the platform page's "sealed baseline" wording until sealed with a calibration sweep. |

## Architecture claims

| Claim | Proof | Surfaces | Status |
|---|---|---|---|
| 5 specialist agents, 5-phase coordinator | Code + engage/agent-v1 artifact | platform page, resume | **CHECK** — sealed run is the single-agent orchestrator (Makefile serves `api:app`); the coordinator is only in the unserved `api_v2f`. `registry.py` defines 4 dispatch phases, not 5. Softened to "implemented, not eval-sealed" on public surfaces. |
| 9-state task machine, heartbeat, takeover | Code | platform page, resume | **CHECK** — schema real; no production caller invokes claim/heartbeat/takeover and no sweeper exists, so stuck tasks are not actually recoverable. Softened to "implemented, not eval-sealed." |
| Hash-chained HMAC audit ledger | Code + agent-v0 (the HMAC bug is the proof it is verified) | everywhere | OK — for the gov PostgreSQL/agent HMAC path. Note: the engage file-backed substrate chain is unkeyed SHA-256; see "Audit chain intact" (CHECK). |
| ACL as query predicate, 4 roles x 5 classifications | Code + keystone-core/retrieval-v1 (8/8 ACL probes blocked, 0 leaks) | platform page, resume, cover letter | OK — [corrected 2026-07-15] repointed off the non-existent `counsel/retrieval-v1` to the sealed `retrieval-v1` probe result. |
| NATS JetStream event bus | Deployed | platform page, resume | **UNSOURCED** — deployed is not evaluated. No sealed case covers it. Softened to "implemented, not eval-sealed." |
| MCP tool exposure | Code | platform page, resume | **UNSOURCED** — the MCP server is a scaffold (one health tool, no wired scope enforcement). Public copy softened to "scaffold"; the "injection still fails at the scope check" security claim removed. |
| OTel GenAI semantic conventions, traces in Tempo | Confirmed manually | platform page, resume | **CHECK** — the env is session-scoped, so this control fails silently on reboot; the systemd unit does not persist OTEL_* vars. |
| Cost on every audit entry and span | Code | platform page, resume | **CHECK** — dispatch cost is hardcoded to 0 (`dispatch.py`); cost span attributes not confirmed present. "Cost recorded on every step / on every span" softened. |
| 7 planes, 2 sites, no external model API dependency | Operational | site, platform page, resume | OK, and public-safe as stated (roles, not names). |

## Narrative claims

| Claim | Proof | Surfaces | Status |
|---|---|---|---|
| FC-005 remediated, commit `38ef89f` | Public permalink | Post #1 (load-bearing), ledger | **BROKEN** — the `keystone-gov/commit/38ef89f` permalink 404s anonymously, the guard is not on `origin/main`, and no re-verified passing run is sealed (retrieval-v1 records FC-005 as LEAKED). **Fix applied:** public surfaces re-pointed to the ledger §FC-005 anchor and wording softened to "domain-scope guard merged (demo-grade), re-verification not yet sealed." **Post #1's footer must cite the ledger §FC-005 anchor and use the demo-grade wording — never the commit permalink, never the word "remediated."** |
| HHEM-2.1-Open, attributed to Vectara | Vectara blog | Post #1, keystone-gov source comment | OK — attribution confirmed. Gate 3 is closed. |
| "Thirteen years at Genesys" | Feb 2012 to Nov 2024 = 12y9m | spoken, About, cover letter | **STALE-ish** — defensible rounding, but LinkedIn says 12+ and the spoken narrative says 13. Pick one per surface and stop drifting. |
| "Since 2024" (Keystone tenure) | Nov 2024 onward | site, platform page, About, resume, blurb, cover letter | **CHECK** — [corrected 2026-07-15] "eighteen months" replaced by "since 2024" on public docs and the platform page (`/platform/index.html` confirmed fixed). Pending confirm: private canon/resume/cover on the next private pass. |
| Demo is live at demo.getkeystone.ai | The host + `smoke-demo` timer | site, cover letter O1 | **Monitored** by the `smoke-demo` timer (15-min HTTP 200 check, fail-closed; EX-010 closed 2026-07-15). Home lab, cloudflared tunnel, no redundancy — the monitor detects an outage within 15 min, it does not prevent one, so still spot-check before a high-stakes send. |
| Speaker, AI Tinkerers NYC / Toronto Tech Week | Acceptance | resume | **CHECK** — accepted is not presented. State it accurately. |

---

## Findings

**1. FC-005 permalink is dead; surfaces re-pointed.** Public surfaces now cite the ledger §FC-005 anchor with demo-grade wording. Post #1 (unwritten as of 2026-07-15) must do the same when drafted; it must not use the `38ef89f` commit permalink and must not use the word "remediated."

**2. Tenure fixed to "since 2024"** on public docs and the platform page. Private surfaces pending the next private pass.

**3. Capability claims (coordinator, 9-state, NATS, MCP, cost) softened from "operational" to "implemented, not eval-sealed"** on the public surface; each is UNSOURCED/CHECK until a sealed case exercises it.

**4. Two claims that cited artifacts which do not exist were removed/repointed:** Counsel 30/30 (no ledger artifact) and the ACL row (repointed to retrieval-v1). The audit-chain-intact claim was downgraded to "audit receipts logged" pending a re-sealed dump with populated hashes.

---

## Rule

Before any publish: every claim in the artifact appears in this table with status OK. Anything CHECK gets checked. Anything STALE gets fixed. Anything BROKEN or UNSOURCED gets cut or softened.

**This table is not documentation. It is a gate.** Run `scripts/verify-claims-matrix.sh` before every publish. If it is not being run, delete this file, because an unused control is worse than an acknowledged gap.
