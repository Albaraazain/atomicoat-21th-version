enum MachineStatus {
  offline, // Machine is not connected
  idle, // Machine is connected but not running
  running, // Machine is running an experiment
  error, // Machine has encountered an error
  maintenance // Machine is under maintenance
}

class Machine {
  final String id; // Unique identifier for the machine
  final String serialNumber; // Physical serial number
  final String location; // Lab location identifier
  final String labName; // Name of the lab
  final String labInstitution; // Institution/Organization name
  final String model; // Model number/name
  final String machineType; // Type of ALD machine
  final DateTime installDate; // Installation date
  final MachineStatus status; // Current operational status
  final String? currentOperator; // ID of current operator (if any)
  final String? currentExperiment; // ID of current running experiment (if any)
  final DateTime lastMaintenance; // Last maintenance date
  final String adminId; // ID of the machine admin
  final bool isActive; // Whether the machine is active in the system

  Machine({
    required this.id,
    required this.serialNumber,
    required this.location,
    required this.labName,
    required this.labInstitution,
    required this.model,
    required this.machineType,
    required this.installDate,
    this.status = MachineStatus.offline,
    this.currentOperator,
    this.currentExperiment,
    required this.lastMaintenance,
    required this.adminId,
    this.isActive = true,
  });

  Machine copyWith({
    String? id,
    String? serialNumber,
    String? location,
    String? labName,
    String? labInstitution,
    String? model,
    String? machineType,
    DateTime? installDate,
    MachineStatus? status,
    String? currentOperator,
    String? currentExperiment,
    DateTime? lastMaintenance,
    String? adminId,
    bool? isActive,
  }) {
    return Machine(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      labName: labName ?? this.labName,
      labInstitution: labInstitution ?? this.labInstitution,
      model: model ?? this.model,
      machineType: machineType ?? this.machineType,
      installDate: installDate ?? this.installDate,
      status: status ?? this.status,
      currentOperator: currentOperator ?? this.currentOperator,
      currentExperiment: currentExperiment ?? this.currentExperiment,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      adminId: adminId ?? this.adminId,
      isActive: isActive ?? this.isActive,
    );
  }
}
