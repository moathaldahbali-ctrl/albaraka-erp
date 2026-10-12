/// صلاحيات BetaSys الكاملة (206 صلاحية)
/// 6 أقسام: file | ops | reports | settings | sec | help
/// لا حذف - لا اختصار - كل ما ورد في المرجع الأصلي
class PermissionsSeed {
  /// v9.4.6: إصدار Seed — يُستخدم في AppInitializer
  static const String seedVersion = 'v9.4.5b-LITE';
  static const int seedGeneration = 1;
  static const List<Map<String, dynamic>> all = [
    // file
    {'code': 'file.open_company',       'name_ar': 'فتح شركة',              'category': 'file', 'sort': 1},
    {'code': 'file.close_company',      'name_ar': 'إغلاق شركة',            'category': 'file', 'sort': 2},
    {'code': 'file.calculator',         'name_ar': 'الحاسبة',                'category': 'file', 'sort': 3},
    {'code': 'file.change_user',        'name_ar': 'تغيير دخول',            'category': 'file', 'sort': 4},
    {'code': 'file.change_password',    'name_ar': 'تغيير كلمة المرور',     'category': 'file', 'sort': 5},
    {'code': 'file.change_fiscal_year', 'name_ar': 'تغيير السنة المالية',   'category': 'file', 'sort': 6},
    {'code': 'file.addresses',          'name_ar': 'قائمة العناوين',         'category': 'file', 'sort': 7},
    {'code': 'file.tasks',              'name_ar': 'قائمة المهام',           'category': 'file', 'sort': 8},
    {'code': 'file.reminders',          'name_ar': 'التذكيرات',              'category': 'file', 'sort': 9},
    {'code': 'file.financial_notes',    'name_ar': 'ملاحظات مالية',          'category': 'file', 'sort': 10},
    {'code': 'file.notes',              'name_ar': 'قائمة الملاحظات',        'category': 'file', 'sort': 11},
    {'code': 'file.toolbar',            'name_ar': 'شريط الإختصار',          'category': 'file', 'sort': 12},
    {'code': 'file.rtl_toggle',         'name_ar': 'تغيير اتجاه القوائم',    'category': 'file', 'sort': 13},
    {'code': 'file.movements_bar',      'name_ar': 'شريط الحركات',           'category': 'file', 'sort': 14},
    {'code': 'file.health_check',       'name_ar': 'فحص النظام',             'category': 'file', 'sort': 15},
    {'code': 'file.update',             'name_ar': 'تحديث',                  'category': 'file', 'sort': 16},
    {'code': 'file.vacuum',             'name_ar': 'ضغط قاعدة المعطيات',     'category': 'file', 'sort': 17},
    {'code': 'file.exit',               'name_ar': 'خروج',                   'category': 'file', 'sort': 18},

    // ops - sales_invoice
    {'code': 'ops.sales_invoice.create', 'name_ar': 'فاتورة مبيعات - إضافة', 'category': 'ops', 'sort': 100},
    {'code': 'ops.sales_invoice.edit',   'name_ar': 'فاتورة مبيعات - تعديل', 'category': 'ops', 'sort': 101},
    {'code': 'ops.sales_invoice.delete', 'name_ar': 'فاتورة مبيعات - حذف',   'category': 'ops', 'sort': 102},
    {'code': 'ops.sales_invoice.print',  'name_ar': 'فاتورة مبيعات - طباعة', 'category': 'ops', 'sort': 103},
    {'code': 'ops.sales_invoice.post',   'name_ar': 'فاتورة مبيعات - ترحيل', 'category': 'ops', 'sort': 104},
    {'code': 'ops.sales_invoice.unpost', 'name_ar': 'فاتورة مبيعات - إلغاء ترحيل', 'category': 'ops', 'sort': 105},

    // ops - sales_return
    {'code': 'ops.sales_return.create', 'name_ar': 'مردودات مبيعات - إضافة', 'category': 'ops', 'sort': 110},
    {'code': 'ops.sales_return.edit',   'name_ar': 'مردودات مبيعات - تعديل', 'category': 'ops', 'sort': 111},
    {'code': 'ops.sales_return.delete', 'name_ar': 'مردودات مبيعات - حذف',   'category': 'ops', 'sort': 112},
    {'code': 'ops.sales_return.print',  'name_ar': 'مردودات مبيعات - طباعة', 'category': 'ops', 'sort': 113},
    {'code': 'ops.sales_return.post',   'name_ar': 'مردودات مبيعات - ترحيل', 'category': 'ops', 'sort': 114},
    {'code': 'ops.sales_return.unpost', 'name_ar': 'مردودات مبيعات - إلغاء ترحيل', 'category': 'ops', 'sort': 115},

    // ops - direct_sales
    {'code': 'ops.direct_sales.create', 'name_ar': 'مبيعات مباشرة - إضافة', 'category': 'ops', 'sort': 120},
    {'code': 'ops.direct_sales.edit',   'name_ar': 'مبيعات مباشرة - تعديل', 'category': 'ops', 'sort': 121},
    {'code': 'ops.direct_sales.delete', 'name_ar': 'مبيعات مباشرة - حذف',   'category': 'ops', 'sort': 122},
    {'code': 'ops.direct_sales.print',  'name_ar': 'مبيعات مباشرة - طباعة', 'category': 'ops', 'sort': 123},
    {'code': 'ops.direct_sales.post',   'name_ar': 'مبيعات مباشرة - ترحيل', 'category': 'ops', 'sort': 124},
    {'code': 'ops.direct_sales.unpost', 'name_ar': 'مبيعات مباشرة - إلغاء ترحيل', 'category': 'ops', 'sort': 125},

    // ops - quotation
    {'code': 'ops.quotation.create', 'name_ar': 'عرض سعر - إضافة', 'category': 'ops', 'sort': 130},
    {'code': 'ops.quotation.edit',   'name_ar': 'عرض سعر - تعديل', 'category': 'ops', 'sort': 131},
    {'code': 'ops.quotation.delete', 'name_ar': 'عرض سعر - حذف',   'category': 'ops', 'sort': 132},
    {'code': 'ops.quotation.print',  'name_ar': 'عرض سعر - طباعة', 'category': 'ops', 'sort': 133},

    // ops - purchase_invoice
    {'code': 'ops.purchase_invoice.create', 'name_ar': 'فاتورة مشتريات - إضافة', 'category': 'ops', 'sort': 140},
    {'code': 'ops.purchase_invoice.edit',   'name_ar': 'فاتورة مشتريات - تعديل', 'category': 'ops', 'sort': 141},
    {'code': 'ops.purchase_invoice.delete', 'name_ar': 'فاتورة مشتريات - حذف',   'category': 'ops', 'sort': 142},
    {'code': 'ops.purchase_invoice.print',  'name_ar': 'فاتورة مشتريات - طباعة', 'category': 'ops', 'sort': 143},
    {'code': 'ops.purchase_invoice.post',   'name_ar': 'فاتورة مشتريات - ترحيل', 'category': 'ops', 'sort': 144},
    {'code': 'ops.purchase_invoice.unpost', 'name_ar': 'فاتورة مشتريات - إلغاء ترحيل', 'category': 'ops', 'sort': 145},

    // ops - purchase_return
    {'code': 'ops.purchase_return.create', 'name_ar': 'مردودات مشتريات - إضافة', 'category': 'ops', 'sort': 150},
    {'code': 'ops.purchase_return.edit',   'name_ar': 'مردودات مشتريات - تعديل', 'category': 'ops', 'sort': 151},
    {'code': 'ops.purchase_return.delete', 'name_ar': 'مردودات مشتريات - حذف',   'category': 'ops', 'sort': 152},
    {'code': 'ops.purchase_return.print',  'name_ar': 'مردودات مشتريات - طباعة', 'category': 'ops', 'sort': 153},
    {'code': 'ops.purchase_return.post',   'name_ar': 'مردودات مشتريات - ترحيل', 'category': 'ops', 'sort': 154},
    {'code': 'ops.purchase_return.unpost', 'name_ar': 'مردودات مشتريات - إلغاء ترحيل', 'category': 'ops', 'sort': 155},

    // ops - receipt_voucher
    {'code': 'ops.receipt_voucher.create', 'name_ar': 'سند قبض - إضافة', 'category': 'ops', 'sort': 160},
    {'code': 'ops.receipt_voucher.edit',   'name_ar': 'سند قبض - تعديل', 'category': 'ops', 'sort': 161},
    {'code': 'ops.receipt_voucher.delete', 'name_ar': 'سند قبض - حذف',   'category': 'ops', 'sort': 162},
    {'code': 'ops.receipt_voucher.print',  'name_ar': 'سند قبض - طباعة', 'category': 'ops', 'sort': 163},
    {'code': 'ops.receipt_voucher.post',   'name_ar': 'سند قبض - ترحيل', 'category': 'ops', 'sort': 164},
    {'code': 'ops.receipt_voucher.unpost', 'name_ar': 'سند قبض - إلغاء ترحيل', 'category': 'ops', 'sort': 165},

    // ops - payment_voucher
    {'code': 'ops.payment_voucher.create', 'name_ar': 'سند صرف - إضافة', 'category': 'ops', 'sort': 170},
    {'code': 'ops.payment_voucher.edit',   'name_ar': 'سند صرف - تعديل', 'category': 'ops', 'sort': 171},
    {'code': 'ops.payment_voucher.delete', 'name_ar': 'سند صرف - حذف',   'category': 'ops', 'sort': 172},
    {'code': 'ops.payment_voucher.print',  'name_ar': 'سند صرف - طباعة', 'category': 'ops', 'sort': 173},
    {'code': 'ops.payment_voucher.post',   'name_ar': 'سند صرف - ترحيل', 'category': 'ops', 'sort': 174},
    {'code': 'ops.payment_voucher.unpost', 'name_ar': 'سند صرف - إلغاء ترحيل', 'category': 'ops', 'sort': 175},

    // ops - journal_voucher
    {'code': 'ops.journal_voucher.create', 'name_ar': 'سند قيد - إضافة', 'category': 'ops', 'sort': 180},
    {'code': 'ops.journal_voucher.edit',   'name_ar': 'سند قيد - تعديل', 'category': 'ops', 'sort': 181},
    {'code': 'ops.journal_voucher.delete', 'name_ar': 'سند قيد - حذف',   'category': 'ops', 'sort': 182},
    {'code': 'ops.journal_voucher.print',  'name_ar': 'سند قيد - طباعة', 'category': 'ops', 'sort': 183},
    {'code': 'ops.journal_voucher.post',   'name_ar': 'سند قيد - ترحيل', 'category': 'ops', 'sort': 184},
    {'code': 'ops.journal_voucher.unpost', 'name_ar': 'سند قيد - إلغاء ترحيل', 'category': 'ops', 'sort': 185},

    // ops - fx_diff_entry
    {'code': 'ops.fx_diff_entry.create', 'name_ar': 'قيد فروق العملات - إضافة', 'category': 'ops', 'sort': 190},
    {'code': 'ops.fx_diff_entry.edit',   'name_ar': 'قيد فروق العملات - تعديل', 'category': 'ops', 'sort': 191},
    {'code': 'ops.fx_diff_entry.delete', 'name_ar': 'قيد فروق العملات - حذف',   'category': 'ops', 'sort': 192},
    {'code': 'ops.fx_diff_entry.print',  'name_ar': 'قيد فروق العملات - طباعة', 'category': 'ops', 'sort': 193},
    {'code': 'ops.fx_diff_entry.post',   'name_ar': 'قيد فروق العملات - ترحيل', 'category': 'ops', 'sort': 194},

    // ops - opening_entry
    {'code': 'ops.opening_entry.create', 'name_ar': 'قيد إفتتاحي - إضافة', 'category': 'ops', 'sort': 200},
    {'code': 'ops.opening_entry.edit',   'name_ar': 'قيد إفتتاحي - تعديل', 'category': 'ops', 'sort': 201},
    {'code': 'ops.opening_entry.delete', 'name_ar': 'قيد إفتتاحي - حذف',   'category': 'ops', 'sort': 202},
    {'code': 'ops.opening_entry.print',  'name_ar': 'قيد إفتتاحي - طباعة', 'category': 'ops', 'sort': 203},
    {'code': 'ops.opening_entry.post',   'name_ar': 'قيد إفتتاحي - ترحيل', 'category': 'ops', 'sort': 204},

    // ops - closing_entry
    {'code': 'ops.closing_entry.create', 'name_ar': 'قيد إقفال - إضافة', 'category': 'ops', 'sort': 210},
    {'code': 'ops.closing_entry.edit',   'name_ar': 'قيد إقفال - تعديل', 'category': 'ops', 'sort': 211},
    {'code': 'ops.closing_entry.delete', 'name_ar': 'قيد إقفال - حذف',   'category': 'ops', 'sort': 212},
    {'code': 'ops.closing_entry.print',  'name_ar': 'قيد إقفال - طباعة', 'category': 'ops', 'sort': 213},
    {'code': 'ops.closing_entry.post',   'name_ar': 'قيد إقفال - ترحيل', 'category': 'ops', 'sort': 214},

    // ops - bank_notice
    {'code': 'ops.bank_notice.create', 'name_ar': 'إشعار بنكي - إضافة', 'category': 'ops', 'sort': 220},
    {'code': 'ops.bank_notice.edit',   'name_ar': 'إشعار بنكي - تعديل', 'category': 'ops', 'sort': 221},
    {'code': 'ops.bank_notice.delete', 'name_ar': 'إشعار بنكي - حذف',   'category': 'ops', 'sort': 222},
    {'code': 'ops.bank_notice.print',  'name_ar': 'إشعار بنكي - طباعة', 'category': 'ops', 'sort': 223},
    {'code': 'ops.bank_notice.post',   'name_ar': 'إشعار بنكي - ترحيل', 'category': 'ops', 'sort': 224},

    // ops - wh_opening
    {'code': 'ops.wh_opening.create', 'name_ar': 'سند افتتاحي مخزني - إضافة', 'category': 'ops', 'sort': 230},
    {'code': 'ops.wh_opening.edit',   'name_ar': 'سند افتتاحي مخزني - تعديل', 'category': 'ops', 'sort': 231},
    {'code': 'ops.wh_opening.delete', 'name_ar': 'سند افتتاحي مخزني - حذف',   'category': 'ops', 'sort': 232},
    {'code': 'ops.wh_opening.print',  'name_ar': 'سند افتتاحي مخزني - طباعة', 'category': 'ops', 'sort': 233},
    {'code': 'ops.wh_opening.post',   'name_ar': 'سند افتتاحي مخزني - ترحيل', 'category': 'ops', 'sort': 234},

    // ops - wh_transfer
    {'code': 'ops.wh_transfer.create', 'name_ar': 'سند تحويل مخزني - إضافة', 'category': 'ops', 'sort': 240},
    {'code': 'ops.wh_transfer.edit',   'name_ar': 'سند تحويل مخزني - تعديل', 'category': 'ops', 'sort': 241},
    {'code': 'ops.wh_transfer.delete', 'name_ar': 'سند تحويل مخزني - حذف',   'category': 'ops', 'sort': 242},
    {'code': 'ops.wh_transfer.print',  'name_ar': 'سند تحويل مخزني - طباعة', 'category': 'ops', 'sort': 243},
    {'code': 'ops.wh_transfer.post',   'name_ar': 'سند تحويل مخزني - ترحيل', 'category': 'ops', 'sort': 244},

    // ops - wh_supply
    {'code': 'ops.wh_supply.create', 'name_ar': 'سند توريد مخزني - إضافة', 'category': 'ops', 'sort': 250},
    {'code': 'ops.wh_supply.edit',   'name_ar': 'سند توريد مخزني - تعديل', 'category': 'ops', 'sort': 251},
    {'code': 'ops.wh_supply.delete', 'name_ar': 'سند توريد مخزني - حذف',   'category': 'ops', 'sort': 252},
    {'code': 'ops.wh_supply.print',  'name_ar': 'سند توريد مخزني - طباعة', 'category': 'ops', 'sort': 253},
    {'code': 'ops.wh_supply.post',   'name_ar': 'سند توريد مخزني - ترحيل', 'category': 'ops', 'sort': 254},

    // ops - wh_issue
    {'code': 'ops.wh_issue.create', 'name_ar': 'سند صرف مخزني - إضافة', 'category': 'ops', 'sort': 260},
    {'code': 'ops.wh_issue.edit',   'name_ar': 'سند صرف مخزني - تعديل', 'category': 'ops', 'sort': 261},
    {'code': 'ops.wh_issue.delete', 'name_ar': 'سند صرف مخزني - حذف',   'category': 'ops', 'sort': 262},
    {'code': 'ops.wh_issue.print',  'name_ar': 'سند صرف مخزني - طباعة', 'category': 'ops', 'sort': 263},
    {'code': 'ops.wh_issue.post',   'name_ar': 'سند صرف مخزني - ترحيل', 'category': 'ops', 'sort': 264},

    // ops - wh_supply_return
    {'code': 'ops.wh_supply_return.create', 'name_ar': 'مردود توريد مخزني - إضافة', 'category': 'ops', 'sort': 270},
    {'code': 'ops.wh_supply_return.edit',   'name_ar': 'مردود توريد مخزني - تعديل', 'category': 'ops', 'sort': 271},
    {'code': 'ops.wh_supply_return.delete', 'name_ar': 'مردود توريد مخزني - حذف',   'category': 'ops', 'sort': 272},
    {'code': 'ops.wh_supply_return.print',  'name_ar': 'مردود توريد مخزني - طباعة', 'category': 'ops', 'sort': 273},
    {'code': 'ops.wh_supply_return.post',   'name_ar': 'مردود توريد مخزني - ترحيل', 'category': 'ops', 'sort': 274},

    // ops - wh_issue_return
    {'code': 'ops.wh_issue_return.create', 'name_ar': 'مردودات صرف مخزني - إضافة', 'category': 'ops', 'sort': 280},
    {'code': 'ops.wh_issue_return.edit',   'name_ar': 'مردودات صرف مخزني - تعديل', 'category': 'ops', 'sort': 281},
    {'code': 'ops.wh_issue_return.delete', 'name_ar': 'مردودات صرف مخزني - حذف',   'category': 'ops', 'sort': 282},
    {'code': 'ops.wh_issue_return.print',  'name_ar': 'مردودات صرف مخزني - طباعة', 'category': 'ops', 'sort': 283},
    {'code': 'ops.wh_issue_return.post',   'name_ar': 'مردودات صرف مخزني - ترحيل', 'category': 'ops', 'sort': 284},

    // ops - purchase_request
    {'code': 'ops.purchase_request.create', 'name_ar': 'طلب شراء - إضافة', 'category': 'ops', 'sort': 290},
    {'code': 'ops.purchase_request.edit',   'name_ar': 'طلب شراء - تعديل', 'category': 'ops', 'sort': 291},
    {'code': 'ops.purchase_request.delete', 'name_ar': 'طلب شراء - حذف',   'category': 'ops', 'sort': 292},
    {'code': 'ops.purchase_request.print',  'name_ar': 'طلب شراء - طباعة', 'category': 'ops', 'sort': 293},

    // ops - inventory_count
    {'code': 'ops.inventory_count.create', 'name_ar': 'محضر جرد مخزني - إضافة', 'category': 'ops', 'sort': 300},
    {'code': 'ops.inventory_count.edit',   'name_ar': 'محضر جرد مخزني - تعديل', 'category': 'ops', 'sort': 301},
    {'code': 'ops.inventory_count.delete', 'name_ar': 'محضر جرد مخزني - حذف',   'category': 'ops', 'sort': 302},
    {'code': 'ops.inventory_count.print',  'name_ar': 'محضر جرد مخزني - طباعة', 'category': 'ops', 'sort': 303},
    {'code': 'ops.inventory_count.post',   'name_ar': 'محضر جرد مخزني - ترحيل', 'category': 'ops', 'sort': 304},

    // reports
    {'code': 'reports.operation_movement', 'name_ar': 'حركة العملية',           'category': 'reports', 'sort': 400},
    {'code': 'reports.pos_movement',       'name_ar': 'حركة نقاط البيع',        'category': 'reports', 'sort': 401},
    {'code': 'reports.cash_movement',      'name_ar': 'حركة الصناديق',          'category': 'reports', 'sort': 402},
    {'code': 'reports.customer_movement',  'name_ar': 'حركة العملاء',           'category': 'reports', 'sort': 403},
    {'code': 'reports.supplier_movement',  'name_ar': 'حركة الموردين',          'category': 'reports', 'sort': 404},
    {'code': 'reports.entry_movement',     'name_ar': 'حركة القيود',            'category': 'reports', 'sort': 405},
    {'code': 'reports.direct_sales',       'name_ar': 'حركة المبيعات المباشرة', 'category': 'reports', 'sort': 406},
    {'code': 'reports.account_statement',  'name_ar': 'كشف حساب',               'category': 'reports', 'sort': 407},
    {'code': 'reports.cost_center',        'name_ar': 'كشف مركز تكلفة',         'category': 'reports', 'sort': 408},
    {'code': 'reports.account_balances',   'name_ar': 'أرصدة الحسابات',         'category': 'reports', 'sort': 409},
    {'code': 'reports.trial_balance',      'name_ar': 'ميزان المراجعة',         'category': 'reports', 'sort': 410},
    {'code': 'reports.profit_loss',        'name_ar': 'الأرباح والخسائر',       'category': 'reports', 'sort': 411},
    {'code': 'reports.balance_sheet',      'name_ar': 'الميزانية العمومية',     'category': 'reports', 'sort': 412},
    {'code': 'reports.item_card',          'name_ar': 'بطاقة الصنف',            'category': 'reports', 'sort': 413},
    {'code': 'reports.item_movement',      'name_ar': 'حركة الأصناف',           'category': 'reports', 'sort': 414},
    {'code': 'reports.stock_movement',     'name_ar': 'حركة المخزون',           'category': 'reports', 'sort': 415},
    {'code': 'reports.item_balance',       'name_ar': 'رصيد الأصناف',           'category': 'reports', 'sort': 416},
    {'code': 'reports.item_party',         'name_ar': 'حركة الأصناف لجهة',      'category': 'reports', 'sort': 417},
    {'code': 'reports.stock_sales',        'name_ar': 'المخزون والمبيعات',      'category': 'reports', 'sort': 418},
    {'code': 'reports.item_costs',         'name_ar': 'تكاليف الأصناف',         'category': 'reports', 'sort': 419},
    {'code': 'reports.reserved_items',     'name_ar': 'الأصناف المحجوزة',       'category': 'reports', 'sort': 420},
    {'code': 'reports.expired_items',      'name_ar': 'الأصناف المنتهية',       'category': 'reports', 'sort': 421},
    {'code': 'reports.reorder_items',      'name_ar': 'الأصناف وحد الطلب',      'category': 'reports', 'sort': 422},
    {'code': 'reports.due_checks',         'name_ar': 'الشيكات المستحقة',       'category': 'reports', 'sort': 423},
    {'code': 'reports.due_installments',   'name_ar': 'الأقساط المستحقة',       'category': 'reports', 'sort': 424},
    {'code': 'reports.alerts',             'name_ar': 'التنبيهات',              'category': 'reports', 'sort': 425},
    {'code': 'reports.summary',            'name_ar': 'الخلاصة',                'category': 'reports', 'sort': 426},

    // settings
    {'code': 'settings.system',           'name_ar': 'تفضيلات النظام',       'category': 'settings', 'sort': 500},
    {'code': 'settings.currencies',       'name_ar': 'عملات النظام',         'category': 'settings', 'sort': 501},
    {'code': 'settings.sms',              'name_ar': 'تهيئة الرسائل القصيرة', 'category': 'settings', 'sort': 502},
    {'code': 'settings.branches',         'name_ar': 'بيانات الفروع',        'category': 'settings', 'sort': 503},
    {'code': 'settings.departments',      'name_ar': 'بيانات الأقسام',       'category': 'settings', 'sort': 504},
    {'code': 'settings.chart_of_accounts','name_ar': 'الدليل المحاسبي',      'category': 'settings', 'sort': 505},
    {'code': 'settings.cost_centers',     'name_ar': 'مراكز التكلفة',        'category': 'settings', 'sort': 506},
    {'code': 'settings.intermediate',     'name_ar': 'الحسابات الوسيطة',     'category': 'settings', 'sort': 507},
    {'code': 'settings.cashboxes',        'name_ar': 'بيانات الصناديق',      'category': 'settings', 'sort': 508},
    {'code': 'settings.banks',            'name_ar': 'بيانات البنوك',        'category': 'settings', 'sort': 509},
    {'code': 'settings.warehouses',       'name_ar': 'بيانات المخازن',       'category': 'settings', 'sort': 510},
    {'code': 'settings.suppliers',        'name_ar': 'بيانات الموردين',      'category': 'settings', 'sort': 511},
    {'code': 'settings.customers',        'name_ar': 'بيانات العملاء',       'category': 'settings', 'sort': 512},
    {'code': 'settings.pos',              'name_ar': 'بيانات نقاط البيع',    'category': 'settings', 'sort': 513},
    {'code': 'settings.credit_cards',     'name_ar': 'بيانات بطائق الإئتمان','category': 'settings', 'sort': 514},
    {'code': 'settings.parties',          'name_ar': 'بيانات الجهات',        'category': 'settings', 'sort': 515},
    {'code': 'settings.item_groups',      'name_ar': 'مجموعات الأصناف',      'category': 'settings', 'sort': 516},
    {'code': 'settings.items',            'name_ar': 'بيانات الأصناف',       'category': 'settings', 'sort': 517},

    // sec
    {'code': 'sec.user_permissions', 'name_ar': 'صلاحيات المستخدمين',   'category': 'sec', 'sort': 600},
    {'code': 'sec.monitor',          'name_ar': 'شاشة المراقبة',         'category': 'sec', 'sort': 601},
    {'code': 'sec.daily_close',      'name_ar': 'الإقفال اليومي',        'category': 'sec', 'sort': 602},
    {'code': 'sec.monthly_close',    'name_ar': 'الإقفال الشهري',        'category': 'sec', 'sort': 603},
    {'code': 'sec.fiscal_close',     'name_ar': 'إقفال السنة المالية',   'category': 'sec', 'sort': 604},
    {'code': 'sec.review_post',      'name_ar': 'مراجعة وترحيل الحركات', 'category': 'sec', 'sort': 605},
    {'code': 'sec.posted_movements', 'name_ar': 'الحركات المرحلة',       'category': 'sec', 'sort': 606},
    {'code': 'sec.sync_movements',   'name_ar': 'تزامن الحركات',         'category': 'sec', 'sort': 607},
    {'code': 'sec.import_movements', 'name_ar': 'استيراد الحركات',       'category': 'sec', 'sort': 608},
    {'code': 'sec.import_data',      'name_ar': 'إستيراد البيانات',      'category': 'sec', 'sort': 609},
    {'code': 'sec.export_data',      'name_ar': 'تصدير البيانات',        'category': 'sec', 'sort': 610},
    {'code': 'sec.restore_backup',   'name_ar': 'إسترجاع النسخة',        'category': 'sec', 'sort': 611},
    {'code': 'sec.backup',           'name_ar': 'النسخ الإحتياطي',       'category': 'sec', 'sort': 612},
    {'code': 'sec.mobile_sync',      'name_ar': 'مزامنة موبايل',         'category': 'sec', 'sort': 613},

    // help
    {'code': 'help.text_assistant', 'name_ar': 'مساعد النص',  'category': 'help', 'sort': 700},
    {'code': 'help.about',          'name_ar': 'عن النظام',    'category': 'help', 'sort': 701},

    // ═══════════════════════════════════════════════════════
    // grants (صلاحيات المنح والإلغاء — الرقابة الدقيقة)
    // المصدر: تبويب "صلاحيات المنح-الإلغاء" من BetaSys
    // ملاحظة: 33 صلاحية مستشفيات (085-117) مستثناة نهائياً
    // ═══════════════════════════════════════════════════════

    // ── 001-021: التحكم الجذري ──
    {'code': 'grants.001_edit_entries',            'name_ar': 'إمكانية تعديل المدخلات',              'category': 'grants', 'sort': 900},
    {'code': 'grants.002_delete_entries',          'name_ar': 'إمكانية حذف المدخلات',                'category': 'grants', 'sort': 901},
    {'code': 'grants.003_search',                  'name_ar': 'إمكانية البحث',                        'category': 'grants', 'sort': 902},
    {'code': 'grants.004_print',                   'name_ar': 'إمكانية الطباعة',                     'category': 'grants', 'sort': 903},
    {'code': 'grants.005_arrows_navigation',       'name_ar': 'إمكانية الإستعراض بالأسهم',           'category': 'grants', 'sort': 904},
    {'code': 'grants.006_credit_sales',            'name_ar': 'إمكانية البيع بالأجل',                'category': 'grants', 'sort': 905},
    {'code': 'grants.007_cash_payments',           'name_ar': 'إمكانية التعامل نقداً',                'category': 'grants', 'sort': 906},
    {'code': 'grants.008_check_payments',          'name_ar': 'إمكانية التعامل بشيك',                'category': 'grants', 'sort': 907},
    {'code': 'grants.009_change_movement_number',  'name_ar': 'إمكانية تغيير رقم الحركة',            'category': 'grants', 'sort': 908},
    {'code': 'grants.010_change_data_number',      'name_ar': 'إمكانية تغيير رقم البيانات',          'category': 'grants', 'sort': 909},
    {'code': 'grants.011_change_movement_date',    'name_ar': 'إمكانية تغيير تاريخ الحركة',          'category': 'grants', 'sort': 910},
    {'code': 'grants.012_change_currency_rate',    'name_ar': 'إمكانية تغيير سعر الصرف للعملة',      'category': 'grants', 'sort': 911},
    {'code': 'grants.013_cash_receipt',            'name_ar': 'إمكانية التعامل نقداً بسند قبض',      'category': 'grants', 'sort': 912},
    {'code': 'grants.014_change_sale_price',       'name_ar': 'إمكانية تغيير سعر البيع للصنف',       'category': 'grants', 'sort': 913},
    {'code': 'grants.015_sales_discount',          'name_ar': 'إمكانية التخفيض في المبيعات',         'category': 'grants', 'sort': 914},
    {'code': 'grants.016_sell_below_cost',         'name_ar': 'إمكانية البيع بأقل من سعر التكلفة',  'category': 'grants', 'sort': 915},
    {'code': 'grants.017_change_sales_bonus',      'name_ar': 'إمكانية تغيير بونص المبيعات',         'category': 'grants', 'sort': 916},
    {'code': 'grants.018_enter_sales_tax',         'name_ar': 'إمكانية إدخال ضريبة المبيعات',        'category': 'grants', 'sort': 917},
    {'code': 'grants.019_line_discount',           'name_ar': 'إمكانية الخصم السطري',                'category': 'grants', 'sort': 918},
    {'code': 'grants.020_duplicate_reference',     'name_ar': 'إمكانية تكرار رقم المرجع',            'category': 'grants', 'sort': 919},
    {'code': 'grants.021_auto_alerts',             'name_ar': 'إظهار تقارير التنبيهات تلقائياً',      'category': 'grants', 'sort': 920},

    // ── 022-042: تجاوزات الإدخال ──
    {'code': 'grants.022_auto_add',                'name_ar': 'إمكانية الإضافة تلقائياً',            'category': 'grants', 'sort': 921},
    {'code': 'grants.023_log_tasks',               'name_ar': 'إمكانية تسجيل المهام',                'category': 'grants', 'sort': 922},
    {'code': 'grants.024_log_notes',               'name_ar': 'إمكانية تسجيل الملاحظات',             'category': 'grants', 'sort': 923},
    {'code': 'grants.025_override_credit_limit',   'name_ar': 'إمكانية تجاوز سقف حد الإئتمان',       'category': 'grants', 'sort': 924},
    {'code': 'grants.026_skip_reference_input',    'name_ar': 'عدم المطالبة بإدخال رقم المرجع',      'category': 'grants', 'sort': 925},
    {'code': 'grants.027_skip_salesman_input',     'name_ar': 'عدم المطالبة بإدخال رقم المندوب',     'category': 'grants', 'sort': 926},
    {'code': 'grants.028_skip_collector_input',    'name_ar': 'عدم المطالبة بإدخال رقم المحصل',      'category': 'grants', 'sort': 927},
    {'code': 'grants.029_skip_region_input',       'name_ar': 'عدم المطالبة بإدخال رقم المنطقة',     'category': 'grants', 'sort': 928},
    {'code': 'grants.030_skip_party_input',        'name_ar': 'عدم المطالبة بإدخال رقم الجهة',       'category': 'grants', 'sort': 929},
    {'code': 'grants.031_skip_notes_input',        'name_ar': 'عدم المطالبة بإدخال الملاحظات',       'category': 'grants', 'sort': 930},
    {'code': 'grants.032_skip_cost_center_input',  'name_ar': 'عدم المطالبة بإدخال مركز التكلفة',   'category': 'grants', 'sort': 931},
    {'code': 'grants.033_close_purchase_orders',   'name_ar': 'إمكانية إقفال أوامر الشراء',          'category': 'grants', 'sort': 932},
    {'code': 'grants.034_change_expiry_date',      'name_ar': 'إمكانية تغيير تاريخ الإنتهاء',        'category': 'grants', 'sort': 933},
    {'code': 'grants.035_edit_specific_field',     'name_ar': 'إمكانية تعديل حقل معين',              'category': 'grants', 'sort': 934},
    {'code': 'grants.036_edit_with_secure_code',   'name_ar': 'إمكانية التعديل برمز الحماية',        'category': 'grants', 'sort': 935},
    {'code': 'grants.037_delete_with_secure_code', 'name_ar': 'إمكانية الحذف برمز الحماية',          'category': 'grants', 'sort': 936},
    {'code': 'grants.038_post_movements',          'name_ar': 'إمكانية ترحيل الحركات',               'category': 'grants', 'sort': 937},
    {'code': 'grants.039_change_password',         'name_ar': 'إمكانية تغيير كلمة المرور',           'category': 'grants', 'sort': 938},
    {'code': 'grants.040_change_fiscal_year',      'name_ar': 'إمكانية تغيير السنة المالية',         'category': 'grants', 'sort': 939},
    {'code': 'grants.041_close_accounts',          'name_ar': 'إمكانية إقفال الحسابات',              'category': 'grants', 'sort': 940},
    {'code': 'grants.042_close_fiscal_year',       'name_ar': 'إمكانية إقفال السنة المالية',         'category': 'grants', 'sort': 941},

    // ── 043-063: أدوات النظام ──
    {'code': 'grants.043_export_movements_excel',  'name_ar': 'إمكانية تصدير الحركات إلى إكسيل',     'category': 'grants', 'sort': 942},
    {'code': 'grants.044_import_movements_excel',  'name_ar': 'إمكانية استيراد الحركات من إكسيل',    'category': 'grants', 'sort': 943},
    {'code': 'grants.045_create_backup',           'name_ar': 'إمكانية إنشاء نسخة إحتياطية',         'category': 'grants', 'sort': 944},
    {'code': 'grants.046_restore_backup',          'name_ar': 'إمكانية إسترجاع نسخة إحتياطية',       'category': 'grants', 'sort': 945},
    {'code': 'grants.047_export_data',             'name_ar': 'إمكانية تصدير البيانات',              'category': 'grants', 'sort': 946},
    {'code': 'grants.048_import_data',             'name_ar': 'إمكانية إستيراد البيانات',            'category': 'grants', 'sort': 947},
    {'code': 'grants.049_close_periods',           'name_ar': 'إمكانية إقفال الفترات',               'category': 'grants', 'sort': 948},
    {'code': 'grants.050_check_item_balance',      'name_ar': 'فحص رصيد الأصناف',                    'category': 'grants', 'sort': 949},
    {'code': 'grants.051_show_balance_on_click',   'name_ar': 'إظهار شاشة الأرصدة عند النقر على الكمية', 'category': 'grants', 'sort': 950},
    {'code': 'grants.052_add_data',                'name_ar': 'إمكانية إضافة البيانات',              'category': 'grants', 'sort': 951},
    {'code': 'grants.053_reprint_movement',        'name_ar': 'إمكانية إعادة طباعة الحركة',          'category': 'grants', 'sort': 952},
    {'code': 'grants.054_auto_print_message',      'name_ar': 'إظهار رسالة للطباعة التلقائية',       'category': 'grants', 'sort': 953},
    {'code': 'grants.055_update_system',           'name_ar': 'إمكانية تحديث النظام',                'category': 'grants', 'sort': 954},
    {'code': 'grants.056_view_monitor_screen',     'name_ar': 'استعراض شاشة المراقبة',               'category': 'grants', 'sort': 955},
    {'code': 'grants.057_view_posted_movements',   'name_ar': 'استعراض الحركات المرحلة',             'category': 'grants', 'sort': 956},
    {'code': 'grants.058_sync_movements_screen',   'name_ar': 'شاشة تزامن الحركات',                  'category': 'grants', 'sort': 957},
    {'code': 'grants.059_system_check',            'name_ar': 'إمكانية فحص النظام',                  'category': 'grants', 'sort': 958},
    {'code': 'grants.060_show_cost_price',         'name_ar': 'إظهار سعر التكلفة',                   'category': 'grants', 'sort': 959},
    {'code': 'grants.061_copy_paste_rows',         'name_ar': 'إمكانية نسخ الصفوف والأعمدة',         'category': 'grants', 'sort': 960},
    {'code': 'grants.062_cancel_period_close',     'name_ar': 'إمكانية إلغاء إقفال فترة',            'category': 'grants', 'sort': 961},
    {'code': 'grants.063_cancel_posting',          'name_ar': 'إمكانية إلغاء الترحيل',               'category': 'grants', 'sort': 962},

    // ── 064-084: الترحيل والبيانات ──
    {'code': 'grants.064_change_date_posting',     'name_ar': 'إمكانية تغيير التاريخ من شاشة الترحيل', 'category': 'grants', 'sort': 963},
    {'code': 'grants.065_change_data_posting',     'name_ar': 'إمكانية تغيير البيانات من الترحيل',   'category': 'grants', 'sort': 964},
    {'code': 'grants.066_edit_account_name',       'name_ar': 'إمكانية تعديل اسم الحساب أو عملية الحساب', 'category': 'grants', 'sort': 965},
    {'code': 'grants.067_edit_item_name',          'name_ar': 'إمكانية تعديل اسم الصنف',             'category': 'grants', 'sort': 966},
    {'code': 'grants.068_change_units_sales',      'name_ar': 'إمكانية تغيير الوحدات في المبيعات',   'category': 'grants', 'sort': 967},
    {'code': 'grants.069_final_posting',           'name_ar': 'إمكانية الترحيل النهائي',             'category': 'grants', 'sort': 968},
    {'code': 'grants.070_skip_bonus_check',        'name_ar': 'السماح بتجاهل فحص التخفيض للبونص',    'category': 'grants', 'sort': 969},
    {'code': 'grants.071_force_credit_special',    'name_ar': 'البيع بالسعر الخاص للأجل إجباري',     'category': 'grants', 'sort': 970},
    {'code': 'grants.072_show_sale_price_list',    'name_ar': 'إمكانية إظهار قائمة سعر البيع',       'category': 'grants', 'sort': 971},
    {'code': 'grants.073_retail_price_sales',      'name_ar': 'إمكانية البيع بسعر التجزئة',          'category': 'grants', 'sort': 972},
    {'code': 'grants.074_special_price_sales',     'name_ar': 'إمكانية البيع بالسعر الخاص',          'category': 'grants', 'sort': 973},
    {'code': 'grants.075_view_account_notes',      'name_ar': 'إمكانية استعراض الملاحظات للحساب',    'category': 'grants', 'sort': 974},
    {'code': 'grants.076_view_branch_sales',       'name_ar': 'إمكانية استعراض المبيعات للفروع',     'category': 'grants', 'sort': 975},
    {'code': 'grants.077_view_inventory_reports',  'name_ar': 'إمكانية استعراض تقارير التقييم للمخزون', 'category': 'grants', 'sort': 976},
    {'code': 'grants.078_show_total_column',       'name_ar': 'إظهار عمود الإجمالي في التقارير والبحث', 'category': 'grants', 'sort': 977},
    {'code': 'grants.079_check_new_mov_number',    'name_ar': 'فحص تاريخ رقم الحركة الجديدة',        'category': 'grants', 'sort': 978},
    {'code': 'grants.080_auto_sales_bonus',        'name_ar': 'إظهار بونص المبيعات تلقائياً',         'category': 'grants', 'sort': 979},
    {'code': 'grants.081_original_print',          'name_ar': 'طباعة طبق الأصل عند إعادة الطباعة',   'category': 'grants', 'sort': 980},
    {'code': 'grants.082_account_details_report',  'name_ar': 'إمكانية إصدار تقرير مفردات الحسابات', 'category': 'grants', 'sort': 981},
    {'code': 'grants.083_daily_debit_report',      'name_ar': 'إمكانية إصدار تقرير حركة اليومية مدين', 'category': 'grants', 'sort': 982},
    {'code': 'grants.084_daily_credit_report',     'name_ar': 'إمكانية إصدار تقرير حركة اليومية دائن', 'category': 'grants', 'sort': 983},

    // ⚠️ 085-117: محذوفة نهائياً (صلاحيات المستشفيات — لا حاجة لها)

    // ── 118-126: تكميلية ──
    {'code': 'grants.118_special_price_sale_2',    'name_ar': 'إمكانية البيع بالسعر الخاص',          'category': 'grants', 'sort': 1017},
    {'code': 'grants.119_show_delete_sales_btn',   'name_ar': 'إظهار زر الإزالة في المبيعات',        'category': 'grants', 'sort': 1018},
    {'code': 'grants.120_log_report_view',         'name_ar': 'تسجيل حدث استعراض التقارير',          'category': 'grants', 'sort': 1019},
    {'code': 'grants.121_show_branch_supply_bal',  'name_ar': 'إظهار رصيد الفرع في طلب التوريد',     'category': 'grants', 'sort': 1020},
    {'code': 'grants.122_multi_branch_query',      'name_ar': 'إمكانية الاستعلام لأكثر من فرع',      'category': 'grants', 'sort': 1021},
    {'code': 'grants.123_print_posted_only',       'name_ar': 'طباعة التقارير التي حالتها مرحلة فقط','category': 'grants', 'sort': 1022},
    {'code': 'grants.124_check_duplicate_ref',     'name_ar': 'فحص تكرار رقم المرجع في المبيعات',   'category': 'grants', 'sort': 1023},
    {'code': 'grants.125_force_cost_floor',        'name_ar': 'منع البيع بأقل من سعر التكلفة إجباري', 'category': 'grants', 'sort': 1024},
    {'code': 'grants.126_auto_show_warehouse',     'name_ar': 'إظهار رقم المخزن والصندوق تلقائياً',  'category': 'grants', 'sort': 1025},

    // app (صلاحيات خاصة بنظام البركة - إضافة)
    {'code': 'app.customers.view',    'name_ar': 'عرض العملاء',      'category': 'app', 'sort': 800},
    {'code': 'app.products.view',     'name_ar': 'عرض الأصناف',       'category': 'app', 'sort': 801},
    {'code': 'app.session.open',      'name_ar': 'فتح وردية',         'category': 'app', 'sort': 802},
    {'code': 'app.session.close_own', 'name_ar': 'إغلاق ورديتي',      'category': 'app', 'sort': 803},
    {'code': 'app.settings.themes',   'name_ar': 'تغيير الثيمات',     'category': 'app', 'sort': 804},
  ];

