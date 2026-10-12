import 'package:flutter/material.dart';
import '../services/permission_service.dart';

/// Widget يخفي/يعرض المحتوى حسب صلاحية معينة
class PermissionGuard extends StatelessWidget {
  final PermissionService service;
  final String userId;
  final String permissionCode;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.service,
    required this.userId,
    required this.permissionCode,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: service.hasPermission(userId, permissionCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.data == true) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}