class UserModel {
  final String id;
  final String username;
  final String? displayName;
  final String? email;
  final String? branchId;
  final String? pinHash;
  final String? pinSalt;
  final bool isActive;
  final int failedAttempts;
  final String? lockedUntil;
  final String? syncedAt;
  final String? createdAt;
  // Joined fields (من user_roles_local + roles_local)
  final String? roleId;
  final String? roleName;

  UserModel({
    required this.id,
    required this.username,
    this.displayName,
    this.email,
    this.branchId,
    this.pinHash,
    this.pinSalt,
    this.isActive = true,
    this.failedAttempts = 0,
    this.lockedUntil,
    this.syncedAt,
    this.createdAt,
    this.roleId,
    this.roleName,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      displayName: map['display_name'] as String?,
      email: map['email'] as String?,
      branchId: map['branch_id'] as String?,
      pinHash: map['pin_hash'] as String?,
      pinSalt: map['pin_salt'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      failedAttempts: map['failed_attempts'] as int? ?? 0,
      lockedUntil: map['locked_until'] as String?,
      syncedAt: map['synced_at'] as String?,
      createdAt: map['created_at'] as String?,
      roleId: map['role_id'] as String?,
      roleName: map['role_name'] as String?,
    );
  }

  String get roleDisplay {
    if (roleName == null) return 'بدون دور';
    switch (roleName) {
      case 'General_Manager': return 'مدير عام';
      case 'Store_Manager': return 'مدير مخزن';
      case 'Accountant': return 'محاسب';
      case 'Cashier': return 'كاشير';
      case 'Inventory_Clerk': return 'أمين مخزن';
      default: return roleName!;
    }
  }
}

class RoleModel {
  final String id;
  final String name;
  final String? description;

  const RoleModel({
    required this.id,
    required this.name,
    this.description,
  });

  String get displayNameAr {
    switch (name) {
      case 'General_Manager': return 'مدير عام';
      case 'Store_Manager': return 'مدير مخزن';
      case 'Accountant': return 'محاسب';
      case 'Cashier': return 'كاشير';
      case 'Inventory_Clerk': return 'أمين مخزن';
      default: return name;
    }
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }
}
