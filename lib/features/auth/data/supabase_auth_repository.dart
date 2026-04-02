import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient? _client;

  @override
  Stream<AuthState> authStateChanges() {
    if (_client == null) {
      return const Stream<AuthState>.empty();
    }
    return _client.auth.onAuthStateChange;
  }

  @override
  User? get currentUser => _client?.auth.currentUser;

  @override
  Future<void> signIn({required String email, required String password}) async {
    final client = _requiredClient;
    await client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    final client = _requiredClient;
    await client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    final client = _requiredClient;
    await client.auth.signOut();
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    final client = _requiredClient;
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String phoneCountryIso2,
    String? avatarUrl,
  }) async {
    final client = _requiredClient;
    final data = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'phone_country_iso2': phoneCountryIso2,
    };
    if (avatarUrl != null) {
      data['avatar_url'] = avatarUrl;
    }

    await client.auth.updateUser(
      UserAttributes(
        data: data,
      ),
    );
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final client = _requiredClient;
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await client.storage
        .from('profiles')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return client.storage.from('profiles').getPublicUrl(path);
  }

  SupabaseClient get _requiredClient {
    if (_client == null) {
      throw const AuthException('Supabase is not configured.');
    }
    return _client;
  }
}
