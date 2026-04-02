import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/motorcycle.dart';
import '../domain/repositories/motorcycle_repository.dart';

class SupabaseMotorcycleRepository implements MotorcycleRepository {
  SupabaseMotorcycleRepository(this._client);

  final SupabaseClient? _client;

  @override
  Stream<List<Motorcycle>> watchMotorcycles(String userId) {
    final client = _client;
    if (client == null) {
      return Stream<List<Motorcycle>>.value([]);
    }

    return client
        .from('motorcycles')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Motorcycle.fromJson).toList());
  }

  @override
  Future<Motorcycle?> getById(String id) async {
    final client = _requiredClient;
    final data = await client.from('motorcycles').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Motorcycle.fromJson(data);
  }

  @override
  Future<void> add(Motorcycle motorcycle) async {
    final client = _requiredClient;
    await client.from('motorcycles').insert(motorcycle.toInsertJson());
  }

  @override
  Future<void> update(Motorcycle motorcycle) async {
    final client = _requiredClient;
    await client.from('motorcycles').update(motorcycle.toJson()).eq('id', motorcycle.id);
  }

  @override
  Future<void> remove(String id) async {
    final client = _requiredClient;
    await client.from('motorcycles').delete().eq('id', id);
  }

  @override
  Future<String?> uploadImage({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final client = _requiredClient;
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await client.storage
        .from('motorcycles')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return client.storage.from('motorcycles').getPublicUrl(path);
  }

  SupabaseClient get _requiredClient {
    if (_client == null) {
      throw const AuthException('Supabase is not configured.');
    }
    return _client;
  }
}
