import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/soat_policy.dart';
import '../domain/repositories/soat_policy_repository.dart';

class SupabaseSoatPolicyRepository implements SoatPolicyRepository {
  SupabaseSoatPolicyRepository(this._client);

  final SupabaseClient? _client;

  @override
  Stream<List<SoatPolicy>> watchByMotorcycle(String motorcycleId) {
    final client = _client;
    if (client == null) {
      return Stream<List<SoatPolicy>>.value([]);
    }

    return client
        .from('soat_policies')
        .stream(primaryKey: ['id'])
        .eq('motorcycle_id', motorcycleId)
        .order('expiry_date', ascending: false)
        .map((rows) => rows.map(SoatPolicy.fromJson).toList());
  }

  @override
  Future<SoatPolicy?> getById(String id) async {
    final data = await _requiredClient.from('soat_policies').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return SoatPolicy.fromJson(data);
  }

  @override
  Future<void> add(SoatPolicy policy) async {
    await _requiredClient.from('soat_policies').insert(policy.toInsertJson());
  }

  @override
  Future<void> update(SoatPolicy policy) async {
    await _requiredClient.from('soat_policies').update(policy.toJson()).eq('id', policy.id);
  }

  @override
  Future<void> remove(String id) async {
    await _requiredClient.from('soat_policies').delete().eq('id', id);
  }

  @override
  Future<SoatPolicy?> getActivePolicy(String motorcycleId) async {
    final today = _formatDate(DateTime.now());
    final data = await _requiredClient
        .from('soat_policies')
        .select()
        .eq('motorcycle_id', motorcycleId)
        .gte('expiry_date', today)
        .order('expiry_date', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return SoatPolicy.fromJson(data);
  }

  @override
  Future<SoatPolicy?> getActiveByLicensePlate({
    required String userId,
    required String licensePlate,
  }) async {
    final motorcycleId = await _resolveMotorcycleIdByPlate(
      userId: userId,
      licensePlate: licensePlate,
    );
    if (motorcycleId == null) return null;
    return getActivePolicy(motorcycleId);
  }

  @override
  Future<List<SoatPolicy>> getHistoryByLicensePlate({
    required String userId,
    required String licensePlate,
  }) async {
    final motorcycleId = await _resolveMotorcycleIdByPlate(
      userId: userId,
      licensePlate: licensePlate,
    );
    if (motorcycleId == null) return [];

    final rows = await _requiredClient
        .from('soat_policies')
        .select()
        .eq('user_id', userId)
        .eq('motorcycle_id', motorcycleId)
        .order('expiry_date', ascending: false);
    return rows.map(SoatPolicy.fromJson).toList();
  }

  @override
  Future<List<SoatPolicy>> getExpiringSoon({required String userId, required int days}) async {
    final now = DateTime.now();
    final until = now.add(Duration(days: days));

    final rows = await _requiredClient
        .from('soat_policies')
        .select()
        .eq('user_id', userId)
        .gte('expiry_date', _formatDate(now))
        .lte('expiry_date', _formatDate(until))
        .order('expiry_date', ascending: true);

    return rows.map(SoatPolicy.fromJson).toList();
  }

  Future<String?> _resolveMotorcycleIdByPlate({
    required String userId,
    required String licensePlate,
  }) async {
    final normalizedPlate = normalizeLicensePlate(licensePlate);
    if (normalizedPlate.isEmpty) return null;

    final motorcycles = await _requiredClient
        .from('motorcycles')
        .select('id, created_at')
        .eq('user_id', userId)
        .eq('license_plate', normalizedPlate);

    if (motorcycles.isEmpty) return null;

    motorcycles.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          DateTime.tryParse(b['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return motorcycles.first['id'] as String;
  }

  SupabaseClient get _requiredClient {
    if (_client == null) {
      throw const AuthException('Supabase is not configured.');
    }
    return _client;
  }
}

String normalizeLicensePlate(String value) {
  return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

String _formatDate(DateTime date) {
  final yyyy = date.year.toString().padLeft(4, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd';
}
