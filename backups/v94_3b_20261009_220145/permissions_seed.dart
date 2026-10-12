/// صلاحيات BetaSys الكاملة (206 صلاحية)
/// 6 أقسام: file | ops | reports | settings | sec | help
/// لا حذف - لا اختصار - كل ما ورد في المرجع الأصلي
class PermissionsSeed {
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

    // app (صلاحيات خاصة بنظام البركة - إضافة)
    {'code': 'app.customers.view',    'name_ar': 'عرض العملاء',      'category': 'app', 'sort': 800},
    {'code': 'app.products.view',     'name_ar': 'عرض الأصناف',       'category': 'app', 'sort': 801},
    {'code': 'app.session.open',      'name_ar': 'فتح وردية',         'category': 'app', 'sort': 802},
    {'code': 'app.session.close_own', 'name_ar': 'إغلاق ورديتي',      'category': 'app', 'sort': 803},
    {'code': 'app.settings.themes',   'name_ar': 'تغيير الثيمات',     'category': 'app', 'sort': 804},
  ];

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
}