  /// v9.4.5a: all + userProfilePermissions مدموجة
  static List<Map<String, dynamic>> get allExtended => [
    ...all,
    ...userProfilePermissions,
    ...masterDataPermissions,
  ];

  /// v9.4.5b-LITE-FIX: دمج كل تعيينات الأدوار مع الحفاظ على *ALL* كقيمة وحيدة
  static Map<String, List<String>> get allRoleAssignments {
    final merged = <String, List<String>>{};

    // دالة مساعدة: تطبيق *ALL* له الأولوية المطلقة
    void merge(String key, List<String> values) {
      // إذا كانت القائمة تحتوي *ALL* — تُلغى كل الإضافات الأخرى
      if (values.contains('*ALL*')) {
        merged[key] = ['*ALL*'];
        return;
      }
      // إذا كانت المفتاح موجوداً بـ *ALL* — لا نضيف
      if (merged[key] != null && merged[key]!.contains('*ALL*')) {
        return;
      }
      merged.putIfAbsent(key, () => <String>[]);
      merged[key]!.addAll(values);
    }

    roleDefaults.forEach(merge);
    userProfileRoleAssignments.forEach(merge);
    masterDataRoleAssignments.forEach(merge);

    // إزالة التكرار (مع الحفاظ على *ALL*)
    merged.forEach((k, v) {
      if (v.contains('*ALL*')) {
        merged[k] = ['*ALL*'];
      } else {
        merged[k] = v.toSet().toList();
      }
    });

    return merged;
  }

