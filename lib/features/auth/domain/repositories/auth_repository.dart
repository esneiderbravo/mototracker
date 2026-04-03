import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

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
    String? avatarUrl,
    String? documentType,
    String? documentNumber,
  });

  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  });
}
