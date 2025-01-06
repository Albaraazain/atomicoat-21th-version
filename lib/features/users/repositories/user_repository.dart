import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/models/user_model.dart';
import '../../../core/auth/enums/user_role.dart';
import 'package:logger/logger.dart';

class UserRepository {
  final _supabase = Supabase.instance.client;
  final _logger = Logger();

  Future<List<UserModel>> getUsers({String? machineSerial}) async {
    try {
      _logger.i('Fetching users from database${machineSerial != null ? ' for machine $machineSerial' : ''}');

      final query = _supabase
          .from('users')
          .select();

      // If machineSerial is provided, filter users for that machine
      final filteredQuery = machineSerial != null
          ? query.eq('machine_serial', machineSerial)
          : query;

      final response = await filteredQuery.order('created_at', ascending: false);

      return (response as List).map((userData) {
        String? roleStr = userData['role'] as String?;
        UserRole? role = roleStr != null ? UserRole.fromString(roleStr) : null;

        return UserModel(
          uid: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String?,
          role: role,
          status: userData['status'] as String?,
          machineSerial: userData['machine_serial'] as String?,
        );
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching users', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateUserRole(String userId, UserRole role, {String? machineSerial}) async {
    try {
      _logger.i('Updating role for user $userId to: ${role.toString()}');

      // If machineSerial is provided, verify user belongs to that machine
      if (machineSerial != null) {
        final query = _supabase
            .from('users')
            .select();

        final user = await query
            .eq('id', userId)
            .eq('machine_serial', machineSerial)
            .maybeSingle();

        if (user == null) {
          throw Exception('User does not belong to this machine');
        }
      }

      await _supabase
          .from('users')
          .update({
            'role': role.toString(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      _logger.i('Role update successful');
    } catch (e, stackTrace) {
      _logger.e('Error updating user role', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateUserStatus(String userId, String status, {String? machineSerial}) async {
    try {
      _logger.i('Updating status for user $userId to: $status');

      // If machineSerial is provided, verify user belongs to that machine
      if (machineSerial != null) {
        final query = _supabase
            .from('users')
            .select();

        final user = await query
            .eq('id', userId)
            .eq('machine_serial', machineSerial)
            .maybeSingle();

        if (user == null) {
          throw Exception('User does not belong to this machine');
        }
      }

      await _supabase
          .from('users')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      _logger.i('Status update successful');
    } catch (e, stackTrace) {
      _logger.e('Error updating user status', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}