# KDAT-097 — Version Approval with Separation of Duties

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

Version creator cannot approve their own version. Authority role required for approval. Enforced at the API layer with 403 responses. Verified via curl tests: same-user approve returns 403, non-authority approve returns 403, cross-user authority approve returns 200.

---

## What this milestone proves

- `POST /versions/{version_id}/approve`: checks `approved_by != created_by` (separation of duties)
- Approval restricted to `_VERSION_APPROVE_ROLES = {"authority"}` — officers and custodians cannot approve
- 403 response with descriptive message when self-approve attempted
- 403 response when non-authority role attempts approval
- 200 response when authority approves version created by a different user
- Version status transitions `pending_review → active`, sets `approved_by`, `published_at`, and `effective_from`
- Previous active version automatically transitioned to `superseded`

---

## Public-safe claims

"Version approval enforces separation of duties at the API layer: version creator cannot approve their own version, authority role required. Verified via curl tests showing correct 403 and 200 responses."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| API endpoint | `keystone-gov` `46a0821` | POST /versions/{id}/approve with SoD check |
| Role check | `_VERSION_APPROVE_ROLES = {"authority"}` | Defined in main.py |

---

## Source basis

Date: 2026-03-29

| Commit | Repo | Purpose |
|--------|------|---------|
| `46a0821` | keystone-gov | feat: document version tracking — approval with SoD |
