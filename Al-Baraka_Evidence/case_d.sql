BEGIN;
INSERT INTO economic_event_registry (client_transaction_id, event_type) VALUES ('d0000000-0000-0000-0000-00000000000d', 'SALE');
INSERT INTO sales (id, client_transaction_id, branch_id, warehouse_id, customer_id, register_session_id, occurred_at) 
VALUES (gen_random_uuid(), 'd0000000-0000-0000-0000-00000000000d', '20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', NOW());
INSERT INTO inventory_adjustments (id, client_transaction_id, branch_id, warehouse_id, user_id, occurred_at) 
VALUES (gen_random_uuid(), 'd0000000-0000-0000-0000-00000000000d', '20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', NOW());

DO $$ BEGIN RAISE NOTICE 'BEFORE COMMIT'; END $$;
COMMIT;
DO $$ BEGIN RAISE NOTICE 'COMMIT SUCCEEDED'; END $$;
