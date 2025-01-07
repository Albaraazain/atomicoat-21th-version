enum MachineStatus {
  offline,
  idle,
  running,
  error,
  maintenance
}

class Machine {
  final String id;
  final String serialNumber;
  final String location;
  final String labName;
  final String labInstitution;
  final String model;
  final String machineType;
  final DateTime installDate;
  final MachineStatus status;
  final String? currentOperatorId;
  final String? currentProcessId;
  final DateTime lastMaintenance;
  final String adminId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.currentOperatorId,
    this.currentProcessId,
    required this.lastMaintenance,
    required this.adminId,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

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
    String? currentOperatorId,
    String? currentProcessId,
    DateTime? lastMaintenance,
    String? adminId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      currentOperatorId: currentOperatorId ?? this.currentOperatorId,
      currentProcessId: currentProcessId ?? this.currentProcessId,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      adminId: adminId ?? this.adminId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert from Map (database) to Machine object
  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'],
      serialNumber: map['serial_number'],
      location: map['location'],
      labName: map['lab_name'],
      labInstitution: map['lab_institution'],
      model: map['model'],
      machineType: map['machine_type'],
      installDate: DateTime.parse(map['install_date']),
      status: _parseStatus(map['status']),
      currentOperatorId: map['current_operator_id'],
      currentProcessId: map['current_process_id'],
      lastMaintenance: DateTime.parse(map['last_maintenance_date']),
      adminId: map['admin_id'],
      isActive: map['is_active'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Convert Machine object to Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'location': location,
      'lab_name': labName,
      'lab_institution': labInstitution,
      'model': model,
      'machine_type': machineType,
      'install_date': installDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'current_operator_id': currentOperatorId,
      'current_process_id': currentProcessId,
      'last_maintenance_date': lastMaintenance.toIso8601String(),
      'admin_id': adminId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static MachineStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'offline':
        return MachineStatus.offline;
      case 'idle':
        return MachineStatus.idle;
      case 'running':
        return MachineStatus.running;
      case 'error':
        return MachineStatus.error;
      case 'maintenance':
        return MachineStatus.maintenance;
      default:
        return MachineStatus.offline;
    }
  }

  static MachineStatus parseStatus(String status) {
    return _parseStatus(status);
  }
}
