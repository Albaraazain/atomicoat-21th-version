// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../core/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/user_role.dart';
import '../models/user_model.dart';
import '../../../main.dart'; // for navigatorKey

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final LoggerService _logger;

  User? _user;
  UserModel? _userModel;
  UserRole? _userRole;
  String? _userStatus;
  bool _isLoading = true;
  String? _error;
  bool _initialized = false;

  AuthProvider(this._authService) : _logger = LoggerService('AuthProvider') {
    _logger.d('Initializing AuthProvider');
    _init();
  }

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get userId => _user?.id;
  UserRole? get userRole => _userRole;
  String? get userStatus => _userStatus;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userRole == UserRole.machineadmin;
  bool get isSuperAdmin => _userRole == UserRole.superAdmin;
  bool get hasAdminPrivileges => isAdmin || isSuperAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _init() async {
    if (_initialized) return;

    try {
      _logger.i('Initializing authentication state');
      _setLoading(true);

      // Initialize auth service
      await _authService.initialize();

      // Check for current user
      _user = _authService.currentUser;
      if (_user != null) {
        _logger.i('Current user found during initialization: ${_user?.id}');
        await _loadUserData();
      } else {
        _logger.i('No current user found during initialization');
      }

      // Listen for auth state changes
      _authService.authStateChanges.listen((event) async {
        final user = event.session?.user;
        _user = user;
        if (_user != null) {
          _logger.i('Auth state changed: User logged in: ${_user?.id}');
          await _loadUserData();
        } else {
          _logger.i('Auth state changed: User logged out');
          _clearUserData();
        }
        notifyListeners();
      });

      _initialized = true;
    } catch (e, stackTrace) {
      _handleError('Failed to initialize auth provider', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (_user == null) return;

      _userRole = await _authService.getUserRole(_user!.id);
      _userStatus = await _authService.getUserStatus(_user!.id);

      _logger.i(
          'User data loaded successfully: ${_user?.id}, role: $_userRole, status: $_userStatus');
    } catch (e, stackTrace) {
      _handleError('Failed to load user data', e, stackTrace);
    }
  }

  void _handleError(String message, dynamic error, StackTrace stackTrace) {
    _logger.e('$message: $error');
    _error = error.toString();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearUserData() {
    _user = null;
    _userModel = null;
    _userRole = null;
    _userStatus = null;
  }

  bool isApproved() {
    return _userStatus == 'active';
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _error = null;

      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        await _loadUserData();
        _logger.i('Sign in successful: ${user.id}');

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      _handleError('Sign in failed', e, stackTrace);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? machineSerial,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        machineSerial: machineSerial,
      );

      if (user != null) {
        _user = user;
        await _loadUserData();
        _logger.i('Sign up successful: ${user.id}');

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      _handleError('Sign up failed', e, stackTrace);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.signOut();
      _clearUserData();

      _logger.i('User signed out successfully');

      // Navigate to login screen
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e, stackTrace) {
      _handleError('Sign out failed', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.sendPasswordResetEmail(email);
      _logger.i('Password reset email sent to: $email');
    } catch (e, stackTrace) {
      _handleError('Failed to send password reset email', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.updateUserRole(userId, role);
      if (userId == _user?.id) {
        _userRole = role;
      }
      _logger.i('User role updated: $userId to $role');
    } catch (e, stackTrace) {
      _handleError('Failed to update user role', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.updateUserStatus(userId, status);
      if (userId == _user?.id) {
        _userStatus = status;
      }
      _logger.i('User status updated: $userId to $status');
    } catch (e, stackTrace) {
      _handleError('Failed to update user status', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.deleteAccount();
      _clearUserData();

      _logger.i('Account deleted successfully');
    } catch (e, stackTrace) {
      _handleError('Account deletion failed', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
