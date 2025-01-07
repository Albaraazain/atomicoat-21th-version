import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/user_role.dart';
import '../../../core/services/logger_service.dart';

class AuthService {
  final SupabaseClient _supabase;
  final LoggerService _logger;

  bool _initialized = false;

  AuthService(this._supabase) : _logger = LoggerService('AuthService');

  // Current user getter
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Initialize service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _logger.i('Initializing AuthService');
      // Check if the users table exists and create it if it doesn't
      await _ensureUsersTableExists();
      _initialized = true;
      _logger.i('AuthService initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize AuthService: ${e.toString()}');
      // Don't rethrow - we want to handle this gracefully
    }
  }

  Future<void> _ensureUsersTableExists() async {
    try {
      // Try to query the users table
      await _supabase.from('users').select('id').limit(1);
      _logger.i('Users table exists');
    } catch (e) {
      _logger.w('Users table might not exist, attempting to create it');
      try {
        // Create the users table if it doesn't exist
        await _supabase.rpc('create_users_table');
        _logger.i('Users table created successfully');
      } catch (e) {
        _logger.e('Failed to create users table: ${e.toString()}');
        // Don't rethrow - we'll handle missing table gracefully
      }
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting sign in for user: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final User? user = response.user;
      if (user != null) {
        _logger.i('Sign in successful for user: ${user.id}');

        // Check if user profile exists
        final userProfile =
            await _supabase.from('users').select().eq('id', user.id).single();

        return user;
      } else {
        _logger.w('Sign in failed: No user returned');
        return null;
      }
    } catch (e) {
      _logger.e('Sign in error: ${e.toString()}');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    String? machineSerial,
  }) async {
    try {
      _logger.i('Attempting sign up for user: $email');

      // Check if user already exists in users table
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      // If user exists but is pending registration, allow sign up
      if (existingUser != null && existingUser['status'] != 'pending_registration') {
        throw Exception('User already exists');
      }

      // Determine user role and status based on existing record
      UserRole role = UserRole.user;
      String status = 'pending';

      if (existingUser != null) {
        // User was pre-created (admin case)
        role = UserRole.fromString(existingUser['role']);
        status = existingUser['status'];
      } else if (machineSerial != null) {
        // Validate machine serial for regular users
        final machine = await _supabase
            .from('machines')
            .select()
            .eq('serial_number', machineSerial)
            .maybeSingle();

        if (machine == null) {
          throw Exception('Invalid machine serial number');
        }

        // Set role to operator by default for machine users
        role = UserRole.operator;
      }

      // Create auth user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = response.user;
      if (user != null) {
        _logger.i('Sign up successful for user: ${user.id}');

        // Create or update user profile
        await _createUserProfile(
          user,
          role,
          name: name,
          machineSerial: machineSerial,
          status: status,
        );

        return user;
      } else {
        _logger.w('Sign up failed: No user returned');
        return null;
      }
    } catch (e) {
      _logger.e('Sign up error: ${e.toString()}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.i('Attempting sign out');
      await _supabase.auth.signOut();
      _logger.i('Sign out successful');
    } catch (e) {
      _logger.e('Sign out error: ${e.toString()}');
      rethrow;
    }
  }

  // Get user role with fallback
  Future<UserRole> getUserRole(String userId) async {
    if (!_initialized) await initialize();

    try {
      _logger.d('Getting user role for: $userId');

      // Try up to 3 times with a delay between attempts
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await _supabase
              .from('users')
              .select('role')
              .eq('id', userId)
              .maybeSingle();

          if (response == null) {
            _logger.w('User profile not found, defaulting to user role');
            return UserRole.user;
          }

          final roleStr = response['role'] as String? ?? 'user';
          _logger.d('User role found: $roleStr');

          return _parseUserRole(roleStr);
        } catch (e) {
          if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
            if (attempt < 3) {
              _logger.w('Network error on attempt $attempt, retrying in 2 seconds...');
              await Future.delayed(Duration(seconds: 2));
              continue;
            }
          }
          rethrow;
        }
      }

      _logger.e('Failed to get user role after 3 attempts');
      return UserRole.user;
    } catch (e) {
      _logger.e('Error getting user role: ${e.toString()}');
      return UserRole.user;
    }
  }

  // Get user status with fallback
  Future<String> getUserStatus(String userId) async {
    if (!_initialized) await initialize();

    try {
      _logger.d('Getting user status for: $userId');

      // Try up to 3 times with a delay between attempts
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await _supabase
              .from('users')
              .select('status')
              .eq('id', userId)
              .maybeSingle();

          if (response == null) {
            _logger.w('User profile not found, defaulting to pending status');
            return 'pending';
          }

          final status = response['status'] as String? ?? 'pending';
          _logger.d('User status found: $status');

          return status;
        } catch (e) {
          if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
            if (attempt < 3) {
              _logger.w('Network error on attempt $attempt, retrying in 2 seconds...');
              await Future.delayed(Duration(seconds: 2));
              continue;
            }
          }
          rethrow;
        }
      }

      _logger.e('Failed to get user status after 3 attempts');
      return 'pending';
    } catch (e) {
      _logger.e('Error getting user status: ${e.toString()}');
      return 'pending';
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      _logger.i('Updating status for user $userId to: $status');
      await _supabase.from('users').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      _logger.i('Status update successful');
    } catch (e) {
      _logger.e('Error updating user status: ${e.toString()}');
      rethrow;
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      _logger.i('Updating role for user $userId to: $role');
      await _supabase.from('users').update({
        'role': role.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      _logger.i('Role update successful');
    } catch (e) {
      _logger.e('Error updating user role: ${e.toString()}');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent successfully');
    } catch (e) {
      _logger.e('Error sending password reset email: ${e.toString()}');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      _logger.i('Attempting to delete account');
      final user = currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Delete user data from users table first
      // This will automatically cascade to delete related records
      await _supabase.from('users').delete().eq('id', user.id);
      _logger.i('Deleted user and related data');

      // Sign out the user
      await signOut();
      _logger.i('Account deleted successfully');
    } catch (e) {
      _logger.e('Account deletion error: ${e.toString()}');
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _createUserProfile(
    User user,
    UserRole role, {
    String? name,
    String? machineSerial,
    String? status,
  }) async {
    try {
      _logger.i('Creating/updating user profile for: ${user.id}');

      // Prepare user data
      final userData = {
        'id': user.id,
        'email': user.email,
        'username': name ?? user.email?.split('@')[0],
        'role': role.toString(),
        'status': status ?? 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Check if user already exists
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', user.email as Object)
          .maybeSingle();

      // Update or insert user record
      if (existingUser != null) {
        await _supabase
            .from('users')
            .update(userData)
            .eq('email', user.email as Object);
      } else {
        await _supabase.from('users').insert(userData);
      }

      // Handle machine assignment if machine serial is provided
      if (machineSerial != null) {
        try {
          // Get machine id from serial number
          final machine = await _supabase
              .from('machines')
              .select('id')
              .eq('serial_number', machineSerial)
              .single();

          // Check for existing assignment
          final existingAssignment = await _supabase
              .from('machine_assignments')
              .select()
              .eq('machine_id', machine['id'])
              .eq('user_id', user.id)
              .maybeSingle();

          if (existingAssignment == null) {
            // Create machine assignment
            await _supabase.from('machine_assignments').insert({
              'machine_id': machine['id'],
              'user_id': user.id,
              'role': role.toString().split('.').last, // Convert enum to string
              'status': 'inactive',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            _logger.i('Created machine assignment for user ${user.id} to machine ${machine['id']}');
          } else {
            _logger.i('Machine assignment already exists for user ${user.id}');
          }
                } catch (e) {
          _logger.e('Error creating machine assignment: ${e.toString()}');
          throw Exception('Failed to create machine assignment: ${e.toString()}');
        }
      }

      _logger.i('User profile created/updated successfully');
    } catch (e) {
      _logger.e('Error creating user profile: ${e.toString()}');
      rethrow;
    }
  }

  UserRole _parseUserRole(String roleStr) {
    try {
      return UserRole.values.firstWhere(
        (role) => role.toString().toLowerCase() == roleStr.toLowerCase(),
        orElse: () => UserRole.user,
      );
    } catch (e) {
      _logger.w('Invalid role string: $roleStr, defaulting to user');
      return UserRole.user;
    }
  }
}