  // ============================================================
  // v9.4.5b-LITE — master_data Expansion (~42)
  // Added: 2026-10-10
  // ============================================================
  static const List<Map<String, dynamic>> masterDataPermissions = [
    // ── help.run (1) ──
    {'key': 'help.run',                              'name_ar': 'BetaSys Run',                  'name_en': 'BetaSys Run',                  'category': 'help'},

    // ── regions (4) ──
    {'key': 'settings.regions.view',                 'name_ar': 'عرض المناطق',                  'name_en': 'View Regions',                 'category': 'settings'},
    {'key': 'settings.regions.create',               'name_ar': 'إضافة منطقة',                  'name_en': 'Create Region',                'category': 'settings'},
    {'key': 'settings.regions.edit',                 'name_ar': 'تعديل منطقة',                  'name_en': 'Edit Region',                  'category': 'settings'},
    {'key': 'settings.regions.delete',               'name_ar': 'حذف منطقة',                    'name_en': 'Delete Region',                'category': 'settings'},

    // ── employees (6) ──
    {'key': 'settings.employees.view',               'name_ar': 'عرض الموظفين',                 'name_en': 'View Employees',               'category': 'settings'},
    {'key': 'settings.employees.create',             'name_ar': 'إضافة موظف',                   'name_en': 'Create Employee',              'category': 'settings'},
    {'key': 'settings.employees.edit',               'name_ar': 'تعديل موظف',                   'name_en': 'Edit Employee',                'category': 'settings'},
    {'key': 'settings.employees.delete',             'name_ar': 'حذف موظف',                     'name_en': 'Delete Employee',              'category': 'settings'},
    {'key': 'settings.employees.assign_user',        'name_ar': 'ربط الموظف بمستخدم',            'name_en': 'Assign User to Employee',      'category': 'settings'},
    {'key': 'settings.employees.import',             'name_ar': 'استيراد الموظفين',              'name_en': 'Import Employees',             'category': 'settings'},

    // ── budget (5) ──
    {'key': 'settings.budget.view',                  'name_ar': 'عرض الموازنة التقديرية',       'name_en': 'View Budget',                  'category': 'settings'},
    {'key': 'settings.budget.create',                'name_ar': 'إضافة بند موازنة',             'name_en': 'Create Budget Item',           'category': 'settings'},
    {'key': 'settings.budget.edit',                  'name_ar': 'تعديل بند موازنة',             'name_en': 'Edit Budget Item',             'category': 'settings'},
    {'key': 'settings.budget.delete',                'name_ar': 'حذف بند موازنة',               'name_en': 'Delete Budget Item',           'category': 'settings'},
    {'key': 'settings.budget.approve',               'name_ar': 'اعتماد الموازنة',              'name_en': 'Approve Budget',               'category': 'settings'},

    // ── account_groups (4) ──
    {'key': 'settings.account_groups.view',          'name_ar': 'عرض مجموعات الحسابات',         'name_en': 'View Account Groups',          'category': 'settings'},
    {'key': 'settings.account_groups.create',        'name_ar': 'إضافة مجموعة حسابات',          'name_en': 'Create Account Group',         'category': 'settings'},
    {'key': 'settings.account_groups.edit',          'name_ar': 'تعديل مجموعة حسابات',          'name_en': 'Edit Account Group',           'category': 'settings'},
    {'key': 'settings.account_groups.delete',        'name_ar': 'حذف مجموعة حسابات',            'name_en': 'Delete Account Group',         'category': 'settings'},

    // ── chart_of_accounts expansion (15) — view موجودة مسبقاً ──
    {'key': 'settings.chart_of_accounts.view',                'name_ar': 'عرض الدليل المحاسبي',       'name_en': 'View Chart of Accounts',       'category': 'settings'},
    {'key': 'settings.chart_of_accounts.create',                'name_ar': 'إضافة حساب',                  'name_en': 'Create Account',                'category': 'settings'},
    {'key': 'settings.chart_of_accounts.edit',                  'name_ar': 'تعديل حساب',                  'name_en': 'Edit Account',                  'category': 'settings'},
    {'key': 'settings.chart_of_accounts.delete',                'name_ar': 'حذف حساب',                    'name_en': 'Delete Account',                'category': 'settings'},
    {'key': 'settings.chart_of_accounts.print',                 'name_ar': 'طباعة الدليل المحاسبي',       'name_en': 'Print Chart',                   'category': 'settings'},
    {'key': 'settings.chart_of_accounts.tree',                  'name_ar': 'عرض شجرة الحسابات',           'name_en': 'View Account Tree',             'category': 'settings'},
    {'key': 'settings.chart_of_accounts.import_excel',          'name_ar': 'استيراد الحسابات من Excel',   'name_en': 'Import from Excel',             'category': 'settings'},
    {'key': 'settings.chart_of_accounts.export_excel',          'name_ar': 'تصدير الحسابات إلى Excel',    'name_en': 'Export to Excel',               'category': 'settings'},
    {'key': 'settings.chart_of_accounts.manage_levels',         'name_ar': 'إدارة مستويات الحسابات',      'name_en': 'Manage Levels',                 'category': 'settings'},
    {'key': 'settings.chart_of_accounts.move_account',          'name_ar': 'نقل حساب',                    'name_en': 'Move Account',                  'category': 'settings'},
    {'key': 'settings.chart_of_accounts.set_opening_balance',   'name_ar': 'تعيين رصيد افتتاحي',          'name_en': 'Set Opening Balance',           'category': 'settings'},
    {'key': 'settings.chart_of_accounts.toggle_active',         'name_ar': 'تفعيل/تعطيل حساب',            'name_en': 'Toggle Active',                 'category': 'settings'},
    {'key': 'settings.chart_of_accounts.set_account_type',      'name_ar': 'تعيين نوع الحساب',            'name_en': 'Set Account Type',              'category': 'settings'},
    {'key': 'settings.chart_of_accounts.set_debit_credit',      'name_ar': 'تعيين طبيعة الحساب (مدين/دائن)', 'name_en': 'Set Debit/Credit',          'category': 'settings'},
    {'key': 'settings.chart_of_accounts.manage_supplier_accounts', 'name_ar': 'إدارة حسابات الموردين',    'name_en': 'Manage Supplier Accounts',      'category': 'settings'},
    {'key': 'settings.chart_of_accounts.manage_customer_accounts', 'name_ar': 'إدارة حسابات العملاء',    'name_en': 'Manage Customer Accounts',      'category': 'settings'},

    // ── settings.system expansion (7) — view موجودة مسبقاً ──
    {'key': 'settings.system.view',                  'name_ar': 'عرض تفضيلات النظام',         'name_en': 'View System Settings',         'category': 'settings'},
    {'key': 'settings.system.edit',                  'name_ar': 'تعديل تفضيلات النظام',         'name_en': 'Edit System Settings',         'category': 'settings'},
    {'key': 'settings.system.backup',                'name_ar': 'أخذ نسخة احتياطية',            'name_en': 'Create Backup',                'category': 'settings'},
    {'key': 'settings.system.restore',               'name_ar': 'استرجاع نسخة احتياطية',        'name_en': 'Restore Backup',               'category': 'settings'},
    {'key': 'settings.system.vacuum',                'name_ar': 'ضغط قاعدة البيانات',           'name_en': 'Vacuum Database',              'category': 'settings'},
    {'key': 'settings.system.update',                'name_ar': 'تحديث النظام',                 'name_en': 'Update System',                'category': 'settings'},
    {'key': 'settings.system.health_check',          'name_ar': 'فحص النظام',                   'name_en': 'Health Check',                 'category': 'settings'},
    {'key': 'settings.system.export_settings',       'name_ar': 'تصدير الإعدادات',              'name_en': 'Export Settings',              'category': 'settings'},
  ];

