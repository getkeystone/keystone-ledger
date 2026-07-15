# FC-005: Domain Scope Guard

Pre-retrieval domain scope guard refusing out-of-corpus queries.
Remediation for retrieval-v1 failure where a greenhouse gas TIER
query returned OHS Part 36 mine-gas chunks with high confidence.

## Contributing factors

1. Embedding vocabulary overlap: "greenhouse gas" and "flammable gas"
   clustered in the same neighborhood due to shared token "gas"
2. HHEM consistency scorer measured answer-to-chunk faithfulness,
   not query-to-chunk relevance; internally consistent wrong-topic
   answer passed the gate
3. No domain scope signaling at pipeline entry; out-of-corpus queries
   reached retrieval without refusal

## Remediation

DOMAIN_OUT_OF_SCOPE classification at pre-retrieval stage.
Queries outside corpus domain coverage route to fail-closed refusal
with documented reason before reaching retrieval.

Labeled demo-grade (phrase block-list, not a general classifier).

## Commits (from keystone-gov, private repo)

- Implementation: 2ecdf50 — FC-005: domain scope guard refusing out-of-corpus queries
- Merge: 38ef89f — Merge FC-005 domain scope guard
- Documentation: 6849416 — README: add FC-005 remediation note under eval table

Patch file included for inspection.
