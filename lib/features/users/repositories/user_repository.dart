import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/models/user_model.dart';
import '../../../core/auth/enums/user_role.dart';
import '../../../core/services/logger_service.dart';

class UserRepository {
  final SupabaseClient _supabase;
  final LoggerService _logger;

  UserRepository(this._supabase) : _logger = LoggerService('UserRepository');

  Future<List<UserModel>> getUsers({String? machineSerial}) async {
    try {
      _logger.i('Fetching users from database${machineSerial != null ? ' for machine $machineSerial' : ''}');

      var query = _supabase.from('users').select('''
        *,
        machine_assignments!inner (
          machine_id,
          role,
          status,
          machines!inner (
            serial_number
          )
        )
      ''');

      // If machineSerial is provided, filter users for that machine
      if (machineSerial != null) {
        query = query.eq('machine_assignments.machines.serial_number', machineSerial);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((userData) {
        String? roleStr = userData['role'] as String?;
        UserRole? role = roleStr != null ? UserRole.fromString(roleStr) : null;

        // Get machine serial from assignments if available
        String? assignedMachineSerial;
        if (userData['machine_assignments'] != null &&
            (userData['machine_assignments'] as List).isNotEmpty &&
            userData['machine_assignments'][0]['machines'] != null) {
          assignedMachineSerial = userData['machine_assignments'][0]['machines']['serial_number'] as String?;
        }

        return UserModel(
          uid: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String?,
          role: role,
          status: userData['status'] as String?,
          machineSerial: assignedMachineSerial,
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching users: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateUserRole(String userId, UserRole role, {String? machineSerial}) async {
    try {
      _logger.i('Updating role for user $userId to: ${role.toString()}');

      // If machineSerial is provided, verify user belongs to that machine
      if (machineSerial != null) {
        final machine = await _supabase
            .from('machines')
            .select('id')
            .eq('serial_number', machineSerial)
            .single();

        final assignment = await _supabase
            .from('machine_assignments')
            .select()
            .eq('user_id', userId)
            .eq('machine_id', machine['id'])
            .maybeSingle();

        if (assignment == null) {
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

      // Update machine assignment role if it exists
      if (machineSerial != null) {
        final machine = await _supabase
            .from('machines')
            .select('id')
            .eq('serial_number', machineSerial)
            .single();

        await _supabase
            .from('machine_assignments')
            .update({
              'role': role.toString(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('machine_id', machine['id']);
      }

      _logger.i('Role update successful');
    } catch (e) {
      _logger.e('Error updating user role: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateUserStatus(String userId, String status, {String? machineSerial}) async {
    try {
      _logger.i('Updating status for user $userId to: $status');

      // If machineSerial is provided, verify user belongs to that machine
      if (machineSerial != null) {
        final machine = await _supabase
            .from('machines')
            .select('id')
            .eq('serial_number', machineSerial)
            .single();

        final assignment = await _supabase
            .from('machine_assignments')
            .select()
            .eq('user_id', userId)
            .eq('machine_id', machine['id'])
            .maybeSingle();

        if (assignment == null) {
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

      // Update machine assignment status if it exists
      if (machineSerial != null) {
        final machine = await _supabase
            .from('machines')
            .select('id')
            .eq('serial_number', machineSerial)
            .single();

        await _supabase
            .from('machine_assignments')
            .update({
              'status': status,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('machine_id', machine['id']);
      }

      _logger.i('Status update successful');
    } catch (e) {
      _logger.e('Error updating user status: ${e.toString()}');
      rethrow;
    }
  }
}