  // ============================================================
  // v9.4.5b-LITE — master_data Role Assignments
  // ============================================================
  static const Map<String, List<String>> masterDataRoleAssignments = {
    'General_Manager': ['*ALL*'],
    'Store_Manager': [
      'settings.regions.view', 'settings.regions.create', 'settings.regions.edit',
      'settings.employees.view', 'settings.employees.create', 'settings.employees.edit',
      'settings.budget.view',
      'settings.account_groups.view',
      'settings.chart_of_accounts.view', 'settings.chart_of_accounts.tree',
      'settings.chart_of_accounts.print', 'settings.chart_of_accounts.export_excel',
      'help.run',
    ],
    'Accountant': [
      'settings.regions.view',
      'settings.employees.view',
      'settings.budget.view', 'settings.budget.create', 'settings.budget.edit', 'settings.budget.approve',
      'settings.account_groups.view', 'settings.account_groups.create', 'settings.account_groups.edit',
      'settings.chart_of_accounts.view', 'settings.chart_of_accounts.create',
      'settings.chart_of_accounts.edit', 'settings.chart_of_accounts.delete',
      'settings.chart_of_accounts.print', 'settings.chart_of_accounts.tree',
      'settings.chart_of_accounts.import_excel', 'settings.chart_of_accounts.export_excel',
      'settings.chart_of_accounts.manage_levels', 'settings.chart_of_accounts.move_account',
      'settings.chart_of_accounts.set_opening_balance', 'settings.chart_of_accounts.toggle_active',
      'settings.chart_of_accounts.set_account_type', 'settings.chart_of_accounts.set_debit_credit',
      'settings.chart_of_accounts.manage_supplier_accounts', 'settings.chart_of_accounts.manage_customer_accounts',
      'settings.system.backup', 'settings.system.vacuum',
      'help.run',
    ],
    'Inventory_Clerk': [
      'settings.regions.view',
      'settings.employees.view',
      'settings.chart_of_accounts.view',
      'help.run',
    ],
    'Cashier': [],
  };
  static const List<Map<String, dynamic>> roles = [
    {'code': 'General_Manager', 'name_ar': 'المدير العام', 'is_system': 1},
    {'code': 'Store_Manager',   'name_ar': 'مدير المخزن',  'is_system': 1},
    {'code': 'Accountant',      'name_ar': 'المحاسب',      'is_system': 1},
    {'code': 'Inventory_Clerk', 'name_ar': 'أمين المخزن',  'is_system': 1},
    {'code': 'Cashier',         'name_ar': 'الكاشير',      'is_system': 1},
  ];

