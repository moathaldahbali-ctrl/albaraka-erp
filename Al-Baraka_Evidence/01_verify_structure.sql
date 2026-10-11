DO $$
DECLARE
    v_missing_tables INT;
    v_extra_tables INT;
    v_missing_d1_triggers INT;
    v_a5_col_check BOOLEAN;
    v_a5_trg_check BOOLEAN;
    canonical_list text[] := ARRAY[
        'chart_of_accounts', 'currencies', 'branches', 'roles', 'permissions', 'categories', 'customers', 'suppliers',
        'economic_event_registry', 'idempotency_records', 'client_applications', 'accounting_periods', 'users',
        'role_permissions', 'warehouses', 'products', 'customer_contacts', 'branch_customers', 'credit_requests',
        'audit_logs', 'user_roles', 'pos_devices', 'cash_registers', 'product_units', 'branch_products', 'stock_ledger',
        'stock_balances', 'inventory_alerts', 'costing_runs', 'purchases', 'inventory_adjustments', 'inventory_transfers',
        'expenses', 'payments', 'credit_approvals', 'register_sessions', 'device_tokens', 'sync_conflicts', 'product_barcodes',
        'purchase_lines', 'purchase_returns', 'payment_refunds', 'inventory_adjustment_lines', 'inventory_transfer_lines',
        'cost_adjustment_events', 'sales', 'cash_transfers', 'cash_adjustments', 'cash_movements', 'purchase_return_lines',
        'journal_entries', 'sale_lines', 'sale_returns', 'journal_lines', 'sale_return_lines'
    ];
BEGIN
    WITH expected_tables AS (SELECT unnest(canonical_list) AS tbl)
    SELECT count(*) INTO v_missing_tables
    FROM expected_tables e
    LEFT JOIN pg_class c ON c.relname = e.tbl 
        AND c.relnamespace = 'public'::regnamespace 
        AND c.relkind = 'r'
    WHERE c.oid IS NULL;

    SELECT count(*) INTO v_extra_tables
    FROM pg_class c
    WHERE c.relnamespace = 'public'::regnamespace 
      AND c.relkind = 'r'
      AND c.relname != ALL(canonical_list);

    IF v_missing_tables > 0 OR v_extra_tables > 0 OR (SELECT count(*) FROM pg_class WHERE relnamespace = 'public'::regnamespace AND relkind = 'r') != 55 THEN
        RAISE EXCEPTION 'STRUCTURAL BLOCKED: Exact 55 canonical tables validation failed. Missing: %, Extra: %', v_missing_tables, v_extra_tables;
    END IF;

    WITH expected_d1_mapping(trg_name, tbl_name) AS (
        VALUES 
            ('d1_trg_registry', 'economic_event_registry'), ('d1_trg_sales', 'sales'), ('d1_trg_purchases', 'purchases'),
            ('d1_trg_sale_returns', 'sale_returns'), ('d1_trg_purchase_returns', 'purchase_returns'),
            ('d1_trg_inv_adjustments', 'inventory_adjustments'), ('d1_trg_inv_transfers', 'inventory_transfers'),
            ('d1_trg_expenses', 'expenses'), ('d1_trg_payments', 'payments'), ('d1_trg_refunds', 'payment_refunds'),
            ('d1_trg_cash_transfers', 'cash_transfers'), ('d1_trg_cash_adjustments', 'cash_adjustments'),
            ('d1_trg_credit_approvals', 'credit_approvals')
    )
    SELECT count(*) INTO v_missing_d1_triggers
    FROM expected_d1_mapping em
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.triggers ist
        JOIN pg_class c ON c.relname = ist.event_object_table AND c.relnamespace = 'public'::regnamespace
        JOIN pg_trigger pt ON pt.tgrelid = c.oid AND pt.tgname = ist.trigger_name
        JOIN pg_proc pr ON pt.tgfoid = pr.oid
        WHERE ist.trigger_name = em.trg_name
          AND ist.event_object_table = em.tbl_name
          AND ist.action_timing = 'AFTER'
          AND ist.action_orientation = 'ROW'
          AND pt.tgdeferrable = true
          AND pt.tginitdeferred = true
          AND pr.proname = 'd1_trigger_router'
        GROUP BY ist.trigger_name
        HAVING bool_and(ist.event_manipulation IN ('INSERT', 'UPDATE', 'DELETE'))
           AND count(DISTINCT ist.event_manipulation) = 3
    );

    IF v_missing_d1_triggers > 0 THEN
        RAISE EXCEPTION 'STRUCTURAL BLOCKED: Exact 13 D1 triggers validation failed.';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class child ON con.conrelid = child.oid
        JOIN pg_class parent ON con.confrelid = parent.oid
        JOIN pg_attribute a_child ON a_child.attrelid = child.oid AND a_child.attnum = ANY(con.conkey)
        JOIN pg_attribute a_parent ON a_parent.attrelid = parent.oid AND a_parent.attnum = ANY(con.confkey)
        WHERE child.relname = 'register_sessions'
          AND a_child.attname = 'pos_device_id'
          AND parent.relname = 'pos_devices'
          AND a_parent.attname = 'id'
          AND con.contype = 'f'
          AND con.confdeltype = 'r' 
          AND a_child.atttypid = 'uuid'::regtype
          AND a_child.attnotnull = true
    ) INTO v_a5_col_check;

    SELECT EXISTS (
        SELECT 1
        FROM information_schema.triggers ist
        JOIN pg_class c ON c.relname = ist.event_object_table AND c.relnamespace = 'public'::regnamespace
        JOIN pg_proc pr ON pr.proname = 'enforce_a5_device_immutability'
        JOIN pg_trigger pt ON pt.tgrelid = c.oid AND pt.tgname = ist.trigger_name AND pt.tgfoid = pr.oid
        WHERE ist.trigger_name = 'trg_a5_device_immutability'
          AND ist.event_object_table = 'register_sessions'
          AND ist.action_timing = 'BEFORE'
          AND ist.action_orientation = 'ROW'
          AND ist.event_manipulation = 'UPDATE'
    ) INTO v_a5_trg_check;

    IF NOT v_a5_col_check OR NOT v_a5_trg_check THEN
        RAISE EXCEPTION 'STRUCTURAL BLOCKED: A5 validation failed (Column constraints or Trigger definitions).';
    END IF;
END $$;
