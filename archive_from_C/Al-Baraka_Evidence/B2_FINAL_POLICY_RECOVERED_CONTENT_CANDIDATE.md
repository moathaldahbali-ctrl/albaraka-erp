# B2 FINAL POLICY — RECOVERED CONTENT CANDIDATE

## Evidence Status

- Policy area: B2 — Accounting Posting Policy Contract
- Content status: CLOSED CONTENT / RECOVERED CONSOLIDATION
- Final content closure: PROVEN under the evidence-bounded consolidation gate
- Original historical Frozen Source: NOT RECOVERED
- Original historical Artifact ID: NOT PROVEN
- Original historical SHA-256: NOT PROVEN
- This file is a newly created recovered-content artifact and MUST NOT be represented as the original historical Frozen Source.
- Implementation / Step 8 authorization: NOT AUTHORIZED.

## A. Accounting Applicability Matrix

Legend:
- Accounting Effect: whether the root creates an accounting effect.
- Timing: authoritative posting point.
- Journal: whether a journal is required.
- Inventory Valuation: whether inventory valuation is affected.
- Cash/Settlement: whether settlement/cash effects may apply.
- AR/AP: whether receivable/payable effects may apply.
- Revenue/Expense: whether revenue/expense effects may apply.
- Tax: whether tax effects may apply.
- Costing: whether costing interaction may apply.
- FX: whether foreign-exchange handling may apply.

| Economic Root | Accounting Effect | Timing | Journal | Inventory Valuation | Cash/Settlement | AR/AP | Revenue/Expense | Tax | Costing | FX |
|---|---|---|---|---|---|---|---|---|---|---|
| sales | YES | Post | YES | YES | CONDITIONAL | YES | YES | YES | YES | YES |
| sale_returns | YES | Post | YES | YES | CONDITIONAL | YES | YES | YES | YES | YES |
| purchases | YES | Post | YES | YES | CONDITIONAL | YES | YES | YES | YES | YES |
| purchase_returns | YES | Post | YES | YES | CONDITIONAL | YES | YES | YES | YES | YES |
| inventory_adjustments | YES | Post | YES | YES | NO | NO | YES | NO | YES | NO |
| inventory_transfers | NO (same-entity) | Post | NO | YES | NO | NO | NO | NO | YES | NO |
| expenses | YES | Post | YES | NO | CONDITIONAL | YES | YES | YES | NO | YES |
| payments | YES | Post | YES | NO | YES | YES | CONDITIONAL (FX) | NO | NO | YES |
| payment_refunds | YES | Post | YES | NO | YES | YES | CONDITIONAL (FX) | NO | NO | YES |
| cash_transfers | YES | Post | YES | NO | YES | NO | NO | NO | NO | CONDITIONAL |
| cash_adjustments | YES | Post | YES | NO | YES | NO | YES | NO | NO | NO |
| credit_approvals | NO | N/A | NO | NO | NO | NO | NO | NO | NO | NO |

**Inventory-transfer interpretation:** the current business is strictly ONE accounting/economic entity. Branch/Warehouse does not constitute a separate accounting entity. Therefore a same-entity transfer has physical and inventory-valuation effects but no GL journal. Future inter-entity transfers are out of scope.

## B. Journal Contract

1. ONE authoritative economic event post produces exactly ONE logical `journal_entries` result.
2. A journal may contain multiple journal lines.
3. If inventory valuation changes, the same journal references the relevant immutable `cost_adjustment_events` identity (`V_new`) through `cost_adjustment_event_id`.
4. Economic-event idempotency prevents duplicate accounting results.
5. Journal rows cannot be orphaned.
6. Mandatory journal generation failure causes the whole Phase-2 transaction to fail and roll back; there is no partial business success.

## C. Debit / Credit Posting Rules

### Sales
- Debit Accounts Receivable or Cash, as applicable.
- Credit Revenue.
- Credit Tax Liability, if applicable.
- Debit COGS.
- Credit Inventory.

### Sale Returns
- Debit Revenue Contra.
- Debit Tax Liability.
- Credit Accounts Receivable or Cash.
- Debit Inventory.
- Credit COGS.

### Purchases
- Debit Inventory or Expense.
- Debit Input Tax, if applicable.
- Credit Accounts Payable or Cash.

### Purchase Returns
- Debit Accounts Payable or Cash.
- Credit Inventory or Expense.
- Credit Input Tax, if applicable.

### Expenses
- Debit Expense.
- Debit Input Tax, if applicable.
- Credit Accounts Payable or Cash.

### Payments
Inbound settlement:
- Debit Cash / Bank / Wallet.
- Credit Accounts Receivable.

Outbound settlement:
- Debit Accounts Payable.
- Credit Cash / Bank / Wallet.

### Payment Refunds
- Reverse the exact original settlement effect.
- Historical refunds do not recalculate a new FX rate.

