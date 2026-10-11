TIER 3 — TRIGGER / DEFERRED / IMMUTABILITY STRUCTURE
6.8 Triggers
Finding: The DDL contains 15 explicit triggers (2 standard BEFORE UPDATE triggers for immutability, and 13 constraint triggers for deferred commit-time validation).
Evidence Class: [E1-E2] Observed
| Trigger Name | Table | Timing | Event | Function/Action | Deferrability | Evidence |
|---|---|---|---|---|---|---|
| trg_a5_device_immutability | register_sessions | BEFORE | UPDATE | enforce_a5_device_immutability() | NOT DEFERRABLE | [E1-E2] |
| enforce_cost_adjustment_immutability | cost_adjustment_events | BEFORE | UPDATE | trg_cost_adjustment_immutability() | NOT DEFERRABLE | [E1-E2] |
| d1_trg_registry | economic_event_registry | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_sales | sales | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_purchases | purchases | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_sale_returns | sale_returns | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_purchase_returns | purchase_returns | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_inv_adjustments | inventory_adjustments | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_inv_transfers | inventory_transfers | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_expenses | expenses | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_payments | payments | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_refunds | payment_refunds | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_cash_transfers | cash_transfers | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_cash_adjustments | cash_adjustments | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
| d1_trg_credit_approvals | credit_approvals | AFTER | INSERT OR UPDATE OR DELETE | d1_trigger_router() | DEFERRABLE INITIALLY DEFERRED | [E1-E2] |
6.9 Deferred Chain
Finding: A structurally encoded deferred validation mechanism (D1) exists, designed to execute at COMMIT time across 13 tables.
Evidence Class: [E5] Derived (from explicit structural mechanics observed in [E1-E2])
 * Mechanism: CREATE CONSTRAINT TRIGGER ... DEFERRABLE INITIALLY DEFERRED
 * Scale: Exactly 13 triggers bound to the d1_trigger_router() function.
 * Target: economic_event_registry (the registry) + 12 root transaction tables (sales, purchases, etc.).
 * Structural Behavior:
   * The d1_trigger_router() determines the target_id (client_transaction_id) based on TG_OP (UPDATE/DELETE/INSERT).
   * It passes the ID to d1_validate_identity(target_id).
   * The validation function aggregates a count (r_count) from all 12 root tables for the specific ID.
   * Explicit Exceptions Raised:
     * If count > 0 but no registry entry: "D1 Violation: Root exists without Registry at COMMIT"
     * If registry entry exists but count = 0: "D1 Violation: Registry exists without Root at COMMIT"
     * If count > 1: "D1 Violation: Multiple Roots (%) exist at COMMIT"
     * If registry event_type mismatch with root origin: "D1 Violation: Registry event_type (%) does not match Root origin (%) at COMMIT"
 * Constraint Rule: We verify structurally that this chain exists and enforces a strict 1-to-1 cardinality and type match between the registry and root tables at commit time. No undocumented business semantic is inferred.
6.10 Immutability — A5 (and A3)
Finding: The DDL explicitly encodes mechanisms to enforce the historical immutability of specific attribution fields (A5) and transaction components (A3).
Evidence Class: [E1-E2] Observed
 * Observed Mechanism (A5 - Device Immutability):
   * Function: enforce_a5_device_immutability()
   * Binding: trg_a5_device_immutability on table register_sessions.
   * Structural Logic: Compares NEW.pos_device_id against OLD.pos_device_id.
   * Exception: If distinct, raises 'A5 Violation: pos_device_id attribution is historically immutable.'
 * Observed Mechanism (A3 - Cost Adjustment Immutability):
   * Function: trg_cost_adjustment_immutability()
   * Binding: enforce_cost_adjustment_immutability on table cost_adjustment_events.
   * Structural Logic: Unconditionally blocks UPDATE.
   * Exception: Raises 'A3 Immutability Violation: cost_adjustment_events historical records cannot be updated.'
TIER 3 STATUS: PASS
PASS-3 — TIER 3 OUTPUT COMPLETE
Awaiting user confirmation before proceeding to Tier 4 (Indexes and Sequences) per §13.1 Output Length Management.

