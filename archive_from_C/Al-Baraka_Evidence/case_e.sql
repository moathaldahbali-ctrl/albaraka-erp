BEGIN;
INSERT INTO economic_event_registry (client_transaction_id, event_type) VALUES ('e0000000-0000-0000-0000-00000000000e', 'SALE');
INSERT INTO expenses (id, client_transaction_id, branch_id, chart_of_accounts_id, amount, user_id, occurred_at) 
VALUES (gen_random_uuid(), 'e0000000-0000-0000-0000-00000000000e', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 100.0, '30000000-0000-0000-0000-000000000001', NOW());

DO $$ BEGIN RAISE NOTICE 'BEFORE COMMIT'; END $$;
COMMIT;
DO $$ BEGIN RAISE NOTICE 'COMMIT SUCCEEDED'; END $$;
