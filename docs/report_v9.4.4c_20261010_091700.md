# تقرير جلسة v9.4.4c — 2026-10-10

## الإنجازات الرئيسية
- 298 صلاحية في Hasura (permissions table)
- UserSyncService مشترك (lib/services/user_sync_service.dart)
- _manualSync موسعة (Sales + Permissions)
- مزامنة فعلية ناجحة: SQLite → GraphQL → Hasura → PostgreSQL
- flutter analyze = 0 errors (13 warning/info)
- ZIP: albaraka_pos_v9.4.4c_20261010_091443.zip (16.47 MB)

## الملفات الجديدة
- lib/services/user_sync_service.dart
- lib/models/user_model.dart
- lib/screens/settings/users_screen.dart
- lib/screens/settings/user_form_screen.dart
- lib/sync/sync_manager_extension.dart
- lib/services/user_service.dart
- D:\albaraka\permissions_seed.sql (288 صلاحية)

## Schemas
### SQLite v15
- users_local (display_name, last_login_at, is_active, synced_at)
- user_permissions_override_local (user_id, permission_key, is_granted, granted_by, granted_at, synced_at)

### Hasura
- permissions (298 سجل)
- roles (5 أدوار)
- role_permissions
- user_permissions_override

## الدروس المستفادة
1. graphql_flutter لا يرفع exception عند errors → فحص result.hasException
2. PowerShell 5.x يفسد UTF-8 → [System.IO.File] دائماً
3. Hasura FK constraint → زرع parent tables أولاً
4. Acronis Active Protection يعترض على flutter build (غير ضار)

## القواعد الذهبية المُضافة
- قاعدة 9: لا تستخدم Set-Content/Get-Content للعربية → [System.IO.File] مع UTF-8 no BOM
- قاعدة 10: قاعدة البيانات أولاً، ثم الكود (FK constraints)

## نقطة الاستئاف للجلسة القادمة
- v9.4.5: توسيع عميق (~140 صلاحية إضافية: user_profile, master_data, ops2, assets)
- v9.5: عرض الفواتير + الدليل المحاسبي (BetaSys style أو Excel style)
- v9.6: مزامنة عكسية (Hasura → Flutter)

## بيانات التطبيق
- مسار: D:\albaraka\albaraka_pos_v9.4.4c_20261010_091443.zip
- الحجم: 16.47 MB
- عدد المستخدمين: 4 (moaz, cashier1, cashier2, test_sync)
- عدد الأدوار: 5
- عدد الصلاحيات: 298 (Hasura) / 288 (Seed)
- آخر إصدار في البقالة: v8.2 (لم يُلمس)