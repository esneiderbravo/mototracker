import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/supabase_motorcycle_repository.dart';
import '../../domain/entities/motorcycle.dart';
import '../../domain/repositories/motorcycle_repository.dart';

final motorcycleRepositoryProvider = Provider<MotorcycleRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMotorcycleRepository(client);
});

final motorcyclesProvider = StreamProvider<List<Motorcycle>>((ref) {
  final authUser = ref.watch(authUserProvider).valueOrNull;
  if (authUser == null) {
    return Stream<List<Motorcycle>>.value([]);
  }

  final repository = ref.watch(motorcycleRepositoryProvider);
  return repository.watchMotorcycles(authUser.id);
});

final motorcycleByIdProvider = FutureProvider.family<Motorcycle?, String>((ref, id) {
  final repository = ref.watch(motorcycleRepositoryProvider);
  return repository.getById(id);
});
