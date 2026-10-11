# PASS-3 VERIFIED REQUIREMENTS REGISTER
# Al-Baraka ERP/POS — Independent ChatGPT Verification
# Status: VERIFIED NORMALIZATION — NOT IMPLEMENTATION AUTHORIZATION

## 1. EXECUTIVE STATUS

Project Revision:
POST-STEP-9-REQUIREMENTS-RECONSTRUCTION

Source Basis:
Gemini Pass-3 Final Reconstruction + independently verified prior evidence

Verification Role:
Independent normalization, correction, evidence classification, and boundary control.

Current Authorization:
- STEP-8 EXECUTION: NOT AUTHORIZED
- PRODUCTION IMPLEMENTATION: NOT AUTHORIZED
- D7: OPEN / NOT INDEPENDENTLY PROVEN AT RUNTIME
- ORIGINAL FROZEN B1 SOURCE: NOT PROVEN
- ORIGINAL FROZEN B2 SOURCE: NOT PROVEN

Requirements Reconstruction Status:
COMPLETE FOR RECOVERED CONTENT / OPEN FOR STRUCTURAL AND RUNTIME EVIDENCE

Confidence:
MIXED

---

## 2. EVIDENCE CLASSIFICATION

E1 = Frozen Direct Source
E2 = Direct Structural/Runtime Evidence
E3 = Recovered Content
E4 = Secondary/Closure/Evaluation
E5 = Inference
E6 = Unknown / Not Proven

Critical rule:
Recovered content MUST NOT be represented as Frozen Source.

---

## 3. B1 — AUTHORIZATION POLICY

Source:
B1_FINAL_POLICY_RECOVERED_CONTENT_CANDIDATE.md

Evidence:
[E3] Recovered Content

Frozen Source Identity:
[E6] Original historical Frozen Source not recovered.

### REQ-B1-001 — Actor Roles and Default Deny
Requirement:
Authorization is permitted only when explicitly matched to:
Role + Permission + Root + Command + Scope + applicable conditions.

Anything not explicitly defined is DENY.

No implicit privilege, emergency bypass, superuser bypass, offline bypass, or sync bypass.

Status:
RECOVERED

Evidence:
[E3]

### REQ-B1-002 — Twelve Economic Roots
Requirement:
Authorization policy covers the twelve defined economic roots.

Status:
RECOVERED

Evidence:
[E3]

### REQ-B1-003 — Separation of Duties
Requirement:
Initiator != Poster is required for:
- purchases
- inventory_adjustments
- payments
- credit_approvals

Status:
RECOVERED

Evidence:
[E3]

### REQ-B1-004 — Store Manager Exception
Requirement:
Store_Manager may Create + Post the same high-risk transaction, subject to audit.

Status:
RECOVERED

Important:
The exact scope of this exception relative to the Initiator != Poster rule is unresolved.

See B1-C01.

### REQ-B1-005 — Amount Thresholds
Requirement:
AMOUNT THRESHOLDS: NONE.

Authorization scope:
GLOBAL.

No location-based amount thresholds are to be invented or inferred.

Status:
RECOVERED

Evidence:
[E3]

### REQ-B1-006 — Offline / Sync Authority
Requirement:
Offline operation does not grant superior authority.

At the authoritative boundary, authorization and required conditions must be re-applied.

Status:
RECOVERED

Evidence:
[E3]

### REQ-B1-007 — Authorization Failure
Requirement:
Authorization failure results in:
DENY -> NO BUSINESS MUTATION -> ROLLBACK WHERE TRANSACTION EXISTS -> DETERMINISTIC FAILURE.

Status:
RECOVERED

### REQ-B1-008 — Retry / Resubmission
Requirement:
A retry of the same logical request:
- preserves Request Identity
- receives a new Attempt Identity
- re-evaluates authorization and applicable preconditions.

Status:
RECOVERED

### REQ-B1-009 — Governance
Requirement:
Store_Manager and Accountant may Submit but may not Approve/Activate/Revoke.

