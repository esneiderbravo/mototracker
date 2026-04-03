import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mototracker/features/ai/domain/models/ai_motorcycle_data.dart';
import 'package:mototracker/features/ai/domain/services/ai_service.dart';
import 'package:mototracker/features/ai/presentation/providers/ai_providers.dart';
import 'package:mototracker/features/garage/domain/entities/motorcycle.dart';
import 'package:mototracker/features/garage/presentation/providers/garage_providers.dart';
import 'package:mototracker/features/garage/presentation/screens/motorcycle_detail_screen.dart';
import 'package:mototracker/features/soat/domain/entities/soat_policy.dart';
import 'package:mototracker/features/soat/presentation/providers/soat_providers.dart';
import 'package:mototracker/i18n/strings.g.dart';

class _FakeAiService implements AiService {
  @override
  Future<AiMotorcycleData?> autofillFromPrompt(String input) async => null;

  @override
  Future<List<String>> generateMotorcycleInsights({
    required String languageCode,
    required String make,
    required String model,
    required int year,
    required String color,
    required int currentKm,
  }) async {
    return ['Check chain tension'];
  }
}

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  Motorcycle buildMotorcycle() {
    return Motorcycle(
      id: 'm-1',
      userId: 'u-1',
      make: 'Honda',
      model: 'CB500F',
      year: 2024,
      color: 'Black',
      licensePlate: 'ABC123',
      currentKm: 1200,
      imageUrl: null,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  SoatPolicy buildPolicy() {
    return SoatPolicy(
      id: 's-1',
      userId: 'u-1',
      motorcycleId: 'm-1',
      insurer: 'Mapfre',
      policyNumber: 'P-12345',
      startDate: DateTime(2026, 1, 1),
      expiryDate: DateTime(2026, 12, 31),
      notes: '',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  testWidgets('Motorcycle detail shows SOAT section and navigates to SOAT history', (tester) async {
    final router = GoRouter(
      initialLocation: '/garage/m-1',
      routes: [
        GoRoute(
          path: '/garage/:id',
          builder: (_, state) => MotorcycleDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/garage/:id/soat',
          builder: (_, __) => const Scaffold(body: Text('soat-history')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiServiceProvider.overrideWithValue(_FakeAiService()),
          motorcycleByIdProvider.overrideWith((ref, id) async => buildMotorcycle()),
          activeSoatByMotorcycleProvider.overrideWith((ref, id) async => buildPolicy()),
        ],
        child: TranslationProvider(child: MaterialApp.router(routerConfig: router)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SOAT coverage'), findsOneWidget);
    expect(find.text('Open SOAT history'), findsOneWidget);

    await tester.ensureVisible(find.text('Open SOAT history'));
    await tester.tap(find.text('Open SOAT history'));
    await tester.pumpAndSettle();

    expect(find.text('soat-history'), findsOneWidget);
  });

  testWidgets('Motorcycle detail shows missing SOAT state', (tester) async {
    final router = GoRouter(
      initialLocation: '/garage/m-1',
      routes: [
        GoRoute(
          path: '/garage/:id',
          builder: (_, state) => MotorcycleDetailScreen(id: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiServiceProvider.overrideWithValue(_FakeAiService()),
          motorcycleByIdProvider.overrideWith((ref, id) async => buildMotorcycle()),
          activeSoatByMotorcycleProvider.overrideWith((ref, id) async => null),
        ],
        child: TranslationProvider(child: MaterialApp.router(routerConfig: router)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No active SOAT for this motorcycle'), findsOneWidget);
    expect(find.text('Add SOAT'), findsOneWidget);
  });
}
