# B1 × B2 REQUIREMENTS RECONSTRUCTION REGISTER

## 0. DOCUMENT CONTROL

- Artifact: `B1_B2_REQUIREMENTS_RECONSTRUCTION_REGISTER.md`
- Purpose: Evidence-bounded reconstruction and consistency mapping of B1 and B2 requirements.
- Nature: Analytical requirements register only.
- No DDL/schema/model/controller/migration change is authorized by this artifact.
- No FSM change is authorized by this artifact.
- No Phase-2 Command Boundary change is authorized by this artifact.
- No authorization-policy change is authorized by this artifact.
- No Governance #234–#274 change is authorized by this artifact.
- STEP-8 execution: NOT AUTHORIZED.
- Implementation authorization: NOT GRANTED.

## 1. SOURCE CLASSIFICATION

### B1
- Source artifact:
  `B1_FINAL_POLICY_RECOVERED_CONTENT_CANDIDATE.md`
- Content status: PROVEN
- Source classification:
  LEVEL 2 — FINAL CONTENT PROVEN — ORIGINAL FROZEN SOURCE NOT PROVEN
- Original historical Frozen Source: NOT RECOVERED
- Original historical artifact identity/SHA-256: NOT PROVEN
- B1 content closure: NOT PROVEN

### B2
- Source artifact:
  `B2_FINAL_POLICY_RECOVERED_CONTENT_CANDIDATE.md`
- Content status: CLOSED CONTENT / RECOVERED CONSOLIDATION
- Final content closure: PROVEN under evidence-bounded consolidation
- Original historical Frozen Source: NOT RECOVERED
- Original historical artifact identity/SHA-256: NOT PROVEN
- B2 content closure: PROVEN as recovered content closure

## 2. EVIDENCE LEVELS

The following distinctions are mandatory:

1. PROVEN CONTENT
   - The requirement is supported by the accessible recovered B1/B2 content.

2. PROVEN ORIGINAL SOURCE
   - The original historical Frozen Source and its identity are independently established.
   - This is NOT established for B1 or B2.

3. INDEPENDENT RUNTIME PROOF
   - The requirement has independent runtime evidence proving execution behavior.
   - The closure-test claims contained inside B1/B2 candidates are not automatically independent runtime proof.

No level may be substituted for another.

## 3. B1 REQUIREMENTS REGISTER

### B1-R01 — Actor Roles
Roles identified:
- Cashier
- Inventory_Clerk
- Accountant
- Store_Manager
- General_Manager

Status: PROVEN CONTENT
Original Frozen Source: NOT PROVEN
Independent Runtime Proof: NOT ESTABLISHED

### B1-R02 — Default Deny
Authorization exists only when explicitly matched.
Anything not explicitly defined is DENY.

Status: PROVEN CONTENT

### B1-R03 — Authorization Tuple
Authorization requires:
Role + Permission + Root + Command + Scope + applicable conditions.

Status: PROVEN CONTENT

### B1-R04 — No Bypass
No implicit, emergency, superuser, offline, or sync bypass.

Status: PROVEN CONTENT

### B1-R05 — Root Authorization Matrix
Authorization is explicitly defined for the 12 current economic roots.

Status: PROVEN CONTENT

### B1-R06 — Transactional SoD
Initiator ≠ Poster is required for:
- purchases
- inventory_adjustments
- payments
- credit_approvals

Status: PROVEN CONTENT

### B1-R07 — No Mandatory SoD for Sales
No mandatory Initiator ≠ Poster requirement is specified for:
- sales
- sale_returns

Status: PROVEN CONTENT

### B1-R08 — Amount Thresholds
Amount thresholds: NONE.

Status: PROVEN CONTENT

### B1-R09 — Scope
Authorization scope: GLOBAL.

Status: PROVEN CONTENT

### B1-R10 — Offline Authority
Offline execution creates no superior authority.

Status: PROVEN CONTENT

### B1-R11 — Authoritative Boundary Re-evaluation
At the authoritative boundary re-apply:
- Actor Identity
- Authorization
- FSM
- Scope
- SoD
- Idempotency
- Concurrency
- DB invariants

Status: PROVEN CONTENT