General_Manager may Submit/Approve/Activate/Revoke subject to:
- SoD
- Quorum
- Expiry
- Materiality
- Atomicity
- Revocation

Status:
RECOVERED

### REQ-B1-010 — Architectural Non-Expansion
Requirement:
B1 does not authorize adding new entities, schema objects, FSM structures, or other architecture.

Status:
RECOVERED

---

## 4. B1 — HUMAN DECISION REQUIRED

### B1-C01 — Store_Manager SoD Exception Scope

Known recovered statements:
1. Initiator != Poster applies to purchases, inventory_adjustments, payments, credit_approvals.
2. Store_Manager may Create + Post the same high-risk transaction, subject to audit.

Unresolved:
Whether the Store_Manager exception overrides the SoD rule for some or all of the listed roots.

Status:
HUMAN-DECISION REQUIRED

Rule:
No inference or automatic precedence selection is permitted.

---

## 5. B2 — ACCOUNTING POLICY

Source:
B2_FINAL_POLICY_RECOVERED_CONTENT_CANDIDATE.md

Evidence:
[E3] Recovered Content

Frozen Source Identity:
[E6] Original historical Frozen Source not recovered.

### REQ-B2-001 — Accounting Applicability
Requirement:
Accounting applicability is defined independently for the twelve economic roots.

Status:
RECOVERED

### REQ-B2-002 — Journal Contract
Requirement:
An authoritative posted economic event produces one logical journal result.

A journal may contain multiple lines.

Mandatory journal-generation failure causes the Phase-2 transaction to fail/rollback.

Status:
RECOVERED

Important:
This does NOT independently prove implementation behavior.

### REQ-B2-003 — Cost Adjustment / V_new
Requirement:
One cost_adjustment_events row represents one immutable costing transition and exact V_new identity.

costing_runs represents mutable current state.

journal_entries references the exact immutable cost adjustment event.

Status:
RECOVERED

### REQ-B2-004 — Account Selection Precedence
Precedence:
1. explicit item/transaction-line mapping
2. category/group
3. entity
4. location
5. system default

If a required role is unresolved:
FAIL CLOSED / REJECT / ROLLBACK.

No arbitrary suspense selection.

Status:
RECOVERED

### REQ-B2-005 — FX Lock
Requirement:
Transaction currency and base currency are distinguished.

Authoritative journals are in base currency.

FX is locked at the exact authoritative economic posting event timestamp.

Missing required FX rate causes failure/rollback.

Status:
RECOVERED

### REQ-B2-006 — FX Realization and Historical Reversal
Requirement:
Realized FX applies to settlements.

Unrealized FX / period-end revaluation is out of scope.

Historical reversals/returns reverse exact original base amounts and do not recalculate using a new FX rate.

Status:
RECOVERED

### REQ-B2-007 — Accounting Period
Requirement:
Posting date resolves the accounting period.

The period must be open.

Missing or hard-closed period causes rejection/rollback.

Concurrent close race must fail safely.

Status:
RECOVERED

### REQ-B2-008 — Costing
Requirement:
Material inventory valuation changes produce required COGS/Inventory accounting effects.

Costing failure causes full transaction rollback.

Status:
RECOVERED

### REQ-B2-009 — Corrections and Causal Ancestry
Requirement:
Posted journals are immutable.

Corrections occur through the applicable return/refund/reversal mechanism and preserve causal ancestry.

Status:
RECOVERED

### REQ-B2-010 — Decimal / Rounding Contract
Requirement:
Calculation precision:
DECIMAL(28,8)

Stored precision:
DECIMAL(19,4) / DECIMAL(19,6)

Rounding:
HALF_EVEN

No IEEE754 arithmetic.

No residual tolerance.

No rounding account.

Unbalanced debit/credit:
FAIL / ROLLBACK.

Status:
RECOVERED

### REQ-B2-011 — Idempotency and Concurrency
Requirement:
Posting paths use the Command Boundary.

For the same Request Identity and same materially relevant payload after commit:
RETURN COMMITTED RESULT.

