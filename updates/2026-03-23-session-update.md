# KDAT Ledger Update: 2026-03-23 Session

## Updates to Existing KDATs

### KDAT-072 (correction)
- **Was:** Alberta OHS Corpus Ingestion (57 docs, 2,717 chunks)
- **Now:** Alberta OHS Corpus Ingestion (54 docs, 2,675 chunks)
- **Reason:** Removed redundant full OHS Code PDF. Removed 2025 split PDFs (poor text quality). Retained 40 individually published OHS Code parts + 14 guides/references.

### KDAT-075 (expanded)
- **Was:** Security Hardening Pass 1 (7 critical/high fixes)
- **Add note:** Extended with 6 additional items in KDAT-084.

## New KDATs

### KDAT-081: Repository Separation
**Status:** Proven
**Evidence:** GitHub repos keystone-lrfd, keystone-demo, keystone-dev. Docker containers keystone-lrfd-*, keystone-demo-*. Volumes migrated.
**Description:** Separated shared keystone-deploy into per-deployment repos. Root cause: shared compose directory allowed commands targeting wrong database.

### KDAT-082: LRFD Roster Seeding
**Status:** Proven
**Evidence:** 23 LRFD members added via SQL. Total 29 managed_users verified.
**Description:** Full LRFD roster (17 members, 5 officers, 1 authority) seeded with disabled status.

### KDAT-083: Cross-Contamination Fix
**Status:** Proven
**Evidence:** user_roles.yaml mounted to override baked-in LRFD roster. LRFD_ROLE_CONFIG_PATH set.
**Description:** Identified a data-isolation gap between pilot and demo environments caused by shared-host infrastructure. Resolved by separating the demo onto a dedicated host to eliminate the shared-compose root cause.

### KDAT-084: Security Hardening Pass 2
**Status:** Proven
**Evidence:** keystone-gov ee0cc6b, keystone-console 0d40db2, keystone-demo e888654.
**Description:** 6 remaining items: seed gating, salt validation, prompt injection, DB permissions, session invalidation, /health gating.

### KDAT-085: Pinned Image Deployment Workflow
**Status:** Proven
**Evidence:** Docker images keystone-api:v0.3.2, v0.4.0, v0.4.1. Compose uses image: not build:.
**Description:** Three-tier: dev builds from source, demo pinned image, LRFD frozen image.

### KDAT-086: Demo UI Polish
**Status:** Proven
**Evidence:** keystone-console commits on dev/keystone-next.
**Description:** members_readonly mode, mock data removal, Training toggle fix, LRFD reference cleanup.

### KDAT-087: Retrieval Tuning Baseline
**Status:** Proven (partial)
**Evidence:** 51-query test harness. 24/48 pass (50%), 2/3 fail-closed correct, 1 false positive.
**Description:** Identified 3 over-refusal gates. Disabled relevance gate and hedge detection pending HHEM. Improved from 23% to 50%.

### KDAT-088: Config-Driven Feature Flags
**Status:** Proven
**Evidence:** deployment.yaml features section. /api/config includes features. Console reads features.members_readonly.
**Description:** Per-deployment feature toggling without code changes.

## Docker Images

| Tag | Used By | Date |
|-----|---------|------|
| keystone-api:v0.3.2 | keystone-lrfd | 2026-03-20 |
| keystone-api:v0.4.0 | (superseded) | 2026-03-20 |
| keystone-api:v0.4.1 | keystone-demo | 2026-03-23 |

## Total: 57 KDATs
