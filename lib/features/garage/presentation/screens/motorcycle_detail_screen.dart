import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../../../soat/presentation/providers/soat_providers.dart';
import '../../../soat/domain/entities/soat_policy.dart';
import '../../../soat/presentation/widgets/soat_status_chip.dart';
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
              final languageCode = Localizations.localeOf(context).languageCode;
              final date = DateFormat.yMd(locale).format(bike.createdAt);
              final km = NumberFormat('#,##0', locale).format(bike.currentKm);
              final bikeName = '${bike.make} ${bike.model}'.trim();
              final insightsInput = (
                languageCode: languageCode,
                make: bike.make,
                model: bike.model,
                year: bike.year,
                color: bike.color,
                currentKm: bike.currentKm,
              );
              final insights = ref.watch(aiInsightsProvider(insightsInput));
              final activeSoat = ref.watch(activeSoatByMotorcycleProvider(bike.id));

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white.withOpacity(0.1), Colors.black.withOpacity(0.06)],
                        ),
                        border: Border.all(color: ThemeTokens.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.24),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
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
                          const SizedBox(height: 18),
                          Text(
                            t.garage.motorcycleDetail,
                            style: const TextStyle(
                              color: ThemeTokens.textSecondary,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(child: _MotorcycleHeroPhoto(imageUrl: bike.imageUrl)),
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
                          const SizedBox(height: 16),
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
                    _DetailCard(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                                  t.garage.aiInsights,
                                  style: const TextStyle(
                                    color: ThemeTokens.primary,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                insights.when(
                                  loading: () => Row(
                                    children: [
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          t.ai.loadingInsights,
                                          style: const TextStyle(
                                            color: ThemeTokens.textSecondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  error: (_, __) => Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.ai.insightsError,
                                        style: const TextStyle(
                                          color: ThemeTokens.textSecondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () =>
                                            ref.invalidate(aiInsightsProvider(insightsInput)),
                                        icon: const Icon(Icons.refresh, size: 16),
                                        label: Text(t.ai.retry),
                                      ),
                                    ],
                                  ),
                                  data: (items) {
                                    if (items.isEmpty) {
                                      return Text(
                                        t.ai.insightsEmpty,
                                        style: const TextStyle(
                                          color: ThemeTokens.textSecondary,
                                          fontSize: 16,
                                        ),
                                      );
                                    }

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: items
                                          .map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(top: 6),
                                                    child: Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: ThemeTokens.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        color: ThemeTokens.textSecondary,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SoatSection(
                      value: activeSoat,
                      motorcycleId: bike.id,
                      licensePlate: bike.licensePlate,
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
                    _SectionHeader(title: t.garage.specifications),
                    const SizedBox(height: 12),
                    _DetailCard(
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
                    _SectionHeader(title: t.garage.dangerZone, color: const Color(0xFFFF4D5A)),
                    const SizedBox(height: 12),
                    _DeleteMotorcycleButton(id: id, bikeName: bikeName),
                    const SizedBox(height: 6),
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

class _SoatSection extends ConsumerWidget {
  const _SoatSection({required this.value, required this.motorcycleId, required this.licensePlate});

  final AsyncValue<SoatPolicy?> value;
  final String motorcycleId;
  final String licensePlate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    return _DetailCard(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.garage.soatSectionTitle,
            style: const TextStyle(
              color: ThemeTokens.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.garage.soatSectionSubtitle,
            style: const TextStyle(color: ThemeTokens.textSecondary),
          ),
          const SizedBox(height: 14),
          AsyncValueBuilder(
            value: value,
            onData: (policy) {
              if (policy == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.soat.noActiveForMotorcycle,
                      style: const TextStyle(color: ThemeTokens.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/garage/$motorcycleId/soat/add'),
                            child: Text(t.soat.addPolicy),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                context.push('/soat/lookup?plate=${licensePlate.toUpperCase()}'),
                            child: Text(t.garage.lookupSoatByPlate),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              final days = policy.daysUntilExpiry(DateTime.now());
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          policy.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      SoatStatusChip(status: policy.expiryStatus(DateTime.now())),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${t.soat.daysUntilExpiry}: $days',
                    style: const TextStyle(color: ThemeTokens.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/garage/$motorcycleId/soat'),
                      child: Text(t.garage.openSoatHistory),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.color = ThemeTokens.textSecondary});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, letterSpacing: 1, fontWeight: FontWeight.w700, fontSize: 18),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor ?? ThemeTokens.border),
      ),
      child: child,
    );
  }
}

class _DeleteMotorcycleButton extends ConsumerStatefulWidget {
  const _DeleteMotorcycleButton({required this.id, required this.bikeName});

  final String id;
  final String bikeName;

  @override
  ConsumerState<_DeleteMotorcycleButton> createState() => _DeleteMotorcycleButtonState();
}

class _DeleteMotorcycleButtonState extends ConsumerState<_DeleteMotorcycleButton> {
  bool _isDeleting = false;

  Future<void> _confirmAndDelete() async {
    final t = Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeTokens.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5C6B), size: 26),
            const SizedBox(width: 10),
            Text(
              t.garage.deleteMotorcycle,
              style: const TextStyle(
                color: ThemeTokens.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          t.garage.deleteConfirmation(name: widget.bikeName),
          style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x55FF1744)),
                foregroundColor: const Color(0xFFFF5C6B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(t.garage.delete, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: ThemeTokens.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(t.shared.cancel),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(motorcycleRepositoryProvider).remove(widget.id);
      ref
        ..invalidate(motorcyclesProvider)
        ..invalidate(motorcycleByIdProvider(widget.id));
      if (mounted) context.go('/garage');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0x55FF1744)),
          foregroundColor: const Color(0xFFFF5C6B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _isDeleting ? null : _confirmAndDelete,
        icon: _isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF5C6B)),
              )
            : const Icon(Icons.delete_outline),
        label: Text(t.garage.deleteMotorcycle, style: const TextStyle(fontWeight: FontWeight.w700)),
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
