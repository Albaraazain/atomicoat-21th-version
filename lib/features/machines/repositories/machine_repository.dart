import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/machine.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/config/env.dart';

class MachineRepository {
  final SupabaseClient _supabase;
  final SupabaseClient _adminClient;
  final LoggerService _logger;

  MachineRepository(this._supabase)
      : _adminClient = SupabaseClient(
          Env.supabaseUrl,
          Env.supabaseServiceRole,
        ),
        _logger = LoggerService('MachineRepository');

  String _generatePasswordFromEmail(String email) {
    final emailPrefix = email.split('@')[0];
    return '$emailPrefix@2024';
  }

  Future<Map<String, dynamic>> createMachine({
    required String serialNumber,
    required String location,
    required String labName,
    required String labInstitution,
    required String model,
    required String machineType,
    required String adminEmail,
  }) async {
    try {
      _logger.i('Starting machine creation process');

      // Check for existing machine
      final existingMachine = await getMachineBySerial(serialNumber);
      if (existingMachine != null) {
        throw PostgrestException(
          message: 'Machine with serial number $serialNumber already exists',
          code: 'DUPLICATE_ERROR',
          details: null,
          hint: null,
        );
      }

      // Generate admin password
      _logger.d('Creating/Verifying admin user with email: $adminEmail');
      final password = _generatePasswordFromEmail(adminEmail);

      // Check for existing user
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', adminEmail)
          .maybeSingle();

      String adminId;
      bool isNewUser = false;

      if (existingUser == null) {
        try {
          // Create new admin user using service role client
          final authResponse = await _adminClient.auth.admin.createUser(
            AdminUserAttributes(
              email: adminEmail,
              password: password,
              emailConfirm: true,
              userMetadata: {
                'role': 'machineadmin',
                'status': 'active',
              },
            ),
          );

          if (authResponse.user == null) {
            throw PostgrestException(
              message: 'Failed to create admin user',
              code: 'USER_CREATION_ERROR',
              details: null,
              hint: null,
            );
          }

          adminId = authResponse.user!.id;
          isNewUser = true;

          // Create user record
          await _adminClient.from('users').upsert({
            'id': adminId,
            'email': adminEmail,
            'username': adminEmail.split('@')[0],
            'role': 'machineadmin',
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          _logger.d('Created new admin user with ID: $adminId');
        } catch (e) {
          _logger.e('Error creating admin user: ${e.toString()}');
          rethrow;
        }
      } else {
        adminId = existingUser['id'];
        _logger.d('Using existing admin user with ID: $adminId');
      }

      // Create machine record
      final machineData = {
        'serial_number': serialNumber,
        'location': location,
        'lab_name': labName,
        'lab_institution': labInstitution,
        'model': model,
        'machine_type': machineType,
        'install_date': DateTime.now().toIso8601String(),
        'status': 'offline',
        'last_maintenance_date': DateTime.now().toIso8601String(),
        'admin_id': adminId,
        'is_active': true,
        'current_operator_id': null,
        'current_process_id': null,
      };

      _logger.d('Creating machine record');
      final machineResponse = await _supabase
          .from('machines')
          .insert(machineData)
          .select()
          .single();

      _logger.d('Machine created with ID: ${machineResponse['id']}');

      // Create machine assignment
      final assignmentData = {
        'machine_id': machineResponse['id'],
        'user_id': adminId,
        'role': 'machineadmin',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      _logger.d('Creating machine assignment');
      await _supabase.from('machine_assignments').insert(assignmentData);
      _logger.d('Machine assignment created');

      // Create default machine components
      _logger.d('Creating default machine components');
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

      _logger.d('Inserting machine components');
      final componentResponses = await _supabase
          .from('machine_components')
          .insert(components)
          .select();
      _logger.d('Created ${componentResponses.length} machine components');

      // Create default parameters for each component
      _logger.d('Creating component parameters');
      final parameters = [];
      for (final component in componentResponses) {
        _logger.d('Setting up parameters for component: ${component['name']}');
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

      _logger.d('Inserting ${parameters.length} component parameters');
      await _supabase
          .from('component_parameters')
          .insert(parameters);
      _logger.d('Component parameters created successfully');

      // Add credentials to response if new user was created
      if (isNewUser) {
        machineResponse['admin_credentials'] = {
          'email': adminEmail,
          'password': password,
          'message': 'New admin user created'
        };
      }

      _logger.i('Machine creation completed successfully');
      return machineResponse;
    } catch (e) {
      _logger.e('Error creating machine: ${e.toString()}');

      // Cleanup on failure
      if (e.toString().contains('machine_assignments')) {
        try {
          final machineId = e.toString().split('machine_id')[1].split('"')[2];
          _logger.d('Cleaning up failed machine creation: $machineId');
          await _supabase.from('machines').delete().eq('id', machineId);
        } catch (cleanupError) {
          _logger.e('Error during cleanup: ${cleanupError.toString()}');
        }
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMachineBySerial(String serialNumber) async {
    try {
      _logger.d('Fetching machine by serial number: $serialNumber');

      final response = await _supabase
          .from('machines')
          .select('''
            *,
            machine_assignments (
              user_id,
              role,
              status
            )
          ''')
          .eq('serial_number', serialNumber)
          .maybeSingle();

      if (response != null) {
        _logger.d('Machine found with ID: ${response['id']}');
      } else {
        _logger.d('No machine found with serial number: $serialNumber');
      }

      return response;
    } catch (e) {
      _logger.e('Error fetching machine by serial: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMachinesByAdmin(String adminId) async {
    try {
      _logger.d('Fetching machines for admin: $adminId');

      // First check if user is superadmin
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', adminId)
          .single();

      final isSuper = userResponse['role'] == 'superadmin';

      // If superadmin, return all machines
      if (isSuper) {
        _logger.d('User is superadmin, fetching all machines');
        final response = await _supabase
            .from('machines')
            .select('''
              *,
              machine_assignments (
                user_id,
                role,
                status
              )
            ''')
            .order('created_at', ascending: false);

        _logger.d('Fetched ${response.length} machines for superadmin');
        return List<Map<String, dynamic>>.from(response);
      }

      // Otherwise, return only machines where user is admin
      final response = await _supabase
          .from('machines')
          .select('''
            *,
            machine_assignments (
              user_id,
              role,
              status
            )
          ''')
          .eq('admin_id', adminId)
          .order('created_at', ascending: false);

      _logger.d('Fetched ${response.length} machines for admin: $adminId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Error fetching machines by admin: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateMachineStatus(String machineId, String status) async {
    try {
      _logger.d('Updating machine status: $machineId to $status');

      await _supabase
          .from('machines')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', machineId);

      _logger.i('Machine status updated successfully');
    } catch (e) {
      _logger.e('Error updating machine status: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateMachineOperator(String machineId, String? operatorId) async {
    try {
      _logger.d('Updating machine operator: $machineId to ${operatorId ?? 'null'}');

      await _supabase
          .from('machines')
          .update({
            'current_operator_id': operatorId,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', machineId);

      _logger.i('Machine operator updated successfully');
    } catch (e) {
      _logger.e('Error updating machine operator: ${e.toString()}');
      rethrow;
    }
  }
}