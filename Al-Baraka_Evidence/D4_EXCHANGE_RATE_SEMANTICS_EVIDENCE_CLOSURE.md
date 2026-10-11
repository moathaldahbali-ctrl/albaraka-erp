# D4 — EXCHANGE-RATE SEMANTICS EVIDENCE CLOSURE

## 1. Scope

This artifact records the evidence status of D4 — Exchange-Rate Semantics.

This is an evidence-closure artifact only.

It does NOT authorize:
- schema modification;
- addition of tables, columns, constraints, triggers, or functions;
- modification of B1/B2 policy;
- implementation;
- STEP-8 execution;
- replacement of any Frozen Source.

No architecture change is authorized by this artifact.

---

## 2. Evidence Sources Reviewed

The following evidence was reviewed:

1. `B2_FINAL_POLICY_RECOVERED_CONTENT_CANDIDATE.md`
2. `B2_INDEPENDENT_EVIDENCE_MAPPING_CLOSURE.md`
3. `B1_B2_FROZEN_SOURCE_RECOVERY_CLOSURE.md`
4. `D7_AUDIT_CAUSAL_TRACEABILITY_EVIDENCE_CLOSURE.md`
5. Runtime database `stage1_test`
6. Read-only database probes executed against `stage1_test`

The original historical Frozen Source for B2 remains NOT RECOVERED.

Recovered policy content is therefore not treated as proof of historical source identity.

---

## 3. Currency Storage Infrastructure

The runtime database `stage1_test` contains:

`public.currencies`

with the following columns:

- `id UUID NOT NULL`
- `code VARCHAR NOT NULL`
- `name VARCHAR NOT NULL`
- `exchange_rate NUMERIC(19,6) NOT NULL`

The database also contains:

- primary key on `currencies.id`;
- unique constraint on `currencies.code`;
- NOT NULL enforcement on `currencies.exchange_rate`.

Classification:

**CURRENCY / EXCHANGE-RATE STORAGE: PROVEN — STRUCTURAL**

This proves storage infrastructure only.

It does not prove transaction-level or posting-level FX semantics.

---

## 4. Decimal / Rounding Contract

Recovered B2 policy content specifies:

- calculation precision: DECIMAL(28,8);
- stored monetary precision: DECIMAL(19,4);
- exchange-rate precision: DECIMAL(19,6);
- division scale: 8;
- rounding mode: HALF_EVEN;
- no rounding account.

The evidence mapping artifact records these as recovered policy semantics and distinguishes them from independently proven runtime execution.

Classification:

**DECIMAL / ROUNDING CONTRACT: PROVEN AS DOCUMENTED POLICY**

Runtime execution of the complete FX calculation and rounding contract is NOT independently proven.

---

## 5. Transaction Currency Binding

The read-only database probe searched for all foreign keys referencing:

`public.currencies(id)`

Result:

**0 rows**

The probe also inspected the 12 Economic Root tables:

- `sales`
- `purchases`
- `sale_returns`
- `purchase_returns`
- `inventory_adjustments`
- `inventory_transfers`
- `expenses`
- `payments`
- `payment_refunds`
- `cash_transfers`
- `cash_adjustments`
- `credit_approvals`

The inspected Economic Roots did not expose a currency column in the returned structure.

Classification:

**TRANSACTION CURRENCY BINDING: NOT INDEPENDENTLY PROVEN**

This artifact does not infer that future application-layer behavior is impossible. It records only that the inspected Stage-1 runtime structure does not independently prove this binding.

---

## 6. Locked Exchange-Rate Snapshot

Recovered B2 policy content specifies that the exchange rate is locked at the exact authoritative economic posting event timestamp.

However, the inspected runtime structure provides only:

`currencies.exchange_rate NUMERIC(19,6)`

No independently verified posting-specific FX snapshot mechanism was found.

The read-only probe found:

- no FX-specific function by name;
- no FX-specific trigger by name/reference;
- no trigger on a currency-related table establishing FX locking;
- no foreign key from the Economic Roots to `currencies(id)`.

Classification:

**LOCKED / POSTING-SPECIFIC FX SNAPSHOT: NOT INDEPENDENTLY PROVEN**

---

## 7. Exact Authoritative FX Timestamp Binding

Recovered B2 policy content specifies an authoritative economic posting timestamp for FX locking.

