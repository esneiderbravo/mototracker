import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/motorcycle.dart';
import '../../../../shared/widgets/async_value_builder.dart';
import '../../../../shared/widgets/moto_bottom_nav.dart';
import '../providers/garage_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final motorcycles = ref.watch(motorcyclesProvider);

    return Scaffold(
      bottomNavigationBar: MotoBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/profile');
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AsyncValueBuilder(
            value: motorcycles,
            onData: (items) {
              final countText = t.garage.garageCount(count: items.length);

              if (items.isEmpty) {
                return _GarageHeader(
                  title: t.garage.title,
                  subtitle: countText,
                  onAdd: () => context.push('/garage/add'),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.two_wheeler,
                              color: ThemeTokens.textSecondary,
                              size: 34,
                            ),
                            const SizedBox(height: 12),
                            Text(t.garage.empty, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () => context.push('/garage/add'),
                              child: Text(t.garage.addMotorcycle),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms);
              }

              return _GarageHeader(
                title: t.garage.title,
                subtitle: countText,
                onAdd: () => context.push('/garage/add'),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final bike = items[index];
                    return _MotorcycleCard(
                      bike: bike,
                      mileageLabel: t.garage.mileage,
                      onTap: () => context.push('/garage/${bike.id}'),
                    ).animate().fadeIn(duration: 280.ms, delay: (index * 50).ms);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GarageHeader extends StatelessWidget {
  const _GarageHeader({
    required this.title,
    required this.subtitle,
    required this.onAdd,
    required this.child,
  });

  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 18),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ThemeTokens.primary.withOpacity(0.28),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: null,
                mini: true,
                elevation: 0,
                onPressed: onAdd,
                backgroundColor: ThemeTokens.primary,
                foregroundColor: ThemeTokens.textPrimary,
                child: const Icon(Icons.add, size: 28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: child),
      ],
    );
  }
}

class _MotorcycleCard extends StatelessWidget {
  const _MotorcycleCard({required this.bike, required this.mileageLabel, required this.onTap});

  final Motorcycle bike;
  final String mileageLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final formattedKm = NumberFormat('#,##0', locale).format(bike.currentKm);
    final license = bike.licensePlate.trim().isEmpty ? '--' : bike.licensePlate.toUpperCase();
    final color = bike.color.trim().isEmpty ? 'N/A' : bike.color;
    final bikeName = '${bike.make} ${bike.model}'.trim();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.12), Colors.white.withOpacity(0.04)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    _PillLabel(label: color, textColor: ThemeTokens.textPrimary),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Icon(Icons.two_wheeler, color: ThemeTokens.primaryDark, size: 56),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    bikeName,
                    style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bikeName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${bike.year}',
                            style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    _PillLabel(label: license, textColor: ThemeTokens.primary),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Text(
                  mileageLabel,
                  style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedKm km',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.label, required this.textColor});

  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeTokens.border),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, letterSpacing: 1.1),
      ),
    );
  }
}
