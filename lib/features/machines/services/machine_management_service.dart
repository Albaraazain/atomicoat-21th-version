import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/machine.dart';
import '../../../core/auth/enums/user_role.dart';
import '../../../core/services/logger_service.dart';

class MachineManagementService {
  final SupabaseClient _supabase;
  final LoggerService _logger;

  MachineManagementService(this._supabase) : _logger = LoggerService('MachineManagementService');

  // Create a new machine and assign an admin
  Future<void> createMachine({
    required String name,
    required String serialNumber,
    required String location,
    required String machineType,
    required String model,
    required String adminEmail,
  }) async {
    try {
      _logger.i('Creating new machine: $name');

      // Start a transaction
      await _supabase.rpc('begin_transaction');

      try {
        // Create machine record
        final machineData = {
          'name': name,
          'serial_number': serialNumber,
          'location': location,
          'machine_type': machineType,
          'model': model,
          'status': 'inactive',
          'install_date': DateTime.now().toIso8601String(),
        };

        final machineResponse = await _supabase
            .from('machines')
            .insert(machineData)
            .select()
            .single();

        // Create or get admin user
        final userData = {
          'email': adminEmail,
          'role': UserRole.machineadmin.toString(),
          'status': 'pending_registration',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final existingUser = await _supabase
            .from('users')
            .select()
            .eq('email', adminEmail as Object)
            .single();

        String userId;
        if (existingUser != null) {
          userId = existingUser['id'];
          // Update existing user
          await _supabase
              .from('users')
              .update(userData)
              .eq('id', userId);
        } else {
          // Insert new user
          final userResponse = await _supabase
              .from('users')
              .insert(userData)
              .select()
              .single();
          userId = userResponse['id'];
        }

        // Create machine assignment
        final assignmentData = {
          'machine_id': machineResponse['id'],
          'user_id': userId,
          'role': 'machineadmin',
          'status': 'active',
        };

        await _supabase.from('machine_assignments').insert(assignmentData);

        // Commit transaction
        await _supabase.rpc('commit_transaction');
        _logger.i('Machine created successfully with ID: ${machineResponse['id']}');
      } catch (e) {
        // Rollback transaction on error
        await _supabase.rpc('rollback_transaction');
        throw e;
      }
    } catch (e, stackTrace) {
      _logger.e('Error creating machine', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Assign a user to a machine
  Future<void> assignUserToMachine({
    required String machineId,
    required String userEmail,
    required String role,
  }) async {
    try {
      _logger.i('Assigning user $userEmail to machine $machineId');

      // Get or create user
      final userData = {
        'email': userEmail,
        'role': role == 'machineadmin' ? UserRole.machineadmin.toString() : UserRole.operator.toString(),
        'status': 'pending_registration',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', userEmail as Object)
          .single();

      String userId;
      if (existingUser != null) {
        userId = existingUser['id'];
      } else {
        final userResponse = await _supabase
            .from('users')
            .insert(userData)
            .select()
            .single();
        userId = userResponse['id'];
      }

      // Create machine assignment
      final assignmentData = {
        'machine_id': machineId,
        'user_id': userId,
        'role': role,
        'status': 'active',
      };

      await _supabase.from('machine_assignments').insert(assignmentData);
      _logger.i('User assigned to machine successfully');
    } catch (e, stackTrace) {
      _logger.e('Error assigning user to machine', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get machine assignments for a user
  Future<List<Map<String, dynamic>>> getUserMachineAssignments(String userId) async {
    try {
      final response = await _supabase
          .from('machine_assignments')
          .select('*, machines(*)')
          .eq('user_id', userId as Object);

      return response as List<Map<String, dynamic>>;
    } catch (e, stackTrace) {
      _logger.e('Error getting user machine assignments', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get assigned users for a machine
  Future<List<Map<String, dynamic>>> getMachineAssignedUsers(String machineId) async {
    try {
      final response = await _supabase
          .from('machine_assignments')
          .select('*, users(*)')
          .eq('machine_id', machineId as Object);

      return response as List<Map<String, dynamic>>;
    } catch (e, stackTrace) {
      _logger.e('Error getting machine assigned users', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}