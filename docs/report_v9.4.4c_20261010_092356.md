# تقرير جلسة v9.4.4c — 2026-10-10

## الحالة النهائية
- flutter analyze: 0 errors (13 warnings تجميلية)
- ZIP: albaraka_pos_v9.4.4c_20261010_091443.zip (16.47 MB)
- التطبيق يعمل على D:\v94_test
- Hasura: 298 صلاحية + 5 أدوار
- SQLite: v15 (users + override)

## الإنجازات الرئيسية
1. أول مزامنة End-to-End: SQLite → GraphQL → Hasura → PostgreSQL
2. 288 صلاحية مزرعة آلياً في Hasura
3. UserSyncService مشترك (يُستخدم من أي مكان)
4. _manualSync موسعة (Sales + Permissions)
5. ربط "إدارة المستخدمين" بالقائمة المنسدلة
6. استعادة main.dart بعد تلف PowerShell
7. استعادة 9 ملفات بعد خطأ R=Invoke-History

## الملفات الجديدة
- lib/services/user_sync_service.dart (1.5 KB)
- lib/models/user_model.dart
- lib/screens/settings/users_screen.dart (5.3 KB)
- lib/screens/settings/user_form_screen.dart (6.8 KB)
- lib/sync/sync_manager_extension.dart
- lib/services/user_service.dart
- D:\albaraka\permissions_seed.sql (25.2 KB، 288 صلاحية)

## Schemas
### SQLite v15
- users_local (display_name, last_login_at, is_active, synced_at)
- user_permissions_override_local (user_id, permission_key, is_granted, granted_by, granted_at, synced_at)

### Hasura
- permissions (298 سجل)
- roles (5 أدوار: GM, SM, Acc, IC, Cashier)
- role_permissions
- user_permissions_override

## الدروس المستفادة
1. graphql_flutter لا يرفع exception عند errors → فحص result.hasException
2. PowerShell 5.x يفسد UTF-8 → [System.IO.File] دائماً
3. Hasura FK constraint → زرع parent tables أولاً
4. Acronis Active Protection يعترض على flutter build (غير ضار)
5. R/B/W محجوزة في PowerShell → لا تستخدمها كأسماء دوال
6. PowerShell 5.x + سكربتات معقدة = خطر تلف الملفات → استخدم VS Code

## القواعد الذهبية المُضافة
- قاعدة 9: [System.IO.File] مع UTF-8 no BOM للعربية
- قاعدة 10: قاعدة البيانات أولاً، ثم الكود (FK constraints)
- قاعدة 11: لا تستخدم أسماء PowerShell المحجوزة (R, B, W)
- قاعدة 12: التحذيرات التجميلية تُترك — لا نخاطر بما يعمل

## نقطة الاستئاف للجلسة القادمة
- v9.4.5: توسيع عميق (~140 صلاحية إضافية)
- v9.5: عرض الفواتير + الدليل المحاسبي
- v9.6: مزامنة عكسية (Hasura → Flutter)

## بيانات
- مسار المشروع: D:\albaraka\albaraka_pos
- آخر ZIP: albaraka_pos_v9.4.4c_20261010_091443.zip (16.47 MB)
- البقالة على: v8.2 (لم تُلمس)
- عدد النسخ الاحتياطية: 40+ main.dart