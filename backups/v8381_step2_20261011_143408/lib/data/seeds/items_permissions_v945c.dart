// ==============================================================================
// v9.4.5c — Items Permissions (41 صلاحية)
// تم التوليد بناءً على مرجع: ايقونات الأصناف وجداولها في نظام بيتاسيس.docx
// ==============================================================================

final List<Map<String, String>> itemsPermissions = [
  // 1. البيانات الأساسية (6)
  {'key': 'items.basic.view', 'name_ar': 'عرض البيانات الأساسية للأصناف'},
  {'key': 'items.basic.create', 'name_ar': 'إضافة صنف جديد'},
  {'key': 'items.basic.edit', 'name_ar': 'تعديل بيانات صنف أساسي'},
  {'key': 'items.basic.delete', 'name_ar': 'حذف صنف'},
  {'key': 'items.basic.excel', 'name_ar': 'استيراد/تصدير بيانات الأصناف (Excel)'},
  {'key': 'items.basic.print', 'name_ar': 'طباعة بطاقة الصنف'},

  // 2. البيانات الإضافية (3)
  {'key': 'items.additional.view', 'name_ar': 'عرض البيانات الإضافية'},
  {'key': 'items.additional.edit', 'name_ar': 'تعديل البيانات الإضافية'},
  {'key': 'items.additional.assign_branch', 'name_ar': 'تعيين مواقع الصنف في الفروع'},

  // 3. الخيارات المتقدمة (6)
  {'key': 'items.advanced.import_excel', 'name_ar': 'استيراد وتحديث البيانات من Excel'},
  {'key': 'items.advanced.change_id', 'name_ar': 'تغيير رقم أو اسم الصنف'},
  {'key': 'items.advanced.update_barcode', 'name_ar': 'تحديث الباركود'},
  {'key': 'items.advanced.export_scale', 'name_ar': 'تصدير أصناف الميزان'},
  {'key': 'items.advanced.update_last_purchase', 'name_ar': 'تحديث سعر آخر شراء'},
  {'key': 'items.advanced.reset_prices', 'name_ar': 'تصفير سعر البيع/التكلفة للأصناف غير المستخدمة'},

  // 4. المكونات (6)
  {'key': 'items.components.view', 'name_ar': 'عرض مكونات الصنف'},
  {'key': 'items.components.create', 'name_ar': 'إضافة مكون جديد'},
  {'key': 'items.components.edit', 'name_ar': 'تعديل مكون'},
  {'key': 'items.components.delete', 'name_ar': 'حذف مكون'},
  {'key': 'items.components.cost.view', 'name_ar': 'عرض التكاليف التشغيلية'},
  {'key': 'items.components.cost.edit', 'name_ar': 'تعديل التكاليف التشغيلية'},

  // 5. شجرة الأصناف (3)
  {'key': 'items.tree.view', 'name_ar': 'عرض شجرة الأصناف'},
  {'key': 'items.tree.manage', 'name_ar': 'إدارة شجرة الأصناف'},
  {'key': 'items.tree.print', 'name_ar': 'طباعة شجرة الأصناف'},

  // 6. الحركة (4)
  {'key': 'items.movement.view', 'name_ar': 'عرض حركات الصنف'},
  {'key': 'items.movement.print', 'name_ar': 'طباعة تقارير الحركة'},
  {'key': 'items.movement.export', 'name_ar': 'تصدير تقارير الحركة'},
  {'key': 'items.movement.audit', 'name_ar': 'مراجعة وتسوية الأرصدة الافتتاحية'},

  // 7. شريط الأدوات (7)
  {'key': 'items.toolbar.save', 'name_ar': 'حفظ التعديلات'},
  {'key': 'items.toolbar.edit', 'name_ar': 'تفعيل وضع التعديل'},
  {'key': 'items.toolbar.delete', 'name_ar': 'حذف/إلغاء'},
  {'key': 'items.toolbar.search', 'name_ar': 'بحث عن صنف'},
  {'key': 'items.toolbar.add', 'name_ar': 'إضافة صنف جديد'},
  {'key': 'items.toolbar.navigate', 'name_ar': 'التنقل بين السجلات'},
  {'key': 'items.toolbar.exit', 'name_ar': 'الخروج من شاشة الأصناف'},

  // 8. وحدات الأصناف الفرعية (6)
  {'key': 'items.units.view', 'name_ar': 'عرض شاشة وحدات الأصناف الفرعية'},
  {'key': 'items.units.create', 'name_ar': 'إضافة وحدة فرعية جديدة'},
  {'key': 'items.units.edit', 'name_ar': 'تعديل بيانات الوحدة الفرعية'},
  {'key': 'items.units.delete', 'name_ar': 'حذف وحدة فرعية'},
  {'key': 'items.units.set_default', 'name_ar': 'تعيين وحدة البيع الافتراضية'},
  {'key': 'items.units.print', 'name_ar': 'طباعة وحدات الأصناف'},
];

