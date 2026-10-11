-- Batch 7/7  (20 products, rows 1201-1220)

-- (1) products
INSERT INTO products (category_id, sku, name, standard_cost, sale_price)
SELECT c.id, v.sku, v.name, v.cost, v.price
FROM (VALUES
  ('supplies', '42-433', 'سم فيران اسود سفري بودرة 10جم', 55::numeric, 100::numeric),
  ('supplies', '42-477', 'مبيد بودر قاهر الذباب علب', 0::numeric, 200::numeric),
  ('supplies', '42-626', 'فحم سفري  الامير مدور', 150::numeric, 250::numeric),
  ('supplies', '42-677', 'ملاعق سفري كبير', 170::numeric, 250::numeric),
  ('sweets', '42-679', 'تمر مكتومي ملكي 900جم', 0::numeric, 1500::numeric),
  ('supplies', '42-851', 'صفار الزعفران والبيض 100جم', 241.71::numeric, 350::numeric),
  ('supplies', '42-904', 'لانبرول للحموضة وقرحة المعدة', 253.78::numeric, 500::numeric),
  ('supplies', '42-928', 'قلاصات سفري كرتوني رقم7', 0::numeric, 650::numeric),
  ('supplies', '42-938', 'سفر سفري عادي كبير', 450::numeric, 600::numeric),
  ('fireworks', '88-001', 'العاب نارية كاتب الاسماء', 0::numeric, 50::numeric),
  ('fireworks', '88-002', 'صواريخ', 8.99::numeric, 25::numeric),
  ('fireworks', '88-003', 'فشيش ناري', 6::numeric, 20::numeric),
  ('fireworks', '88-004', 'طماش برع', 10::numeric, 20::numeric),
  ('fireworks', '88-005', 'رصاص مسدس نار', 0::numeric, 300::numeric),
  ('fireworks', '88-006', 'طماش دويرة', 0::numeric, 25::numeric),
  ('fireworks', '88-007', 'طماش رجم موقف', 108.34::numeric, 141::numeric),
  ('fireworks', '88-008', 'طماش شريط كبير', 0::numeric, 0::numeric),
  ('fireworks', '88-009', 'طماش ابو حمامة', 0::numeric, 0::numeric),
  ('fireworks', '88-010', 'طليع كبير', 0::numeric, 300::numeric),
  ('fireworks', '88-011', 'قريح العاب', 100::numeric, 300::numeric)
) AS v(slug, sku, name, cost, price)
JOIN categories c ON c.slug = v.slug
ON CONFLICT (sku) DO NOTHING;

-- (2) product_units
INSERT INTO product_units (product_id, unit_code, conversion_factor)
SELECT p.id, v.unit, 1
FROM (VALUES
  ('42-433', 'حبة'),
  ('42-477', 'علبة'),
  ('42-626', 'حبة'),
  ('42-677', 'شدة'),
  ('42-679', 'كيلو'),
  ('42-851', 'علبة'),
  ('42-904', 'شريط'),
  ('42-928', 'شدة'),
  ('42-938', 'شدة'),
  ('88-001', 'حبة'),
  ('88-002', 'حبة'),
  ('88-003', 'حبة'),
  ('88-004', 'حبة'),
  ('88-005', 'حبة'),
  ('88-006', 'حبة'),
  ('88-007', 'حبة'),
  ('88-008', 'حبة'),
  ('88-009', 'حبة'),
  ('88-010', 'حبة'),
  ('88-011', 'حبة')
) AS v(sku, unit)
JOIN products p ON p.sku = v.sku
ON CONFLICT (product_id, unit_code) DO NOTHING;

-- (3) branch_products
INSERT INTO branch_products (branch_id, product_id, status)
SELECT '11111111-1111-1111-1111-111111111111'::uuid, p.id, 'active'
FROM products p
WHERE p.sku IN ('42-433', '42-477', '42-626', '42-677', '42-679', '42-851', '42-904', '42-928', '42-938', '88-001', '88-002', '88-003', '88-004', '88-005', '88-006', '88-007', '88-008', '88-009', '88-010', '88-011')
ON CONFLICT (branch_id, product_id) DO NOTHING;

-- (4) stock_balances
INSERT INTO stock_balances (warehouse_id, product_id, quantity)
SELECT '33333333-3333-3333-3333-333333333333'::uuid, p.id, v.qty
FROM (VALUES
  ('42-433', 79::numeric),
  ('42-477', 4::numeric),
  ('42-626', 3::numeric),
  ('42-677', 9::numeric),
  ('42-679', 0::numeric),
  ('42-851', 1::numeric),
  ('42-904', 18.2::numeric),
  ('42-928', 0::numeric),
  ('42-938', 81::numeric),
  ('88-001', 54::numeric),
  ('88-002', 125::numeric),
  ('88-003', 2191::numeric),
  ('88-004', 13::numeric),
  ('88-005', 51.89::numeric),
  ('88-006', 0::numeric),
  ('88-007', 25.5::numeric),
  ('88-008', 5::numeric),
  ('88-009', 15::numeric),
  ('88-010', 0::numeric),
  ('88-011', 9::numeric)
) AS v(sku, qty)
JOIN products p ON p.sku = v.sku
ON CONFLICT (warehouse_id, product_id) DO NOTHING;