### Inventory Adjustments
Shortage:
- Debit Inventory Loss Expense.
- Credit Inventory.

Surplus:
- Debit Inventory.
- Credit Inventory Gain Income.

### Inventory Transfers
For the current single accounting/economic entity:
- GL Journal = NONE.
- Source inventory quantity decreases.
- Destination inventory quantity increases.
- Total inventory quantity remains economically conserved.
- No revenue, expense, P&L, intercompany AR/AP, or intercompany GL is created.

Future inter-entity behavior is explicitly out of scope.

### Cash Transfers
- Debit destination Cash / Bank / Wallet.
- Credit source Cash / Bank / Wallet.

### Cash Adjustments
Shortage:
- Debit Cash Shortage Expense.
- Credit Cash.

Surplus:
- Debit Cash.
- Credit Cash Surplus Income.

### Credit Approvals
- No accounting effect.
- No journal.
- Approval is a governance/domain decision and does not itself create a financial posting.

## D. Deterministic Account Selection

Account-selection precedence is:

1. Explicit item/transaction-line mapping.
2. Category/group mapping.
3. Entity mapping.
4. Location mapping.
5. System default.

If a required account role cannot be resolved:
- FAIL CLOSED.
- Reject the posting.
- Roll back the transaction.
- Do not select an arbitrary suspense account.

## E. Currency / FX Policy

1. The system has a base currency and a transaction currency.
2. Authoritative journals are represented in base currency.
3. The exchange rate is locked at the exact authoritative economic posting event timestamp.
4. If the required exchange rate is missing, the command fails and rolls back.
5. Realized FX is applicable to settlements.
6. Unrealized FX / period-end revaluation is out of scope for the current roots.
7. Historical FX reversals/returns reverse the exact original base-currency amounts of the linked original journal; they do not perform a new FX calculation.

## F. Accounting Period Policy

1. The authoritative posting date resolves the applicable accounting period.
2. The period must be open.
3. Missing or hard-closed periods cause rejection and rollback.
4. A concurrent accounting-period close race causes the posting to fail rather than silently post into a closed period.

## G. Costing Interaction

1. One `cost_adjustment_events` row corresponds to one immutable costing transition.
2. That transition has one exact `V_new` identity.
3. `costing_runs` represents the mutable current state.
4. When inventory valuation changes, the journal references the exact `cost_adjustment_event_id`.
5. Economically material inventory valuation changes produce the required COGS / Inventory accounting lines.
6. Costing failure causes the complete Phase-2 business transaction to fail and roll back.

## H. Corrections / Reversals

1. Posted journals are immutable.
2. Sales are corrected through `sale_returns`.
3. Purchases are corrected through `purchase_returns`.
4. Payments are corrected through `payment_refunds`.
5. Cancellation is available only before posting where the FSM permits it.
6. A reversal preserves causal ancestry to the original economic event.

## I. Decimal / Rounding Contract

1. Calculation precision: `DECIMAL(28,8)`.
2. Stored monetary/quantity precision follows the established project contract:
   - `DECIMAL(19,4)` where applicable.
   - `DECIMAL(19,6)` where applicable.
3. Rounding mode: `HALF_EVEN`.
4. Journal debits and credits must balance exactly.
5. There is no residual tolerance.
6. There is no rounding account.
7. Any residual/unbalanced result causes FAIL → ROLLBACK.

## J. Idempotency / Concurrency

1. The Phase-2 Command Boundary is authoritative for all posting paths, including offline/sync replay.
2. The same Request Identity with the same materially relevant payload after successful commit returns the committed result.
3. The same Request Identity with a materially changed payload produces an identity/payload conflict.
4. A retry that constitutes a new attempt uses a new Attempt Identity and re-evaluates authorization and all applicable preconditions.
5. Concurrent duplicate posting is serialized so that only one authoritative business result is created; the competing retry receives the committed result where applicable.
6. No offline/sync path bypasses authorization, FSM, idempotency, concurrency, or DB invariants.

## K. Failure Semantics

For any mandatory precondition, authorization check, account resolution, FX resolution, period validation, costing operation, journal generation, audit requirement, or DB invariant failure:

**FAIL → ROLLBACK → NO PARTIAL BUSINESS SUCCESS**

There is no implicit emergency bypass, superuser bypass, offline bypass, or sync bypass.

## L. Audit / Traceability

The traceability chain is:

`Request Identity → Attempt Identity → Economic Event → Cost Adjustment Event / V_new → Journal Entry → Journal Lines`

The business transaction must fail and roll back if a mandatory audit write fails.

For critical audit-failure evidence governed by Governance #272, the critical failure evidence must durably survive outside the rolled-back business transaction boundary.

## M. Architectural Impact

