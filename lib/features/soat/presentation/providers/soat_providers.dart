import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/supabase_soat_policy_repository.dart';
import '../../domain/entities/soat_policy.dart';
import '../../domain/repositories/soat_policy_repository.dart';

final soatPolicyRepositoryProvider = Provider<SoatPolicyRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSoatPolicyRepository(client);
});

final soatByMotorcycleProvider = StreamProvider.family<List<SoatPolicy>, String>((
  ref,
  motorcycleId,
) {
  final repository = ref.watch(soatPolicyRepositoryProvider);
  return repository.watchByMotorcycle(motorcycleId);
});

final soatByIdProvider = FutureProvider.family<SoatPolicy?, String>((ref, soatId) {
  final repository = ref.watch(soatPolicyRepositoryProvider);
  return repository.getById(soatId);
});

final activeSoatByMotorcycleProvider = FutureProvider.family<SoatPolicy?, String>((
  ref,
  motorcycleId,
) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) {
    return Future<SoatPolicy?>.value(null);
  }

  final repository = ref.watch(soatPolicyRepositoryProvider);
  return repository.getActivePolicy(motorcycleId);
});

final soatByLicensePlateProvider = FutureProvider.family<SoatPolicy?, String>((ref, rawPlate) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) {
    return Future<SoatPolicy?>.value(null);
  }

  final normalizedPlate = normalizeLicensePlate(rawPlate);
  if (normalizedPlate.isEmpty) {
    return Future<SoatPolicy?>.value(null);
  }

  return ref
      .watch(soatPolicyRepositoryProvider)
      .getActiveByLicensePlate(userId: authUser.id, licensePlate: normalizedPlate);
});

final expiringSoatProvider = FutureProvider.family<List<SoatPolicy>, int>((ref, days) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) {
    return Future<List<SoatPolicy>>.value([]);
  }

  return ref.watch(soatPolicyRepositoryProvider).getExpiringSoon(userId: authUser.id, days: days);
});
