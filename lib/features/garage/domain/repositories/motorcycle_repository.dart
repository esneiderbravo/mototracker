import 'dart:typed_data';

import '../entities/motorcycle.dart';

abstract class MotorcycleRepository {
  Stream<List<Motorcycle>> watchMotorcycles(String userId);
  Future<Motorcycle?> getById(String id);
  Future<void> add(Motorcycle motorcycle);
  Future<void> update(Motorcycle motorcycle);
  Future<void> remove(String id);
  Future<String?> uploadImage({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  });
}
