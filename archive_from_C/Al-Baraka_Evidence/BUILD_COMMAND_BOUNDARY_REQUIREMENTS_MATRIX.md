# BUILD_COMMAND_BOUNDARY_REQUIREMENTS_MATRIX.md
Purpose: Matrix of Command Boundary stages separating policy, framework, and implementation.
Source Basis: Verified Pass-3 Baseline.
Evidence Classification: Layer A [E3], Layer B [E4], Layer C [E6].
Current Status: POLICY RECOVERED / IMPLEMENTATION NOT PROVEN.
Explicit Limitations: No implementation claimed. Framework stages do not assume explicit policy recovery unless supported.

| Stage | Layer A: Explicit Recovered Policy [E3] | Layer B: Reconstruction Framework [E4] | Layer C: Structural/Runtime Proof [E1/E2] | Overall Stage Status |
|---|---|---|---|---|
| 1. Command Reception | NONE | Framework logical entry point | NONE [E6] | NOT PROVEN |
| 2. Req ID Validation | Policy concept: Request Identity exists and participates in idempotency/retry semantics [E3] | Framework mapping | Specific validation stage: NOT PROVEN [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 3. Authentication | Actor identity / role concepts recovered [E3] | Framework mapping | Specific Authentication stage: NOT PROVEN [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 4. Authorization | 12 roots, Global, No limits [E3] | Framework mapping | Specific Authorization stage: NOT PROVEN [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 5. Scope | GLOBAL explicitly defined [E3] | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 6. SoD | Base: Initiator ≠ Poster [E3]. Exception: Store_Manager Create+Post [E3] (Scope: UNRESOLVED / HUMAN-DECISION). | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 7. Payload Validation | NONE explicitly recovered [E3] | Framework mapping | NONE [E6] | NOT PROVEN |
| 8. Idempotency | Attempt ID, serialization [E3] | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 9. Concurrency | Concurrent duplicate mgmt [E3] | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 10. Preconditions | Open period, valid FX [E3] | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 11. DB Transaction | NONE | Framework logical boundary | NONE [E6] | NOT PROVEN |
| 12. State Transition | NONE | Framework sequencing | NONE [E6] | NOT PROVEN |
| 13. Economic Event | Authoritative economic event identity / registration [E3] | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 14. Accounting | Journal mapping rules [E3] | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 15. Audit | Causal chain traceability [E3] | Framework mapping | NONE [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 16. Commit | Transactional atomicity / no partial success policy recovered [E3] | Framework mapping | Explicit Command Boundary Commit stage: NOT PROVEN [E6] | POLICY RECOVERED / IMPL NOT PROVEN |
| 17. Response | NONE | Framework boundary closure | NONE [E6] | NOT PROVEN |

### Economic Event vs. Costing / Journal Binding Separation
Recovered policy [E3] explicitly separates the following concepts (Implementation remains [E6] NOT PROVEN):
*   **Economic Event:** Authoritative economic event identity / registration.
*   **Cost Adjustment / V_new:** `cost_adjustment_events.id` = immutable V_new.
*   **Costing Current State:** `costing_runs.id` = mutable current state.
*   **Journal Binding:** `journal_entries.cost_adjustment_event_id` references the exact immutable cost adjustment event.
