═══════════════════════════════════════════════════════════════
PASS-3 — TIER 2 — CONSTRAINT STRUCTURE
Source: Gemini under PASS-3 Directive v1.1
Date: 2026-09-24
═══════════════════════════════════════════════════════════════

[

TIER 2 — CONSTRAINT STRUCTURE

6.5 UNIQUE Constraints

Finding: The DDL contains multiple explicit UNIQUE constraints, functioning as inline column constraints, table-level composite declarations (especially for association tables), and one explicit unique index. Evidence Class: [E1-E2] Observed

Inline UNIQUE Constraints (Single Column):

chart_of_accounts: account_code

currencies: code

branches: code

roles: name

permissions: slug

categories: slug

customers: code

suppliers: code

idempotency_records: idempotency_key

client_applications: client_key

users: username, email (2 separate unique constraints)

warehouses: code

products: sku

pos_devices: device_uuid

cash_registers: code

device_tokens: token_hash

product_barcodes: barcode

Root Transaction Tables (All 12 root tables share the same inline unique constraint on the FK mapping to the central registry): purchases, inventory_adjustments, inventory_transfers, expenses, payments, credit_approvals, purchase_returns, payment_refunds, sales, cash_transfers, cash_adjustments, sale_returns ➔ UNIQUE (client_transaction_id)

Composite UNIQUE Constraints (Table-Level):

role_permissions: UNIQUE (role_id, permission_id)

branch_customers: UNIQUE (branch_id, customer_id)

user_roles: UNIQUE (user_id, role_id, branch_id)

product_units: UNIQUE (product_id, unit_code)

branch_products: UNIQUE (branch_id, product_id)

stock_balances: UNIQUE (warehouse_id, product_id)

costing_runs: UNIQUE (warehouse_id, product_id)

cost_adjustment_events: UNIQUE (economic_cause_id, calculation_version_id, transition_hash)

Unique Indexes:

register_sessions: CREATE UNIQUE INDEX idx_single_open_session ON register_sessions (cash_register_id) WHERE status = 'OPEN';

Missing UNIQUE Constraints (Not Established): Finding: As strictly reviewed per request, line-item tables and ledger entries inherently lack explicit uniqueness on their business keys within this DDL to allow multiple identical lines per document/transaction. Evidence Class: [E6] Not Established

stock_ledger

inventory_transfer_lines

purchase_lines

sale_lines

journal_lines

inventory_adjustment_lines

purchase_return_lines

sale_return_lines

6.6 NOT NULL — Two-Level Reporting (Level A)

Finding: NOT NULL constraints are explicitly defined across the schema. Counts below strictly represent columns with explicitly declared NOT NULL constraints (excluding the inherently NOT NULL primary key id columns). Evidence Class: [E1-E2] Observed

TableNOT NULL columnsTableNOT NULL columnschart_of_accounts3costing_runs5currencies3purchases6branches2inventory_adjustments5roles1inventory_transfers5permissions1expenses6categories2payments5customers3credit_approvals4suppliers2register_sessions5economic_event_registry2device_tokens2idempotency_records2sync_conflicts2client_applications2product_barcodes3accounting_periods4purchase_lines6users4purchase_returns6role_permissions2payment_refunds5warehouses3inventory_adjustment_lines3products4inventory_transfer_lines3customer_contacts1cost_adjustment_events5branch_customers2sales6credit_requests3cash_transfers6audit_logs4cash_adjustments5user_roles3cash_movements3pos_devices3purchase_return_lines4cash_registers3journal_entries5product_units3sale_lines6branch_products3sale_returns6stock_ledger4journal_lines4stock_balances3sale_return_lines4inventory_alerts3 

(Note: economic_event_registry has PK client_transaction_id, so its NOT NULL count is 2: event_type and created_at)

6.7 CHECK Constraints

Finding: Explicit CHECK constraints (and one EXCLUDE constraint utilizing the btree_gist extension) are present in the DDL. Evidence Class: [E1-E2] Observed

TableConstraint NameExpressionaccounting_periodschk_end_after_startCHECK (end_date >= start_date)accounting_periodsexclude_overlapping_periodsEXCLUDE USING gist (branch_id WITH =, daterange(start_date, end_date + integer '1', '[)') WITH &&)paymentschk_payment_mutualityCHECK ((customer_id IS NOT NULL AND supplier_id IS NULL) OR (customer_id IS NULL AND supplier_id IS NOT NULL)) 

TIER 2 STATUS: PASS

PASS-3 — TIER 2 OUTPUT COMPLETE.

]

انتهى محتوى TIER 2.

