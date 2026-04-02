import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> authStateChanges();
  User? get currentUser;
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
  Future<void> changePassword({required String newPassword});
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String phoneCountryIso2,
  });
}
