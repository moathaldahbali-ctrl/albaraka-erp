# BUILD_REQUIREMENTS_MASTER_REGISTER.md
Purpose: Central requirements register for all substantive recovered B1 and B2 content, and verified A1/A2/A5 rules.
Source Basis: Verified Pass-3 Baseline.
Evidence Classification: Mixed ([E2], [E3], [E6]).
Current Status: RECONSTRUCTED CANDIDATE.
Explicit Limitations: No implementation authorized. DDL structurally blocked (GATE-0 Unavailable). No implicit privileges, emergency bypasses, or missing permissions invented.

| Req ID | Domain | Statement | Source | Class | VM | DD Class | Status |
|---|---|---|---|---|---|---|---|
| REQ-A1-001 | Integrity | Evidence gap / verification target: Initial-state, initial-balance, concurrency, locking. | NONE | [E6] | VM-6 | DD-1 | NOT PROVEN |
| REQ-A2-001 | Accounting | Evidence gap / verification target: Initial-value and immutable journal structural semantics. | NONE | [E6] | VM-6 | DD-1 | NOT PROVEN |
| REQ-A5-001 | Device ID | Historical device attribution is immutable (UUID, FK, Trigger, Function). | Historic | [E2] | VM-1 | DD-1 | PROVEN |
| REQ-B1-001 | Auth Roles | Actor roles explicitly defined: Cashier, Inventory_Clerk, Accountant, Store_Manager, General_Manager. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-002 | Auth Base | Default-Deny applies. No implicit privilege, emergency bypass, superuser bypass, offline bypass, or sync bypass. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-003 | Auth Identity | Auth resolved via: Role + Permission + Root + Command + Scope + applicable conditions. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-004 | Auth Matrix | Auth matrix mapping governs all 12 economic roots (Create/Edit/Post/Cancel permissions). Evaluated at execution. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-005 | Auth Scope | Authorization scope is strictly GLOBAL. Amount thresholds = NONE. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-006 | SoD Base | Initiator ≠ Poster for: purchases, inventory_adjustments, payments, credit_approvals. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-007 | SoD Exception| Store_Manager may Create + Post same high-risk transaction. (Scope: HUMAN-DECISION / B1-C01 unresolved). | B1 Rec | [E3] | VM-3 | DD-4 | HUMAN-DECISION |
| REQ-B1-008 | Auth Failure | DENY → no business mutation → rollback where transaction exists → deterministic failure. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-009 | Retry / Dup | Same logical Req ID + Attempt ID retry → auth re-eval. Dup after commit → return committed result. Changed payload → conflict. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-010 | Operations | Draft editing is an operation/command, NOT an FSM state. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-011 | Governance | Store_Manager Submit only. Accountant Submit only. General_Manager Submit/Approve/Activate/Revoke. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B1-012 | Sync Auth | Offline/sync requires strict authoritative-boundary revalidation. | B1 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-001 | Roots Applic.| Acc. applies to: sales, sale_returns, purchases, purchase_returns, inv_adj, inv_transfers, expenses, payments, payment_refunds, cash_transfers, cash_adj, credit_approvals. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-002 | Journal Cont.| Authoritative economic posting → logical journal result. Multiple lines allowed. No orphaned rows. Failure → rollback. No partial success. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-003 | Journal Impl.| Exactly once journal creation implementation guarantee. | NONE | [E6] | VM-6 | DD-1 | NOT PROVEN |
| REQ-B2-004 | D/C Mappings | Explicit Debit/Credit mappings required for the 12 roots. No invented accounts beyond recovered policy. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-005 | Acc Precedence| 1) explicit line map, 2) category/group, 3) entity, 4) location, 5) system default. Unresolved → fail closed/reject/rollback. No arbitrary suspense account. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-006 | FX Rules | Base+Txn currency. Base authoritative journals. FX locked at exact posting event timestamp. Missing rate → fail/rollback. Realized FX only. Historical reversal uses exact orig base amounts (no new FX). | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-007 | Acc Period | Posting date resolves period. Must be open. Missing/hard-closed period → reject/rollback. Concurrent close race → failure. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-008 | Costing | One cost_adj_event row = one immutable transition (V_new). costing_runs.id = mutable state. Journal references exact cost_adj_event_id. Material inv valuation requires COGS/Inv lines. Failure → full rollback. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-009 | Corrections | Posted journals immutable. Reversal preserves causal ancestry. Corrections via explicit returns/refunds. Cancellation only where FSM permits before posting. (Reversal is a mechanism, NOT a state). | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-010 | Decimals | Calc precision DECIMAL(28,8). Stored DECIMAL(19,4)/(19,6). HALF_EVEN. Exact D/C balance. No residual tolerance/rounding account. Unbalanced → FAIL/ROLLBACK. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-011 | Idempotency | After commit, same Req ID + same materially relevant payload → return committed result. Changed payload → conflict. Retry → new Attempt ID + auth/precondition re-eval. Concurrent duplicates serialized. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-012 | Failure Matrix| Mandatory failure cascade (auth, precondition, acc mapping, FX, period, costing, journal, audit, DB invariant) → FAIL / ROLLBACK / NO PARTIAL BUSINESS SUCCESS. | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-B2-013 | Audit Chain | Causal chain: Req ID → Attempt ID → Econ Event → Cost Adj Event/V_new → Journal Entry → Journal Lines. Mandatory audit fail → business rollback. Gov #272 evidence survives rollback. (Runtime proof = [E6]). | B2 Rec | [E3] | VM-3 | DD-4 | RECOVERED |
| REQ-ALL-01 | Architecture | NO NEW ENTITY. NO NEW SCHEMA. NO NEW FSM. NO NEW COMMAND BOUNDARY. NO B1 AUTH CHANGE. NO GOV #234-#274 CHANGE. (Without explicit authorization). | B1/B2 | [E3] | VM-3 | DD-4 | RECOVERED |
