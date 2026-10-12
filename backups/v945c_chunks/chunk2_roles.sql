BEGIN;
INSERT INTO roles (id, name, display_name_ar, is_system) VALUES ('General_Manager', 'General_Manager', 'ط§ظ„ظ…ط¯ظٹط± ط§ظ„ط¹ط§ظ…', true) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, display_name_ar = EXCLUDED.display_name_ar;
INSERT INTO roles (id, name, display_name_ar, is_system) VALUES ('Store_Manager', 'Store_Manager', 'ظ…ط¯ظٹط± ط§ظ„ظ…ط®ط²ظ†', true) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, display_name_ar = EXCLUDED.display_name_ar;
INSERT INTO roles (id, name, display_name_ar, is_system) VALUES ('Accountant', 'Accountant', 'ط§ظ„ظ…ط­ط§ط³ط¨', true) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, display_name_ar = EXCLUDED.display_name_ar;
INSERT INTO roles (id, name, display_name_ar, is_system) VALUES ('Inventory_Clerk', 'Inventory_Clerk', 'ط£ظ…ظٹظ† ط§ظ„ظ…ط®ط²ظ†', true) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, display_name_ar = EXCLUDED.display_name_ar;
INSERT INTO roles (id, name, display_name_ar, is_system) VALUES ('Cashier', 'Cashier', 'ط§ظ„ظƒط§ط´ظٹط±', true) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, display_name_ar = EXCLUDED.display_name_ar;
COMMIT;
