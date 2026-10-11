# BUILD_EVIDENCE_GAP_REGISTER.md
Purpose: Consolidated gap register separating evidence criticality from current-gate blocking.
Source Basis: Verified Pass-3 Baseline.
Current Status: OPEN.

| Gap ID | Description | Affected Requirement | Evidence Criticality | Current-Gate Blocking | Status |
|---|---|---|---|---|---|
| GAP-A1-001 | A1/A2 direct evidence missing. | Initial states, locks. | CRITICAL | NO | OPEN |
| GAP-B1-001 | Orig. Frozen B1/B2 source missing. | All B1/B2 claims. | NON-CRITICAL | NO | OPEN |
| GAP-D7-001 | D7 trace not proven independently. | Causal traceability. | CRITICAL | NO | OPEN |
| GAP-DDL-01 | canonical_stage1_ddl_v2.sql unavail. | All DD-1 dependencies.| CRITICAL | YES (Blocks Struct Verification) | OPEN |
| GAP-FSM-01 | FSM structural proof missing. | State transitions. | CRITICAL | NO (Proceed with Policy) | OPEN |
| GAP-CB-001 | Command Boundary runtime proof. | All stages 1-17. | CRITICAL | NO (Proceed with Policy) | OPEN |
