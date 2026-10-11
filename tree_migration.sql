-- v8.3.8.1: Hierarchical categories
BEGIN;

-- 1) Add parent_id column
ALTER TABLE categories ADD COLUMN IF NOT EXISTS parent_id uuid REFERENCES categories(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);

-- 2) Insert 6 parent categories
INSERT INTO categories (id, slug, name, parent_id) VALUES ('10000000-0000-0000-0000-000000000001', 'basic_food', 'الأغذية الأساسية', NULL) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO categories (id, slug, name, parent_id) VALUES ('10000000-0000-0000-0000-000000000002', 'dairy_products', 'منتجات الألبان', NULL) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO categories (id, slug, name, parent_id) VALUES ('10000000-0000-0000-0000-000000000003', 'beverages', 'المشروبات', NULL) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO categories (id, slug, name, parent_id) VALUES ('10000000-0000-0000-0000-000000000004', 'snacks', 'الوجبات الخفيفة', NULL) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO categories (id, slug, name, parent_id) VALUES ('10000000-0000-0000-0000-000000000005', 'care_cleaning', 'العناية والتنظيف', NULL) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO categories (id, slug, name, parent_id) VALUES ('10000000-0000-0000-0000-000000000006', 'other', 'أخرى', NULL) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;

-- 3) Link children to parents
UPDATE categories SET parent_id = '10000000-0000-0000-0000-000000000001' WHERE slug IN ('rice_pasta','oils_ghee_butter','pastries','canned','vegetables','minced_meat','vinegar_salt_sauce');
UPDATE categories SET parent_id = '10000000-0000-0000-0000-000000000002' WHERE slug IN ('milk','dairy','jam_butter');
UPDATE categories SET parent_id = '10000000-0000-0000-0000-000000000003' WHERE slug IN ('juices','mineral_water','scented_water','soft_drinks');
UPDATE categories SET parent_id = '10000000-0000-0000-0000-000000000004' WHERE slug IN ('biscuits','cake','honey','chips','sweets');
UPDATE categories SET parent_id = '10000000-0000-0000-0000-000000000005' WHERE slug IN ('accessories','cosmetics','detergents_soap');
UPDATE categories SET parent_id = '10000000-0000-0000-0000-000000000006' WHERE slug IN ('balance','foreigners','supplies','tools','qour','recharge_cards','fireworks');
COMMIT;