The inspected runtime evidence does not independently establish a database-level or runtime mechanism that binds a specific exchange-rate value to that exact authoritative posting timestamp.

Classification:

**EXACT AUTHORITATIVE FX TIMESTAMP BINDING: NOT PROVEN**

---

## 8. Missing FX Rate → Failure / Rollback

Recovered B2 policy content specifies:

Missing required exchange rate → command fails and rolls back.

No independent runtime test proving this complete behavior was found in the available verification harness.

The existing harness covers D1 Economic Event Registry integrity and A5 device immutability, but does not establish the B2 missing-FX runtime failure path.

Classification:

**MISSING FX → FAIL / ROLLBACK: NOT RUNTIME PROVEN**

---

## 9. Historical FX Reversal / Return Semantics

Recovered B2 policy content specifies that historical FX reversals/returns use the exact original base-currency amounts and do not perform a new FX calculation.

The available runtime evidence does not independently prove this complete behavior.

Classification:

**HISTORICAL FX REVERSAL SEMANTICS: NOT RUNTIME PROVEN**

---

## 10. FX Function / Trigger Probe

Read-only runtime probe result:

### Functions

Search for non-system functions with names containing:
- exchange
- currency
- fx
- rate

Result:

**0 rows**

### Triggers

Search for triggers containing or referencing:
- exchange
- currency
- fx
- rate
- exchange_rate

Result:

**0 rows**

### Currency-related table triggers

Result:

**0 rows**

These results do not prove that application-layer FX behavior is impossible.

They prove only that no corresponding database function/trigger mechanism was identified by the read-only probes.

---

## 11. Currency Table Dependency Probe

The dependency probe found only:

`pg_toast` internal dependency for `public.currencies`.

No business-level dependent object was returned.

The internal PostgreSQL TOAST dependency is not treated as an FX business mechanism.

Classification:

**BUSINESS-LEVEL CURRENCY DEPENDENCY: NOT INDEPENDENTLY PROVEN**

---

## 12. Frozen B2 Source Status

The original historical Frozen Source for B2 has not been recovered.

The available B2 artifacts explicitly distinguish:

- recovered policy/content;
- evidence mapping;
- historical Frozen Source identity.

Recovered content must not be treated as a replacement for the missing historical Frozen Source.

Classification:

**ORIGINAL FROZEN B2 SOURCE: NOT RECOVERED**

---

## 13. Architecture Decision Boundary

The evidence collected here does NOT establish an architecture defect.

It establishes an evidence/runtime-enforcement gap.

No change is authorized to:

- `canonical_stage1_ddl_v2.sql`;
- the 55 canonical entities;
- any existing table;
- any column;
- any FK;
- any constraint;
- any trigger;
- any function;
- B1;
- B2;
- Governance #272;
- the Master Prompt.

No new entity or schema object may be introduced as a consequence of this artifact.

---

## 14. Final D4 Classification

**D4 — EXCHANGE-RATE SEMANTICS:**

**PARTIALLY PROVEN — FX STORAGE INFRASTRUCTURE PROVEN; TRANSACTION / POSTING FX SEMANTICS NOT INDEPENDENTLY PROVEN**

Subclassification:

- Currency storage: PROVEN — STRUCTURAL
- Exchange-rate storage: PROVEN — STRUCTURAL
- Decimal / rounding policy: PROVEN — DOCUMENTED
- Transaction currency binding: NOT PROVEN
- Locked FX snapshot: NOT PROVEN
- Exact posting-time FX binding: NOT PROVEN
- Missing FX → failure / rollback: NOT RUNTIME PROVEN
- Historical FX reversal semantics: NOT RUNTIME PROVEN
- FX-specific DB functions: NOT FOUND
- FX-specific DB triggers: NOT FOUND
- Business-level currency dependency: NOT INDEPENDENTLY PROVEN
- Original Frozen B2 Source: NOT RECOVERED

---

## 15. STEP-8 Decision Boundary

D4 does not authorize STEP-8 execution.

**STEP-8 EXECUTION AUTHORIZATION: NOT GRANTED**

**IMPLEMENTATION AUTHORIZATION: NOT ESTABLISHED**

D4 remains an open evidence item until the required independent evidence is available.

No partial execution is authorized.

---

## 16. Integrity / Change Constraint

This artifact records evidence status only.

It does not alter the canonical architecture.

Any future change to the architecture, B1, B2, or the Master Prompt requires its own explicit authorization and evidence gate.

