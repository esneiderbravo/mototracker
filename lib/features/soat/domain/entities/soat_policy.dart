enum SoatExpiryStatus { active, due30, due15, due5, expired }

class SoatPolicy {
  const SoatPolicy({
    required this.id,
    required this.userId,
    required this.motorcycleId,
    required this.insurer,
    required this.policyNumber,
    required this.startDate,
    required this.expiryDate,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String motorcycleId;
  final String insurer;
  final String policyNumber;
  final DateTime startDate;
  final DateTime expiryDate;
  final String notes;
  final DateTime createdAt;

  String get displayName => '$policyNumber - $insurer';

  int daysUntilExpiry(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  bool isExpired(DateTime now) => daysUntilExpiry(now) < 0;

  SoatExpiryStatus expiryStatus(DateTime now) {
    final days = daysUntilExpiry(now);
    if (days < 0) return SoatExpiryStatus.expired;
    if (days <= 5) return SoatExpiryStatus.due5;
    if (days <= 15) return SoatExpiryStatus.due15;
    if (days <= 30) return SoatExpiryStatus.due30;
    return SoatExpiryStatus.active;
  }

  SoatPolicy copyWith({
    String? id,
    String? userId,
    String? motorcycleId,
    String? insurer,
    String? policyNumber,
    DateTime? startDate,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return SoatPolicy(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      motorcycleId: motorcycleId ?? this.motorcycleId,
      insurer: insurer ?? this.insurer,
      policyNumber: policyNumber ?? this.policyNumber,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SoatPolicy.fromJson(Map<String, dynamic> json) {
    return SoatPolicy(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      motorcycleId: json['motorcycle_id'] as String,
      insurer: json['insurer'] as String? ?? '',
      policyNumber: json['policy_number'] as String? ?? '',
      startDate: DateTime.parse(json['start_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'motorcycle_id': motorcycleId,
      'insurer': insurer,
      'policy_number': policyNumber,
      'start_date': _formatDate(startDate),
      'expiry_date': _formatDate(expiryDate),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'motorcycle_id': motorcycleId,
      'insurer': insurer,
      'policy_number': policyNumber,
      'start_date': _formatDate(startDate),
      'expiry_date': _formatDate(expiryDate),
      'notes': notes,
    };
  }

  static String _formatDate(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }
}
