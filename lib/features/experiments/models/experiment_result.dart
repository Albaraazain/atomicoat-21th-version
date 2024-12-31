class ExperimentResult {
  final Map<String, double> qualityMetrics;
  final Map<String, List<double>> parameterDeviations;
  final List<String> observations;
  final List<Map<String, dynamic>> recommendations;
  final Map<String, double> measurements;
  final double qualityScore;
  final List<String> criticalDeviations;

  ExperimentResult({
    required this.qualityMetrics,
    required this.parameterDeviations,
    required this.observations,
    required this.recommendations,
    required this.measurements,
    required this.qualityScore,
    this.criticalDeviations = const [],
  });

  factory ExperimentResult.fromMap(Map<String, dynamic> map) {
    return ExperimentResult(
      qualityMetrics: Map<String, double>.from(map['qualityMetrics']),
      parameterDeviations: Map<String, List<double>>.from(
        map['parameterDeviations'].map(
          (key, value) => MapEntry(key, List<double>.from(value)),
        ),
      ),
      observations: List<String>.from(map['observations']),
      recommendations: List<Map<String, dynamic>>.from(map['recommendations']),
      measurements: Map<String, double>.from(map['measurements']),
      qualityScore: map['qualityScore']?.toDouble() ?? 0.0,
      criticalDeviations: List<String>.from(map['criticalDeviations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qualityMetrics': qualityMetrics,
      'parameterDeviations': parameterDeviations,
      'observations': observations,
      'recommendations': recommendations,
      'measurements': measurements,
      'qualityScore': qualityScore,
      'criticalDeviations': criticalDeviations,
    };
  }
}
