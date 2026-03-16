# KDAT-051 — CF Gate Snapshot in Health Pack (Sanitized, No Secrets)

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/cf-gate-snapshot.sh` probes `lrfd.getkeystone.ai` (no redirect
follow) and records only secret-free fields: HTTP status, location host and
path (≤ 80 chars), `has_query` boolean, `service_token_status` boolean
(extracted in-memory and then discarded), CF-Ray, and Server. Full Location
URLs are never stored. The snapshot is included in every health pack as
`pack/snapshots/cf-gate.json` (machine-readable) and `pack/snapshots/cf-gate.txt`
(7-line human summary).

---

## What this milestone proves

- `scripts/cf-gate-snapshot.sh`: three-probe structure against
  `https://lrfd.getkeystone.ai`:
  1. `GET /` — gate active (302) vs open (200)
  2. `GET /api/health` — health endpoint gating
  3. `GET /api/health` with service token headers (skipped if token env
     vars absent)
- **Secret hygiene enforced**:
  - `location_host` + `location_path` (≤ 80 chars) stored; full URL discarded
  - `has_query` is boolean only
  - `service_token_status` extracted as boolean in memory; raw URL discarded
  - CF-Ray and Server headers stored (contain no secrets)
  - Token values and Client ID are never printed
- `pack/snapshots/cf-gate.json`: fields `gate_active`, `team_domain_match`,
  `service_token_ok`, `cf_ray`, `server`
- `pack/snapshots/cf-gate.txt`: 7-line human summary
- `scripts/pilot-health-pack.sh` updated: invokes `cf-gate-snapshot.sh` in
  Snapshots section; sanitizes `cf-gate.txt` before secret scan
- `scripts/test_kdat051_cf_gate_snapshot.sh` — **24/24 PASS**:
  - Location parsing, query stripping, service_token_status extraction
  - JSON safety (no secret values), no-token skip path
  - Classification fields (`gate_active`, `team_domain_match`, `service_token_ok`)
  - TXT format and line count
- All KDAT health pack tests pass together: KDAT-049 52/52, KDAT-050 18/18,
  KDAT-051 24/24
- Real host validation: secret scan OK; no-leak grep OK

---

## What this milestone does NOT prove

- That the classification is correct for all CF Access configurations (tested
  against host-primary deployment only)
- Long-run availability or response-time of the probed endpoint
- That `service_token_status` reflects authentication state beyond a boolean
  (only HTTP status code is interpreted)

---

## Public-safe claims

"Every health pack includes a sanitized CF gate snapshot proving Cloudflare
Access gating behavior: gate active, team domain match, and service token
acceptance — all recorded without storing secrets, full URLs, or token values.
24/24 tests pass. Validated on real host-primary host with secret scan OK."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `bcf7a9f` | feat(kdat-051): CF gate snapshot in health pack (sanitized, no secrets) |
| CF gate snapshot | `scripts/cf-gate-snapshot.sh` | 3 probes; secret-free JSON + TXT output |
| Health pack update | `scripts/pilot-health-pack.sh` | invokes cf-gate-snapshot.sh; sanitizes output |
| Regression tests | `scripts/test_kdat051_cf_gate_snapshot.sh` | 24/24 PASS |
| Docs | `docs/public-access.md` | KDAT-051 section with fields, hygiene guarantees, no-leak verification command |

---

## Verification and tests

**`scripts/test_kdat051_cf_gate_snapshot.sh`** — 24/24 PASS

| Test group | Coverage |
|-----------|----------|
| Location parsing | `location_host`/`location_path` extracted correctly |
| Query stripping | `has_query` boolean; raw query string discarded |
| Token extraction | `service_token_status` boolean; raw URL discarded |
| JSON safety | No secret values in JSON output |
| No-token skip | Probe 3 skipped when token vars absent |
| Classification | `gate_active`, `team_domain_match`, `service_token_ok` fields present |
| TXT format | 7-line summary correct |

---

## Known limitations and caveats

- Probe 3 (service token) silently skips when `CF-Access-Client-Id`/`Secret`
  vars are absent; `service_token_ok` is `null` in that case.
- `location_path` is truncated to 80 chars; paths longer than 80 chars lose
  the tail.
- Classification tested against host-primary only; other CF Access configurations
  may produce different gate states.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16.

| Commit | Purpose |
|--------|---------|
| `bcf7a9f` | Delivery: cf-gate-snapshot.sh + health pack update + 24-test suite |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat051_cf_gate_snapshot.sh
```
