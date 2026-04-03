import 'package:flutter_test/flutter_test.dart';
import 'package:mototracker/features/soat/domain/entities/soat_policy.dart';

void main() {
  group('SoatPolicy', () {
    final policy = SoatPolicy(
      id: '1',
      userId: 'user-1',
      motorcycleId: 'moto-1',
      insurer: 'ACME',
      policyNumber: 'ABC123',
      startDate: DateTime(2026, 1, 1),
      expiryDate: DateTime(2026, 1, 31),
      notes: 'note',
      createdAt: DateTime(2026, 1, 1),
    );

    test('serializes to and from json', () {
      final json = policy.toJson();
      final roundTrip = SoatPolicy.fromJson(json);

      expect(roundTrip.id, policy.id);
      expect(roundTrip.userId, policy.userId);
      expect(roundTrip.motorcycleId, policy.motorcycleId);
      expect(roundTrip.policyNumber, policy.policyNumber);
      expect(roundTrip.startDate, DateTime(2026, 1, 1));
      expect(roundTrip.expiryDate, DateTime(2026, 1, 31));
    });

    test('computes expiry bands with date-only boundaries', () {
      expect(policy.expiryStatus(DateTime(2025, 12, 10)), SoatExpiryStatus.active);
      expect(policy.expiryStatus(DateTime(2026, 1, 10)), SoatExpiryStatus.due30);
      expect(policy.expiryStatus(DateTime(2026, 1, 20)), SoatExpiryStatus.due15);
      expect(policy.expiryStatus(DateTime(2026, 1, 28)), SoatExpiryStatus.due5);
      expect(policy.expiryStatus(DateTime(2026, 2, 1)), SoatExpiryStatus.expired);
    });
  });
}