### B1-R12 — Authorization Failure
Authorization failure:
DENY → NO BUSINESS MUTATION → ROLLBACK WHERE TRANSACTION EXISTS → DETERMINISTIC FAILURE.

Status: PROVEN CONTENT

### B1-R13 — No Partial Business Success
Denied authorization must not produce partial business success.

Status: PROVEN CONTENT

### B1-R14 — Retry Identity
Same logical Request Identity may use a new Attempt Identity on retry, with authorization re-evaluated.

Status: PROVEN CONTENT

### B1-R15 — Duplicate After Commit
Same Request Identity after successful commit returns the committed result.

Status: PROVEN CONTENT

### B1-R16 — Changed Payload Conflict
Same Request Identity with materially changed payload produces Identity/Payload Conflict and requires a new Request Identity.

Status: PROVEN CONTENT

### B1-R17 — Draft Edit
Editing an existing Draft is a separate operation and Post authorization is evaluated at execution.

Status: PROVEN CONTENT

### B1-R18 — Governance Authorization
Store_Manager and Accountant may Submit but may not Approve/Activate/Revoke.
General_Manager may Submit/Approve/Activate/Revoke subject to applicable governance conditions.

Status: PROVEN CONTENT

### B1-R19 — Missing Authorization Policy
Missing Command/Root authorization defaults to DENY.

Status: PROVEN CONTENT

### B1-R20 — Revoked Authorization During Sync
Offline command reaching authoritative boundary after authorization revocation is DENIED.

Status: PROVEN CONTENT

### B1-R21 — Architectural Non-Expansion
B1 does not authorize new entities, schema requirements, roles, FSM transitions, command-boundary rules, or economic roots.

Status: PROVEN CONTENT

## 4. B2 REQUIREMENTS REGISTER

### B2-R01 — Accounting Applicability
Each current economic root has defined accounting applicability.

Status: PROVEN CONTENT

### B2-R02 — One Economic Event → One Journal Result
One authoritative economic event post produces one logical journal_entries result.

Status: PROVEN CONTENT

### B2-R03 — Journal Lines
A journal may contain multiple journal lines.

Status: PROVEN CONTENT

### B2-R04 — Cost Adjustment Linkage
Where inventory valuation changes, the journal references the relevant immutable cost_adjustment_event identity / V_new.

Status: PROVEN CONTENT

### B2-R05 — No Orphan Journals
Journal rows cannot be orphaned.

Status: PROVEN CONTENT

### B2-R06 — Journal Failure Atomicity
Mandatory journal generation failure causes complete transaction failure and rollback.

Status: PROVEN CONTENT

### B2-R07 — Deterministic Account Selection
Account selection precedence:
1. Explicit item/transaction-line mapping
2. Category/group mapping
3. Entity mapping
4. Location mapping
5. System default

Status: PROVEN CONTENT

### B2-R08 — Account Resolution Fail-Closed
Unresolved required account causes rejection and rollback; arbitrary suspense account selection is prohibited.

Status: PROVEN CONTENT

### B2-R09 — Root Posting Rules
Sales, sale_returns, purchases, purchase_returns, expenses, payments, payment_refunds, inventory_adjustments, inventory_transfers, cash_transfers, cash_adjustments, and credit_approvals have defined posting behavior.

Status: PROVEN CONTENT

### B2-R10 — Same-Entity Transfer
Current branch/warehouse structure represents one accounting/economic entity.
Same-entity inventory transfer has no GL journal.

Status: PROVEN CONTENT

### B2-R11 — Credit Approval
Credit approval creates no accounting effect and no journal.

Status: PROVEN CONTENT

### B2-R12 — Base Currency
Authoritative journals are represented in base currency.

Status: PROVEN CONTENT

### B2-R13 — FX Lock
Exchange rate is locked at the exact authoritative economic posting timestamp.

Status: PROVEN CONTENT

### B2-R14 — Missing FX
Missing required FX rate causes failure and rollback.

Status: PROVEN CONTENT

### B2-R15 — Realized FX
Realized FX applies to settlements.

Status: PROVEN CONTENT

### B2-R16 — Unrealized FX Out of Scope
Unrealized FX / period-end revaluation is out of scope for current roots.

Status: PROVEN CONTENT

### B2-R17 — Historical FX Reversal
Historical reversal/return uses exact original base-currency amounts and does not calculate a new FX rate.

