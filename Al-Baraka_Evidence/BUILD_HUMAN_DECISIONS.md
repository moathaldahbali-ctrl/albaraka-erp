# BUILD_HUMAN_DECISIONS.md
Purpose: Escalate unresolved constraints blocking architecture or policy.
Source Basis: Verified Pass-3 Baseline.
Evidence Classification: [HUMAN-DECISION].
Current Status: PENDING.

### HD-01: GATE-0 Current DDL Availability
**Context:** `canonical_stage1_ddl_v2.sql` is currently UNAVAILABLE. Structural dependency mapping is blocked.
**Decision Options:**
1. ACCEPT CONTINUATION WITH STRUCTURAL DEPENDENCIES BLOCKED
2. PROVIDE ACCESSIBLE VERIFIED DDL
3. HALT

### HD-02: B1-C01 Managerial SoD Exception Scope
**Context:** B1 requires "Initiator ≠ Poster". Exception states "Store_Manager may Create + Post same high-risk transaction."
**Decision Options (Scope selection):**
1. Overrides SoD for SOME roots (must define which).
2. Overrides SoD for ALL four roots (purchases, inv_adj, payments, credit).
3. Applies only to another defined subset.
4. Has another scope entirely.
*(Agent is strictly prohibited from selecting the scope automatically).*
