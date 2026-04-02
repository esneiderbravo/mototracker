class AiMotorcycleData {
  const AiMotorcycleData({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
  });

  final String make;
  final String model;
  final int year;
  final String color;

  factory AiMotorcycleData.fromJson(Map<String, dynamic> json) {
    return AiMotorcycleData(
      make: (json['make'] as String? ?? '').trim(),
      model: (json['model'] as String? ?? '').trim(),
      year: int.tryParse('${json['year'] ?? ''}') ?? DateTime.now().year,
      color: (json['color'] as String? ?? 'Black').trim(),
    );
  }
}
