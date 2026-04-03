import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mototracker/features/soat/data/supabase_soat_policy_repository.dart';
import 'package:mototracker/features/soat/domain/entities/soat_policy.dart';
import 'package:mototracker/features/soat/domain/repositories/soat_policy_repository.dart';
import 'package:mototracker/features/soat/presentation/providers/soat_providers.dart';
import 'package:mototracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeSoatRepository implements SoatPolicyRepository {
  String? lastUserId;
  String? lastPlate;
  int activePolicyCalls = 0;

  @override
  Future<void> add(SoatPolicy policy) async {}

  @override
  Future<SoatPolicy?> getActiveByLicensePlate({
    required String userId,
    required String licensePlate,
  }) async {
    lastUserId = userId;
    lastPlate = licensePlate;
    return null;
  }

  @override
  Future<SoatPolicy?> getActivePolicy(String motorcycleId) async {
    activePolicyCalls++;
    return null;
  }

  @override
  Future<SoatPolicy?> getById(String id) async => null;

  @override
  Future<List<SoatPolicy>> getExpiringSoon({required String userId, required int days}) async => [];

  @override
  Future<List<SoatPolicy>> getHistoryByLicensePlate({
    required String userId,
    required String licensePlate,
  }) async => [];

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> update(SoatPolicy policy) async {}

  @override
  Stream<List<SoatPolicy>> watchByMotorcycle(String motorcycleId) => const Stream.empty();
}

void main() {
  test('normalizeLicensePlate removes spaces and symbols', () {
    expect(normalizeLicensePlate('ab c-123'), 'ABC123');
  });

  test('soatByLicensePlateProvider uses normalized value and current user scope', () async {
    final fakeRepo = _FakeSoatRepository();
    final fakeUser = User(
      id: 'user-42',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final container = ProviderContainer(
      overrides: [
        soatPolicyRepositoryProvider.overrideWithValue(fakeRepo),
        authUserProvider.overrideWith((_) => Stream<User?>.value(fakeUser)),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen<AsyncValue<SoatPolicy?>>(
      soatByLicensePlateProvider('ab c-123'),
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(soatByLicensePlateProvider('ab c-123').future);

    expect(fakeRepo.lastUserId, 'user-42');
    expect(fakeRepo.lastPlate, 'ABC123');
  });

  test('activeSoatByMotorcycleProvider returns null and skips repo when unauthenticated', () async {
    final fakeRepo = _FakeSoatRepository();
    final container = ProviderContainer(
      overrides: [
        soatPolicyRepositoryProvider.overrideWithValue(fakeRepo),
        authUserProvider.overrideWith((ref) => Stream<User?>.value(null)),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen<AsyncValue<SoatPolicy?>>(
      activeSoatByMotorcycleProvider('m-1'),
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final result = await container.read(activeSoatByMotorcycleProvider('m-1').future);

    expect(result, isNull);
    expect(fakeRepo.activePolicyCalls, 0);
  });

  test('activeSoatByMotorcycleProvider queries repo when authenticated', () async {
    final fakeRepo = _FakeSoatRepository();
    final fakeUser = User(
      id: 'user-100',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final container = ProviderContainer(
      overrides: [
        soatPolicyRepositoryProvider.overrideWithValue(fakeRepo),
        authUserProvider.overrideWith((ref) => Stream<User?>.value(fakeUser)),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen<AsyncValue<SoatPolicy?>>(
      activeSoatByMotorcycleProvider('m-1'),
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await container.read(activeSoatByMotorcycleProvider('m-1').future);

    expect(fakeRepo.activePolicyCalls, 1);
  });
}
