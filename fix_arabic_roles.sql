-- v8.3.7e: Fix Arabic display_name_ar in roles
BEGIN;
UPDATE roles SET display_name_ar = 'المدير العام' WHERE id = 'General_Manager';
UPDATE roles SET display_name_ar = 'مدير المخزن' WHERE id = 'Store_Manager';
UPDATE roles SET display_name_ar = 'المحاسب' WHERE id = 'Accountant';
UPDATE roles SET display_name_ar = 'أمين المخزن' WHERE id = 'Inventory_Clerk';
UPDATE roles SET display_name_ar = 'الكاشير' WHERE id = 'Cashier';
COMMIT;
