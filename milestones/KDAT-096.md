# KDAT-096 — Document Version Tracking Schema (Migration 23)

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`document_versions` and `version_events` tables added to keystone-demo postgres via idempotent migration 23. Partial unique index enforces at-most-one-active-version per document at the database level. Temporal effectivity columns (`effective_from`, `effective_to`) support point-in-time version queries. Supersession chain tracked via `supersedes_version_id`. Five API endpoints verified: list versions, get current, get at-date, create draft, approve.

---

## What this milestone proves

- `document_versions` table: status lifecycle (`draft → pending_review → active → superseded`), partial unique index `ix_one_active_version` on `doc_id WHERE status='active'`, effectivity date range, supersession chain
- `version_events` table: append-only audit trail for version lifecycle; UPDATE/DELETE/TRUNCATE revoked from `keystone_app` role
- `corpus_chunks.version_id` nullable FK column added for backward compatibility
- 5 API endpoints: `GET /versions/{doc_id}`, `GET /versions/{doc_id}/current`, `GET /versions/{doc_id}/at/{as_of}`, `POST /versions`, `POST /versions/{version_id}/approve`
- Migration is idempotent (`CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`)
- SQLAlchemy models added to `models.py`: `DocumentVersion`, `VersionEvent`

---

## Public-safe claims

"Document version tracking schema with one-active-version database constraint, temporal point-in-time queries, and append-only version event audit trail. Five API endpoints. Migration idempotent."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Migration | `keystone-demo/initdb/23-document-versions.sql` | Idempotent; partial unique index |
| API endpoints | `keystone-gov` `46a0821` | 5 endpoints for version lifecycle |
| Models | `keystone-gov/api/models.py` | DocumentVersion, VersionEvent |

---

## Source basis

Date: 2026-03-29

| Commit | Repo | Purpose |
|--------|------|---------|
| `46a0821` | keystone-gov | feat: document version tracking (5 endpoints, models, schemas) |
| `9ea4f36` | keystone-demo | feat: migration 23 — document_versions + version_events |
