import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../core/utils/locale_controller.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/app_alerts.dart';
import '../../../../shared/widgets/moto_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _avatarUrl;
  XFile? _selectedAvatar;
  String? _loadedUserId;
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPhoneCountryIso2 = 'CO';
  String _phoneDigits = '';
  bool _isLoadingProfile = false;
  bool _isSaving = false;

  Future<void> _loadProfileData(
    String userId,
    Map<String, dynamic>? metadata,
    String fallbackDisplayName,
  ) async {
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    final fullName = (metadata?['full_name'] as String?)?.trim();
    final phone = (metadata?['phone'] as String?)?.trim() ?? '';
    final avatarUrl = (metadata?['avatar_url'] as String?)?.trim();
    final countryIso =
        ((metadata?['phone_country_iso2'] as String?)?.trim().toUpperCase().isNotEmpty ?? false)
        ? (metadata?['phone_country_iso2'] as String).toUpperCase()
        : 'CO';
    if (!mounted) return;
    setState(() {
      _loadedUserId = userId;
      _avatarUrl = (avatarUrl?.isEmpty ?? true) ? null : avatarUrl;
      _selectedAvatar = null;
      _fullNameController.text = (fullName?.isNotEmpty ?? false)
          ? fullName!
          : fallbackDisplayName;
      _selectedPhoneCountryIso2 = countryIso;
      _phoneDigits = _digitsOnly(phone);
      _phoneController.text = _toLocalDigits(_phoneDigits, countryIso);
    });
    _isLoadingProfile = false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null) return;
    if (!mounted) return;
    setState(() => _selectedAvatar = image);
  }

  Future<void> _saveProfile(String userId) async {
    setState(() => _isSaving = true);
    try {
      var avatarUrl = _avatarUrl;
      if (_selectedAvatar != null) {
        final bytes = await _selectedAvatar!.readAsBytes();
        avatarUrl = await ref.read(authRepositoryProvider).uploadAvatar(
          userId: userId,
          fileName: _selectedAvatar!.name,
          bytes: bytes,
        );
      }

      await ref.read(authRepositoryProvider).updateProfile(
            fullName: _fullNameController.text.trim(),
            phone: _phoneDigits.isNotEmpty
                ? _phoneDigits
                : _digitsOnly(_phoneController.text.trim()),
            phoneCountryIso2: _selectedPhoneCountryIso2,
            avatarUrl: avatarUrl,
          );

      if (mounted) {
        setState(() {
          _avatarUrl = avatarUrl;
          _selectedAvatar = null;
        });
      }
      if (!mounted) return;
      final t = Translations.of(context);
      AppAlerts.success(context, message: t.profile.saveSuccess);
    } catch (e) {
      if (!mounted) return;
      final t = Translations.of(context);
      AppAlerts.error(context, message: t.profile.saveError, detail: e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final user = ref.watch(authUserProvider).valueOrNull;
    final locale = ref.watch(localeControllerProvider);
    final localeController = ref.read(localeControllerProvider.notifier);
    final userId = user?.id ?? 'guest';

    final emailPrefix = (user?.email ?? '').split('@').first.trim();
    final fallbackDisplayName = emailPrefix.isEmpty
        ? 'Moto Rider'
        : _capitalizeWords(emailPrefix.replaceAll('.', ' '));

    if (_loadedUserId != userId) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadProfileData(userId, user?.userMetadata, fallbackDisplayName),
      );
    }

    final safeDisplayName = _fullNameController.text.trim().isEmpty
        ? fallbackDisplayName
        : _fullNameController.text.trim();
    final avatarFile = _selectedAvatar != null ? File(_selectedAvatar!.path) : null;

    return Scaffold(
      bottomNavigationBar: MotoBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/garage');
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.profile.pilotProfile.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  _LocaleToggle(
                    isSpanish: locale == AppLocale.es,
                    onSpanish: localeController.setSpanish,
                    onEnglish: localeController.setEnglish,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeTokens.surface,
                        border: Border.all(color: Colors.white70, width: 3),
                      ),
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      child: avatarFile != null
                          ? Image.file(avatarFile, width: 150, height: 150, fit: BoxFit.cover)
                          : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? Image.network(
                              _avatarUrl!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Text(
                                  safeDisplayName[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w700),
                                );
                              },
                            )
                          : Text(
                              safeDisplayName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w700),
                            ),
                    ),
                    IconButton(
                      onPressed: _pickAvatar,
                      style: IconButton.styleFrom(
                        backgroundColor: ThemeTokens.primary,
                        foregroundColor: ThemeTokens.textPrimary,
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  t.garage.addPhoto,
                  style: const TextStyle(color: ThemeTokens.textSecondary),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  safeDisplayName,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${t.profile.riderSince.toUpperCase()} MAR 2026',
                  style: const TextStyle(
                    color: ThemeTokens.primary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _Label(label: t.profile.fullName),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(hintText: t.profile.fullName),
              ),
              const SizedBox(height: 14),
              _Label(label: t.profile.mobilePhone),
              IntlPhoneField(
                controller: _phoneController,
                initialCountryCode: _selectedPhoneCountryIso2,
                disableLengthCheck: true,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: t.profile.mobilePhone),
                onCountryChanged: (country) {
                  setState(() {
                    _selectedPhoneCountryIso2 = country.code;
                    if (_phoneController.text.trim().isNotEmpty) {
                      _phoneDigits = _digitsOnly('${country.dialCode}${_phoneController.text.trim()}');
                    }
                  });
                },
                onChanged: (phone) {
                  _selectedPhoneCountryIso2 = phone.countryISOCode;
                  _phoneDigits = _digitsOnly(phone.completeNumber);
                },
              ),
              const SizedBox(height: 14),
              _Label(label: t.profile.emailAddress),
              _ReadOnlyField(value: user?.email ?? t.profile.noEmail),
              const SizedBox(height: 8),
              Text(
                t.profile.emailReadOnlyHint,
                style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _saveProfile(userId),
                icon: const Icon(Icons.save_outlined),
                label: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.profile.saveChanges),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/change-password'),
                icon: const Icon(Icons.lock_outline),
                label: Text(t.auth.changePassword),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x66FF1744)),
                  foregroundColor: const Color(0xFFFF5C6B),
                ),
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/auth');
                },
                icon: const Icon(Icons.logout),
                label: Text(t.auth.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocaleToggle extends StatelessWidget {
  const _LocaleToggle({required this.isSpanish, required this.onSpanish, required this.onEnglish});

  final bool isSpanish;
  final VoidCallback onSpanish;
  final VoidCallback onEnglish;

  @override
  Widget build(BuildContext context) {
    Widget segment({required String label, required bool selected, required VoidCallback onTap}) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? ThemeTokens.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? ThemeTokens.textPrimary : ThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 170,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: ThemeTokens.border),
      ),
      child: Row(
        children: [
          segment(label: 'ES', selected: isSpanish, onTap: onSpanish),
          segment(label: 'EN', selected: !isSpanish, onTap: onEnglish),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Text(label, style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 18)),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        // Slight red-tinted background to indicate blocked/locked state.
        color: const Color(0x22FF1744),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x66FF1744)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: ThemeTokens.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF7A85), size: 20),
        ],
      ),
    );
  }
}

String _capitalizeWords(String value) {
  if (value.isEmpty) return value;
  return value
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String _toLocalDigits(String rawDigits, String iso2) {
  final digits = _digitsOnly(rawDigits);
  if (digits.isEmpty) return '';

  // For Colombia, we store country code + national number (e.g. 573195854272)
  // and show local part in the input (3195854272) with +57 selector.
  if (iso2 == 'CO' && digits.startsWith('57') && digits.length > 10) {
    return digits.substring(2);
  }

  return digits;
}


