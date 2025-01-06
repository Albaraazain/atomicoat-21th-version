import 'package:flutter/foundation.dart';
import '../repositories/machine_repository.dart';
import '../models/machine.dart';
import '../../../core/services/logger_service.dart';

class MachineProvider extends ChangeNotifier {
  final MachineRepository _repository;
  final LoggerService _logger;
  List<Machine> _machines = [];
  bool _isLoading = false;
  String? _error;

  MachineProvider(this._repository) : _logger = LoggerService('MachineProvider');

  List<Machine> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>?> createMachine({
    required String serialNumber,
    required String location,
    required String labName,
    required String labInstitution,
    required String model,
    required String machineType,
    required String adminEmail,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.d('Creating machine with serial number: $serialNumber');

      final response = await _repository.createMachine(
        serialNumber: serialNumber,
        location: location,
        labName: labName,
        labInstitution: labInstitution,
        model: model,
        machineType: machineType,
        adminEmail: adminEmail,
      );

      // If this is a new machine, add it to our local list
      if (response != null) {
        final newMachine = Machine.fromMap(response);
        _machines.add(newMachine);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _logger.e('Error creating machine: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMachinesForAdmin(String adminId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.d('Loading machines for admin: $adminId');
      final response = await _repository.getMachinesByAdmin(adminId);

      _machines = response.map((data) => Machine.fromMap(data)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading machines: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMachineStatus(String machineId, String statusStr) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateMachineStatus(machineId, statusStr);

      // Update the local machine status
      final index = _machines.indexWhere((m) => m.id == machineId);
      if (index != -1) {
        _machines[index] = _machines[index].copyWith(
          status: Machine.parseStatus(statusStr),
        );
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error updating machine status: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMachineOperator(String machineId, String? operatorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateMachineOperator(machineId, operatorId);

      // Update the local machine operator
      final index = _machines.indexWhere((m) => m.id == machineId);
      if (index != -1) {
        _machines[index] = _machines[index].copyWith(currentOperatorId: operatorId);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error updating machine operator: ${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
