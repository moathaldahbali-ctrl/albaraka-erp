import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:gql/language.dart' as gql_lang;
import 'package:graphql/client.dart' show gql;
import '../db/local_db.dart';

/// v9.2 — خدمة الصلاحيات
/// تُحمَّل عند تسجيل الدخول — تُخزَّن في الذاكرة + cache محلي (للأوفلاين)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final Set<String> _permissions = {};
  String? _username;
  String? _roleName;

  Set<String> get permissions => Set.unmodifiable(_permissions);
  String? get username => _username;
  String? get roleName => _roleName;
  bool get isLoaded => _username != null;

  /// فحص صلاحية واحدة
  bool has(String slug) => _permissions.contains(slug);

  /// فحص أي من الصلاحيات
  bool hasAny(List<String> slugs) => slugs.any(_permissions.contains);

  /// فحص كل الصلاحيات
  bool hasAll(List<String> slugs) => slugs.every(_permissions.contains);

  /// تحميل صلاحيات المستخدم الحالي من Hasura (مع cache محلي)
  Future<void> loadForCurrentUser(GraphQLClient client) async {
    final userId = await LocalDatabase.instance.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('[Auth] No current user id');
      clear();
      return;
    }
    _username = userId;

    // 1) حاول القراءة من Hasura
    try {
      final ok = await _loadFromHasura(client, userId);
      if (ok) {
        await _saveCache(userId);
        debugPrint('[Auth] ${_permissions.length} perms loaded for $userId (${_roleName})');
        return;
      }
    } catch (e) {
      debugPrint('[Auth] Hasura load failed: $e');
    }

    // 2) Fallback: اقرأ من cache
    final ok = await _loadCache(userId);
    if (!ok) {
      debugPrint('[Auth] No cache for $userId — صلاحيات فارغة');
    }
  }

  Future<bool> _loadFromHasura(GraphQLClient client, String userId) async {
    final q = gql(r'''
      query GetUserPerms($userId: uuid!) {
        users(where: {id: {_eq: $userId}}, limit: 1) {
          id
          user_roles {
            role {
              name
              role_permissions {
                permission { slug }
              }
            }
          }
        }
      }
    ''');

    final res = await client.query(QueryOptions(
      document: q,
      variables: {'userId': userId},
    ));

    if (res.hasException) return false;
    final users = res.data?['users'] as List<dynamic>?;
    if (users == null || users.isEmpty) return false;

    _permissions.clear();
    _roleName = null;

    final userRoles = users.first['user_roles'] as List<dynamic>? ?? [];
    for (final ur in userRoles) {
      final role = ur['role'];
      if (role == null) continue;
      _roleName ??= role['name'] as String?;
      final rps = role['role_permissions'] as List<dynamic>? ?? [];
      for (final rp in rps) {
        final perm = rp['permission'];
        if (perm == null) continue;
        final slug = perm['slug'] as String?;
        if (slug != null) _permissions.add(slug);
      }
    }
    return true;
  }

  Future<void> _saveCache(String userId) async {
    final db = await LocalDatabase.instance.database;
    final value = '${_roleName ?? ''}|${_permissions.join(',')}';
    final key = 'perms:$username';
    await db.rawInsert(
      "INSERT OR REPLACE INTO drafts_local (key, value, updated_at) VALUES (?, ?, ?)",
      [key, value, DateTime.now().toIso8601String()],
    );
  }

  Future<bool> _loadCache(String userId) async {
    try {
      final db = await LocalDatabase.instance.database;
      final rows = await db.query('drafts_local',
          where: 'key = ?', whereArgs: ['perms:$username'], limit: 1);
      if (rows.isEmpty) return false;
      final raw = rows.first['value'] as String? ?? '';
      final parts = raw.split('|');
      if (parts.length < 2) return false;
      _roleName = parts[0].isEmpty ? null : parts[0];
      _permissions
        ..clear()
        ..addAll(parts[1].split(',').where((s) => s.isNotEmpty));
      debugPrint('[Auth] ${_permissions.length} perms from cache for $username');
      return true;
    } catch (_) {
      return false;
    }
  }

  void clear() {
    _permissions.clear();
    _username = null;
    _roleName = null;
  }
}