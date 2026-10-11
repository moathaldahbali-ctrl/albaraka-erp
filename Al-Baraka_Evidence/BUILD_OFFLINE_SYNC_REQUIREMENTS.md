# BUILD_OFFLINE_SYNC_REQUIREMENTS.md
Purpose: Offline and Sync authorization and FSM behavior.
Source Basis: Verified Pass-3 Baseline.
Evidence Classification: Mixed.
Current Status: POLICY RECOVERED / RUNTIME UNPROVEN.
Explicit Limitations: Implementation-level exactness is unproven.

| Concept | Recovered Policy Requirement [E3] | Implementation Proof [E6] | Status |
|---|---|---|---|
| Auth Revalidation | Sync requires full authoritative-boundary revalidation. | NONE | NOT PROVEN |
| FSM Integrity | Offline states strictly re-evaluated against current DB. | NONE | NOT PROVEN |
| Identity Tracking | Request/Attempt Identity maintained across sync. | NONE | NOT PROVEN |
| Scope & SoD | Offline actions cannot bypass GLOBAL authorization scope (Amount thresholds = NONE) or SoD rules. | NONE | NOT PROVEN |
| Conflict Behavior | Changed payloads during sync trigger conflict rejections. | NONE | NOT PROVEN |
