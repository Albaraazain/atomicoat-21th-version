// In data_point.dart

class ProcessDataPoint {
  final String parameter;
  final double value;
  final DateTime timestamp;
  final String? unit;
  final double? setPoint;

  ProcessDataPoint({
    required this.parameter,
    required this.value,
    required this.timestamp,
    this.unit,
    this.setPoint,
  });

  double get deviation => setPoint != null ? (value - setPoint!).abs() : 0.0;
  bool get isWithinTolerance =>
      setPoint != null ? deviation <= (setPoint! * 0.05) : true;

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'unit': unit,
      'set_point': setPoint,
    };
  }

  factory ProcessDataPoint.fromJson(Map<String, dynamic> json) {
    return ProcessDataPoint(
      parameter: json['parameter'],
      value: json['value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      unit: json['unit'],
      setPoint: json['set_point']?.toDouble(),
    );
  }

  @override
  String toString() =>
      'ProcessDataPoint($parameter: $value${unit != null ? ' $unit' : ''})';
}
