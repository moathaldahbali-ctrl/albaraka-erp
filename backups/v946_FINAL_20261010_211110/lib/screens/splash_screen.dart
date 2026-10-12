import 'package:flutter/material.dart';
import '../core/bootstrap/bootstrap_result.dart';

/// v9.4.6: شاشة البداية — تُعرض أثناء Bootstrap
///
/// تقبل [result] (اختياري) — إذا كانت null، تعرض حالة "جاري التشغيل"
/// إذا كانت محدّدة، تعرض النتيجة النهائية
class SplashScreen extends StatelessWidget {
  final BootstrapResult? result;
  final VoidCallback? onRetry;

  const SplashScreen({
    super.key,
    this.result,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E3A5F),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── الشعار ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/logo_color.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) => Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        size: 70,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── الاسم ──
                const Text(
                  'بقالة وبهارات البركة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'البركة لنظم المعلومات',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'POS/ERP — v9.4.6',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),

                const Spacer(),

                // ── الحالة ──
                _buildStatus(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    // ── حالة: Bootstrap لم يبدأ بعد ──
    if (result == null) {
      return Column(
        children: const [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تشغيل النظام...',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      );
    }

    // ── حالة: فشل ──
    if (result!.status == BootstrapStatus.failed) {
      return Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 42,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          const Text(
            'فشل تشغيل النظام',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              result!.errorMessage ?? 'خطأ غير معروف',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // ── حالة: نجاح جزئي (Offline) ──
    if (result!.status == BootstrapStatus.partial) {
      return Column(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 32,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 12),
          const Text(
            'يعمل محلياً بدون إنترنت',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${result!.permissionsCount} صلاحية · '
            '${result!.rolesCount} أدوار',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      );
    }

    // ── حالة: نجاح ──
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 32,
          color: Colors.greenAccent,
        ),
        const SizedBox(height: 12),
        const Text(
          'جاهز',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${result!.permissionsCount} صلاحية · '
          '${result!.rolesCount} أدوار · '
          '${result!.duration.inMilliseconds}ms',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}