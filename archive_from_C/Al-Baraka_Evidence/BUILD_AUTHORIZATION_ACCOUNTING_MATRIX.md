# BUILD_AUTHORIZATION_ACCOUNTING_MATRIX.md
Purpose: B1 × B2 Reconciliation Matrix.
Source Basis: Verified Pass-3 Baseline.
Evidence Classification: [E3] Recovered Content.
Current Status: RECONCILED AT POLICY LEVEL.
Explicit Limitations: B1-C01 remains strictly unresolved.

| Intersection Area | Policy Evaluation [E3] | Conflict Status | Notes |
|---|---|---|---|
| Auth vs Accounting | Consistent | RECOVERED | Both enforce fail-closed on violation. |
| Offline/Sync vs Auth | Consistent | RECOVERED | Full re-authorization required at sync. |
| Idempotency vs Acc. | Consistent | RECOVERED | Idempotency prevents duplicate authoritative accounting results on posting paths where accounting applies, while credit_approvals and other non-accounting roots retain their recovered accounting applicability. |
| Failure / Rollback | Consistent | RECOVERED | Total rollback, no partial mutations. |
| Costing / V_new | Consistent | RECOVERED | V_new inextricably linked to event. |
| FX vs Accounting | Consistent | RECOVERED | Exact posting timestamp FX lock. |
| Accounting Period | Consistent | RECOVERED | Checked pre-commit. |
| Audit / Governance | Consistent | RECOVERED | Causal chain traceable across domains. |
| Arch Non-Expansion | Consistent | RECOVERED | Confined to 55 canonical entities. |
| **SoD vs Posting** | **Ambiguous** | **HUMAN-DECISION**| **Base recovered policy: Initiator ≠ Poster [E3]. Managerial exception: Store_Manager may Create + Post same high-risk transaction [E3]. Exception scope: UNRESOLVED / HUMAN-DECISION REQUIRED.** |
