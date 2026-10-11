# B1 FINAL BUSINESS AUTHORIZATION POLICY
## RECOVERED CONTENT CANDIDATE — EVIDENCE-BOUNDED

STATUS:
- B1 FINAL CONTENT STATUS: PROVEN
- SOURCE CLASSIFICATION: LEVEL 2 — FINAL CONTENT PROVEN — ORIGINAL FROZEN SOURCE NOT PROVEN
- ORIGINAL HISTORICAL FROZEN SOURCE: NOT RECOVERED / NOT PROVEN
- ORIGINAL FROZEN ARTIFACT IDENTITY / SHA-256: NOT PROVEN
- B1 CONTENT CLOSURE: NOT PROVEN
- CROSS-GATE VERIFICATION: NOT POSSIBLE FROM ACCESSIBLE B1 EVIDENCE
- IMPLEMENTATION / STEP 8 AUTHORIZATION: NOT AUTHORIZED

IMPORTANT:
This artifact preserves only B1 business-authorization content directly supported by the
accessible final B1 evidence. It does not convert unavailable Cross-Gate references into
proven facts and must not be treated as the original historical Frozen Source.

---

## 1. ACTOR ROLES

The proven B1 policy identifies the following roles:

- Cashier
- Inventory_Clerk
- Accountant
- Store_Manager
- General_Manager

---

## 2. DEFAULT-DENY AUTHORIZATION MODEL

Authorization exists only when the request is explicitly matched to:

Role + Permission + Root + Command + Scope + applicable conditions.

Anything not explicitly defined is DENY.

The policy provides no:
- Implicit privilege
- Emergency bypass
- Superuser bypass
- Offline bypass
- Sync bypass

---

## 3. AUTHORIZATION MATRIX

Scope: GLOBAL

### sales
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Posters: Cashier, Store_Manager
- SoD: No mandatory Initiator ≠ Poster requirement

### sale_returns
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: N/A
- Authorized Posters: Cashier, Store_Manager
- SoD: No mandatory Initiator ≠ Poster requirement

### purchases
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Poster: Store_Manager
- SoD: Initiator ≠ Poster required

### purchase_returns
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: N/A
- Authorized Poster: Store_Manager
- SoD: Initiator ≠ Poster required

### inventory_adjustments
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Poster: Store_Manager
- SoD: Initiator ≠ Poster required

### inventory_transfers
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Poster: Store_Manager
- SoD: Initiator ≠ Poster required

### expenses
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Posters: Accountant, Store_Manager
- SoD: Initiator ≠ Poster required

### payments
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Poster: Accountant
- SoD: Initiator ≠ Poster required

### payment_refunds
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: N/A
- Authorized Poster: Accountant
- SoD: Initiator ≠ Poster required

### cash_transfers
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Posters: Accountant, Store_Manager
- SoD: Initiator ≠ Poster required

### cash_adjustments
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Poster: Accountant
- SoD: Initiator ≠ Poster required

### credit_approvals
- Create: ALLOW
- Edit: ALLOW
- Post: ALLOW
- Cancel: ALLOW
- Authorized Posters: Accountant, General_Manager
- SoD: Initiator ≠ Poster required

---

## 4. SEPARATION OF DUTIES

Transactional SoD requires:

Initiator ≠ Poster

for:
- purchases
- inventory_adjustments
- payments
- credit_approvals

No mandatory Initiator ≠ Poster requirement is specified for:
- sales
- sale_returns

The proven B1 policy also specifies an explicit managerial exception:

Store_Manager may Create + Post the same high-risk transaction, subject to audit.

---

## 5. AMOUNT THRESHOLDS AND SCOPE

- Amount Thresholds: NONE
- Scope: GLOBAL

---

## 6. OFFLINE / SYNC AUTHORIZATION

Offline execution does not create superior authority.

At the authoritative boundary, the following are re-applied:
- Actor Identity
- Authorization
- FSM
- Scope
- SoD
- Idempotency
- Concurrency
- DB invariants

If authorization or another required condition fails during synchronization:
- FAIL / DENY
- No conversion into a different economic operation
- No bypass of the authoritative authorization boundary

