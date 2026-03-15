# KDAT-035 — Bundle Config + Trust Bootstrap

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

Backup bundles now include non-secret configuration files and trust store
material: user roles YAML, trust store public keys, the public evidence key,
and a redacted environment template. Restore automatically reinstalls these
on the target host. `test_restore_drill.sh` asserts bundle contents and
restore behaviour.

---

## What this milestone proves

- `scripts/backup.sh`: collects `config/` directory containing:
  - `lrfd_user_roles.yaml`
  - `trust/evidence_pubkeys/*.pem`
  - `keys/evidence_ed25519_public.pem`
  - `env.sanitized` (Python-redacted: `AUDIT_HMAC_KEY`, `CLOUDFLARE_ACCESS_CLIENT_SECRET`,
    `CLOUDFLARE_ACCESS_CLIENT_ID`, `PUBLIC_DEMO_RESET_TOKEN`, and any var name
    matching `SECRET|TOKEN|KEY|PASSWORD|PASS|CRED` except safe vars)
  - Bumps manifest schema to v3; adds `config_bootstrap` metadata block
- `scripts/restore.sh`: `restore_config_bootstrap()`:
  - Restores roles yaml (mode 600), trust store (700 dir / 600 files),
    public key (644)
  - Installs `env.sanitized` as env only when env is absent; otherwise prints
    `[INFO]` with template path
  - Post-restore preflight: `[OK]`/`[WARN]` for roles yaml and trust key count
  - Wired into both `--fresh` and clean-reload code paths
  - Gracefully skips if no `config/` dir (backwards compat with pre-035 bundles)
- `scripts/test_restore_drill.sh` (extended for KDAT-035 assertions):
  - Asserts `config/env.sanitized` present in bundle
  - Asserts `CLIENT_SECRET` / `AUDIT_HMAC_KEY` / `RESET_TOKEN` absent or `=REDACTED`
  - Asserts `config/lrfd_user_roles.yaml` present when source exists on host
  - Asserts `config/trust/evidence_pubkeys/` keys present when source exists
- `docs/backup-restore.md`: updated bundle contents table; "Config + Trust
  Bootstrap (KDAT-035)" section covering what is included, what is excluded,
  restore behaviour, preflight checks

---

## What this milestone does NOT prove

- That private keys are backed up (they are intentionally excluded)
- Secret rotation or key escrow
- Multi-host trust store synchronization
- That the redaction regex covers all possible secret variable names in all
  deployment configurations (it covers the known set plus a broad regex)

---

## Public-safe claims

"Backup bundles include non-secret config files: user roles YAML, trust store
public keys, the public evidence signing key, and a redacted environment
template. Secret values are redacted before inclusion. Restore reinstalls
config and trust store on the target host, with a preflight check confirming
roles file and trust key presence. Private keys are never backed up."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `f5cba91` | feat(kdat-035): bundle config + trust bootstrap |
| Backup update | `scripts/backup.sh` | config/ collection; schema v3; env redaction |
| Restore update | `scripts/restore.sh` | `restore_config_bootstrap()`; preflight |
| Drill script | `scripts/test_restore_drill.sh` | KDAT-035 assertions in Step 2 |
| Docs | `docs/backup-restore.md` | Config + Trust Bootstrap section |

---

## Verification and tests

**`scripts/test_restore_drill.sh`** covers KDAT-035 in Step 2:

| Assertion | Condition |
|-----------|-----------|
| `config/env.sanitized` present in bundle | Always |
| `CLIENT_SECRET` / `AUDIT_HMAC_KEY` / `RESET_TOKEN` absent or `=REDACTED` | Always |
| `config/lrfd_user_roles.yaml` present | When source exists on host |
| `config/trust/evidence_pubkeys/` keys present | When source exists on host |

---

## Known limitations and caveats

- Private keys (`evidence_ed25519.pem`, `AUDIT_HMAC_KEY`) are never bundled.
  Operators must transfer private key material separately to a restored host.
- The `env.sanitized` template should be reviewed after restore before
  applying to a new deployment — it lists the variables that need real values.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `f5cba91` | Delivery: config/trust collection in backup, restore_config_bootstrap, drill assertions |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Run the full drill (covers KDAT-031/034/035 assertions):
bash scripts/test_restore_drill.sh

# Inspect what config/ contains in a fresh backup:
bash scripts/backup.sh
tar tzf ~/keystone/backups/keystone-backup-*.tar.gz | grep config/
```
