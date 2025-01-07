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
        userId = existingUser['id'];
        // Update existing user
        await _supabase
            .from('users')
            .update(userData)
            .eq('id', userId);

        // Create machine assignment
        final assignmentData = {
          'machine_id': machineResponse['id'],
          'user_id': userId,
          'role': 'machineadmin',
          'status': 'active',
        };

        await _supabase.from('machine_assignments').insert(assignmentData);

        // Create default machine components
        final components = [
          {
            'machine_id': machineResponse['id'],
            'name': 'Reaction Chamber',
            'type': 'chamber',
            'is_activated': true,
          },
          {
            'machine_id': machineResponse['id'],
            'name': 'Mass Flow Controller',
            'type': 'mfc',
            'is_activated': true,
          },
          {
            'machine_id': machineResponse['id'],
            'name': 'Precursor Line A',
            'type': 'precursor_line',
            'is_activated': true,
          },
          {
            'machine_id': machineResponse['id'],
            'name': 'Precursor Line B',
            'type': 'precursor_line',
            'is_activated': true,
          },
          {
            'machine_id': machineResponse['id'],
            'name': 'Backline Heater',
            'type': 'heater',
            'is_activated': true,
          },
          {
            'machine_id': machineResponse['id'],
            'name': 'Frontline Heater',
            'type': 'heater',
            'is_activated': true,
          },
        ];

        // Insert all components
        final componentResponses = await _supabase
            .from('machine_components')
            .insert(components)
            .select();

        // Create default parameters for each component
        final parameters = [];
        for (final component in componentResponses) {
          switch (component['type']) {
            case 'chamber':
              parameters.addAll([
                {
                  'component_id': component['id'],
                  'name': 'temperature',
                  'unit': '°C',
                  'min_value': 0.0,
                  'max_value': 400.0,
                  'current_value': 25.0,
                  'set_value': 25.0,
                },
                {
                  'component_id': component['id'],
                  'name': 'pressure',
                  'unit': 'Torr',
                  'min_value': 0.0,
                  'max_value': 760.0,
                  'current_value': 760.0,
                  'set_value': 760.0,
                },
              ]);
              break;
            case 'mfc':
              parameters.add({
                'component_id': component['id'],
                'name': 'flow_rate',
                'unit': 'sccm',
                'min_value': 0.0,
                'max_value': 1000.0,
                'current_value': 0.0,
                'set_value': 0.0,
              });
              break;
            case 'precursor_line':
              parameters.addAll([
                {
                  'component_id': component['id'],
                  'name': 'temperature',
                  'unit': '°C',
                  'min_value': 0.0,
                  'max_value': 200.0,
                  'current_value': 25.0,
                  'set_value': 25.0,
                },
                {
                  'component_id': component['id'],
                  'name': 'valve_state',
                  'unit': 'boolean',
                  'min_value': 0.0,
                  'max_value': 1.0,
                  'current_value': 0.0,
                  'set_value': 0.0,
                },
              ]);
              break;
            case 'heater':
              parameters.add({
                'component_id': component['id'],
                'name': 'temperature',
                'unit': '°C',
                'min_value': 0.0,
                'max_value': 200.0,
                'current_value': 25.0,
                'set_value': 25.0,
              });
              break;
          }
        }

        // Insert all parameters
        await _supabase
            .from('component_parameters')
            .insert(parameters);

        // Commit transaction
        await _supabase.rpc('commit_transaction');
        _logger.i('Machine created successfully with ID: ${machineResponse['id']}');
      } catch (e) {
        // Rollback transaction on error
        await _supabase.rpc('rollback_transaction');
        rethrow;
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
      userId = existingUser['id'];

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

      return response;
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

      return response;
    } catch (e, stackTrace) {
      _logger.e('Error getting machine assigned users', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}