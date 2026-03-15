# KDAT-034 — Restore Enforcement: Modern vs. Legacy Bundle Detection

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`restore.sh` now auto-detects whether a bundle is modern (contains
`manifest/supplychain-manifest.json`) or legacy (pre-KDAT-031). Modern bundles
always run supply chain validation. Legacy bundles are blocked by default and
require an explicit `--allow-legacy` opt-in. `test_restore_drill.sh` covers
all three code paths (modern, legacy-blocked, legacy-allowed).

---

## What this milestone proves

- `scripts/restore.sh`:
  - Auto-detects bundle type on extract: MODERN if
    `manifest/supplychain-manifest.json` present, LEGACY otherwise
  - MODERN bundles: supply chain validation always runs; `--skip-manifest-check`
    prints `[WARN] ignored` (not a hard fail) to avoid breaking existing automation
  - LEGACY bundles: blocked by default with a prominent error box explaining why
    and providing the exact remediation command
  - `--allow-legacy`: new flag for pre-KDAT-031 bundles; prints a warning listing
    what cannot be verified (image digests, pip freeze, git SHAs, node lock hash)
  - `--skip-manifest-check` on a legacy bundle: honoured as a deprecated alias for
    `--allow-legacy` with a visible deprecation notice
- `scripts/test_restore_drill.sh` (extended to cover three paths):
  - Step 2: bundle assertions (supplychain-manifest.json present)
  - Case A (Step 3): modern `--fresh` restore; must PASS
  - Step 4: builds a legacy bundle by stripping supplychain-manifest.json
  - Case B1 (Step 5): legacy restore without `--allow-legacy`; must exit nonzero
    with "LEGACY BUNDLE" in output
  - Case B2 (Step 6): legacy restore with `--allow-legacy` (clean reload); must PASS
  - Step 7: final `smoke-origin.sh` (7/7 PASS)
- `docs/backup-restore.md`: "Legacy Bundle Restore (KDAT-034)" section explaining
  enforcement, `--allow-legacy` usage, deprecation behaviour

---

## What this milestone does NOT prove

- That legacy bundles are safe to restore in a production environment (they lack
  supply chain verification; the `--allow-legacy` path explicitly warns about this)
- Cross-machine legacy bundle transfer
- Migration tooling to upgrade legacy bundles to modern format

---

## Public-safe claims

"Restore auto-detects modern (post-KDAT-031) versus legacy backup bundles.
Modern bundles always validate the supply chain manifest. Legacy bundles are
refused by default; an explicit `--allow-legacy` flag is required, which prints
a prominent warning listing unverifiable components. The full three-path coverage
(modern, legacy-blocked, legacy-allowed) is exercised by `test_restore_drill.sh`."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `ad2c990` | feat(kdat-034): enforce supplychain manifest on restore |
| Restore update | `scripts/restore.sh` | Auto-detect + enforcement logic |
| Drill script | `scripts/test_restore_drill.sh` | Three-path coverage |
| Docs | `docs/backup-restore.md` | "Legacy Bundle Restore" section |

---

## Verification and tests

**`scripts/test_restore_drill.sh`** covers KDAT-034 explicitly:

| Step | Assertion |
|------|-----------|
| 2 | `supplychain-manifest.json` present in bundle |
| 3 (Case A) | Modern `--fresh` restore exits 0 |
| 4 | Legacy bundle created by stripping manifest; manifest absent confirmed |
| 5 (Case B1) | Legacy restore without `--allow-legacy` exits nonzero; "LEGACY BUNDLE" in output |
| 6 (Case B2) | Legacy restore with `--allow-legacy` exits 0 (clean reload) |
| 7 | Final `smoke-origin.sh` 7/7 PASS |

Delivery commit states: "Case A: --fresh PASS; Case B1: correctly rejected;
Case B2: --allow-legacy PASS; smoke-origin.sh 7/7 PASS (O-1 O0 O1 O2 O3 O4 O5)."

---

## Known limitations and caveats

- `test_restore_drill.sh` with `--fresh` (Case A) wipes the postgres data
  volume. Do not run during live pilot sessions.
- The `--skip-manifest-check` deprecation alias is maintained for backwards
  compatibility but should be considered removed for new automation.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `ad2c990` | Delivery: auto-detect, enforcement, `--allow-legacy`, drill rewrite |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Full three-path drill (WARNING: wipes postgres volume in Case A):
bash scripts/test_restore_drill.sh
```