  static const List<String> cashierPermissions = [
    'app.customers.view',
    'app.products.view',
    'ops.sales_invoice.create',
    'ops.sales_invoice.print',
    'app.session.open',
    'app.session.close_own',
    'app.settings.themes',
  ];

  // '*ALL*' = كل الصلاحيات (يُفسَّر في SeedRunner)
  static const List<String> gmPermissions = ['*ALL*'];

  static const List<String> storeManagerPermissions = [
    // file
    'file.open_company', 'file.close_company', 'file.calculator',
    'file.change_user', 'file.change_password',
    'file.addresses', 'file.tasks', 'file.reminders',
    'file.financial_notes', 'file.notes', 'file.toolbar',
    'file.rtl_toggle', 'file.movements_bar', 'file.exit',
    // ops
    'ops.sales_invoice.create', 'ops.sales_invoice.edit', 'ops.sales_invoice.print', 'ops.sales_invoice.post',
    'ops.sales_return.create', 'ops.sales_return.edit', 'ops.sales_return.print',
    'ops.direct_sales.create', 'ops.direct_sales.edit', 'ops.direct_sales.print',
    'ops.quotation.create', 'ops.quotation.edit', 'ops.quotation.print',
    'ops.purchase_invoice.create', 'ops.purchase_invoice.edit', 'ops.purchase_invoice.print', 'ops.purchase_invoice.post',
    'ops.purchase_return.create', 'ops.purchase_return.edit', 'ops.purchase_return.print',
    'ops.receipt_voucher.create', 'ops.receipt_voucher.edit', 'ops.receipt_voucher.print', 'ops.receipt_voucher.post',
    'ops.payment_voucher.create', 'ops.payment_voucher.edit', 'ops.payment_voucher.print', 'ops.payment_voucher.post',
    'ops.journal_voucher.create', 'ops.journal_voucher.edit', 'ops.journal_voucher.print',
    'ops.opening_entry.create', 'ops.opening_entry.edit', 'ops.opening_entry.print',
    'ops.bank_notice.create', 'ops.bank_notice.edit', 'ops.bank_notice.print',
    'ops.wh_opening.create', 'ops.wh_opening.edit', 'ops.wh_opening.print', 'ops.wh_opening.post',
    'ops.wh_transfer.create', 'ops.wh_transfer.edit', 'ops.wh_transfer.print', 'ops.wh_transfer.post',
    'ops.wh_supply.create', 'ops.wh_supply.edit', 'ops.wh_supply.print', 'ops.wh_supply.post',
    'ops.wh_issue.create', 'ops.wh_issue.edit', 'ops.wh_issue.print', 'ops.wh_issue.post',
    'ops.wh_supply_return.create', 'ops.wh_supply_return.edit', 'ops.wh_supply_return.print',
    'ops.wh_issue_return.create', 'ops.wh_issue_return.edit', 'ops.wh_issue_return.print',
    'ops.purchase_request.create', 'ops.purchase_request.edit', 'ops.purchase_request.print',
    'ops.inventory_count.create', 'ops.inventory_count.edit', 'ops.inventory_count.print',
    // reports
    'reports.operation_movement', 'reports.pos_movement', 'reports.cash_movement',
    'reports.customer_movement', 'reports.supplier_movement', 'reports.entry_movement',
    'reports.direct_sales', 'reports.account_statement', 'reports.cost_center',
    'reports.account_balances', 'reports.trial_balance', 'reports.profit_loss',
    'reports.item_card', 'reports.item_movement', 'reports.stock_movement',
    'reports.item_balance', 'reports.item_party', 'reports.stock_sales',
    'reports.item_costs', 'reports.reserved_items', 'reports.expired_items',
    'reports.reorder_items', 'reports.alerts', 'reports.summary',
    // settings
    'settings.items', 'settings.item_groups', 'settings.warehouses',
    'settings.suppliers', 'settings.customers', 'settings.pos',
    'settings.cashboxes', 'settings.branches', 'settings.departments',
    // sec
    'sec.review_post', 'sec.posted_movements', 'sec.daily_close',
    'sec.monthly_close', 'sec.backup', 'sec.import_data', 'sec.export_data',
    // help
    'help.text_assistant', 'help.about',
    // app
    'app.customers.view', 'app.products.view', 'app.session.open',
    'app.session.close_own', 'app.settings.themes',
    // grants (محدودة — بدون صلاحيات النظام الحساسة)
    'grants.003_search', 'grants.004_print', 'grants.005_arrows_navigation',
    'grants.038_post_movements', 'grants.043_export_movements_excel',
    'grants.050_check_item_balance', 'grants.051_show_balance_on_click',
    'grants.058_sync_movements_screen', 'grants.060_show_cost_price',
  ];

