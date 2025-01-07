enum StepType {
  valve,
  purge,
  loop,
  setParameter,
}

class RecipeStep {
  final String? id;
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final StepType type;
  final int sequenceNumber;
  final String? parentStepId;

  RecipeStep({
    this.id,
    required this.name,
    required this.description,
    required this.parameters,
    required this.type,
    required this.sequenceNumber,
    this.parentStepId,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      parameters: (json['parameters'] ?? {}) as Map<String, dynamic>,
      type: StepType.values.firstWhere(
        (e) => e.toString() == 'StepType.${json['type']}',
        orElse: () => StepType.setParameter,
      ),
      sequenceNumber: (json['sequence_number'] ?? 0) as int,
      parentStepId: json['parent_step_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'description': description,
      'parameters': parameters,
      'type': type.toString().split('.').last,
      'sequence_number': sequenceNumber,
    } as Map<String, dynamic>;
    if (id != null) json['id'] = id as Object;
    if (parentStepId != null) json['parent_step_id'] = parentStepId as Object;
    return json;
  }
}

class Recipe {
  final String? id;
  final String name;
  final String description;
  final List<RecipeStep> steps;
  final bool isPublic;
  final int version;
  final String createdBy;
  final String machineType;
  final String? substrate;
  final double chamberTemperatureSetPoint;
  final double pressureSetPoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.isPublic = false,
    this.version = 1,
    required this.createdBy,
    required this.machineType,
    this.substrate,
    required this.chamberTemperatureSetPoint,
    required this.pressureSetPoint,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      steps: (json['recipe_steps'] as List? ?? [])
          .map((step) => RecipeStep.fromJson(step))
          .toList(),
      isPublic: json['is_public'] ?? false,
      version: json['version'] ?? 1,
      createdBy: json['created_by'],
      machineType: json['machine_type'],
      substrate: json['substrate'],
      chamberTemperatureSetPoint: json['chamber_temperature_set_point'].toDouble(),
      pressureSetPoint: json['pressure_set_point'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'description': description,
      'is_public': isPublic,
      'version': version,
      'created_by': createdBy,
      'machine_type': machineType,
      'substrate': substrate,
      'chamber_temperature_set_point': chamberTemperatureSetPoint,
      'pressure_set_point': pressureSetPoint,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) json['id'] = id;
    return json;
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<RecipeStep>? steps,
    bool? isPublic,
    int? version,
    String? createdBy,
    String? machineType,
    String? substrate,
    double? chamberTemperatureSetPoint,
    double? pressureSetPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      isPublic: isPublic ?? this.isPublic,
      version: version ?? this.version,
      createdBy: createdBy ?? this.createdBy,
      machineType: machineType ?? this.machineType,
      substrate: substrate ?? this.substrate,
      chamberTemperatureSetPoint: chamberTemperatureSetPoint ?? this.chamberTemperatureSetPoint,
      pressureSetPoint: pressureSetPoint ?? this.pressureSetPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Mock recipe for testing purposes
  static Recipe getMockRecipe() {
    final now = DateTime.now();
    return Recipe(
      id: 'mock_recipe_1',
      name: 'Standard ALD Process',
      description: 'Basic ALD process for thin film deposition',
      steps: [
        RecipeStep(
          id: 'step_1',
          name: 'Precursor A Pulse',
          description: 'Introduce precursor A into chamber',
          type: StepType.valve,
          parameters: {
            'valve_number': '1',
            'duration': 1.0,
            'flow_rate': 100.0,
          },
          sequenceNumber: 1,
        ),
        RecipeStep(
          id: 'step_2',
          name: 'Purge Step',
          description: 'Clear chamber of precursor A',
          type: StepType.purge,
          parameters: {
            'duration': 5.0,
            'flow_rate': 200.0,
          },
          sequenceNumber: 2,
        ),
        RecipeStep(
          id: 'step_3',
          name: 'Temperature Ramp',
          description: 'Ramp up chamber temperature',
          type: StepType.setParameter,
          parameters: {
            'parameter': 'temperature',
            'value': 250.0,
          },
          sequenceNumber: 3,
        ),
      ],
      isPublic: true,
      version: 1,
      createdBy: 'mock_operator_1',
      machineType: 'thermal_ald',
      substrate: 'Silicon Wafer',
      chamberTemperatureSetPoint: 200.0,
      pressureSetPoint: 1.0,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
  }
}
