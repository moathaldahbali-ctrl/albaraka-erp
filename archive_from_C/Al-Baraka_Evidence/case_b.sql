BEGIN;
INSERT INTO economic_event_registry (client_transaction_id, event_type) VALUES ('a0000000-0000-0000-0000-00000000000a', 'SALE');
INSERT INTO sales (id, client_transaction_id, branch_id, warehouse_id, customer_id, register_session_id, occurred_at) 
VALUES (gen_random_uuid(), 'a0000000-0000-0000-0000-00000000000a', '20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', NOW());

INSERT INTO economic_event_registry (client_transaction_id, event_type) VALUES ('b0000000-0000-0000-0000-00000000000b', 'SALE');
UPDATE sales SET client_transaction_id = 'b0000000-0000-0000-0000-00000000000b' WHERE client_transaction_id = 'a0000000-0000-0000-0000-00000000000a';

DO $$ BEGIN RAISE NOTICE 'BEFORE COMMIT'; END $$;
COMMIT;
DO $$ BEGIN RAISE NOTICE 'COMMIT SUCCEEDED'; END $$;
