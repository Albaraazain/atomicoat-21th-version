enum UserRole {
  superAdmin,
  machineadmin,
  operator,
  user;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'superadmin':
        return UserRole.superAdmin;
      case 'machineadmin':
        return UserRole.machineadmin;
      case 'operator':
        return UserRole.operator;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  @override
  String toString() {
    return name.toLowerCase();
  }

  bool get isSuperAdmin => this == UserRole.superAdmin;
  bool get isMachineAdmin => this == UserRole.machineadmin;
  bool get isOperator => this == UserRole.operator;
  bool get isUser => this == UserRole.user;

  // Helper method to check if user has admin-level or higher privileges
  bool get hasAdminPrivileges => this == UserRole.machineadmin || this == UserRole.superAdmin;

  // Helper method to check if user can manage machines (superAdmin only)
  bool get canManageMachines => this == UserRole.superAdmin;
}
