# KDAT-045 — Cloudflared JWT Helper + Guarded CF Workflow Gate

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/cf-jwt.sh` acquires a Cloudflare Access JWT via `cloudflared access
token`, validates its shape and expiry, and writes it to
`~/.cache/keystone/cf_jwt/lrfd.jwt` (chmod 600). `scripts/_jwt.sh` provides
base64url decode helpers (`ks_jwt_valid`, `ks_jwt_ttl`, `ks_jwt_exp`) with no
`jq` dependency. `smoke-origin.sh O6` is hardened to require two explicit
opt-in vars (`SMOKE_CF_WORKFLOW=1` and `SMOKE_CF_WORKFLOW_ACK=I_ACCEPT_WRITES`)
before it can issue any write; it auto-acquires a fresh JWT when the gate is
satisfied and the JWT is absent or stale.

---

## What this milestone proves

- `scripts/cf-jwt.sh`: acquires JWT via `cloudflared access token`; validates
  shape and exp; writes to `~/.cache/keystone/cf_jwt/lrfd.jwt` (chmod 600);
  never prints the token
- `scripts/_jwt.sh`: base64url decode helpers (`ks_jwt_valid`, `ks_jwt_ttl`,
  `ks_jwt_exp`); handles valid/expired/malformed/no-exp tokens; no jq required
- `smoke-origin.sh O6` write guard hardened — both must be set to enable live writes:
  - `SMOKE_CF_WORKFLOW=1`
  - `SMOKE_CF_WORKFLOW_ACK=I_ACCEPT_WRITES`
  - Default: `[SKIP]` naming both required vars
  - JWT auto-acquire: when gates satisfied and JWT absent/stale, O6 calls `cf-jwt.sh`;
    `[SKIP]` if `cloudflared` not available
- `scripts/test_kdat045_cf_jwt.sh` — **18/18 PASS**:
  - `_jwt.sh`: valid / expired / malformed / no-exp token handling
  - `cf-jwt.sh`: SKIP (no cloudflared), FAIL (empty token), PASS (stub returns
    valid JWT, file written, perms 600, token not printed)
  - `smoke-origin.sh O6`: SKIP with no gates / partial gate / wrong ACK

---

## What this milestone does NOT prove

- That a real `cloudflared` binary is installed in the deployment environment
  (cf-jwt.sh exits with `[SKIP]` when absent)
- That the acquired JWT can authenticate against the live API (only shape and
  expiry are validated locally)
- Automatic JWT refresh on expiry during a long-running smoke (O6 refreshes
  once at start)

---

## Public-safe claims

"A helper script acquires and validates a Cloudflare Access JWT using
`cloudflared`, writing it to a chmod-600 cache file without printing the
token. The CF supervisor workflow smoke gate requires two explicit opt-in
environment variables before issuing any API writes. 18/18 tests pass covering
token validation, safe-skip paths, and write-gate enforcement."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `bbdfbd7` | feat(kdat-045): cloudflared jwt helper + guarded CF workflow |
| JWT helper | `scripts/cf-jwt.sh` | acquires + validates + caches JWT; no token printed |
| JWT helpers | `scripts/_jwt.sh` | base64url decode; ks_jwt_valid/ttl/exp; no jq |
| Smoke gate | `scripts/smoke-origin.sh` O6 | dual opt-in guard; JWT auto-acquire |
| Regression tests | `scripts/test_kdat045_cf_jwt.sh` | 18/18 PASS |
| Docs | `docs/public-access.md` | "CF JWT helper (KDAT-045)" section |

---

## Verification and tests

**`scripts/test_kdat045_cf_jwt.sh`** — 18/18 PASS

| Test group | Coverage |
|-----------|----------|
| `_jwt.sh` | Valid token passes; expired fails; malformed fails; no-exp fails |
| `cf-jwt.sh` | SKIP when cloudflared absent; FAIL on empty token; PASS with stub JWT; perms 600; token not in output |
| O6 gate | SKIP with no vars; SKIP with partial gate; SKIP with wrong ACK value |

---

## Known limitations and caveats

- JWT is acquired from `cloudflared`; if `cloudflared` is not installed or
  authenticated the helper exits with `[SKIP]` rather than FAIL. This means
  a misconfigured environment silently skips the write test.
- The write gate (`I_ACCEPT_WRITES`) must be re-supplied in every shell session.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16.

| Commit | Purpose |
|--------|---------|
| `bbdfbd7` | Delivery: cf-jwt.sh + _jwt.sh + O6 write guard + tests |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat045_cf_jwt.sh
```
