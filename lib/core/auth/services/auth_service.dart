import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../enums/user_role.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Current user getter
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<User?> signIn(
      {required String email, required String password}) async {
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

        if (userProfile == null) {
          _logger.w('User profile not found, creating new profile');
          // Create user profile if it doesn't exist
          await _createUserProfile(user, UserRole.user);
        }

        return user;
      } else {
        _logger.w('Sign in failed: No user returned');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Sign in error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  }) async {
    try {
      _logger.i('Attempting sign up for user: $email');

      // Validate machine serial
      if (!await _validateMachineSerial(machineSerial)) {
        throw Exception('Invalid machine serial number');
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = response.user;
      if (user != null) {
        _logger.i('Sign up successful for user: ${user.id}');

        // Create user profile
        await _createUserProfile(
          user,
          UserRole.user,
          name: name,
          machineSerial: machineSerial,
        );

        return user;
      } else {
        _logger.w('Sign up failed: No user returned');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Sign up error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.i('Attempting sign out');
      await _supabase.auth.signOut();
      _logger.i('Sign out successful');
    } catch (e, stackTrace) {
      _logger.e('Sign out error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get user role
  Future<UserRole> getUserRole(String userId) async {
    try {
      _logger.d('Getting user role for: $userId');
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      if (response == null) {
        _logger.w('User profile not found, defaulting to user role');
        return UserRole.user;
      }

      final roleStr = response['role'] as String? ?? 'user';
      _logger.d('User role found: $roleStr');

      return _parseUserRole(roleStr);
    } catch (e, stackTrace) {
      _logger.e('Error getting user role', error: e, stackTrace: stackTrace);
      return UserRole.user; // Default to user role on error
    }
  }

  // Get user status
  Future<String?> getUserStatus(String userId) async {
    try {
      _logger.d('Getting user status for: $userId');
      final response = await _supabase
          .from('users')
          .select('status')
          .eq('id', userId)
          .single();

      if (response == null) {
        _logger.w('User profile not found');
        return null;
      }

      final status = response['status'] as String?;
      _logger.d('User status found: $status');

      return status;
    } catch (e, stackTrace) {
      _logger.e('Error getting user status', error: e, stackTrace: stackTrace);
      return null;
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
    } catch (e, stackTrace) {
      _logger.e('Error updating user status', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      _logger.e('Error updating user role', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent successfully');
    } catch (e, stackTrace) {
      _logger.e('Error sending password reset email',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _createUserProfile(
    User user,
    UserRole role, {
    String? name,
    String? machineSerial,
  }) async {
    try {
      String status;
      switch (role) {
        case UserRole.superAdmin:
        case UserRole.admin:
          status = 'active';
          break;
        case UserRole.operator:
        case UserRole.user:
          status = 'pending';
          break;
      }

      final userData = {
        'id': user.id,
        'email': user.email,
        'role': role.toString(),
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) userData['name'] = name;
      if (machineSerial != null) userData['machine_serial'] = machineSerial;

      await _supabase.from('users').insert(userData);
      _logger.i('User profile created successfully');
    } catch (e, stackTrace) {
      _logger.e('Error creating user profile',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> _validateMachineSerial(String serial) async {
    // TODO: Implement actual machine serial validation
    _logger.w(
        'Machine serial validation not implemented, returning true for testing');
    return true;
  }

  UserRole _parseUserRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'superadmin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}