Status: PROVEN CONTENT

### B2-R18 — Accounting Period
Posting date resolves an accounting period and the period must be open.

Status: PROVEN CONTENT

### B2-R19 — Period Close Race
Concurrent accounting-period close race causes posting failure rather than posting into a closed period.

Status: PROVEN CONTENT

### B2-R20 — Costing Identity
One cost_adjustment_events row represents one immutable costing transition with one exact V_new identity.

Status: PROVEN CONTENT

### B2-R21 — Costing Current State
costing_runs represents mutable current costing state.

Status: PROVEN CONTENT

### B2-R22 — Costing Failure Atomicity
Costing failure causes complete business transaction failure and rollback.

Status: PROVEN CONTENT

### B2-R23 — Posted Journal Immutability
Posted journals are immutable.

Status: PROVEN CONTENT

### B2-R24 — Dedicated Corrections
Corrections use:
- sale_returns for sales
- purchase_returns for purchases
- payment_refunds for payments

Status: PROVEN CONTENT

### B2-R25 — Causal Reversal
Reversal preserves causal ancestry to the original economic event.

Status: PROVEN CONTENT

### B2-R26 — Decimal Contract
Calculation precision: DECIMAL(28,8).
Stored precision follows established DECIMAL(19,4)/(19,6) contract where applicable.

Status: PROVEN CONTENT

### B2-R27 — HALF_EVEN
Rounding mode: HALF_EVEN.

Status: PROVEN CONTENT

### B2-R28 — Exact Journal Balance
Debits and credits must balance exactly.

Status: PROVEN CONTENT

### B2-R29 — No Residual Tolerance
No residual tolerance and no rounding account.

Status: PROVEN CONTENT

### B2-R30 — Residual Failure
Residual/unbalanced result causes FAIL → ROLLBACK.

Status: PROVEN CONTENT

### B2-R31 — Authoritative Command Boundary
All posting paths, including offline/sync replay, use the authoritative Phase-2 Command Boundary.

Status: PROVEN CONTENT

### B2-R32 — Idempotent Replay
Same Request Identity + same materially relevant payload after successful commit returns committed result.

Status: PROVEN CONTENT

### B2-R33 — Payload Conflict
Same Request Identity + materially changed payload produces identity/payload conflict.

Status: PROVEN CONTENT

### B2-R34 — New Attempt
New attempt uses new Attempt Identity and re-evaluates authorization and applicable preconditions.

Status: PROVEN CONTENT

### B2-R35 — Concurrent Duplicate Serialization
Concurrent duplicate posting is serialized so only one authoritative business result is created.

Status: PROVEN CONTENT

### B2-R36 — No Offline/Sync Bypass
Offline/sync cannot bypass authorization, FSM, idempotency, concurrency, or DB invariants.

Status: PROVEN CONTENT

### B2-R37 — Universal Failure Contract
Mandatory failure of precondition, authorization, account resolution, FX, period, costing, journal, audit, or DB invariant causes:
FAIL → ROLLBACK → NO PARTIAL BUSINESS SUCCESS.

Status: PROVEN CONTENT

### B2-R38 — Audit Traceability
Required chain:
Request Identity → Attempt Identity → Economic Event → Cost Adjustment Event / V_new → Journal Entry → Journal Lines

Status: PROVEN CONTENT

### B2-R39 — Mandatory Audit Failure
Mandatory audit-write failure causes business transaction failure and rollback.

Status: PROVEN CONTENT

### B2-R40 — Governance #272 Durable Evidence
Critical audit-failure evidence under Governance #272 must survive outside the rolled-back business transaction boundary.

Status: PROVEN CONTENT AS RECOVERED POLICY CONTENT
Independent runtime proof: NOT ESTABLISHED

### B2-R41 — Architectural Non-Expansion
B2 does not authorize new entities, schema objects, FSM changes, Command Boundary changes, B1 authorization changes, or Governance #234–#274 changes.

Status: PROVEN CONTENT

## 5. B1 × B2 CONSISTENCY MATRIX

### C01 — Authorization vs Accounting
B1 determines who may execute a root/command.
B2 determines the accounting effect after authorized posting.

Result: CONSISTENT

