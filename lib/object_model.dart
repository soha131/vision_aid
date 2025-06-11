class ObjectPrediction {
  final String? description;
  final List<String>? alerts;
  final String? text;

  ObjectPrediction({
    this.description,
    this.alerts,
    this.text,
  });

  factory ObjectPrediction.fromJson(Map<String, dynamic> json) {
    return ObjectPrediction(
      description: json['description'],
      alerts: List<String>.from(json['alerts'] ?? []),
      text: json['text'],
    );
  }
}
