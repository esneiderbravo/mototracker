import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/async_value_builder.dart';
import '../../../../shared/widgets/moto_bottom_nav.dart';
import '../providers/garage_providers.dart';

class MotorcycleDetailScreen extends ConsumerWidget {
  const MotorcycleDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final motorcycle = ref.watch(motorcycleByIdProvider(id));

    return Scaffold(
      bottomNavigationBar: MotoBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.go('/profile');
          } else {
            context.go('/garage');
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AsyncValueBuilder(
            value: motorcycle,
            onData: (bike) {
              if (bike == null) {
                return Center(child: Text(t.garage.notFound));
              }

              final locale = Localizations.localeOf(context).toString();
              final date = DateFormat.yMd(locale).format(bike.createdAt);
              final km = NumberFormat('#,##0', locale).format(bike.currentKm);
              final bikeName = '${bike.make} ${bike.model}'.trim();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white.withOpacity(0.08), Colors.black.withOpacity(0.02)],
                        ),
                        border: Border.all(color: ThemeTokens.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton.filledTonal(
                                onPressed: () => context.pop(),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: ThemeTokens.textPrimary,
                                ),
                                icon: const Icon(Icons.arrow_back),
                              ),
                              const Spacer(),
                              _TagPill(label: bike.licensePlate.toUpperCase()),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: _MotorcycleHeroPhoto(imageUrl: bike.imageUrl),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: Text(
                              bikeName,
                              style: const TextStyle(
                                color: ThemeTokens.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            bikeName,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${t.garage.modelYear} ${bike.year}',
                            style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeTokens.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: ThemeTokens.primary.withOpacity(0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: ThemeTokens.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.garage.aiInsights.toUpperCase(),
                                  style: const TextStyle(
                                    color: ThemeTokens.primary,
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  t.garage.aiTipsSoon,
                                  style: const TextStyle(
                                    color: ThemeTokens.textSecondary,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.speed,
                            label: t.garage.mileage,
                            value: '$km km',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.palette_outlined,
                            label: t.garage.color,
                            value: bike.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      t.garage.specifications.toUpperCase(),
                      style: const TextStyle(
                        color: ThemeTokens.textSecondary,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          _Info(label: t.garage.make, value: bike.make),
                          _Info(label: t.garage.model, value: bike.model),
                          _Info(label: t.garage.year, value: '${bike.year}'),
                          _Info(label: t.garage.licensePlate, value: bike.licensePlate),
                          _Info(label: t.garage.createdAt, value: date, showDivider: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.garage.dangerZone.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFF4D5A),
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0x55FF1744)),
                          foregroundColor: const Color(0xFFFF5C6B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          await ref.read(motorcycleRepositoryProvider).remove(id);
                          if (context.mounted) context.go('/garage');
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: Text(t.garage.deleteMotorcycle),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value, this.showDivider = true});

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 18),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeTokens.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: ThemeTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeTokens.primary.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(color: ThemeTokens.primary.withOpacity(0.22), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ThemeTokens.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _MotorcycleHeroPhoto extends StatelessWidget {
  const _MotorcycleHeroPhoto({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return const Icon(Icons.two_wheeler, color: ThemeTokens.primaryDark, size: 74);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        url,
        width: 210,
        height: 132,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const SizedBox(
            width: 210,
            height: 132,
            child: Icon(Icons.two_wheeler, color: ThemeTokens.primaryDark, size: 74),
          );
        },
      ),
    );
  }
}

