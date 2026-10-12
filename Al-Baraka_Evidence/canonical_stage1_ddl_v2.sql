A. CANONICAL ARTIFACT
-- ============================================================================
-- FOUNDATIONAL EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ============================================================================
-- LEVEL 0 ENTITIES
-- ============================================================================
CREATE TABLE chart_of_accounts (
id UUID PRIMARY KEY,
account_code VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL,
type VARCHAR NOT NULL
);

CREATE TABLE currencies (
id UUID PRIMARY KEY,
code VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL,
exchange_rate DECIMAL(19,6) NOT NULL
);

CREATE TABLE branches (
id UUID PRIMARY KEY,
code VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL
);

CREATE TABLE roles (
id UUID PRIMARY KEY,
name VARCHAR NOT NULL UNIQUE,
description VARCHAR
);

CREATE TABLE permissions (
id UUID PRIMARY KEY,
slug VARCHAR NOT NULL UNIQUE,
description VARCHAR
);

CREATE TABLE categories (
id UUID PRIMARY KEY,
slug VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL
);

CREATE TABLE customers (
id UUID PRIMARY KEY,
code VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL,
credit_limit DECIMAL(19,4) NOT NULL
);

CREATE TABLE suppliers (
id UUID PRIMARY KEY,
code VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL
);

