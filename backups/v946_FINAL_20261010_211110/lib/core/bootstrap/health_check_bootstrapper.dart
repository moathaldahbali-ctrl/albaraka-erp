import 'package:graphql/client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'bootstrap_result.dart';

/// v9.4.6: فحص اتصال Hasura + كتابة الحالة
class HealthCheckBootstrapper {
  final GraphQLClient client;
  final Database db;

  HealthCheckBootstrapper({
    required this.client,
    required this.db,
  });

  Future<HealthStatus> run() async {
    final sw = Stopwatch()..start();

    try {
      final result = await client
          .query(
            QueryOptions(
              document: gql('query { currencies(limit: 1) { code } }'),
              fetchPolicy: FetchPolicy.networkOnly,
            ),
          )
          .timeout(const Duration(seconds: 5));

      sw.stop();

      if (result.hasException) {
        final err = result.exception?.toString() ?? 'unknown';
        debugPrint('[HealthCheck] Hasura error: $err');
        await _saveState('offline', '');
        return HealthStatus.offline(err);
      }

      debugPrint('[HealthCheck] Hasura OK — ${sw.elapsedMilliseconds}ms');
      await _saveState('ok', '${sw.elapsedMilliseconds}');
      return HealthStatus.online(sw.elapsedMilliseconds);
    } catch (e) {
      sw.stop();
      debugPrint('[HealthCheck] Exception: $e');
      await _saveState('offline', '');
      return HealthStatus.offline(e.toString());
    }
  }

  Future<void> _saveState(String status, String latency) async {
    await db.insert(
      'bootstrap_state',
      {
        'key': 'last_health_check',
        'value': '$status|$latency',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}