# KDAT-030 — Pinned Images + Supply Chain Manifest

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

All external Docker images in `docker-compose.yml` are pinned by immutable
SHA-256 digest. A supply chain manifest captures the full input state
(image digests, pip freeze, package-lock hash, per-repo git SHAs) at release
time. A verification script asserts digest integrity at smoke time.

---

## What this milestone proves

- `docker-compose.yml`: external images pinned by `@sha256:` digest
  (postgres:16-alpine and caddy:2-alpine); human-readable tag preserved
  as inline comment; api service unchanged (local build)
- `scripts/verify-release-inputs.sh` (new):
  - V1: every `image:` line has `@sha256:`
  - V2: `docker compose config` parses cleanly
  - V3: running container digests match compose-pinned values
  - V4: console HTML does not leak `KDAT-` debug strings
  - Exit 1 on any FAIL
- `scripts/generate-supplychain-manifest.sh` (new): writes
  `docs/supplychain-manifest.json` (deterministic, sorted); captures
  `time_utc`, host/OS, per-repo git SHA + dirty flag, compose image
  digests, `package-lock.json` sha256, sorted `pip freeze` from api container
- `scripts/upgrade-image-digests.sh` (new): pulls latest for each pinned
  tag, rewrites digest in `docker-compose.yml`, calls `verify-release-inputs.sh`;
  does NOT restart containers automatically
- `scripts/smoke-origin.sh`: O0 assertion calls `verify-release-inputs.sh`;
  PASS/FAIL propagates to smoke exit code
- `docs/supplychain-manifest.json` (new): initial manifest snapshot
- `docs/public-access.md`: "Release inputs and supply chain manifest (KDAT-030)"
  section with verify, generate, and upgrade commands

Delivery commit states: "Verified: verify-release-inputs.sh 5/5 PASS;
smoke-origin.sh 5/5 PASS (O0-O4); supplychain-manifest.json generated
and parses cleanly."

---

## What this milestone does NOT prove

- That pinned digests are from trusted registries (no image signing / Cosign)
- Reproducible builds of the `api` local image (local build, not pinned externally)
- Automated periodic digest rotation (upgrade script is manual)
- Full software bill of materials (SBOM) in a standard format (SPDX/CycloneDX)

---

## Public-safe claims

"External Docker images are pinned by immutable SHA-256 digest in
`docker-compose.yml`. A supply chain manifest captures image digests,
pip freeze output, package-lock hash, and per-repo git SHAs at release time.
A verification script confirms pinned digests match running containers.
This check runs as part of the origin smoke suite (assertion O0)."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `b670579` | feat(kdat-030): pin images by digest + supply chain manifest |
| Verification script | `scripts/verify-release-inputs.sh` | 4 assertions; exit 1 on FAIL |
| Manifest generator | `scripts/generate-supplychain-manifest.sh` | Deterministic JSON output |
| Digest upgrader | `scripts/upgrade-image-digests.sh` | Manual rotation tool |
| Smoke integration | `scripts/smoke-origin.sh` O0 | Propagates FAIL to smoke exit code |
| Manifest snapshot | `docs/supplychain-manifest.json` | Initial capture |
| Docs | `docs/public-access.md` | "Release inputs and supply chain manifest" section |

---

## Verification and tests

**`scripts/smoke-origin.sh` O0** — calls `verify-release-inputs.sh`:

| # | Assertion |
|---|-----------|
| O0 | verify-release-inputs.sh exits 0 (images pinned, running digests match) |

**`scripts/verify-release-inputs.sh`** — 4 assertions:

| # | Assertion |
|---|-----------|
| V1 | Every `image:` line in docker-compose.yml has `@sha256:` |
| V2 | `docker compose config` parses cleanly |
| V3 | Running postgres/web container digests match compose-pinned values |
| V4 | Console HTML does not contain `KDAT-` debug strings |

---

## Known limitations and caveats

- Digest rotation is manual. Running `upgrade-image-digests.sh` pulls
  `:latest` for each pinned tag; operators should review changes before
  deploying.
- The `api` local image is built from source and is not pinned externally.
  Its build inputs are captured via pip freeze in the manifest.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `b670579` | Delivery: digest pinning, verify script, manifest generator, smoke O0 |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Verify current release inputs:
bash scripts/verify-release-inputs.sh

# Generate a fresh supply chain manifest:
bash scripts/generate-supplychain-manifest.sh

# Full origin smoke (includes O0):
bash scripts/smoke-origin.sh
```