CREATE TABLE economic_event_registry (
client_transaction_id UUID PRIMARY KEY,
event_type VARCHAR NOT NULL,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE idempotency_records (
id UUID PRIMARY KEY,
idempotency_key VARCHAR NOT NULL UNIQUE,
response_payload JSONB,
created_at TIMESTAMPTZ NOT NULL
);

-- ============================================================================
-- LEVEL 1 ENTITIES
-- ============================================================================
CREATE TABLE client_applications (
id UUID PRIMARY KEY,
client_key VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL,
branch_id UUID REFERENCES branches(id) ON DELETE RESTRICT
);

CREATE TABLE accounting_periods (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
start_date DATE NOT NULL,
end_date DATE NOT NULL,
status VARCHAR NOT NULL,
CONSTRAINT chk_end_after_start CHECK (end_date >= start_date),
CONSTRAINT exclude_overlapping_periods EXCLUDE USING gist (
branch_id WITH =,
daterange(start_date, end_date + integer '1', '[)') WITH &&
)
);

CREATE TABLE users (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
username VARCHAR NOT NULL UNIQUE,
email VARCHAR NOT NULL UNIQUE,
password_hash VARCHAR NOT NULL
);

CREATE TABLE role_permissions (
id UUID PRIMARY KEY,
role_id UUID NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE RESTRICT,
UNIQUE (role_id, permission_id)
);

CREATE TABLE warehouses (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
code VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL
);

CREATE TABLE products (
id UUID PRIMARY KEY,
category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
sku VARCHAR NOT NULL UNIQUE,
name VARCHAR NOT NULL,
standard_cost DECIMAL(19,6) NOT NULL
);

CREATE TABLE customer_contacts (
id UUID PRIMARY KEY,
customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
phone VARCHAR,
email VARCHAR
);

CREATE TABLE branch_customers (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
UNIQUE (branch_id, customer_id)
);

CREATE TABLE credit_requests (
id UUID PRIMARY KEY,
customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
requested_amount DECIMAL(19,4) NOT NULL
);

-- ============================================================================
-- LEVEL 2 ENTITIES
-- ============================================================================
CREATE TABLE audit_logs (
id UUID PRIMARY KEY,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
action VARCHAR NOT NULL,
occurred_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE user_roles (
id UUID PRIMARY KEY,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
role_id UUID NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
UNIQUE (user_id, role_id, branch_id)
);

CREATE TABLE pos_devices (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
device_uuid VARCHAR NOT NULL UNIQUE
);

CREATE TABLE cash_registers (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
code VARCHAR NOT NULL UNIQUE
);

CREATE TABLE product_units (
id UUID PRIMARY KEY,
product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
unit_code VARCHAR NOT NULL,
conversion_factor DECIMAL(19,6) NOT NULL,
UNIQUE (product_id, unit_code)
);

CREATE TABLE branch_products (
id UUID PRIMARY KEY,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
status VARCHAR NOT NULL,
UNIQUE (branch_id, product_id)
);

CREATE TABLE stock_ledger (
id UUID PRIMARY KEY,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
quantity DECIMAL(19,4) NOT NULL,
timestamp TIMESTAMPTZ NOT NULL
);

CREATE TABLE stock_balances (
id UUID PRIMARY KEY,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
quantity DECIMAL(19,4) NOT NULL,
UNIQUE (warehouse_id, product_id)
);

CREATE TABLE inventory_alerts (
id UUID PRIMARY KEY,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
threshold DECIMAL(19,4) NOT NULL
);

CREATE TABLE costing_runs (
id UUID PRIMARY KEY,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
input_revision TEXT NOT NULL,
effective_version BIGINT NOT NULL,
status VARCHAR NOT NULL,
UNIQUE (warehouse_id, product_id)
);

CREATE TABLE purchases (
id UUID PRIMARY KEY,
client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
occurred_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE inventory_adjustments (
id UUID PRIMARY KEY,
client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
occurred_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE inventory_transfers (
id UUID PRIMARY KEY,
client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,
source_warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
target_warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
occurred_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE expenses (
id UUID PRIMARY KEY,
client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
chart_of_accounts_id UUID NOT NULL REFERENCES chart_of_accounts(id) ON DELETE RESTRICT,
amount DECIMAL(19,4) NOT NULL,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
occurred_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE payments (
id UUID PRIMARY KEY,
client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,
branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,
customer_id UUID REFERENCES customers(id) ON DELETE RESTRICT,
supplier_id UUID REFERENCES suppliers(id) ON DELETE RESTRICT,
amount DECIMAL(19,4) NOT NULL,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
occurred_at TIMESTAMPTZ NOT NULL,
CONSTRAINT chk_payment_mutuality CHECK ((customer_id IS NOT NULL AND supplier_id IS NULL) OR (customer_id IS NULL AND supplier_id IS NOT NULL))
);

CREATE TABLE credit_approvals (
id UUID PRIMARY KEY,
client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,
credit_request_id UUID NOT NULL REFERENCES credit_requests(id) ON DELETE RESTRICT,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
occurred_at TIMESTAMPTZ NOT NULL
);

-- ============================================================================
-- LEVEL 3 ENTITIES
-- ============================================================================
CREATE TABLE register_sessions (
id UUID PRIMARY KEY,
cash_register_id UUID NOT NULL REFERENCES cash_registers(id) ON DELETE RESTRICT,
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
pos_device_id UUID NOT NULL REFERENCES pos_devices(id) ON DELETE RESTRICT,
status VARCHAR NOT NULL,
opened_at TIMESTAMPTZ NOT NULL,
closed_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_single_open_session ON register_sessions (cash_register_id) WHERE status = 'OPEN';

CREATE OR REPLACE FUNCTION enforce_a5_device_immutability() RETURNS TRIGGER AS $$
BEGIN
IF NEW.pos_device_id IS DISTINCT FROM OLD.pos_device_id THEN
RAISE EXCEPTION 'A5 Violation: pos_device_id attribution is historically immutable.';
END IF;
RETURN NEW;
END;

\[
 LANGUAGE plpgsql;  
  
CREATE TRIGGER trg_a5_device_immutability  
    BEFORE UPDATE ON register_sessions  
    FOR EACH ROW EXECUTE FUNCTION enforce_a5_device_immutability();  
  
CREATE TABLE device_tokens (  
    id UUID PRIMARY KEY,  
    pos_device_id UUID NOT NULL REFERENCES pos_devices(id) ON DELETE RESTRICT,  
    token_hash VARCHAR NOT NULL UNIQUE  
);  
  
CREATE TABLE sync_conflicts (  
    id UUID PRIMARY KEY,  
    pos_device_id UUID NOT NULL REFERENCES pos_devices(id) ON DELETE RESTRICT,  
    status VARCHAR NOT NULL  
);  
  
CREATE TABLE product_barcodes (  
    id UUID PRIMARY KEY,  
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,  
    product_unit_id UUID NOT NULL REFERENCES product_units(id) ON DELETE RESTRICT,  
    barcode VARCHAR NOT NULL UNIQUE  
);  
  
CREATE TABLE purchase_lines (  
    id UUID PRIMARY KEY,  
    purchase_id UUID NOT NULL REFERENCES purchases(id) ON DELETE RESTRICT,  
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,  
    product_unit_id UUID NOT NULL REFERENCES product_units(id) ON DELETE RESTRICT,  
    quantity DECIMAL(19,4) NOT NULL,  
    unit_cost DECIMAL(19,4) NOT NULL,  
    subtotal DECIMAL(19,4) NOT NULL  
);  
  
CREATE TABLE purchase_returns (  
    id UUID PRIMARY KEY,  
    client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,  
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,  
    original_purchase_id UUID NOT NULL REFERENCES purchases(id) ON DELETE RESTRICT,  
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,  
    occurred_at TIMESTAMPTZ NOT NULL  
);  
  
CREATE TABLE payment_refunds (  
    id UUID PRIMARY KEY,  
    client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,  
    amount DECIMAL(19,4) NOT NULL,  
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,  
    occurred_at TIMESTAMPTZ NOT NULL  
);  
  
CREATE TABLE inventory_adjustment_lines (  
    id UUID PRIMARY KEY,  
    inventory_adjustment_id UUID NOT NULL REFERENCES inventory_adjustments(id) ON DELETE RESTRICT,  
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,  
    quantity DECIMAL(19,4) NOT NULL  
);  
  
CREATE TABLE inventory_transfer_lines (  
    id UUID PRIMARY KEY,  
    inventory_transfer_id UUID NOT NULL REFERENCES inventory_transfers(id) ON DELETE RESTRICT,  
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,  
    quantity DECIMAL(19,4) NOT NULL  
);  
  
CREATE TABLE cost_adjustment_events (  
    id UUID PRIMARY KEY,   
    economic_cause_id UUID NOT NULL REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    costing_run_id UUID NOT NULL REFERENCES costing_runs(id) ON DELETE RESTRICT,  
    calculation_version_id UUID NOT NULL,  
    reverses_adjustment_id UUID REFERENCES cost_adjustment_events(id) ON DELETE RESTRICT,  
    transition_hash TEXT NOT NULL,  
    input_revision TEXT NOT NULL,  
    UNIQUE (economic_cause_id, calculation_version_id, transition_hash)  
);  
  
CREATE OR REPLACE FUNCTION trg_cost_adjustment_immutability() RETURNS TRIGGER AS $$  
BEGIN  
    RAISE EXCEPTION 'A3 Immutability Violation: cost_adjustment_events historical records cannot be updated.';  
END;  
$$ LANGUAGE plpgsql;  
  
CREATE TRIGGER enforce_cost_adjustment_immutability  
    BEFORE UPDATE ON cost_adjustment_events  
    FOR EACH ROW EXECUTE FUNCTION trg_cost_adjustment_immutability();  
  
-- ============================================================================  
-- LEVEL 4 ENTITIES  
-- ============================================================================  
CREATE TABLE sales (  
    id UUID PRIMARY KEY,  
    client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,  
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,  
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,  
    register_session_id UUID NOT NULL REFERENCES register_sessions(id) ON DELETE RESTRICT,  
    occurred_at TIMESTAMPTZ NOT NULL  
);  
  
CREATE TABLE cash_transfers (  
    id UUID PRIMARY KEY,  
    client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    source_register_id UUID NOT NULL REFERENCES cash_registers(id) ON DELETE RESTRICT,  
    target_register_id UUID NOT NULL REFERENCES cash_registers(id) ON DELETE RESTRICT,  
    amount DECIMAL(19,4) NOT NULL,  
    register_session_id UUID NOT NULL REFERENCES register_sessions(id) ON DELETE RESTRICT,  
    occurred_at TIMESTAMPTZ NOT NULL  
);  
  
CREATE TABLE cash_adjustments (  
    id UUID PRIMARY KEY,  
    client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    cash_register_id UUID NOT NULL REFERENCES cash_registers(id) ON DELETE RESTRICT,  
    amount DECIMAL(19,4) NOT NULL,  
    register_session_id UUID NOT NULL REFERENCES register_sessions(id) ON DELETE RESTRICT,  
    occurred_at TIMESTAMPTZ NOT NULL  
);  
  
CREATE TABLE cash_movements (  
    id UUID PRIMARY KEY,  
    register_session_id UUID NOT NULL REFERENCES register_sessions(id) ON DELETE RESTRICT,  
    economic_event_registry UUID NOT NULL REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    amount DECIMAL(19,4) NOT NULL  
);  
  
CREATE TABLE purchase_return_lines (  
    id UUID PRIMARY KEY,  
    purchase_return_id UUID NOT NULL REFERENCES purchase_returns(id) ON DELETE RESTRICT,  
    purchase_line_id UUID NOT NULL REFERENCES purchase_lines(id) ON DELETE RESTRICT,  
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,  
    quantity DECIMAL(19,4) NOT NULL  
);  
  
CREATE SEQUENCE journal_number_seq NO MINVALUE NO MAXVALUE NO CYCLE;  
  
CREATE TABLE journal_entries (  
    id UUID PRIMARY KEY,  
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,  
    posting_period_id UUID NOT NULL REFERENCES accounting_periods(id) ON DELETE RESTRICT,  
    cost_adjustment_event_id UUID REFERENCES cost_adjustment_events(id) ON DELETE RESTRICT,  
    document_number VARCHAR NOT NULL,  
    journal_number BIGINT NOT NULL DEFAULT nextval('journal_number_seq'),  
    status VARCHAR NOT NULL  
);  
  
-- ============================================================================  
-- LEVEL 5 ENTITIES  
-- ============================================================================  
CREATE TABLE sale_lines (  
    id UUID PRIMARY KEY,  
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE RESTRICT,  
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,  
    product_unit_id UUID NOT NULL REFERENCES product_units(id) ON DELETE RESTRICT,  
    quantity DECIMAL(19,4) NOT NULL,  
    unit_price DECIMAL(19,4) NOT NULL,  
    subtotal DECIMAL(19,4) NOT NULL  
);  
  
CREATE TABLE sale_returns (  
    id UUID PRIMARY KEY,  
    client_transaction_id UUID NOT NULL UNIQUE REFERENCES economic_event_registry(client_transaction_id) ON DELETE RESTRICT,  
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE RESTRICT,  
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,  
    original_sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE RESTRICT,  
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,  
    occurred_at TIMESTAMPTZ NOT NULL  
);  
  
CREATE TABLE journal_lines (  
    id UUID PRIMARY KEY,  
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE RESTRICT,  
    chart_of_accounts_id UUID NOT NULL REFERENCES chart_of_accounts(id) ON DELETE RESTRICT,  
    debit DECIMAL(19,4) NOT NULL,  
    credit DECIMAL(19,4) NOT NULL  
);  
  
-- ============================================================================  
-- LEVEL 6 ENTITIES  
-- ============================================================================  
CREATE TABLE sale_return_lines (  
    id UUID PRIMARY KEY,  
    sale_return_id UUID NOT NULL REFERENCES sale_returns(id) ON DELETE RESTRICT,  
    sale_line_id UUID NOT NULL REFERENCES sale_lines(id) ON DELETE RESTRICT,  
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,  
    quantity DECIMAL(19,4) NOT NULL  
);  
  
-- ============================================================================  
-- D1 COMMIT-TIME INTEGRITY DEFERRED TRIGGER IMPLEMENTATION  
-- ============================================================================  
CREATE OR REPLACE FUNCTION d1_validate_identity(target_id UUID) RETURNS VOID AS $$  
DECLARE  
    reg_event_type VARCHAR;  
    matched_type VARCHAR;  
    r_count INTEGER;  
BEGIN  
    SELECT event_type INTO reg_event_type FROM economic_event_registry WHERE client_transaction_id = target_id;  
  
    SELECT MAX(root_type), COALESCE(SUM(c), 0) INTO matched_type, r_count FROM (  
        SELECT 'SALE' AS root_type, COUNT(*) AS c FROM sales WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'PURCHASE', COUNT(*) FROM purchases WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'SALE_RETURN', COUNT(*) FROM sale_returns WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'PURCHASE_RETURN', COUNT(*) FROM purchase_returns WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'INV_ADJUSTMENT', COUNT(*) FROM inventory_adjustments WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'INV_TRANSFER', COUNT(*) FROM inventory_transfers WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'EXPENSE', COUNT(*) FROM expenses WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'PAYMENT', COUNT(*) FROM payments WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'PAYMENT_REFUND', COUNT(*) FROM payment_refunds WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'CASH_TRANSFER', COUNT(*) FROM cash_transfers WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'CASH_ADJUSTMENT', COUNT(*) FROM cash_adjustments WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
        UNION ALL SELECT 'CREDIT_APPROVAL', COUNT(*) FROM credit_approvals WHERE client_transaction_id = target_id HAVING COUNT(*) > 0  
    ) AS root_counts;  
  
    IF reg_event_type IS NULL THEN  
        IF r_count > 0 THEN  
            RAISE EXCEPTION 'D1 Violation: Root exists without Registry at COMMIT for %', target_id;  
        END IF;  
        RETURN;  
    END IF;  
  
    IF r_count = 0 THEN  
        RAISE EXCEPTION 'D1 Violation: Registry exists without Root at COMMIT for %', target_id;  
    END IF;  
  
    IF r_count > 1 THEN  
        RAISE EXCEPTION 'D1 Violation: Multiple Roots (%) exist at COMMIT for %', r_count, target_id;  
    END IF;  
  
    IF reg_event_type != matched_type THEN  
        RAISE EXCEPTION 'D1 Violation: Registry event_type (%) does not match Root origin (%) at COMMIT.', reg_event_type, matched_type;  
    END IF;  
END;  
$$ LANGUAGE plpgsql;  
  
CREATE OR REPLACE FUNCTION d1_trigger_router() RETURNS TRIGGER AS $$  
BEGIN  
    IF TG_OP = 'UPDATE' AND OLD.client_transaction_id IS DISTINCT FROM NEW.client_transaction_id THEN  
        PERFORM d1_validate_identity(OLD.client_transaction_id);  
        PERFORM d1_validate_identity(NEW.client_transaction_id);  
    ELSIF TG_OP = 'DELETE' THEN  
        PERFORM d1_validate_identity(OLD.client_transaction_id);  
    ELSE  
        PERFORM d1_validate_identity(NEW.client_transaction_id);  
    END IF;  
    RETURN NULL;  
END;  
$$ LANGUAGE plpgsql;  
  
-- EXACT 13 DEFERRED TRIGGER BINDINGS  
CREATE CONSTRAINT TRIGGER d1_trg_registry AFTER INSERT OR UPDATE OR DELETE ON economic_event_registry DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_sales AFTER INSERT OR UPDATE OR DELETE ON sales DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_purchases AFTER INSERT OR UPDATE OR DELETE ON purchases DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_sale_returns AFTER INSERT OR UPDATE OR DELETE ON sale_returns DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_purchase_returns AFTER INSERT OR UPDATE OR DELETE ON purchase_returns DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_inv_adjustments AFTER INSERT OR UPDATE OR DELETE ON inventory_adjustments DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_inv_transfers AFTER INSERT OR UPDATE OR DELETE ON inventory_transfers DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_expenses AFTER INSERT OR UPDATE OR DELETE ON expenses DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_payments AFTER INSERT OR UPDATE OR DELETE ON payments DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_refunds AFTER INSERT OR UPDATE OR DELETE ON payment_refunds DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_cash_transfers AFTER INSERT OR UPDATE OR DELETE ON cash_transfers DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_cash_adjustments AFTER INSERT OR UPDATE OR DELETE ON cash_adjustments DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();  
CREATE CONSTRAINT TRIGGER d1_trg_credit_approvals AFTER INSERT OR UPDATE OR DELETE ON credit_approvals DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION d1_trigger_router();