  static const List<String> accountantPermissions = [
    // file
    'file.calculator', 'file.change_user', 'file.change_password',
    'file.change_fiscal_year', 'file.financial_notes', 'file.notes',
    'file.toolbar', 'file.rtl_toggle', 'file.exit',
    // ops (محاسبية)
    'ops.journal_voucher.create', 'ops.journal_voucher.edit', 'ops.journal_voucher.print', 'ops.journal_voucher.post',
    'ops.receipt_voucher.create', 'ops.receipt_voucher.edit', 'ops.receipt_voucher.print', 'ops.receipt_voucher.post',
    'ops.payment_voucher.create', 'ops.payment_voucher.edit', 'ops.payment_voucher.print', 'ops.payment_voucher.post',
    'ops.opening_entry.create', 'ops.opening_entry.edit', 'ops.opening_entry.print', 'ops.opening_entry.post',
    'ops.closing_entry.create', 'ops.closing_entry.edit', 'ops.closing_entry.print', 'ops.closing_entry.post',
    'ops.fx_diff_entry.create', 'ops.fx_diff_entry.edit', 'ops.fx_diff_entry.print',
    'ops.bank_notice.create', 'ops.bank_notice.edit', 'ops.bank_notice.print',
    // reports (محاسبية)
    'reports.entry_movement', 'reports.account_statement', 'reports.cost_center',
    'reports.account_balances', 'reports.trial_balance', 'reports.profit_loss',
    'reports.balance_sheet', 'reports.customer_movement', 'reports.supplier_movement',
    'reports.cash_movement', 'reports.due_checks', 'reports.due_installments',
    'reports.summary',
    // settings
    'settings.chart_of_accounts', 'settings.cost_centers', 'settings.intermediate',
    'settings.currencies', 'settings.customers', 'settings.suppliers',
    'settings.banks', 'settings.cashboxes',
    // sec
    'sec.daily_close', 'sec.monthly_close', 'sec.fiscal_close',
    'sec.review_post', 'sec.posted_movements', 'sec.backup',
    'sec.import_data', 'sec.export_data',
    // help
    'help.text_assistant', 'help.about',
    // app
    'app.customers.view', 'app.settings.themes',
    // grants
    'grants.001_edit_entries', 'grants.002_delete_entries', 'grants.003_search',
    'grants.004_print', 'grants.005_arrows_navigation',
    'grants.010_change_data_number', 'grants.011_change_movement_date',
    'grants.020_duplicate_reference', 'grants.021_auto_alerts',
    'grants.038_post_movements', 'grants.039_change_password',
    'grants.040_change_fiscal_year', 'grants.041_close_accounts',
    'grants.042_close_fiscal_year', 'grants.043_export_movements_excel',
    'grants.049_close_periods', 'grants.060_show_cost_price',
    'grants.063_cancel_posting', 'grants.064_change_date_posting',
    'grants.065_change_data_posting', 'grants.069_final_posting',
    'grants.082_account_details_report', 'grants.083_daily_debit_report',
    'grants.084_daily_credit_report',
  ];

