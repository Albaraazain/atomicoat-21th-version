import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/providers/auth_provider.dart';
import '../../../core/auth/enums/user_role.dart';
import '../../../core/auth/models/user_model.dart';
import '../providers/user_provider.dart';
import '../../../core/services/logger_service.dart';
import '../widgets/user_card_placeholder.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = false;
  bool _isRefreshing = false;
  final _logger = LoggerService('UserManagementScreen');
  final Map<String, bool> _updatingRoles = {};
  final Map<String, bool> _updatingStatuses = {};

  @override
  void initState() {
    super.initState();
    _logger.d('Initializing UserManagementScreen');
    _initializeUserManagement();
  }

  Future<void> _initializeUserManagement() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final supabase = context.read<SupabaseClient>();

    _logger
        .d('Initializing user management with role: ${authProvider.userRole}, '
            'isAdmin: ${authProvider.isAdmin}, '
            'isSuperAdmin: ${authProvider.isSuperAdmin}');

    setState(() => _isLoading = true);
    try {
      // Set current user in provider
      if (authProvider.userId != null && authProvider.userRole != null) {
        userProvider.setCurrentUser(
          authProvider.userId!,
          authProvider.userRole!,
        );
      } else {
        throw Exception('User not properly authenticated');
      }

      // If machine admin, get their machine serial from assignments
      if (authProvider.isAdmin && !authProvider.isSuperAdmin) {
        try {
          final adminId = authProvider.userId;

          if (adminId != null) {
            final response = await supabase
                .from('machine_assignments')
                .select('machines (serial_number)')
                .eq('user_id', adminId)
                .eq('role', 'machineadmin')
                .single();

            if (response['machines'] != null) {
              final machineSerial =
                  response['machines']['serial_number'] as String;
              _logger.d('Setting machine serial for admin: $machineSerial');
              userProvider.setCurrentMachine(machineSerial);
            }
          }
        } catch (e) {
          _logger.e('Error getting admin machine assignment: $e');
        }
      }

      // Load users based on admin type
      if (authProvider.hasAdminPrivileges) {
        _logger.d('Loading users as admin');
        await userProvider.loadUsers(isSuperAdmin: authProvider.isSuperAdmin);
        _logger.d('Users loaded: ${userProvider.users.length} users found');
      } else {
        _logger.w('User does not have admin privileges to load users');
      }
    } catch (e) {
      _logger.e('Error loading users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUsers() async {
    if (_isRefreshing) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      _logger.d('Loading users with role: ${authProvider.userRole}, '
          'isAdmin: ${authProvider.isAdmin}, '
          'isSuperAdmin: ${authProvider.isSuperAdmin}');

      // Load users based on admin type
      if (authProvider.hasAdminPrivileges) {
        _logger.d('Loading users as admin');
        await userProvider.loadUsers(isSuperAdmin: authProvider.isSuperAdmin);
        _logger.d('Users loaded: ${userProvider.users.length} users found');
      } else {
        _logger.w('User does not have admin privileges to load users');
      }
    } catch (e) {
      _logger.e('Error loading users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshUsers() async {
    if (_isLoading) return;

    setState(() => _isRefreshing = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      await userProvider.loadUsers(isSuperAdmin: authProvider.isSuperAdmin);
    } catch (e) {
      _logger.e('Error refreshing users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing users: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _updateUserRole(String userId, UserRole newRole) async {
    if (_updatingRoles[userId] == true) return;

    setState(() => _updatingRoles[userId] = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      _logger.d('Updating user $userId role to: $newRole');
      await userProvider.updateUserRole(
        userId,
        newRole,
        isSuperAdmin: authProvider.isSuperAdmin,
      );
      _logger.d('User role updated successfully');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role updated successfully')),
        );
      }
    } catch (e) {
      _logger.e('Failed to update user role: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update user role: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updatingRoles[userId] = false);
      }
    }
  }

  Future<void> _updateUserStatus(String userId, String newStatus) async {
    if (_updatingStatuses[userId] == true) return;

    setState(() => _updatingStatuses[userId] = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      _logger.d('Updating user $userId status to: $newStatus');
      await userProvider.updateUserStatus(
        userId,
        newStatus,
        isSuperAdmin: authProvider.isSuperAdmin,
      );
      _logger.d('User status updated successfully');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User status updated successfully')),
        );
      }
    } catch (e) {
      _logger.e('Failed to update user status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update user status: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updatingStatuses[userId] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Check if user has admin privileges
    if (!authProvider.hasAdminPrivileges) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        body: const Center(
          child: Text('You do not have permission to access this page'),
        ),
      );
    }

    String title = authProvider.isSuperAdmin
        ? 'All Users Management'
        : 'Machine Users Management';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUsers,
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const UserCardPlaceholder(),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return RefreshIndicator(
          onRefresh: _refreshUsers,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView.builder(
              key: ValueKey(_isRefreshing),
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                return _buildUserCard(user);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final authProvider = context.watch<AuthProvider>();
    final availableRoles = authProvider.isSuperAdmin
        ? [UserRole.machineadmin, UserRole.operator, UserRole.user]
        : [UserRole.operator, UserRole.user];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${user.role?.toString() ?? 'No Role'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (user.name != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Name: ${user.name}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (user.machineSerial != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Machine: ${user.machineSerial}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusChip(user.status ?? 'pending'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRoleDropdown(user, availableRoles),
                      if (_updatingRoles[user.uid] == true)
                        const CircularProgressIndicator(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildStatusButton(user),
                    if (_updatingStatuses[user.uid] == true)
                      const CircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = Colors.green;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'inactive':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildRoleDropdown(UserModel user, List<UserRole> availableRoles) {
    _logger.d(
        '[_buildRoleDropdown] Current user role: ${user.role}, Available roles: $availableRoles');

    // If the user is a superadmin or another machine admin, don't show the dropdown
    if (user.role?.toString() == 'superadmin' ||
        (user.role?.toString() == 'machineadmin' &&
            !context.read<AuthProvider>().isSuperAdmin)) {
      return Text(
        'Role: ${user.role}',
        style: TextStyle(color: Colors.grey[600]),
      );
    }

    // Ensure the current role is in the available roles
    if (user.role != null && !availableRoles.contains(user.role)) {
      _logger.w(
          '[_buildRoleDropdown] User role ${user.role} not in available roles: $availableRoles');
      return Text(
        'Role: ${user.role}',
        style: TextStyle(color: Colors.grey[600]),
      );
    }

    return DropdownButton<UserRole>(
      value: user.role ?? UserRole.user,
      items: availableRoles.map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(role.toString()),
        );
      }).toList(),
      onChanged: (newRole) {
        if (newRole != null && newRole != user.role) {
          _updateUserRole(user.uid, newRole);
        }
      },
    );
  }

  Widget _buildStatusButton(UserModel user) {
    final currentStatus = user.status ?? 'pending';
    return TextButton(
      onPressed: () {
        final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
        _updateUserStatus(user.uid, newStatus);
      },
      child: Text(
        currentStatus == 'active' ? 'Deactivate' : 'Activate',
        style: TextStyle(
          color: currentStatus == 'active' ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
