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

  bool _initialized = false;

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
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize AuthService', error: e, stackTrace: stackTrace);
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
      } catch (e, stackTrace) {
        _logger.e('Failed to create users table', error: e, stackTrace: stackTrace);
        // Don't rethrow - we'll handle missing table gracefully
      }
    }
  }

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
    String? machineSerial,
  }) async {
    try {
      _logger.i('Attempting sign up for user: $email');

      // Check if user already exists in users table
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email as Object)
          .single();

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
            .single();

        if (machine == null) {
          throw Exception('Invalid machine serial number');
        }
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

  // Get user role with fallback
  Future<UserRole> getUserRole(String userId) async {
    if (!_initialized) await initialize();

    try {
      _logger.d('Getting user role for: $userId');
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle instead of single to avoid errors

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

  // Get user status with fallback
  Future<String> getUserStatus(String userId) async {
    if (!_initialized) await initialize();

    try {
      _logger.d('Getting user status for: $userId');
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
    } catch (e, stackTrace) {
      _logger.e('Error getting user status', error: e, stackTrace: stackTrace);
      return 'pending'; // Default to pending on error
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
    String status = 'pending',
  }) async {
    try {
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

      // If user already exists, update it
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', user.email != null ? user.email as Object : '')
          .single();

      if (existingUser != null) {
        await _supabase
            .from('users')
            .update(userData)
            .eq('email', user.email as Object);
      } else {
        await _supabase.from('users').insert(userData);
      }

      _logger.i('User profile created/updated successfully');
    } catch (e, stackTrace) {
      _logger.e('Error creating user profile',
          error: e, stackTrace: stackTrace);
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