  static const List<String> inventoryClerkPermissions = [
    // file
    'file.calculator', 'file.change_user', 'file.change_password',
    'file.tasks', 'file.toolbar', 'file.rtl_toggle', 'file.exit',
    // ops (مخزنية)
    'ops.wh_opening.create', 'ops.wh_transfer.create', 'ops.wh_supply.create',
    'ops.wh_issue.create', 'ops.wh_supply_return.create', 'ops.wh_issue_return.create',
    'ops.purchase_request.create', 'ops.inventory_count.create',
    // reports (مخزنية)
    'reports.item_card', 'reports.item_movement', 'reports.stock_movement',
    'reports.item_balance', 'reports.item_party', 'reports.stock_sales',
    'reports.item_costs', 'reports.reserved_items', 'reports.expired_items',
    'reports.reorder_items', 'reports.alerts',
    // settings
    'settings.items', 'settings.item_groups', 'settings.warehouses', 'settings.suppliers',
    // help
    'help.text_assistant', 'help.about',
    // app
    'app.customers.view', 'app.products.view', 'app.settings.themes',
    // grants
    'grants.003_search', 'grants.004_print', 'grants.005_arrows_navigation',
    'grants.050_check_item_balance', 'grants.051_show_balance_on_click',
    'grants.060_show_cost_price',
  ];

