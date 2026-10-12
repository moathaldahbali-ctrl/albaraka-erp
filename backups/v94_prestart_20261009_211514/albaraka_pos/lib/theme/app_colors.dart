// lib/theme/app_colors.dart
// لوحة ألوان البركة — مستخرجة من تصميم Betasys
// آخر تحديث: 2026-10-07

import 'package:flutter/material.dart';

/// ألوان نظام البركة
/// المرجع: تصميم Betasys Mini (2026-10-07)
class AppColors {
  AppColors._(); // منع الإنشاء

  // ─── الأساسية (من Betasys) ───
  /// برتقالي رأس الجدول
  static const Color headerOrange = Color(0xFFF39C12);
  static const Color headerRow = Color(0xFFE8A97E);

  /// كريمي الصفوف المتبادلة
  static const Color rowCream = Color(0xFFFFF8E7);

  /// أصفر حقل الكمية
  static const Color fieldYellow = Color(0xFFFFF9C4);

  /// أزرق غامق (المجموع)
  static const Color totalBlue = Color(0xFF1E3A8A);

  /// رمادي شريط الأدوات
  static const Color toolbarGrey = Color(0xFFF5F5F5);

  // ─── الحالات ───
  /// نجاح (خلفية متبقي = 0)
  static const Color successGreen = Color(0xFF4CAF50);

  /// نجاح فاتح (خلفية)
  static const Color successLight = Color(0xFFC8E6C9);

  /// تحذير (متبقي سالب)
  static const Color warningRed = Color(0xFFD32F2F);

  /// تحذير فاتح
  static const Color warningLight = Color(0xFFFFCDD2);

  // ─── المحايدة ───
  static const Color background = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFBDBDBD);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ─── الأزرق (التركيز) ───
  /// خلفية الصف المحدد في البحث (Betasys)
  static const Color selectedRow = Color(0xFF3F51B5);

  /// أزرق فاتح (خلفية بطاقات)
  static const Color infoLight = Color(0xFFE3F2FD);

  // ─── درجات إضافية ───
  /// برتقالي فاتح (تفاصيل)
  static const Color orangeLight = Color(0xFFFFE0B2);

  /// برتقالي داكن (عنوان)
  static const Color orangeDark = Color(0xFFBF6D3E);

  /// رمادي فاتح جداً (خلفيات)
  static const Color greyLight = Color(0xFFEEEEEE);

  /// رمادي متوسط (حدود خفيفة)
  static const Color greyMedium = Color(0xFF9E9E9E);
}