import '../entities/soat_policy.dart';

abstract class SoatPolicyRepository {
  Stream<List<SoatPolicy>> watchByMotorcycle(String motorcycleId);

  Future<SoatPolicy?> getById(String id);
  Future<void> add(SoatPolicy policy);
  Future<void> update(SoatPolicy policy);
  Future<void> remove(String id);

  Future<SoatPolicy?> getActivePolicy(String motorcycleId);

  Future<SoatPolicy?> getActiveByLicensePlate({
    required String userId,
    required String licensePlate,
  });

  Future<List<SoatPolicy>> getHistoryByLicensePlate({
    required String userId,
    required String licensePlate,
  });

  Future<List<SoatPolicy>> getExpiringSoon({required String userId, required int days});
}
