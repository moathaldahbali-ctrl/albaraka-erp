import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../sync/sync_manager_extension.dart';

/// نتيجة المزامنة
class SyncResult {
  final bool success;
  final int itemsSynced;
  final String message;

  const SyncResult({
    required this.success,
    required this.itemsSynced,
    required this.message,
  });
}

/// خدمة مزامنة مشتركة — تُستخدم من أي مكان في التطبيق
class UserSyncService {
  static const String _hasuraUrl =
      'https://eewgyrglhvkxjwzevcwm.hasura.ap-southeast-1.nhost.run/v1/graphql';

  /// مزامنة صلاحيات المستخدمين (override)
  static Future<SyncResult> syncUserPermissions(String secret) async {
    try {
      final httpLink = HttpLink(
        _hasuraUrl,
        defaultHeaders: {
          'x-hasura-admin-secret': secret,
        },
      );
      final client = GraphQLClient(link: httpLink, cache: GraphQLCache());

      final count = await syncUserPermissionsOverride(client);

      return SyncResult(
        success: true,
        itemsSynced: count,
        message: count > 0
            ? 'تمت مزامنة $count سجل'
            : 'لا يوجد ما يُزامن',
      );
    } catch (e) {
      debugPrint('Sync error: $e');
      return SyncResult(
        success: false,
        itemsSynced: 0,
        message: 'خطأ في المزامنة: $e',
      );
    }
  }
}
