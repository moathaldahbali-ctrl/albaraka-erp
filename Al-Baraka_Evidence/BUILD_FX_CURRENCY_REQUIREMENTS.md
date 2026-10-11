# BUILD_FX_CURRENCY_REQUIREMENTS.md
Purpose: Separation of FX Storage, Policy, and Runtime.
Source Basis: Verified Pass-3 Baseline.
Evidence Classification: Mixed.
Current Status: POLICY RECOVERED / IMPLEMENTATION UNPROVEN.
Explicit Limitations: Implementation semantics remain strictly unproven without runtime evidence.

| Dimension | Statement / Requirement | Source | Class | Status |
|---|---|---|---|---|
| Storage | DDL schema implementation of FX columns. | canonical_stage1_ddl_v2.sql | [E6] | NOT PROVEN (GATE-0 UNAVAILABLE) |
| Policy | Base/Txn currency, timestamp lock, realized FX only. | B2 Rec | [E3] | RECOVERED CANDIDATE |
| Policy | Historical reversal utilizes original base amount. | B2 Rec | [E3] | RECOVERED CANDIDATE |
| Runtime | Execution of exact timestamp lock and fail-closed logic.| NONE | [E6] | NOT PROVEN |
