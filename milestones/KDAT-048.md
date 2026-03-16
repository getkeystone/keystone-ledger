# KDAT-048 — Deterministic CF JWT Cache + Acquisition Gate

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/cf-jwt.sh` is rewritten with a deterministic 5-step JWT acquisition
order: (1) `KS_CF_JWT_FILE` override, (2) cache hit with TTL ≥ 300 s,
(3) `cloudflared access token`, (4) `cf-jwt-from-service-token.sh` (gated by
`SMOKE_CF_JWT_ACQUIRE=1`), (5) `[SKIP]` exit 0. The script never exits
non-zero for a missing JWT. Cache lives at
`~/.cache/keystone/jwt/cf.jwt` (dir 0700, file 0600). Secret hygiene:
`CF-Access-Client-Secret` value is never printed.

---

## What this milestone proves

- `scripts/cf-jwt.sh` rewritten: deterministic 5-step acquisition;
  cache dir `~/.cache/keystone/jwt/` (0700); cache file `cf.jwt` (0600);
  KDAT-041 maintenance skip + KDAT-038 lock added
- **Step 1** — `KS_CF_JWT_FILE`: read-only override; expired file falls
  through to step 2
- **Step 2** — cache hit: exits 0 printing "using cache" when TTL ≥ 300 s
- **Step 3** — `cloudflared access token` (`--aud` or `--app`): writes to
  cache on success; expired token falls through to step 4
- **Step 4** — `cf-jwt-from-service-token.sh` (requires
  `SMOKE_CF_JWT_ACQUIRE=1`): calls `GET /cdn-cgi/access/get-identity` with
  `CF-Access-Client-Id/Secret` headers; treats non-200 and missing `jwt`
  field as `[SKIP]`; value of `CF-Access-Client-Secret` is never printed
- **Step 5** — `[SKIP]` exit 0: never blocks smoke
- `scripts/_cf_endpoints.sh`: new helper providing `ks_cf_team_url` and
  `ks_cf_aud` from env
- `smoke-origin.sh O6` updated: delegates all JWT acquisition to `cf-jwt.sh`;
  reads from `KS_CF_JWT_FILE` or cache; O6 becomes `[SKIP]` (not `[FAIL]`)
  when no JWT is available
- `scripts/test_kdat048_cf_jwt_cache.sh` — **30/30 PASS** covering:
  - Steps 1–5 happy paths and fallthrough chains
  - Cache creation, permissions (0600/0700), TTL boundary
  - Secret hygiene: no `CF-Access-Client-Secret` value, no
    `CLOUDFLARE_ACCESS_CLIENT_SECRET`, no long token-like sequences in output
  - O6 smoke `[SKIP]` behaviour with and without ACQUIRE

---

## What this milestone does NOT prove

- That a real `cloudflared` binary with a valid login is present (steps 3–4
  require environment-specific setup)
- Performance characteristics of JWT acquisition across steps
- That `cf-jwt-from-service-token.sh` succeeds end-to-end against a live
  CF Access application (step 4 requires valid service token credentials)

---

## Public-safe claims

"The CF JWT helper follows a deterministic 5-step acquisition order and never
exits non-zero for a missing JWT. JWT caching uses file permissions 0600/0700.
The `CF-Access-Client-Secret` value is never printed in any code path.
30/30 contract tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `c1669e3` | feat(kdat-048): deterministic CF JWT cache + acquisition gate |
| JWT helper | `scripts/cf-jwt.sh` | 5-step acquisition; cache at `~/.cache/keystone/jwt/cf.jwt` |
| Service token helper | `scripts/cf-jwt-from-service-token.sh` | gated by `SMOKE_CF_JWT_ACQUIRE=1`; [SKIP] on non-200 |
| CF endpoints helper | `scripts/_cf_endpoints.sh` | `ks_cf_team_url`, `ks_cf_aud` |
| Smoke gate update | `scripts/smoke-origin.sh` O6 | delegates to cf-jwt.sh; [SKIP] not [FAIL] |
| Regression tests | `scripts/test_kdat048_cf_jwt_cache.sh` | 30/30 PASS |
| Docs | `docs/public-access.md` | KDAT-048 section |

---

## Verification and tests

**`scripts/test_kdat048_cf_jwt_cache.sh`** — 30/30 PASS

| Test group | Coverage |
|-----------|----------|
| Step 1 | `KS_CF_JWT_FILE` valid → "using KS_CF_JWT_FILE", no cache write |
| Step 2 | Cache valid → "using cache" |
| Steps 3–4 | cloudflared stub valid → "refreshed cache via cloudflared" |
| Step 4 | ACQUIRE=1 + curl 400/200-no-jwt → [SKIP] |
| Step 5 | No cloudflared, no ACQUIRE → [SKIP] |
| Fallthrough | Expired KS_CF_JWT_FILE → falls to cache; cloudflared expired → [SKIP] |
| Hygiene | No CF-Access-Client-Secret value; no CLOUDFLARE_ACCESS_CLIENT_SECRET; no long token sequences |
| O6 smoke | WORKFLOW=1+ACK, no JWT, no ACQUIRE → O6 [SKIP] not [FAIL] |

---

## Known limitations and caveats

- Steps 3 and 4 require environment-specific tooling (`cloudflared` or valid
  service token credentials). Tests use stubs for these steps.
- Cache TTL is 300 s; tokens with shorter expiry may be served stale.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16.

| Commit | Purpose |
|--------|---------|
| `c1669e3` | Delivery: cf-jwt.sh rewrite + cf-jwt-from-service-token.sh + _cf_endpoints.sh + 30-test suite |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat048_cf_jwt_cache.sh
```
