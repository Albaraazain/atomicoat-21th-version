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

  factory ExperimentResult.fromJson(Map<String, dynamic> json) {
    return ExperimentResult(
      qualityMetrics: Map<String, double>.from(json['quality_metrics']),
      parameterDeviations: Map<String, List<double>>.from(
        json['parameter_deviations'].map(
          (key, value) => MapEntry(key, List<double>.from(value)),
        ),
      ),
      observations: List<String>.from(json['observations']),
      recommendations: List<Map<String, dynamic>>.from(json['recommendations']),
      measurements: Map<String, double>.from(json['measurements']),
      qualityScore: json['quality_score']?.toDouble() ?? 0.0,
      criticalDeviations: List<String>.from(json['critical_deviations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality_metrics': qualityMetrics,
      'parameter_deviations': parameterDeviations,
      'observations': observations,
      'recommendations': recommendations,
      'measurements': measurements,
      'quality_score': qualityScore,
      'critical_deviations': criticalDeviations,
    };
  }
}