---

## 7. AUTHORIZATION EVALUATION AND FAILURE SEMANTICS

Authorization is evaluated at execution against the authoritative boundary.

Failure semantics:

DENY
→ NO BUSINESS MUTATION
→ ROLLBACK WHERE TRANSACTION EXISTS
→ DETERMINISTIC FAILURE

A denied authorization must not produce partial business success.

---

## 8. RETRY / RESUBMIT BEHAVIOR

The proven B1 content specifies:

### Case A — Retry of the same logical request
- Same Request Identity
- New Attempt Identity
- Authorization is re-evaluated

### Case B — Duplicate after successful commit
- RETURN COMMITTED RESULT

### Case C — Materially changed payload
- IDENTITY/PAYLOAD CONFLICT
- A new Request Identity is required

### Case D — Edit existing Draft
- Editing the Draft is a separate operation
- Post authorization is evaluated at execution
- Resubmission does not bypass authorization

---

## 9. GOVERNANCE AUTHORIZATION BOUNDARY

The B1 evidence defines the following governance authorization policy:

### Store_Manager
- Submit: ALLOW
- Approve: DENY
- Activate: DENY
- Revoke: DENY

### Accountant
- Submit: ALLOW
- Approve: DENY
- Activate: DENY
- Revoke: DENY

### General_Manager
- Submit: ALLOW
- Approve: ALLOW
- Activate: ALLOW
- Revoke: ALLOW

The General_Manager governance permissions remain subject to the applicable:
- SoD
- Quorum
- Expiry
- Materiality
- Atomicity
- Revocation

conditions specified by the B1 policy.

---

## 10. VERIFIED B1 CONSISTENCY TESTS

The accessible B1 evidence reports the following results:

1. Cashier creates Sales Draft and Posts → ALLOW
2. Cashier Posts Payments → DENY
3. Inventory_Clerk creates Inventory Adjustment then Posts → DENY
4. Store_Manager creates and Posts Inventory Adjustment → ALLOW
5. User Cancels Posted Transaction → DENY
6. User Cancels Sale Return Draft → N/A
7. Unauthorized Governance Activate → DENY
8. General_Manager Approves after Submit of same object → DENY
9. Same Request Identity retry after successful Commit → RETURN COMMITTED RESULT
10. Same Request Identity with materially changed payload → IDENTITY/PAYLOAD CONFLICT
11. Offline command reaches authoritative boundary after authorization was revoked → DENY
12. Authorization policy missing for Command/Root → DEFAULT DENY

---

## 11. ARCHITECTURAL NON-EXPANSION RULE

The B1 policy does not authorize adding or changing:
- a new business entity
- a new schema requirement
- a new role entity
- a new FSM transition
- a new Phase-2 command-boundary rule
- a new economic root

Any such architectural change requires its own authorized gate and evidence.

---

## 12. EVIDENCE LIMITATIONS

The following were NOT accessible for independent Cross-Gate verification in the B1 evidence used
to recover this content:

- Original canonical Stage-1 source
- A1
- A2
- A5
- D1
- FSM source
- Phase-2 Command Boundary source
- Phase-2 Idempotency source
- B2
- B3
- Governance closure references

Therefore this artifact does NOT claim that those external references were independently
verified during this recovery operation.

This artifact is a recovered CONTENT CANDIDATE, not the original Frozen Source.

---

## 13. FINAL B1 STATUS

B1 FINAL CONTENT STATUS:
PROVEN

SOURCE CLASSIFICATION:
LEVEL 2 — FINAL CONTENT PROVEN — ORIGINAL FROZEN SOURCE NOT PROVEN

ORIGINAL FROZEN SOURCE:
NOT RECOVERED

ORIGINAL FROZEN ARTIFACT IDENTITY:
NOT PROVEN

B1 CONTENT CLOSURE:
NOT PROVEN

IMPLEMENTATION / STEP 8:
NOT AUTHORIZED

---

END OF EVIDENCE-BOUNDED B1 RECOVERED CONTENT CANDIDATE