### C02 — SoD vs Accounting
B1 SoD is an authorization precondition.
B2 does not bypass SoD.

Result: CONSISTENT

### C03 — Sales
B1 permits specified posters.
B2 defines sales accounting.

Result: CONSISTENT

### C04 — Purchases
B1 permits Store_Manager with SoD.
B2 defines purchase accounting.

Result: CONSISTENT

### C05 — Inventory Adjustments
B1 permits Store_Manager subject to SoD.
B2 defines gain/loss accounting and costing interaction.

Result: CONSISTENT

### C06 — Inventory Transfers
B1 controls authorization.
B2 defines same-entity transfer as physical/inventory effect with no GL journal.

Result: CONSISTENT

### C07 — Credit Approvals
B1 controls authorization.
B2 defines credit approval as non-accounting governance/domain decision.

Result: CONSISTENT

### C08 — Offline/Sync
B1 denies superior offline authority.
B2 requires the same authoritative Command Boundary.

Result: CONSISTENT

### C09 — Idempotency
B1 and B2 define compatible Request Identity, Attempt Identity, replay, conflict, and concurrency semantics.

Result: CONSISTENT

### C10 — Failure Atomicity
B1 authorization failure and B2 accounting failure both prohibit partial business success.

Result: CONSISTENT

### C11 — Costing / V_new
B2 specifies costing identity and journal linkage.
B1 contains no conflicting rule.

Result: CONSISTENT / DEPENDENCY PRESERVED

### C12 — FX
B2 specifies FX semantics.
B1 contains no conflicting rule.

Result: CONSISTENT / DEPENDENCY PRESERVED

### C13 — Accounting Period
B2 specifies open-period and close-race behavior.
B1 contains no conflicting rule.

Result: CONSISTENT

### C14 — Audit / Governance #272
B1 contains audit/governance conditions.
B2 requires rollback on mandatory audit failure and durable critical failure evidence under Governance #272.

Result: CONSISTENT / DEPENDENCY PRESERVED

### C15 — Architectural Boundary
B1 and B2 both prohibit unauthorized architectural expansion.

Result: CONSISTENT

## 6. B1-C01 — UNRESOLVED ISSUE

### Store_Manager Managerial SoD Exception Scope

B1 states:
- Transactional SoD requires Initiator ≠ Poster for purchases, inventory_adjustments, payments, and credit_approvals.
- It also states an explicit managerial exception allowing Store_Manager to Create + Post the same high-risk transaction, subject to audit.

The accessible evidence does not independently establish whether the managerial exception:
1. overrides Initiator ≠ Poster for some/all of the four high-risk roots; or
2. has a narrower scope.

No inference is permitted.

Status:
**UNRESOLVED / NOT PROVEN**

This is not classified as a proven conflict.

## 7. RUNTIME-PROOF BOUNDARY

The B1/B2 candidate documents contain reported consistency/closure tests.

Those reported tests are classified as:
- recovered policy claims/content;
- NOT independent runtime proof unless independently backed by runtime artifacts.

Known D7 runtime evidence remains separately classified.
This register does not reopen D7.

## 8. OVERALL RECONCILIATION RESULT

**B1 × B2 CONSISTENCY STATUS: CONDITIONAL**

Reason:
- No proven direct B1/B2 contradiction identified.
- One B1 issue remains unresolved:
  Store_Manager managerial SoD exception scope.
- Several B2 behaviors remain content-proven but not independently runtime-proven.
- Original historical Frozen Sources for B1 and B2 remain unrecovered.

## 9. AUTHORIZATION BOUNDARY

This register does NOT authorize:
- STEP-8 execution;
- implementation;
- production code;
- migrations;
- models;
- controllers;
- DDL changes;
- schema changes;
- FSM changes;
- Command Boundary changes;
- B1 policy changes;
- B2 policy changes;
- Governance #234–#274 changes.

## 10. NEXT AUTHORIZED ACTIVITY

After this register is integrity-checked, the next authorized activity is continued requirements reconstruction from the next blocked requirement area.

B1-C01 must remain explicitly marked:
**UNRESOLVED / NOT PROVEN**

until an authoritative source resolves its scope.

---
END OF B1 × B2 REQUIREMENTS RECONSTRUCTION REGISTER