This B2 policy does NOT authorize:
- any new entity;
- any new schema object beyond the already frozen architecture;
- any FSM change;
- any Phase-2 Command Boundary change;
- any B1 authorization-policy change;
- any Governance #234–#274 change.

It is a policy closure artifact only.

## N. Closure Tests

The recovered policy includes the following expected closure tests:

1. Valid sale → success with balanced journal.
2. Missing account mapping → FAIL / ROLLBACK.
3. Valid sale return → success.
4. Valid purchase → success.
5. Valid purchase return → success.
6. Inventory gain adjustment → success.
7. Inventory loss adjustment → success.
8. Same-entity inventory transfer → source quantity decreases, destination quantity increases, total inventory quantity conserved, no P&L, journal NONE.
9. Valid expense → success.
10. Valid payment → success.
11. Valid payment refund → success.
12. Valid cash transfer → success.
13. Valid cash adjustment → success.
14. Credit approval → no GL.
15. Missing FX rate → FAIL / ROLLBACK.
16. Historical FX reversal → exact original base-currency amounts.
17. Closed accounting period → FAIL / ROLLBACK.
18. Unbalanced journal → FAIL / ROLLBACK.
19. Duplicate Request Identity with same payload → committed result.
20. Same Request Identity with changed payload → conflict.
21. Concurrent duplicate posting → one authoritative success; competing attempt returns the committed result where applicable.
22. Costing → exact `V_new` linkage.
23. Correction/reversal → causal traceability preserved.
24. Rounding residual → FAIL / ROLLBACK.

## O. Blocker Closure Status

### Blocker 1 — Rounding
PROVEN:
- Exact mathematical balancing required.
- No residual tolerance.
- No rounding account.
- Residual causes failure and rollback.

### Blocker 2 — Unrealized FX
PROVEN:
- Unrealized FX is out of scope.
- No current root triggers period-end revaluation.

### Blocker 3 — Audit vs Governance #272
PROVEN in the recovered conversational closure content:
- Business transaction fails/rolls back on mandatory audit failure.
- Critical audit-failure evidence must survive outside the rolled-back business transaction boundary under Governance #272.

### Blocker 4 — Economic Event / Journal / Cost Adjustment
PROVEN:
- One authoritative economic event produces one journal result.
- Where valuation changes, one immutable costing transition identifies the exact `V_new`.
- The journal references the economic event and, where applicable, `cost_adjustment_event_id`.

### Blocker 5 — Historical FX Returns
PROVEN:
- Historical returns/reversals use the exact original base-currency amounts.
- No new FX calculation is performed.

### Blocker 6 — Inventory Transfers
PROVEN:
- Current business has one accounting/economic entity.
- Same-entity transfer has physical/inventory-valuation effects only.
- No GL journal is generated.
- Future inter-entity accounting is out of scope.

## P. Evidence / Source Classification

The accessible evidence supports the following classification:

- Original Conditional B2 Gate: PROVEN from accessible project content.
- Final B2 Policy Content: PROVEN as conversational closure content.
- Blockers 1–6: PROVEN in the accessible closure content.
- B2 Content Closure: PROVEN under the evidence-bounded consolidation rule.
- Original Historical Frozen Source: NOT RECOVERED.
- Original historical Artifact ID: NOT PROVEN.
- Original historical SHA-256: NOT PROVEN.
- This artifact: RECOVERED CONTENT CANDIDATE, newly generated from the recovered content.

## Q. Cross-Gate Verification Status

The following limitations remain explicit:

- Full 55-entity DDL verification: NOT POSSIBLE from the accessible B2 source alone.
- D1 full verification: NOT POSSIBLE where the complete D1 source is unavailable.
- B3 full verification: NOT POSSIBLE where only summaries/partial accessible text are available.
- A1/A2/A5, FSM, Phase-2 Command Boundary, Phase-2 Idempotency, and V_new identity were reported as verified from accessible project content, but this artifact does not replace their respective source artifacts.

Therefore:

**B2 CONTENT CLOSURE IS PROVEN.**

**GLOBAL IMPLEMENTATION AUTHORIZATION IS NOT GRANTED.**

## R. Controlled-Artifact Rule

This file must be cited as:

`B2_FINAL_POLICY_RECOVERED_CONTENT_CANDIDATE.md`

It MUST NOT be renamed or represented as:
- the original B2 Frozen Source;
- the original historical artifact;
- proof of the original historical SHA-256.

A future original Frozen Source, if recovered, supersedes this candidate for historical identity purposes.

## S. Final B2 State

**B2 STATUS: CLOSED — CONTENT PROVEN**

**B2 ORIGINAL FROZEN SOURCE: NOT RECOVERED**

**B2 IMPLEMENTATION / STEP 8: NOT AUTHORIZED**

**GLOBAL PROJECT AUTHORIZATION: NOT ESTABLISHED BY THIS ARTIFACT**
