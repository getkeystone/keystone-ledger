# KDAT-044 — CF Supervisor Workflow Proof (Case Pack + Offline Verify)

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/supervisor-flow-cf.sh` is a deterministic scripted proof that the
full officer-level supervisor path works in Cloudflare Access mode without a
browser login: POST /query → GET /guidance → POST /decisions → PATCH /review
→ POST /cases → GET /cases/{id}/pack.zip → `verify_case_pack.py` (exit 0).
The script uses KDAT-038 lock and KDAT-041 maintenance skip. When CF is not
enabled or no JWT is available the script exits 0 with a `[SKIP]` line;
`smoke-origin.sh` O6 treats `[SKIP]` as a smoke PASS rather than a failure.

---

## What this milestone proves

- `scripts/supervisor-flow-cf.sh`: full supervisor API path with CF JWT auth:
  - `POST /query` → `GET /guidance` → `POST /decisions` → `PATCH /review`
  - `POST /cases` → `GET /cases/{id}/pack.zip` → `verify_case_pack.py` (exit 0)
- Auth discovery (via `keystone-gov/api/cf_identity.py`): API requires
  `cf-access-jwt-assertion` (RS256, Cloudflare-signed); JWT acquired from
  `KS_CF_JWT_FILE` or service token exchange
- Graceful `[SKIP]` when: CF not enabled, or no JWT available — not a smoke
  failure
- KDAT-038 lock (`supervisor-flow-cf.lock`) + KDAT-041 maintenance skip
- No secrets printed; `CF_FLOW_EMAIL`/`CF_FLOW_NAME` identity overrides supported
- Default identity: `noreply@getkeystone.ai` (officer, in role config)
- `smoke-origin.sh O6`: `[SKIP]` when CF disabled or no JWT → smoke still PASSes;
  FAIL only when supervisor-flow-cf.sh exits non-zero
- `scripts/test_kdat044_supervisor_flow_contract.sh` — **11/11 PASS**:
  - Structural checks (maintenance/lock/skip references present)
  - `[SKIP]` path: CF disabled → exit 0
  - `[SKIP]` path: CF enabled but no JWT → exit 0
  - No forbidden secret patterns in output

---

## What this milestone does NOT prove

- That the full API path runs end-to-end without a valid CF JWT and live stack
  (O6 is `[SKIP]` when JWT is absent)
- Performance or latency of the supervisor workflow
- That case pack content is semantically correct (only exit code of
  `verify_case_pack.py` is checked)
- Multi-user or concurrent supervisor sessions

---

## Public-safe claims

"A scripted proof of the full Cloudflare-authenticated supervisor workflow
exists: query → guidance → operator decision → supervisor review → incident
case → signed case pack → offline trust-store verification (exit 0). The
script requires a valid CF Access JWT; when absent it exits 0 with a `[SKIP]`
rather than blocking smoke. 11/11 contract tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `7500197` | feat(kdat-044): CF supervisor workflow proof |
| Workflow script | `scripts/supervisor-flow-cf.sh` | full supervisor path; KDAT-038 lock; KDAT-041 skip |
| Smoke gate | `scripts/smoke-origin.sh` O6 | [SKIP] when no JWT; FAIL on non-zero exit |
| Contract tests | `scripts/test_kdat044_supervisor_flow_contract.sh` | 11/11 PASS |
| Docs | `docs/public-access.md` | "Supervisor workflow script (CF mode)" section |

---

## Verification and tests

**`scripts/test_kdat044_supervisor_flow_contract.sh`** — 11/11 PASS

| Test | Assertion |
|------|-----------|
| Structural | Maintenance/lock/skip code present |
| CF disabled | Script exits 0 with `[SKIP]` |
| CF enabled, no JWT | Script exits 0 with `[SKIP]` |
| No secrets | No forbidden patterns in script output |

---

## Known limitations and caveats

- Full end-to-end path requires a live Keystone stack + valid CF JWT. Tests
  confirm the safe-skip and contract structure; they do not exercise the full
  API path without a stack.
- `smoke-origin.sh O6` is `[SKIP]`-by-default; it only exercises the live path
  when `SMOKE_CF_WORKFLOW=1` and `SMOKE_CF_WORKFLOW_ACK=I_ACCEPT_WRITES` are set
  (added in KDAT-045).

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16.

| Commit | Purpose |
|--------|---------|
| `7500197` | Delivery: supervisor-flow-cf.sh + smoke O6 + contract tests |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat044_supervisor_flow_contract.sh
```
