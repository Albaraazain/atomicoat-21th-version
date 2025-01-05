import '../../../features/recipes/models/recipe.dart';
import '../../../features/process/models/process_execution.dart';
import '../../../features/process/models/process_data_point.dart';
import 'experiment_metadata.dart';
import 'experiment_result.dart';

class Experiment {
  final String id;
  final String machineId;
  final Recipe recipe;
  final DateTime startTime;
  final DateTime endTime;
  final String operatorId;
  final ProcessStatus status;
  final List<ProcessDataPoint> dataPoints;
  final ExperimentMetadata metadata;
  final ExperimentResult? result;
  final String? notes;

  Experiment({
    required this.id,
    required this.machineId,
    required this.recipe,
    required this.startTime,
    required this.endTime,
    required this.operatorId,
    required this.status,
    required this.dataPoints,
    required this.metadata,
    this.result,
    this.notes,
  });

  Duration get duration => endTime.difference(startTime);

  bool get isSuccessful =>
      status == ProcessStatus.completed &&
      (result?.qualityScore ?? 0) >= metadata.qualityThreshold;

  Map<String, List<ProcessDataPoint>> get parameterDataSeries {
    final series = <String, List<ProcessDataPoint>>{};
    for (final point in dataPoints) {
      series.putIfAbsent(point.parameter, () => []).add(point);
    }
    return series;
  }

  List<ProcessDataPoint> getParameterData(String parameter) {
    return dataPoints.where((point) => point.parameter == parameter).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machine_id': machineId,
      'recipe': recipe.toJson(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'operator_id': operatorId,
      'status': status.toString().split('.').last,
      'data_points': dataPoints.map((p) => p.toJson()).toList(),
      'metadata': metadata.toJson(),
      'result': result?.toJson(),
      'notes': notes,
    };
  }

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      id: json['id'],
      machineId: json['machine_id'],
      recipe: Recipe.fromJson(json['recipe']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      operatorId: json['operator_id'],
      status: ProcessStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => ProcessStatus.failed,
      ),
      dataPoints: (json['data_points'] as List)
          .map((p) => ProcessDataPoint.fromJson(p))
          .toList(),
      metadata: ExperimentMetadata.fromJson(json['metadata']),
      result: json['result'] != null
          ? ExperimentResult.fromJson(json['result'])
          : null,
      notes: json['notes'],
    );
  }

  factory Experiment.fromProcessExecution(
    ProcessExecution process,
    ExperimentMetadata metadata,
    ExperimentResult? result,
  ) {
    return Experiment(
      id: process.id,
      machineId: process.machineId,
      recipe: process.recipe,
      startTime: process.startTime,
      endTime: process.endTime!,
      operatorId: process.operatorId,
      status: process.status,
      dataPoints: process.dataPoints,
      metadata: metadata,
      result: result,
    );
  }

  @override
  String toString() =>
      'Experiment(id: $id, recipe: ${recipe.name}, status: $status)';
}