Changed payload:
IDENTITY/PAYLOAD CONFLICT.

Retry:
NEW ATTEMPT IDENTITY + RE-EVALUATION.

Concurrent duplicates:
must serialize so that only one authoritative result is produced.

Status:
RECOVERED

Important boundary:
This is a recovered policy requirement.

It is NOT independent proof of an implementation-level "exactly-once journal creation" guarantee.

### REQ-B2-012 — Failure Cascade
Requirement:
Mandatory failure involving authorization, preconditions, account resolution, FX, period, costing, journal generation, audit, or DB invariants causes:
FAIL / ROLLBACK / NO PARTIAL BUSINESS SUCCESS.

Status:
RECOVERED

### REQ-B2-013 — Audit Causal Chain
Requirement:
Required causal chain:

Request Identity
-> Attempt Identity
-> Economic Event
-> Cost Adjustment Event / V_new
-> Journal Entry
-> Journal Lines

Mandatory audit failure rolls back the business transaction.

Critical audit-failure evidence under Governance #272 must survive outside the rolled-back business transaction.

Status:
RECOVERED

Important:
Runtime proof belongs to D7 and is not established here.

---

## 6. FSM RECONSTRUCTION BOUNDARY

Recovered policy concepts include:
- Draft
- Posted
- Cancel-before-post where applicable
- Returns/refunds/reversal mechanisms for correction after posting
- Edit as an operation permitted in applicable pre-post conditions

Critical correction:
"Edit" is an OPERATION/COMMAND, not a proven FSM state.

Critical correction:
"Reversal" is a CORRECTION MECHANISM, not a proven FSM state.

"Posted" may be treated as a recovered state/concept, but no stronger implementation semantics are inferred.

FSM implementation:
[E6] NOT PROVEN

No undocumented transition is to be invented.

---

## 7. COMMAND BOUNDARY

The reconstruction framework identifies the following conceptual stages:

1. Command Reception
2. Request Identity Validation
3. Authentication
4. Authorization
5. Scope
6. SoD
7. Payload Validation
8. Idempotency
9. Concurrency
10. Preconditions
11. DB Transaction
12. State Transition
13. Economic Event
14. Accounting
15. Audit
16. Commit
17. Response

Evidence classification:

B1/B2 explicitly recover requirements concerning:
- Request Identity
- Attempt Identity
- Authorization
- SoD
- Idempotency
- Preconditions
- DB transaction / rollback
- Economic Event
- Accounting
- Audit

Other stages may be framework-level reconstruction structure rather than independently frozen historical requirements.

Therefore:

Command Boundary policy:
PARTIALLY RECOVERED

Command Boundary implementation:
[E6] NOT PROVEN

No implementation architecture is authorized by this register.

---

## 8. A1 / A2 / A5

### A1
Initial-state / initial-value/concurrency evidence:
[E6] Direct source not recovered.

Structural/runtime proof:
NOT PROVEN.

### A2
Concurrency / initial-state related evidence:
[E6] Direct source not recovered.

Structural/runtime proof:
NOT PROVEN.

### A5
Historical technical evidence:
[E2] Proven through prior local structural/runtime verification.

Evidence included:
- register_sessions.pos_device_id
- UUID FK to pos_devices.id
- NOT NULL
- ON DELETE RESTRICT
- enforce_a5_device_immutability
- trg_a5_device_immutability
- BEFORE UPDATE ROW
- failing update test
- same-value update passing test

Current Gemini environment:
[E6] Not independently re-executable there.

Important:
Current environmental inability does NOT invalidate the historical local verification result.

Historical artifact SHA/size:
NOT COMPUTED in the current A5 extraction record unless separately pinned.

---

## 9. FX / CURRENCY

Storage infrastructure:
Current canonical DDL evidence is DD-dependent and currently unavailable to Gemini.

Recovered policy:
[E3] FX semantics are recovered in B2.

Runtime proof:
[E6] Not independently proven.

Therefore:

