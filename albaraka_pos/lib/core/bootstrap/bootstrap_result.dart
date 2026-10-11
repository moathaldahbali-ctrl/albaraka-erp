import 'package:flutter/foundation.dart';

/// v9.4.6: حالة تشغيل AppInitializer
enum BootstrapStatus {
  /// كل شيء نجح
  success,

  /// نجح جزئياً (مثلاً: Hasura أوفلاين لكن المحلي يعمل)
  partial,

  /// فشل حرج
  failed,
}

/// v9.4.6: نتيجة Bootstrap موحّدة
@immutable
class BootstrapResult {
  final BootstrapStatus status;
  final String? errorMessage;

  // ── التفاصيل ──
  final bool migrationsRan;
  final int permissionsCount;
  final int rolesCount;
  final int roleAssignmentsCount;
  final bool hasuraOnline;
  final int pendingSynced;
  final int pendingFailed;

  // ── التوقيتات ──
  final DateTime startedAt;
  final DateTime finishedAt;

  const BootstrapResult({
    required this.status,
    this.errorMessage,
    this.migrationsRan = false,
    this.permissionsCount = 0,
    this.rolesCount = 0,
    this.roleAssignmentsCount = 0,
    this.hasuraOnline = false,
    this.pendingSynced = 0,
    this.pendingFailed = 0,
    required this.startedAt,
    required this.finishedAt,
  });

  /// مدة التشغيل
  Duration get duration => finishedAt.difference(startedAt);

  /// هل نجح كلياً؟
  bool get isSuccess => status == BootstrapStatus.success;

  /// هل يعمل محلياً على الأقل؟
  bool get isOperational =>
      status == BootstrapStatus.success || status == BootstrapStatus.partial;

  /// نسخة سريعة للفشل
  factory BootstrapResult.failed(
    String error, {
    required DateTime startedAt,
    DateTime? finishedAt,
  }) {
    return BootstrapResult(
      status: BootstrapStatus.failed,
      errorMessage: error,
      startedAt: startedAt,
      finishedAt: finishedAt ?? DateTime.now(),
    );
  }

  /// نسخة للنجاح الجزئي (Offline)
  factory BootstrapResult.partial({
    required DateTime startedAt,
    DateTime? finishedAt,
    required int permissionsCount,
    required int rolesCount,
    required int roleAssignmentsCount,
    String? warning,
  }) {
    return BootstrapResult(
      status: BootstrapStatus.partial,
      errorMessage: warning,
      permissionsCount: permissionsCount,
      rolesCount: rolesCount,
      roleAssignmentsCount: roleAssignmentsCount,
      hasuraOnline: false,
      startedAt: startedAt,
      finishedAt: finishedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'BootstrapResult('
        'status: $status, '
        'duration: ${duration.inMilliseconds}ms, '
        'perms: $permissionsCount, '
        'roles: $rolesCount, '
        'assigns: $roleAssignmentsCount, '
        'hasura: $hasuraOnline, '
        'synced: $pendingSynced, '
        'failed: $pendingFailed'
        ')';
  }
}

/// v9.4.6: نتيجة فحص الصحة
@immutable
class HealthStatus {
  final bool isOnline;
  final int latencyMs;
  final String? error;

  const HealthStatus({
    required this.isOnline,
    this.latencyMs = 0,
    this.error,
  });

  factory HealthStatus.offline(String error) =>
      HealthStatus(isOnline: false, error: error);

  factory HealthStatus.online(int latencyMs) =>
      HealthStatus(isOnline: true, latencyMs: latencyMs);

  @override
  String toString() =>
      'HealthStatus(online: $isOnline, latency: ${latencyMs}ms'
      '${error != null ? ', error: $error' : ''})';
}