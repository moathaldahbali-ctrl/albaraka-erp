# أدوات تطوير مشروع البركة POS/ERP

سكربتات Dart مساعدة. تُشغَّل يدوياً من داخل مجلد المشروع.

## طريقة التشغيل

## السكربتات المتاحة

| السكربت | الغرض |
|---|---|
| `probe_db.dart` | فحص بنية SQLite (جداول + أعمدة + صفوف) |
| `check_sales.dart` | عرض الفواتير المحلية |
| `check_sample.dart` | عيّنة من المنتجات |
| `check_units.dart` | وحدات منتجات محددة |
| `diagnose_sync.dart` | فحص بيانات المزامنة |
| `migrate_v6.dart` | ترقية schema v5→v6 (مرة واحدة) |
| `migrate_v7.dart` | ترقية schema v6→v7 (مرة واحدة) |
| `migrate_v8.dart` | ترقية schema v7→v8 (مرة واحدة) |
| `migrate_v9.dart` | ترقية schema v8→v9 (مرة واحدة) |
| `load_products_to_sqlite.dart` | سحب 1220 منتجاً من Hasura |
| `load_units_to_sqlite.dart` | سحب 1248 وحدة |
| `load_categories_to_sqlite.dart` | سحب 29 تصنيفاً |

## المسارات

- **قاعدة البيانات:** `D:\albaraka\data\albaraka_local.db`
- **المفتاح السري:** `D:\albaraka\albaraka_pos\.env`
- **Hasura:** `https://eewgyrglhvkxjwzevcwm.hasura.ap-southeast-1.nhost.run/v1/graphql`

## ملاحظات

- كل السكربتات تستخدم `package:sqflite_common_ffi` — Dart نقي، بلا Flutter.
- لتشغيلها مع كود التطبيق (`lib/`)، استخدم `flutter run`.
- عند تغيير schema (مثل v9→v10)، أنشئ `migrate_v10.dart` جديد + أضف `oldVersion < 10` في `local_db.dart`.