final Map<String, List<String>> itemsRoleAssignments = {
  'General_Manager': [
    'items.basic.view', 'items.basic.create', 'items.basic.edit', 'items.basic.delete', 'items.basic.excel', 'items.basic.print',
    'items.additional.view', 'items.additional.edit', 'items.additional.assign_branch',
    'items.advanced.import_excel', 'items.advanced.change_id', 'items.advanced.update_barcode', 'items.advanced.export_scale', 'items.advanced.update_last_purchase', 'items.advanced.reset_prices',
    'items.components.view', 'items.components.create', 'items.components.edit', 'items.components.delete', 'items.components.cost.view', 'items.components.cost.edit',
    'items.tree.view', 'items.tree.manage', 'items.tree.print',
    'items.movement.view', 'items.movement.print', 'items.movement.export', 'items.movement.audit',
    'items.toolbar.save', 'items.toolbar.edit', 'items.toolbar.delete', 'items.toolbar.search', 'items.toolbar.add', 'items.toolbar.navigate', 'items.toolbar.exit',
    'items.units.view', 'items.units.create', 'items.units.edit', 'items.units.delete', 'items.units.set_default', 'items.units.print'
  ],
  'Store_Manager': [
    'items.basic.view', 'items.basic.create', 'items.basic.edit', 'items.basic.excel', 'items.basic.print',
    'items.additional.view', 'items.additional.edit', 'items.additional.assign_branch',
    'items.advanced.import_excel', 'items.advanced.update_barcode', 'items.advanced.export_scale', 'items.advanced.update_last_purchase',
    'items.components.view', 'items.components.create', 'items.components.edit', 'items.components.cost.view',
    'items.tree.view', 'items.tree.manage', 'items.tree.print',
    'items.movement.view', 'items.movement.print', 'items.movement.export',
    'items.toolbar.save', 'items.toolbar.edit', 'items.toolbar.search', 'items.toolbar.add', 'items.toolbar.navigate', 'items.toolbar.exit',
    'items.units.view', 'items.units.create', 'items.units.edit', 'items.units.set_default', 'items.units.print'
  ],
  'Accountant': [
    'items.basic.view', 'items.basic.print',
    'items.components.view', 'items.components.cost.view',
    'items.movement.view', 'items.movement.print',
    'items.toolbar.search', 'items.toolbar.navigate', 'items.toolbar.exit'
  ],
  'Inventory_Clerk': [
    'items.basic.view', 'items.basic.print',
    'items.additional.view',
    'items.components.view',
    'items.tree.view', 'items.tree.print',
    'items.movement.view', 'items.movement.print', 'items.movement.export',
    'items.toolbar.search', 'items.toolbar.navigate', 'items.toolbar.exit',
    'items.units.view', 'items.units.print'
  ],
  'Cashier': [],
};