import 'dart:io';

void main() {
  final ts = DateTime.now()
      .toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '')
      .substring(0, 14);

  _patchSyncManager(ts);
  _patchMain(ts);

  print('DONE. Backup suffix: .bak_$ts');
}

void _patchSyncManager(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\sync\sync_manager.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('syncPendingSessions')) {
    print('sync_manager.dart: already patched, skipping.');
    return;
  }

  const func1 = r'''
  Future<SyncResult> syncPendingSessions(GraphQLClient client) async {
    final db = await LocalDatabase.instance.database;
    final pending = await db.query(
      'register_sessions_local',
      where: 'synced_at IS NULL',
      orderBy: 'opened_at ASC',
    );

    int synced = 0;
    int failed = 0;

    for (final session in pending) {
      try {
        await _syncOneSession(db, client, session);
        synced++;
      } catch (e) {
        failed++;
        debugPrint('Session sync failed for ${session['id']}: $e');
      }
    }

    return SyncResult(synced: synced, failed: failed, total: pending.length);
  }

''';

  const func2 = r'''
  Future<void> _syncOneSession(
    Database db,
    GraphQLClient client,
    Map<String, dynamic> session,
  ) async {
    final sessionId = session['id'] as String;

    final mutation = gql(r"""
      mutation SyncSession($session: register_sessions_insert_input!) {
        insert_register_sessions_one(
          object: $session
          on_conflict: {
            constraint: register_sessions_pkey
            update_columns: [
              status, closed_at, closing_cash,
              expected_cash, difference, notes
            ]
          }
        ) {
          id
          status
        }
      }
    """);

    final variables = {
      'session': {
        'id': sessionId,
        'client_transaction_id': session['client_transaction_id'],
        'user_id': session['cashier_id'],
        'cash_register_id': session['cash_register_id'],
        'pos_device_id': session['pos_device_id'],
        'branch_id': session['branch_id'],
        'warehouse_id': session['warehouse_id'],
        'status': session['status'],
        'opened_at': session['opened_at'],
        'opening_cash': session['opening_cash'],
        if (session['closed_at'] != null) 'closed_at': session['closed_at'],
        if (session['closing_cash'] != null)
          'closing_cash': session['closing_cash'],
        if (session['expected_cash'] != null)
          'expected_cash': session['expected_cash'],
        if (session['difference'] != null) 'difference': session['difference'],
        if (session['notes'] != null) 'notes': session['notes'],
      },
    };

    final result = await client.mutate(
      MutationOptions(document: mutation, variables: variables),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    await db.update(
      'register_sessions_local',
      {'synced_at': DateTime.now().toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

''';

  content = _insertBefore(
      content, 'Future<Map<String, String>> _lookupUnitKeys(', func1);
  content = _insertBefore(
      content,
      'Future<void> _markSynced(Database db, String saleId) async {',
      func2);

  file.writeAsStringSync(content);
  print('sync_manager.dart: patched.');
}

void _patchMain(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\main.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('syncPendingSessions')) {
    print('main.dart: already patched, skipping.');
    return;
  }

  final re = RegExp(
      r'(\n[ \t]*)await[ \t]+SyncManager\.instance\.syncPendingSales\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)');
  if (!re.hasMatch(content)) {
    print('main.dart: WARNING - call site not found. Skipped.');
    return;
  }

  content = content.replaceAllMapped(re, (m) {
    final indent = m[1]!;
    final arg = m[2]!;
    return '${indent}// v7.4/8: sessions before sales (FK)\n'
        '${indent}await SyncManager.instance.syncPendingSessions($arg);\n'
        '${indent}await SyncManager.instance.syncPendingSales($arg)';
  });

  file.writeAsStringSync(content);
  print('main.dart: patched.');
}

String _insertBefore(String content, String marker, String insertion) {
  final idx = content.indexOf(marker);
  if (idx < 0) throw Exception('Marker not found: $marker');
  final lineStart = content.lastIndexOf('\n', idx) + 1;
  return content.substring(0, lineStart) +
      insertion +
      content.substring(lineStart);
}
