import 'package:flutter/foundation.dart';
import '../models/machine.dart';

class MachineProvider with ChangeNotifier {
  // Hardcoded machines list for now
  final List<Machine> _machines = [
    Machine(
      id: 'ALD-1001',
      serialNumber: 'SN001',
      location: 'Lab A',
      labName: 'Nanofabrication Lab',
      labInstitution: 'Tech University',
      model: 'ALD-2000',
      machineType: 'Thermal ALD',
      installDate: DateTime(2023, 1, 1),
      status: MachineStatus.idle,
      lastMaintenance: DateTime.now().subtract(const Duration(days: 5)),
      adminId: 'admin123',
    ),
    Machine(
      id: 'ALD-1002',
      serialNumber: 'SN002',
      location: 'Lab B',
      labName: 'Materials Lab',
      labInstitution: 'Tech University',
      model: 'ALD-2000',
      machineType: 'Plasma ALD',
      installDate: DateTime(2023, 2, 1),
      status: MachineStatus.running,
      lastMaintenance: DateTime.now().subtract(const Duration(days: 15)),
      adminId: 'admin123',
    ),
    Machine(
      id: 'ALD-1003',
      serialNumber: 'SN003',
      location: 'Lab C',
      labName: 'Surface Science Lab',
      labInstitution: 'Tech University',
      model: 'ALD-3000',
      machineType: 'Thermal ALD',
      installDate: DateTime(2023, 3, 1),
      status: MachineStatus.maintenance,
      lastMaintenance: DateTime.now().subtract(const Duration(days: 25)),
      adminId: 'admin123',
    ),
    Machine(
      id: 'ALD-1004',
      serialNumber: 'SN004',
      location: 'Lab D',
      labName: 'Semiconductor Lab',
      labInstitution: 'Tech University',
      model: 'ALD-3000',
      machineType: 'Plasma ALD',
      installDate: DateTime(2023, 4, 1),
      status: MachineStatus.error,
      lastMaintenance: DateTime.now().subtract(const Duration(days: 35)),
      adminId: 'admin123',
    ),
  ];

  // Get all machines
  List<Machine> get machines => List.unmodifiable(_machines);

  // Get machine by ID
  Machine? getMachineById(String id) {
    try {
      return _machines.firstWhere((machine) => machine.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new machine
  void addMachine(Machine machine) {
    _machines.add(machine);
    notifyListeners();
  }

  // Update machine
  void updateMachine(Machine updatedMachine) {
    final index = _machines.indexWhere((m) => m.id == updatedMachine.id);
    if (index != -1) {
      _machines[index] = updatedMachine;
      notifyListeners();
    }
  }

  // Delete machine
  void deleteMachine(String id) {
    _machines.removeWhere((machine) => machine.id == id);
    notifyListeners();
  }

  // Update machine status
  void updateMachineStatus(String id, MachineStatus status) {
    final machine = getMachineById(id);
    if (machine != null) {
      final updatedMachine = machine.copyWith(status: status);
      updateMachine(updatedMachine);
    }
  }
}
