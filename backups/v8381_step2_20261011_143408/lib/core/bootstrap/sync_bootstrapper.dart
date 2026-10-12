import 'package:graphql/client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import '../../sync/sync_manager.dart';
import '../../sync/product_units_sync_service.dart';

/// v9.4.6: تشغيل مزامنة العناصر المعلّقة (اختياري عند الإقلاع)
class SyncBootstrapper {
  final GraphQLClient client;
  final Database db;

  SyncBootstrapper({
    required this.client,
    required this.db,
  });

  /// يُرجع [SyncSummary] بالنتائج
  Future<SyncSummary> run({bool enabled = true}) async {
    if (!enabled) {
      debugPrint('[SyncBootstrapper] Skipped (health offline)');
      return const SyncSummary(synced: 0, failed: 0);
    }

    final sw = Stopwatch()..start();
    int synced = 0;
    int failed = 0;

    try {
      final salesResult = await SyncManager.instance.syncPendingSales(client);
      synced += salesResult.synced;
      failed += salesResult.failed;
      debugPrint(
        '[SyncBootstrapper] Sales: synced=${salesResult.synced}, '
        'failed=${salesResult.failed}, total=${salesResult.total}',
      );

      final sessionsResult =
          await SyncManager.instance.syncPendingSessions(client);
      synced += sessionsResult.synced;
      failed += sessionsResult.failed;
      debugPrint(
        '[SyncBootstrapper] Sessions: synced=${sessionsResult.synced}, '
        'failed=${sessionsResult.failed}, total=${sessionsResult.total}',
      );

      // ── v8.3.7c: مزامنة الوحدات والباركود ──
      final unitsSummary =
          await ProductUnitsSyncService.instance.syncAll(client);
      synced += unitsSummary.synced;
      failed += unitsSummary.failed;
      debugPrint(
        '[SyncBootstrapper] Units+Barcodes: synced=${unitsSummary.synced}, '
        'failed=${unitsSummary.failed}, total=${unitsSummary.total}',
      );

      await _saveState(synced, failed);
    } catch (e) {
      debugPrint('[SyncBootstrapper] Exception: $e');
    }

    sw.stop();
    debugPrint(
      '[SyncBootstrapper] Done — ${sw.elapsedMilliseconds}ms, '
      'synced=$synced, failed=$failed',
    );
    return SyncSummary(synced: synced, failed: failed);
  }

  Future<void> _saveState(int synced, int failed) async {
    await db.insert(
      'bootstrap_state',
      {
        'key': 'last_sync_at',
        'value': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'bootstrap_state',
      {
        'key': 'last_sync_result',
        'value': '$synced|$failed',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

/// v9.4.6: ملخص مزامنة
class SyncSummary {
  final int synced;
  final int failed;
  const SyncSummary({required this.synced, required this.failed});
}