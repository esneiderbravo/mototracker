enum DocumentType { cc, ce, pas }

extension DocumentTypeX on DocumentType {
  String get documentType {
    switch (this) {
      case DocumentType.cc:
        return 'C';
      case DocumentType.ce:
        return 'CE';
      case DocumentType.pas:
        return 'P';
    }
  }

  String get displayLabel {
    switch (this) {
      case DocumentType.cc:
        return 'C.C.';
      case DocumentType.ce:
        return 'C.E.';
      case DocumentType.pas:
        return 'Pasaporte';
    }
  }
}

DocumentType documentTypeFromCode(String code) {
  switch (code.toUpperCase()) {
    case 'CE':
      return DocumentType.ce;
    case 'P':
      return DocumentType.pas;
    default:
      return DocumentType.cc;
  }
}

class ProfileIdentification {
  const ProfileIdentification({required this.documentType, required this.documentNumber});

  final DocumentType documentType;

  /// Normalized numeric-only document number.
  final String documentNumber;

  bool get isComplete => documentNumber.isNotEmpty;

  /// Builds from Supabase `user_metadata` map.
  static ProfileIdentification? fromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;
    final typeCode = metadata['document_type'] as String?;
    final rawNumber = (metadata['document_number'] as String?)?.trim() ?? '';
    final number = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (typeCode == null || number.isEmpty) return null;
    return ProfileIdentification(
      documentType: documentTypeFromCode(typeCode),
      documentNumber: number,
    );
  }

  /// Key-value entries to merge into Supabase user_metadata.
  Map<String, String> toMetadataEntries() => {
    'document_type': documentType.documentType,
    'document_number': documentNumber,
  };

  ProfileIdentification copyWith({DocumentType? documentType, String? documentNumber}) =>
      ProfileIdentification(
        documentType: documentType ?? this.documentType,
        documentNumber: documentNumber ?? this.documentNumber,
      );
}
