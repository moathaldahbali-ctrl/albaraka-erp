import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../db/local_db.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../sync/sync_manager_extension.dart';
import 'user_form_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _users = await UserService(LocalDatabase.instance)
          .getAllUsers(includeInactive: true);
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  /// v8.3.10 — safe display name (handles null + empty string)
  String _displayName(UserModel u) {
    final dn = u.displayName?.trim() ?? '';
    if (dn.isNotEmpty) return dn;
    return u.username;
  }

  /// v8.3.10 — safe initial (handles null + empty + multi-byte)
  String _initial(UserModel u) {
    final s = _displayName(u);
    if (s.isEmpty) return '?';
    return s.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المستخدمين'),
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'مزامنة',
              onPressed: _syncPermissions,
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _users.isEmpty
                ? const Center(child: Text('لا يوجد مستخدمون'))
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, i) {
                      final u = _users[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                u.isActive ? Colors.green : Colors.grey,
                            child: Text(
                              _initial(u),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(_displayName(u)),
                          subtitle: Text('${u.roleDisplay} · ${u.username}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => UserFormScreen(user: u)),
                              );
                              if (result == true) _load();
                            },
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UserFormScreen(user: u)),
                            );
                            if (result == true) _load();
                          },
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserFormScreen()),
            );
            if (result == true) _load();
          },
          backgroundColor: const Color(0xFF1E3A5F),
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('مستخدم جديد',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _syncPermissions() async {
    try {
      final httpLink = HttpLink(
        'https://eewgyrglhvkxjwzevcwm.hasura.ap-southeast-1.nhost.run/v1/graphql',
        defaultHeaders: {
          'x-hasura-admin-secret': 'ke9EdI9RHKCjEfADA6UJxCelMSRpd1AgiIATeaEAap4',
        },
      );
      final client = GraphQLClient(link: httpLink, cache: GraphQLCache());
      final count = await syncUserPermissionsOverride(client);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                count > 0 ? 'تمت مزامنة $count سجل' : 'لا يوجد ما يُزامن'),
            backgroundColor: count > 0 ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