FX Policy:
RECOVERED

FX Storage:
NOT PROVEN IN CURRENT VERIFICATION CONTEXT

FX Runtime:
NOT PROVEN

---

## 10. OFFLINE / SYNC

Recovered policy:
- Offline does not grant additional authority.
- Authoritative boundary re-applies authorization and relevant controls.
- Failed authorization/conditions remain failures.
- No conversion into a different economic operation.
- No offline/sync bypass.

Evidence:
[E3]

Structural/runtime implementation:
[E6] NOT PROVEN

---

## 11. MASTER DATA

Recovered architectural requirement:
No architectural expansion beyond the canonical 55 entities.

Evidence:
[E3]

Current structural verification:
DD-dependent and not independently available in Gemini environment.

No new entity is authorized.

Status:
RECOVERED POLICY / STRUCTURAL STATUS NOT PROVEN

---

## 12. B1 x B2 RECONCILIATION

Overall:
NO DIRECT CONTRADICTION PROVEN.

Areas reconciled:
- Authorization vs Accounting
- SoD vs Posting
- Offline/Sync
- Idempotency
- Failure/Rollback
- Costing/V_new
- FX
- Accounting Period
- Audit
- Architectural Non-Expansion

Qualification:
B1-C01 remains unresolved and requires human decision.

Important:
An ambiguity is not automatically a conflict.

Status:
PROVISIONALLY CONSISTENT / HUMAN DECISION REQUIRED FOR B1-C01

---

## 13. EVIDENCE GAPS

### Critical / DD-dependent
- Canonical DDL availability for independent structural verification in Gemini environment.

### Open historical identity gaps
- Original Frozen B1 source identity.
- Original Frozen B2 source identity.

### Runtime gaps
- FSM implementation runtime proof.
- Command Boundary implementation runtime proof.
- FX runtime semantics proof.
- D7 audit/causal runtime proof.

D7 remains OPEN and unchanged.

---

## 14. D7 BOUNDARY

D7 status:
OPEN / NOT INDEPENDENTLY PROVEN AT RUNTIME.

This register does not reopen D7.

The appearance of Request Identity, Attempt Identity, Command Boundary, Audit, or causal-chain requirements in B1/B2 reconstruction does not constitute new D7 runtime evidence.

No D7 status change is authorized by this document.

---

## 15. ARCHITECTURAL IMPACT

Recovered policy:
NO ARCHITECTURAL EXPANSION AUTHORIZED.

Actual implementation/schema impact:
[E6] UNKNOWN until DD-dependent structural verification is available.

No:
- new entity
- new table
- new schema object
- new FSM
- new Command Boundary architecture
- new authorization architecture

may be introduced under this register.

---

## 16. THREE-DIMENSIONAL GATE STATUS

### Requirements Coverage
COMPLETE FOR RECOVERED CONTENT

### Structural Confidence
MIXED / OPEN

### Runtime Confidence
MIXED / OPEN

### Authorization
NOT AUTHORIZED

STEP-8:
NOT AUTHORIZED

Production Implementation:
NOT AUTHORIZED

---

## 17. HUMAN DECISIONS REQUIRED

### HD-01 — Canonical DDL Availability
Decision:
Provide accessible canonical DDL for DD-dependent verification OR explicitly keep DD-dependent verification blocked.

Important:
This is NOT permission to bypass structural verification.

DD-independent recovered requirements may continue to be normalized.

### HD-02 — B1-C01
Decision required on the exact scope of the Store_Manager Create+Post exception relative to Initiator != Poster.

No automatic inference permitted.

---

## 18. TERMINAL CONTROL PRINCIPLES

Reconstruct what evidence supports.

Preserve what evidence cannot prove.

Escalate what humans must decide.

Never manufacture certainty.

Never stall progress on non-critical gaps.

Never grant authority without a human Gate.

Never convert recovered content into Frozen Source.

Never convert runtime observation into historical Frozen Source without artifact identity.

Never convert architectural feasibility into architectural authorization.

END OF REGISTER
