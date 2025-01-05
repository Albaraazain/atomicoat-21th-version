enum StepType {
  valve,
  purge,
  loop,
  setParameter,
}

class RecipeStep {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final StepType type;
  final List<RecipeStep>? subSteps;

  RecipeStep({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
    required this.type,
    this.subSteps,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      parameters: json['parameters'],
      type: StepType.values.firstWhere(
        (e) => e.toString() == 'StepType.${json['type']}',
        orElse: () => StepType.setParameter,
      ),
      subSteps: json['sub_steps'] != null
          ? (json['sub_steps'] as List)
              .map((step) => RecipeStep.fromJson(step))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parameters': parameters,
      'type': type.toString().split('.').last,
      'sub_steps': subSteps?.map((step) => step.toJson()).toList(),
    };
  }
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<RecipeStep> steps;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String machineId;
  final String substrate;
  final double chamberTemperatureSetPoint;
  final double pressureSetPoint;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.machineId,
    required this.substrate,
    required this.chamberTemperatureSetPoint,
    required this.pressureSetPoint,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      steps: (json['steps'] as List)
          .map((step) => RecipeStep.fromJson(step))
          .toList(),
      isPublic: json['is_public'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['created_by'],
      machineId: json['machine_id'],
      substrate: json['substrate'],
      chamberTemperatureSetPoint:
          json['chamber_temperature_set_point'].toDouble(),
      pressureSetPoint: json['pressure_set_point'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'steps': steps.map((step) => step.toJson()).toList(),
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'machine_id': machineId,
      'substrate': substrate,
      'chamber_temperature_set_point': chamberTemperatureSetPoint,
      'pressure_set_point': pressureSetPoint,
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<RecipeStep>? steps,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? machineId,
    String? substrate,
    double? chamberTemperatureSetPoint,
    double? pressureSetPoint,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      machineId: machineId ?? this.machineId,
      substrate: substrate ?? this.substrate,
      chamberTemperatureSetPoint:
          chamberTemperatureSetPoint ?? this.chamberTemperatureSetPoint,
      pressureSetPoint: pressureSetPoint ?? this.pressureSetPoint,
    );
  }

  factory Recipe.mock() {
    return Recipe(
      id: 'recipe_1',
      name: 'Standard ALD Process',
      description: 'Basic ALD process for thin film deposition',
      createdBy: 'operator_1',
      machineId: 'machine_1',
      substrate: 'Silicon Wafer',
      chamberTemperatureSetPoint: 200.0,
      pressureSetPoint: 1.0,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      steps: [
        RecipeStep(
          id: 'step_1',
          name: 'Precursor A Pulse',
          description: 'Introduce precursor A into chamber',
          type: StepType.valve,
          parameters: {
            'duration': 0.5,
            'temperature': 200.0,
            'pressure': 1.0,
          },
          subSteps: [],
        ),
        RecipeStep(
          id: 'step_2',
          name: 'Purge',
          description: 'Clear chamber of precursor A',
          type: StepType.purge,
          parameters: {
            'duration': 2.0,
            'flowRate': 100.0,
          },
          subSteps: [],
        ),
      ],
      isPublic: true,
    );
  }
}
