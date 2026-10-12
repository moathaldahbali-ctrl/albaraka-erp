import 'package:flutter/material.dart';
import '../../db/local_db.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _displayCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String? _selectedRoleId;
  List<RoleModel> _roles = [];
  bool _loadingRoles = true;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    if (_isEdit) {
      _usernameCtrl.text = widget.user!.username;
      _displayCtrl.text = widget.user!.displayName ?? '';
      _selectedRoleId = widget.user!.roleId;
    }
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await UserService(LocalDatabase.instance).getAllRoles();
      if (mounted) {
        setState(() {
          _roles = roles;
          _loadingRoles = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading roles: $e');
      if (mounted) setState(() => _loadingRoles = false);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _displayCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final svc = UserService(LocalDatabase.instance);

    try {
      if (_isEdit) {
        await svc.updateUser(
          widget.user!.id,
          displayName: _displayCtrl.text.trim(),
          roleId: _selectedRoleId,
        );
      } else {
        await svc.createUser(
          username: _usernameCtrl.text.trim(),
          pin: _pinCtrl.text,
          roleId: _selectedRoleId!,
          displayName: _displayCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'تعديل مستخدم' : 'مستخدم جديد'),
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
        ),
        body: _loadingRoles
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _usernameCtrl,
                      enabled: !_isEdit,
                      decoration: const InputDecoration(
                        labelText: 'اسم الدخول',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _displayCtrl,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_isEdit)
                      TextFormField(
                        controller: _pinCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'PIN (4 أرقام)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (v) => (v == null || v.length != 4)
                            ? 'PIN من 4 أرقام'
                            : null,
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedRoleId,
                      decoration: const InputDecoration(
                        labelText: 'الدور',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      items: _roles
                          .map((r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.displayNameAr),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRoleId = v),
                      validator: (v) => v == null ? 'اختر الدور' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('حفظ'),
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A5F),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.cancel),
                          label: const Text('إلغاء'),
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