  /// خريطة الدور → مصفوفة الصلاحيات
  static const Map<String, List<String>> roleDefaults = {
    'General_Manager': gmPermissions,
    'Store_Manager': storeManagerPermissions,
    'Accountant': accountantPermissions,
    'Inventory_Clerk': inventoryClerkPermissions,
    'Cashier': cashierPermissions,
  };

  // ============================================================
  // v9.4.5a — user_profile Permissions (~20)
  // Added: 2026-10-10
  // ============================================================
  static const List<Map<String, dynamic>> userProfilePermissions = [
    {'key': 'users.view',                  'name_ar': 'عرض المستخدمين',           'name_en': 'View Users',                'category': 'user_profile'},
    {'key': 'users.create',                'name_ar': 'إضافة مستخدم جديد',       'name_en': 'Create User',               'category': 'user_profile'},
    {'key': 'users.edit',                  'name_ar': 'تعديل بيانات مستخدم',     'name_en': 'Edit User',                 'category': 'user_profile'},
    {'key': 'users.delete',                'name_ar': 'حذف مستخدم',              'name_en': 'Delete User',               'category': 'user_profile'},
    {'key': 'users.change_password',       'name_ar': 'تغيير كلمة مرور',         'name_en': 'Change Password',           'category': 'user_profile'},
    {'key': 'users.reset_password',        'name_ar': 'إعادة تعيين كلمة المرور', 'name_en': 'Reset Password',            'category': 'user_profile'},
    {'key': 'users.force_password_change', 'name_ar': 'إلزام بتغيير كلمة المرور','name_en': 'Force Password Change',     'category': 'user_profile'},
    {'key': 'users.activate',              'name_ar': 'تفعيل/تعطيل مستخدم',      'name_en': 'Activate/Deactivate User',  'category': 'user_profile'},
    {'key': 'users.assign_role',           'name_ar': 'تعيين دور للمستخدم',      'name_en': 'Assign Role',               'category': 'user_profile'},
    {'key': 'users.view_permissions',      'name_ar': 'عرض صلاحيات المستخدم',    'name_en': 'View User Permissions',     'category': 'user_profile'},
    {'key': 'users.edit_permissions',      'name_ar': 'تعديل صلاحيات المستخدم',  'name_en': 'Edit User Permissions',     'category': 'user_profile'},
    {'key': 'users.assign_branch',         'name_ar': 'تعيين فروع للمستخدم',     'name_en': 'Assign Branch',             'category': 'user_profile'},
    {'key': 'users.assign_warehouse',      'name_ar': 'تعيين مخازن للمستخدم',    'name_en': 'Assign Warehouse',          'category': 'user_profile'},
    {'key': 'users.assign_cash_register',  'name_ar': 'تعيين صناديق للمستخدم',   'name_en': 'Assign Cash Register',      'category': 'user_profile'},
    {'key': 'users.assign_pos',            'name_ar': 'تعيين نقاط بيع للمستخدم', 'name_en': 'Assign POS',                'category': 'user_profile'},
    {'key': 'users.set_discount_limit',    'name_ar': 'تحديد أعلى نسبة تخفيض',   'name_en': 'Set Discount Limit',        'category': 'user_profile'},
    {'key': 'users.set_expiry',            'name_ar': 'تحديد مدة الصلاحية',      'name_en': 'Set Account Expiry',        'category': 'user_profile'},
    {'key': 'users.view_login_history',    'name_ar': 'عرض سجل الدخول',          'name_en': 'View Login History',        'category': 'user_profile'},
    {'key': 'users.manage_sessions',       'name_ar': 'إدارة الجلسات النشطة',    'name_en': 'Manage Active Sessions',    'category': 'user_profile'},
    {'key': 'users.export',                'name_ar': 'تصدير بيانات المستخدمين', 'name_en': 'Export Users',              'category': 'user_profile'},
  ];

  // ============================================================
  // v9.4.5a — user_profile Role Assignments
  // ============================================================
  static const Map<String, List<String>> userProfileRoleAssignments = {
    'General_Manager': [
      'users.view', 'users.create', 'users.edit', 'users.delete',
      'users.change_password', 'users.reset_password', 'users.force_password_change',
      'users.activate', 'users.assign_role', 'users.view_permissions',
      'users.edit_permissions', 'users.assign_branch', 'users.assign_warehouse',
      'users.assign_cash_register', 'users.assign_pos', 'users.set_discount_limit',
      'users.set_expiry', 'users.view_login_history', 'users.manage_sessions',
      'users.export',
    ],
    'Store_Manager': [
      'users.view', 'users.create', 'users.edit',
      'users.activate', 'users.assign_role', 'users.view_permissions',
      'users.assign_branch', 'users.assign_warehouse', 'users.assign_cash_register',
      'users.assign_pos', 'users.set_discount_limit', 'users.set_expiry',
      'users.view_login_history', 'users.manage_sessions', 'users.export',
    ],
    'Accountant': [
      'users.view', 'users.view_permissions', 'users.view_login_history',
      'users.export', 'users.set_expiry',
    ],
    'Inventory_Clerk': [
      'users.view', 'users.view_permissions',
    ],
    'Cashier': [],
  };

  // v9.4.5a — user_profile Permissions (20)
  
}