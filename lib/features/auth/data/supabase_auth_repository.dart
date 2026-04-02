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
  }) async {
    final client = _requiredClient;
    await client.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': fullName,
          'phone': phone,
          'phone_country_iso2': phoneCountryIso2,
        },
      ),
    );
  }

  SupabaseClient get _requiredClient {
    if (_client == null) {
      throw const AuthException('Supabase is not configured.');
    }
    return _client;
  }
}
