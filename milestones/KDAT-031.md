# KDAT-031 — Restore Drill + Supplychain Manifest in Backups

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

The backup/restore pipeline now embeds the supply chain manifest in every
bundle and validates it on restore. An end-to-end restore drill script
(`test_restore_drill.sh`) backs up, restores with `--fresh`, and runs
`smoke-origin.sh` as a single verifiable sequence. Smoke assertion O-1
confirms the manifest is present and parses as valid JSON.

---

## What this milestone proves

- `scripts/backup.sh`: regenerates supply chain manifest at backup time;
  embeds as `manifest/supplychain-manifest.json` in bundle; bumps schema
  to v2 with `supplychain_manifest_sha256` and `supplychain_manifest_path` fields
- `scripts/restore.sh`: validates `manifest/supplychain-manifest.json` on
  restore (JSON parse + static image pin check + repo dirty WARN);
  adds `--skip-manifest-check` flag for legacy bundles; final smoke now
  calls `smoke-origin.sh` instead of `smoke-web.sh`
- `scripts/smoke-origin.sh` O-1: supplychain manifest exists and parses
  as valid JSON
- `scripts/test_restore_drill.sh` (new): end-to-end drill:
  backup to /tmp → restore `--fresh` → `smoke-origin.sh` → PASS/FAIL banner
- `docs/backup-restore.md`: updated bundle contents table, smoke reference
  updated to `smoke-origin.sh`, Restore Drill section added

---

## What this milestone does NOT prove

- Cross-host restore (operator-host transfer) — that is KDAT-036
- Legacy bundle handling (graceful rejection or opt-in) — that is KDAT-034
- Config and trust store restoration — that is KDAT-035
- Hot backup or zero-downtime restore
- Automated periodic drill scheduling (manual invocation only at this stage)

---

## Public-safe claims

"Every backup bundle includes a supply chain manifest (image digests, pip
freeze, package-lock hash, git SHAs). Restore validates the manifest before
proceeding. Smoke assertion O-1 confirms manifest presence and JSON validity.
An end-to-end restore drill script verifies the full backup → restore →
smoke cycle."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `81c63c3` | feat(kdat-031): restore drill + supplychain manifest in backups |
| Backup update | `scripts/backup.sh` | Embeds manifest; schema v2 |
| Restore update | `scripts/restore.sh` | Validates manifest; calls smoke-origin.sh |
| Smoke O-1 | `scripts/smoke-origin.sh` | Manifest present + valid JSON |
| Drill script | `scripts/test_restore_drill.sh` | End-to-end: backup → restore → smoke |
| Docs | `docs/backup-restore.md` | Bundle table + Restore Drill section |

---

## Verification and tests

**`scripts/smoke-origin.sh` O-1**:

| # | Assertion |
|---|-----------|
| O-1 | `docs/supplychain-manifest.json` exists and parses as valid JSON |

**`scripts/test_restore_drill.sh`** (also covers KDAT-034 and KDAT-035):
- Step 1: backup current state to /tmp
- Step 2: verify bundle contents (supplychain-manifest.json present)
- Step 3: restore with `--fresh`; must PASS
- Step 8: final `smoke-origin.sh` (all O-1 through O5 must PASS)

---

## Known limitations and caveats

- `test_restore_drill.sh` with `--fresh` wipes the postgres data volume.
  All data is restored from the Step 1 backup. Do not run during live pilot sessions.
- The drill is manually invoked; no scheduling is in place at this milestone
  (scheduled drill is KDAT-036).

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `81c63c3` | Delivery: manifest-in-backup, restore validation, smoke O-1, restore drill |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Origin smoke (includes O-1 manifest check):
bash scripts/smoke-origin.sh

# Full end-to-end restore drill (WARNING: wipes postgres volume):
bash scripts/test_restore_drill.sh
```
