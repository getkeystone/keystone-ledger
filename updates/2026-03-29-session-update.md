# KDAT Ledger Update: 2026-03-29 Session

## New KDATs

### KDAT-096: Water Utility Fixture Corpus (13 SOPs, 16 files)
**Status:** Proven
**Evidence:** keystone-experiments commit a650bac. fixtures/water/corpus/ (16 markdown files).
**Description:** 13 synthetic water/wastewater treatment SOPs authored for Ontario municipal utility context. 3 versioned procedure pairs with testable differences (chlorination CT 20->30min, sampling +PFAS protocol, emergency response MECP 24h->1h notification). 3 ACL levels (all-operators, certified-operators, management). Regulatory references validated against O. Reg. 170/03, Health Canada PFAS Objective (30 ng/L, 25 PFAS, Aug 2024), O. Reg. 632/05, CSA Z460-20.

### KDAT-097: Water Utility Holdout Query Set (30 queries)
**Status:** Proven
**Evidence:** keystone-experiments commit a650bac. fixtures/water/test_queries.json.
**Description:** 30-query holdout following KDAT-001B schema. Distribution: 15 retrieval_in_corpus, 5 acl_denied, 5 fail_closed_ooc, 3 temporal, 1 latency, 1 audit_integrity. 4 test users mapped to Ontario operator certification classes (I-IV). Every ACL denial case maps to a restricted document in the corpus.

### KDAT-098: Water Utility Seed Data (24 documents, 4 users, 3 groups)
**Status:** Proven
**Evidence:** keystone-experiments commit a650bac. fixtures/water/seed.sql.
**Description:** Seed SQL for two-layer corpus: 16 synthetic SOPs (Layer 1) + 8 government reference PDFs (Layer 2, 381 pages). Layer 2 includes Ontario Design Guidelines (5 chapters), Safe Drinking Water Act 2002, Health Canada DWQS Summary Table, Ontario MOH Treatment Options Factsheet. Reference PDFs stored outside repo at REDACTED_PATH on host-primary.

### KDAT-099: Water Utility Market Validation
**Status:** Proven
**Evidence:** internal market-validation working docs (tracked privately, not published).
**Description:** Structured market analysis of utility sectors; water/wastewater selected as the first wedge. Commercial model, competitor analysis, and go-to-market detail are tracked in private strategy docs and are not published here.

## Outstanding

### KDAT-100: Water Corpus Regression (pending Session 3)
**Status:** Outstanding
**Gate:** Must pass 80%+ retrieval accuracy, 100% fail-closed, 100% ACL containment on the 30-query water holdout before any external use of the water corpus.
**Depends on:** keystone-experiments Docker stack running on host-primary with water corpus ingested.
