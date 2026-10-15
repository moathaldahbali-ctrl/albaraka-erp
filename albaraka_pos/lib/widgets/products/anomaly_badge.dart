// lib/widgets/products/anomaly_badge.dart
// -----------------------------------------------------------------
// شارة تحذيرية موحّدة لحالة الصنف/المنتج
// v8.3.8.x: يدعم both API (type=) و (reason=) للتوافق الخلفي
// -----------------------------------------------------------------
import 'package:flutter/material.dart';

enum AnomalyType {
  none,        // سليم
  needsReview, // يحتاج مراجعة
  zeroCost,    // تكلفة صفر
  lossMaking,  // خاسر (بيع <= تكلفة)
  empty,       // فارغ تماماً (0/0)
}

class AnomalyBadge extends StatelessWidget {
  final AnomalyType? type;
  final String? reason;
  final bool compact;
  final bool showLabel;

  const AnomalyBadge({
    super.key,
    this.type,
    this.reason,
    this.compact = false,
    this.showLabel = true,
  });

  AnomalyType get _resolved {
    if (type != null) return type!;
    return _parseReason(reason);
  }

  static AnomalyType _parseReason(String? r) {
    if (r == null || r.trim().isEmpty) return AnomalyType.none;
    final s = r.trim();

    // Arabic keywords first
    if (s.contains('فارغ')) return AnomalyType.empty;
    if (s.contains('تكلفة') && s.contains('صفر')) return AnomalyType.zeroCost;
    if (s.contains('خاسر') || s.contains('خسار')) return AnomalyType.lossMaking;
    if (s.contains('مراجعة')) return AnomalyType.needsReview;

    // English keywords
    final rl = s.toLowerCase();
    if (rl.contains('empty') || rl == 'zero_zero' || rl == '0/0') return AnomalyType.empty;
    if (rl.contains('zero_cost') || rl == 'zerocost' || rl == 'zero cost') return AnomalyType.zeroCost;
    if (rl.contains('loss')) return AnomalyType.lossMaking;
    if (rl.contains('review')) return AnomalyType.needsReview;

    // Fallback: something is wrong but unknown -> needsReview
    return AnomalyType.needsReview;
  }

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(_resolved);
    if (spec == null) return const SizedBox.shrink();

    final radius = BorderRadius.circular(compact ? 6 : 8);
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    final fontSize = compact ? 10.0 : 12.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: radius,
        border: Border.all(color: spec.fg.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(spec.icon, size: fontSize + 2, color: spec.fg),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              spec.label,
              style: TextStyle(
                color: spec.fg,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BadgeSpec? _specFor(AnomalyType t) {
    switch (t) {
      case AnomalyType.none:
        return null;
      case AnomalyType.needsReview:
        return _BadgeSpec(
          label: 'يحتاج مراجعة',
          fg: const Color(0xFF9A3412),
          bg: const Color(0xFFFFEDD5),
          icon: Icons.help_outline,
        );
      case AnomalyType.zeroCost:
        return _BadgeSpec(
          label: 'تكلفة صفر',
          fg: const Color(0xFF92400E),
          bg: const Color(0xFFFEF3C7),
          icon: Icons.money_off,
        );
      case AnomalyType.lossMaking:
        return _BadgeSpec(
          label: 'خاسر',
          fg: const Color(0xFF991B1B),
          bg: const Color(0xFFFEE2E2),
          icon: Icons.trending_down,
        );
      case AnomalyType.empty:
        return _BadgeSpec(
          label: 'فارغ تماماً',
          fg: const Color(0xFF374151),
          bg: const Color(0xFFE5E7EB),
          icon: Icons.block,
        );
    }
  }
}

class _BadgeSpec {
  final String label;
  final Color fg;
  final Color bg;
  final IconData icon;
  _BadgeSpec({required this.label, required this.fg, required this.bg, required this.icon});
}

// -----------------------------------------------------------------
// مساعد: تحديد نوع الحالة من القيم
// -----------------------------------------------------------------
AnomalyType classifyAnomaly({
  required num standardCost,
  required num salePrice,
}) {
  if (standardCost == 0 && salePrice == 0) return AnomalyType.empty;
  if (standardCost == 0) return AnomalyType.zeroCost;
  if (salePrice > 0 && salePrice <= standardCost) return AnomalyType.lossMaking;
  return AnomalyType.none;
}